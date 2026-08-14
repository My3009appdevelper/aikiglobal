import { createClient } from "npm:@supabase/supabase-js@2.110.7";
import { createSupabaseContext } from "npm:@supabase/server";

import { authenticateAdmin } from "./auth.ts";
import {
  type FirebaseCredentials,
  getFirebaseAccessToken,
  loadFirebaseCredentials,
  sendFirebaseMessage,
} from "./firebase.ts";
import { createDispatchHandler, HttpError } from "./handler.ts";
import { createDispatchProcessor } from "./processor.ts";
import { ManualDispatchService } from "./service.ts";
import {
  SupabaseAdminAuthGateway,
  SupabaseNotificationRepository,
} from "./supabase_repository.ts";

interface EdgeRuntimeApi {
  waitUntil(promise: Promise<unknown>): void;
}

const supabaseUrl = requiredEnv("SUPABASE_URL");
const serviceRoleClient = createClient(
  supabaseUrl,
  requiredEnv("SUPABASE_SERVICE_ROLE_KEY"),
  {
    auth: {
      autoRefreshToken: false,
      detectSessionInUrl: false,
      persistSession: false,
    },
  },
);
const adminAuthGateway = new SupabaseAdminAuthGateway(serviceRoleClient);

const handler = createDispatchHandler({
  authenticateAdmin: async (request) => {
    const { data: context, error } = await createSupabaseContext(request, {
      auth: "user",
    });
    if (error !== null || context === null) {
      console.error("dispatch-notification-event auth context failed", {
        status: error?.status ?? null,
        code: error?.code ?? null,
        message: error?.message ?? null,
      });
      throw new HttpError(
        401,
        "La sesión de Supabase no pudo validarse. Vuelve a iniciar sesión.",
      );
    }

    const authUserId = context.userClaims?.id;
    if (typeof authUserId !== "string" || authUserId.trim().length === 0) {
      throw new HttpError(401, "El JWT no contiene un usuario válido.");
    }
    return await authenticateAdmin(authUserId, adminAuthGateway);
  },
  createService: () => {
    const serviceRoleClient = createClient(
      supabaseUrl,
      requiredEnv("SUPABASE_SERVICE_ROLE_KEY"),
      {
        auth: {
          autoRefreshToken: false,
          detectSessionInUrl: false,
          persistSession: false,
        },
      },
    );
    const repository = new SupabaseNotificationRepository(serviceRoleClient);
    let firebaseCredentials: FirebaseCredentials | null = null;
    const credentials = () => firebaseCredentials ??= loadFirebaseCredentials();
    const processor = createDispatchProcessor({
      repository,
      concurrency: 10,
      getAccessToken: () => getFirebaseAccessToken(credentials()),
      send: (request, accessToken) =>
        sendFirebaseMessage(credentials(), request, accessToken),
    });
    return new ManualDispatchService(repository, processor);
  },
  schedule: (background) => {
    const edgeRuntime = (globalThis as typeof globalThis & {
      EdgeRuntime?: EdgeRuntimeApi;
    }).EdgeRuntime;
    if (edgeRuntime === undefined) {
      console.error("EdgeRuntime.waitUntil no está disponible.");
      void background;
      return;
    }
    edgeRuntime.waitUntil(background);
  },
});

Deno.serve(handler);

function requiredEnv(name: string): string {
  const value = Deno.env.get(name)?.trim() ?? "";
  if (value.length === 0) {
    throw new Error(`Falta la variable ${name}.`);
  }
  return value;
}

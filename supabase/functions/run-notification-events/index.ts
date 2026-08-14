import { createClient } from "npm:@supabase/supabase-js@2.110.7";

import {
  type FirebaseCredentials,
  getFirebaseAccessToken,
  loadFirebaseCredentials,
  sendFirebaseMessage,
} from "../dispatch-notification-event/firebase.ts";
import { createDispatchProcessor } from "../dispatch-notification-event/processor.ts";
import { SupabaseNotificationRepository } from "../dispatch-notification-event/supabase_repository.ts";
import { AutomaticNotificationRunner } from "./service.ts";

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
const runnerSecret = Deno.env.get("NOTIFICATION_RUNNER_SECRET")?.trim() ||
  requiredEnv("SUPABASE_SERVICE_ROLE_KEY");

Deno.serve(async (request) => {
  if (request.method !== "POST") {
    return jsonResponse(405, { error: "Método no permitido." });
  }
  if (request.headers.get("x-notification-runner-secret") !== runnerSecret) {
    return jsonResponse(401, { error: "Invocador no autorizado." });
  }

  let body: Record<string, unknown> = {};
  try {
    const parsed = await request.json();
    if (isRecord(parsed)) {
      body = parsed;
    }
  } catch {
    body = {};
  }

  const dryRun = body.dry_run === true;
  const credentials = loadFirebaseCredentials();
  const repository = new SupabaseNotificationRepository(serviceRoleClient);
  const processor = createDispatchProcessor({
    repository,
    concurrency: 10,
    getAccessToken: () => getFirebaseAccessToken(credentials),
    send: (fcmRequest, accessToken) =>
      sendFirebaseMessage(credentials, fcmRequest, accessToken),
  });
  const runner = new AutomaticNotificationRunner(repository, processor, {
    dryRun,
    domainEventLimit: 100,
  });
  const run = runner.run();
  const edgeRuntime = (globalThis as typeof globalThis & {
    EdgeRuntime?: EdgeRuntimeApi;
  }).EdgeRuntime;

  if (edgeRuntime !== undefined) {
    edgeRuntime.waitUntil(run);
    return jsonResponse(202, {
      accepted: true,
      dry_run: dryRun,
    });
  }

  const summary = await run;
  return jsonResponse(200, { ...summary });
});

function requiredEnv(name: string): string {
  const value = Deno.env.get(name)?.trim() ?? "";
  if (value.length === 0) {
    throw new Error(`Falta la variable ${name}.`);
  }
  return value;
}

function isRecord(value: unknown): value is Record<string, unknown> {
  return typeof value === "object" && value !== null && !Array.isArray(value);
}

function jsonResponse(status: number, body: Record<string, unknown>): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: {
      "content-type": "application/json; charset=utf-8",
      "cache-control": "no-store",
    },
  });
}

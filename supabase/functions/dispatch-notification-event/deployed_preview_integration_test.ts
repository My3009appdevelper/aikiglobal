import { assert, assertEquals } from "jsr:@std/assert@1.0.14";

const integrationEnabled = Deno.args.includes("--integration");

Deno.test({
  name: "deployed preview returns the authenticated event counts",
  ignore: !integrationEnabled,
  fn: async () => {
    const functionUrl = requiredEnv(
      "DISPATCH_NOTIFICATION_EVENT_FUNCTION_URL",
    );
    const anonKey = requiredEnv("SUPABASE_ANON_KEY");
    const adminJwt = requiredEnv("SUPABASE_ADMIN_JWT");
    const uuidNotificationEvent = requiredEnv("UUID_NOTIFICATION_EVENT");

    const response = await fetch(functionUrl, {
      method: "POST",
      headers: {
        authorization: `Bearer ${adminJwt}`,
        apikey: anonKey,
        "content-type": "application/json",
      },
      body: JSON.stringify({
        mode: "preview",
        uuid_notification_event: uuidNotificationEvent,
      }),
    });
    const body = await response.json();

    assertEquals(
      response.status,
      200,
      `Preview desplegado respondió ${response.status}: ${
        JSON.stringify(body)
      }`,
    );
    assert(isRecord(body), "Preview desplegado devolvió un JSON inválido.");
    assertEquals(body.uuid_notification_event, uuidNotificationEvent);
    assertNonNegativeInteger(body.target_profile_count, "target_profile_count");
    assertNonNegativeInteger(body.target_device_count, "target_device_count");
  },
});

function requiredEnv(name: string): string {
  const value = Deno.env.get(name)?.trim() ?? "";
  if (value.length === 0) {
    throw new Error(`Falta la variable ${name} para la prueba desplegada.`);
  }
  return value;
}

function assertNonNegativeInteger(value: unknown, name: string): void {
  assert(
    typeof value === "number" && Number.isInteger(value) && value >= 0,
    `${name} no es un entero no negativo.`,
  );
}

function isRecord(value: unknown): value is Record<string, unknown> {
  return typeof value === "object" && value !== null && !Array.isArray(value);
}

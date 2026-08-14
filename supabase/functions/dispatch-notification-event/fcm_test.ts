import { assertEquals } from "jsr:@std/assert@1.0.14";

import {
  buildFcmRequest,
  classifyFcmResponse,
  parseRetryAfterMs,
  sendFcmWithRetry,
} from "./fcm.ts";

Deno.test("buildFcmRequest targets FID before the legacy token", () => {
  const request = buildFcmRequest({
    installationId: "fid-primary",
    fcmToken: "registration-token",
    title: "Título",
    body: "Mensaje",
    uuidNotificationDispatch: "dispatch-1",
    uuidNotificationInbox: "inbox-1",
    category: "content",
    actionType: "open_content_item",
    actionPayload: { uuid_content_item: "content-1" },
  });

  assertEquals(request, {
    message: {
      fid: "fid-primary",
      notification: { title: "Título", body: "Mensaje" },
      data: {
        schema_version: "1",
        uuid_notification_dispatch: "dispatch-1",
        uuid_notification_inbox: "inbox-1",
        category: "content",
        action_type: "open_content_item",
        action_payload: '{"uuid_content_item":"content-1"}',
      },
    },
  });
});

Deno.test("buildFcmRequest falls back to token only when FID is absent", () => {
  const request = buildFcmRequest({
    installationId: null,
    fcmToken: "registration-token",
    title: "Título",
    body: "Mensaje",
    uuidNotificationDispatch: "dispatch-1",
    uuidNotificationInbox: "inbox-1",
    category: "general",
    actionType: "none",
    actionPayload: {},
  });

  assertEquals(request.message.fid, undefined);
  assertEquals(request.message.token, "registration-token");
});

Deno.test("classifyFcmResponse recognizes success, retryable and auth errors", () => {
  assertEquals(classifyFcmResponse(200, { name: "message-1" }), {
    kind: "success",
    code: null,
    message: null,
  });
  assertEquals(
    classifyFcmResponse(429, { error: { status: "RESOURCE_EXHAUSTED" } }),
    {
      kind: "retryable",
      code: "RESOURCE_EXHAUSTED",
      message: null,
    },
  );
  assertEquals(classifyFcmResponse(503, { error: { status: "UNAVAILABLE" } }), {
    kind: "retryable",
    code: "UNAVAILABLE",
    message: null,
  });
  assertEquals(
    classifyFcmResponse(401, { error: { status: "UNAUTHENTICATED" } }),
    {
      kind: "permanent",
      code: "UNAUTHENTICATED",
      message: null,
    },
  );
});

Deno.test("classifyFcmResponse recognizes UNREGISTERED in FCM details", () => {
  assertEquals(
    classifyFcmResponse(404, {
      error: {
        status: "NOT_FOUND",
        message: "Requested entity was not found.",
        details: [{
          "@type": "type.googleapis.com/google.firebase.fcm.v1.FcmError",
          errorCode: "UNREGISTERED",
        }],
      },
    }),
    {
      kind: "invalid",
      code: "UNREGISTERED",
      message: "Requested entity was not found.",
    },
  );
});

Deno.test("parseRetryAfterMs supports seconds and HTTP dates", () => {
  const now = Date.parse("2026-07-16T12:00:00.000Z");
  assertEquals(parseRetryAfterMs("12", now), 12_000);
  assertEquals(
    parseRetryAfterMs("Thu, 16 Jul 2026 12:00:20 GMT", now),
    20_000,
  );
  assertEquals(parseRetryAfterMs("invalid", now), null);
});

Deno.test("sendFcmWithRetry honors Retry-After for 429 and 5xx", async () => {
  const statuses = [429, 503, 200];
  const delays: number[] = [];
  const result = await sendFcmWithRetry(
    () => {
      const status = statuses.shift()!;
      return Promise.resolve(
        new Response(
          JSON.stringify(
            status === 200 ? { name: "ok" } : {
              error: {
                status: status === 429 ? "RESOURCE_EXHAUSTED" : "UNAVAILABLE",
              },
            },
          ),
          {
            status,
            headers: status === 429
              ? { "retry-after": "2" }
              : status === 503
              ? { "retry-after": "12" }
              : undefined,
          },
        ),
      );
    },
    {
      maxAttempts: 3,
      random: () => 0.5,
      sleep: (milliseconds: number) => {
        delays.push(milliseconds);
        return Promise.resolve();
      },
    },
  );

  assertEquals(result.classification.kind, "success");
  assertEquals(result.attempts, 3);
  assertEquals(delays, [60_500, 20_500]);
});

Deno.test("sendFcmWithRetry uses safe defaults and jitter without Retry-After", async () => {
  const delays: number[] = [];
  const responses = [429, 503, 503, 200];
  await sendFcmWithRetry(
    () => Promise.resolve(new Response("{}", { status: responses.shift()! })),
    {
      maxAttempts: 4,
      random: () => 0.5,
      sleep: (milliseconds) => {
        delays.push(milliseconds);
        return Promise.resolve();
      },
    },
  );

  assertEquals(delays, [60_500, 20_500, 40_500]);
});

Deno.test("sendFcmWithRetry grows 429 backoff exponentially with jitter", async () => {
  const delays: number[] = [];
  const responses = [429, 429, 429, 200];
  await sendFcmWithRetry(
    () =>
      Promise.resolve(
        new Response("{}", {
          status: responses.shift()!,
          headers: { "retry-after": "2" },
        }),
      ),
    {
      maxAttempts: 4,
      random: () => 0.25,
      sleep: (milliseconds) => {
        delays.push(milliseconds);
        return Promise.resolve();
      },
    },
  );

  assertEquals(delays, [60_250, 120_250, 240_250]);
});

Deno.test("sendFcmWithRetry does not retry permanent or invalid responses", async () => {
  for (
    const response of [
      new Response(JSON.stringify({ error: { status: "UNAUTHENTICATED" } }), {
        status: 401,
      }),
      new Response(
        JSON.stringify({
          error: {
            details: [{
              "@type": "type.googleapis.com/google.firebase.fcm.v1.FcmError",
              errorCode: "UNREGISTERED",
            }],
          },
        }),
        { status: 404 },
      ),
    ]
  ) {
    let attempts = 0;
    const result = await sendFcmWithRetry(() => {
      attempts += 1;
      return Promise.resolve(response.clone());
    });

    assertEquals(attempts, 1);
    assertEquals(result.attempts, 1);
  }
});

Deno.test("sendFcmWithRetry classifies network exceptions as uncertain without retry", async () => {
  let attempts = 0;
  const result = await sendFcmWithRetry(() => {
    attempts += 1;
    return Promise.reject(new TypeError("network timeout"));
  });

  assertEquals(attempts, 1);
  assertEquals(result.classification, {
    kind: "uncertain",
    code: "NETWORK_ERROR",
    message: "network timeout",
  });
});

import { assertEquals } from "jsr:@std/assert@1.0.14";

import { createDispatchHandler, HttpError } from "./handler.ts";

const eventUuid = "7f72daff-8ab4-4ed8-a302-51f49b249804";
const requestUuid = "8f72daff-8ab4-4ed8-a302-51f49b249804";

Deno.test("handler rejects non-POST requests with the event field", async () => {
  const handler = createDispatchHandler({
    authenticateAdmin: () => Promise.resolve({ uuidProfile: "admin-1" }),
    createService: () => neverService(),
    schedule: () => {},
  });

  const response = await handler(
    new Request("http://local", { method: "GET" }),
  );

  assertEquals(response.status, 405);
  assertEquals(await response.json(), {
    uuid_notification_event: null,
    error: { message: "Método no permitido." },
  });
});

Deno.test("handler validates authorization before creating service-role access", async () => {
  let serviceCreated = false;
  const handler = createDispatchHandler({
    authenticateAdmin: () => {
      throw new HttpError(403, "No autorizado.");
    },
    createService: () => {
      serviceCreated = true;
      return neverService();
    },
    schedule: () => {},
  });

  const response = await handler(postRequest("preview"));

  assertEquals(response.status, 403);
  assertEquals(serviceCreated, false);
  assertEquals(await response.json(), {
    uuid_notification_event: eventUuid,
    error: { message: "No autorizado." },
  });
});

Deno.test("handler returns preview counts without scheduling background work", async () => {
  let scheduled = false;
  const handler = createDispatchHandler({
    authenticateAdmin: (request: Request) => {
      assertEquals(request.headers.get("authorization"), "Bearer valid-jwt");
      return Promise.resolve({ uuidProfile: "admin-1" });
    },
    createService: () => ({
      preview: () =>
        Promise.resolve({
          uuidNotificationEvent: eventUuid,
          title: "Título",
          body: "Mensaje",
          category: "general",
          audienceType: "all_users",
          actionType: "open_home",
          actionPayload: {},
          targetProfileCount: 3,
          targetDeviceCount: 4,
        }),
      send: () => Promise.reject(new Error("unexpected send")),
      analytics: () => Promise.reject(new Error("unexpected analytics")),
    }),
    schedule: () => {
      scheduled = true;
    },
  });

  const response = await handler(postRequest("preview"));

  assertEquals(response.status, 200);
  assertEquals(scheduled, false);
  assertEquals(await response.json(), {
    uuid_notification_event: eventUuid,
    title: "Título",
    body: "Mensaje",
    category: "general",
    audience_type: "all_users",
    action_type: "open_home",
    action_payload: {},
    target_profile_count: 3,
    target_device_count: 4,
  });
});

Deno.test("handler returns logical 202 and schedules only accepted sends", async () => {
  let scheduled = 0;
  const handler = createDispatchHandler({
    authenticateAdmin: () => Promise.resolve({ uuidProfile: "admin-1" }),
    createService: () => ({
      preview: () => Promise.reject(new Error("unexpected preview")),
      send: () =>
        Promise.resolve({
          uuidNotificationEvent: eventUuid,
          uuidNotificationDispatch: "dispatch-1",
          status: "processing",
          targetProfileCount: 3,
          targetDeviceCount: 4,
          reused: false,
          sourceDispatchUuid: null,
          background: Promise.resolve(),
        }),
      analytics: () => Promise.reject(new Error("unexpected analytics")),
    }),
    schedule: () => {
      scheduled += 1;
    },
  });

  const response = await handler(postRequest("send"));

  assertEquals(response.status, 202);
  assertEquals(scheduled, 1);
  assertEquals(await response.json(), {
    uuid_notification_event: eventUuid,
    uuid_notification_dispatch: "dispatch-1",
    status: "processing",
    target_profile_count: 3,
    target_device_count: 4,
    reused: false,
    source_dispatch_uuid: null,
  });
});

function postRequest(mode: "preview" | "send"): Request {
  return new Request("http://local", {
    method: "POST",
    headers: {
      authorization: "Bearer valid-jwt",
      "content-type": "application/json",
    },
    body: JSON.stringify({
      mode,
      uuid_notification_event: eventUuid,
      ...(mode === "send" ? { request_id: requestUuid } : {}),
    }),
  });
}

function neverService() {
  return {
    preview: () => Promise.reject(new Error("service should not run")),
    send: () => Promise.reject(new Error("service should not run")),
    analytics: () => Promise.reject(new Error("service should not run")),
  };
}

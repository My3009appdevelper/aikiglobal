import { assertEquals, assertThrows } from "jsr:@std/assert@1.0.14";

import {
  aggregateDispatchResults,
  decideIdempotency,
  DispatchRequestError,
  parseDispatchRequest,
  selectAudienceProfiles,
  selectEligibleDevices,
  validateManualEvent,
} from "./domain.ts";

const eventUuid = "7f72daff-8ab4-4ed8-a302-51f49b249804";
const requestUuid = "8f72daff-8ab4-4ed8-a302-51f49b249804";
const sourceDispatchUuid = "9f72daff-8ab4-4ed8-a302-51f49b249804";

Deno.test("parseDispatchRequest accepts preview and trims the event UUID", () => {
  assertEquals(
    parseDispatchRequest({
      mode: "preview",
      uuid_notification_event: " 7f72daff-8ab4-4ed8-a302-51f49b249804 ",
    }),
    {
      mode: "preview",
      uuidNotificationEvent: "7f72daff-8ab4-4ed8-a302-51f49b249804",
      uuidNotificationDispatch: null,
      requestId: null,
      sourceDispatchUuid: null,
      retryDispatchUuid: null,
    },
  );
});

Deno.test("parseDispatchRequest accepts an idempotent resend target", () => {
  assertEquals(
    parseDispatchRequest({
      mode: "send",
      uuid_notification_event: eventUuid,
      request_id: requestUuid,
      source_dispatch_uuid: sourceDispatchUuid,
    }),
    {
      mode: "send",
      uuidNotificationEvent: eventUuid,
      uuidNotificationDispatch: null,
      requestId: requestUuid,
      sourceDispatchUuid,
      retryDispatchUuid: null,
    },
  );
});

Deno.test("parseDispatchRequest rejects ambiguous or incomplete command targets", () => {
  for (
    const body of [
      { mode: "send", uuid_notification_event: eventUuid },
      {
        mode: "send",
        uuid_notification_event: eventUuid,
        request_id: "not-a-uuid",
      },
      {
        mode: "send",
        uuid_notification_event: eventUuid,
        request_id: requestUuid,
        source_dispatch_uuid: sourceDispatchUuid,
        retry_dispatch_uuid: sourceDispatchUuid,
      },
      {
        mode: "preview",
        uuid_notification_event: eventUuid,
        request_id: requestUuid,
      },
    ]
  ) {
    const error = assertThrows(
      () => parseDispatchRequest(body),
      DispatchRequestError,
    ) as DispatchRequestError;
    assertEquals(error.status, 400);
  }
});

Deno.test("parseDispatchRequest rejects malformed bodies", () => {
  for (
    const body of [
      null,
      {},
      { mode: "later", uuid_notification_event: crypto.randomUUID() },
      { mode: "send", uuid_notification_event: "not-a-uuid" },
    ]
  ) {
    const error = assertThrows(
      () => parseDispatchRequest(body),
      DispatchRequestError,
    ) as DispatchRequestError;
    assertEquals(error.status, 400);
  }
});

Deno.test("validateManualEvent enforces the complete manual once window", () => {
  const now = new Date("2026-07-16T12:00:00.000Z");
  const validEvent = {
    trigger_type: "manual",
    trigger_key: null,
    execution_mode: "once",
    status: "active",
    starts_at: "2026-07-16T11:00:00.000Z",
    ends_at: "2026-07-16T13:00:00.000Z",
    deleted_at: null,
  };

  assertEquals(validateManualEvent(validEvent, now), null);
  assertEquals(
    validateManualEvent(
      { ...validEvent, trigger_key: "content.published" },
      now,
    ),
    "El evento no es manual.",
  );
  assertEquals(
    validateManualEvent({ ...validEvent, ends_at: now.toISOString() }, now),
    "El evento no está vigente.",
  );
});

Deno.test("audience selectors include only active non-deleted profiles", () => {
  const profiles = [
    { uuid_profile: "user-1", role: "user", activo: true, deleted_at: null },
    { uuid_profile: "admin-1", role: "admin", activo: true, deleted_at: null },
    { uuid_profile: "user-2", role: "user", activo: false, deleted_at: null },
    {
      uuid_profile: "admin-2",
      role: "admin",
      activo: true,
      deleted_at: "2026-07-16T00:00:00.000Z",
    },
  ];

  assertEquals(
    selectAudienceProfiles(profiles, "all").map((profile) =>
      profile.uuid_profile
    ),
    ["user-1", "admin-1"],
  );
  assertEquals(
    selectAudienceProfiles(profiles, "all_users").map((profile) =>
      profile.uuid_profile
    ),
    ["user-1"],
  );
  assertEquals(
    selectAudienceProfiles(profiles, "all_admins").map((profile) =>
      profile.uuid_profile
    ),
    ["admin-1"],
  );
});

Deno.test("eligible devices prefer FID, allow token fallback and deduplicate identity", () => {
  const base = {
    uuid_profile: "user-1",
    is_active: true,
    permission_status: "authorized",
    deleted_at: null,
  };
  const devices = [
    {
      ...base,
      uuid_notification_device: "device-1",
      installation_id: "fid-1",
      fcm_token: "token-1",
    },
    {
      ...base,
      uuid_notification_device: "device-duplicate",
      installation_id: "fid-1",
      fcm_token: "token-duplicate",
    },
    {
      ...base,
      uuid_notification_device: "device-fid-only",
      installation_id: "fid-2",
      fcm_token: " ",
    },
    {
      ...base,
      uuid_notification_device: "device-provisional",
      installation_id: "fid-3",
      fcm_token: "token-3",
      permission_status: "provisional",
    },
    {
      ...base,
      uuid_notification_device: "device-token-fallback",
      installation_id: " ",
      fcm_token: "fallback-token",
    },
    {
      ...base,
      uuid_notification_device: "device-token-fallback-duplicate",
      installation_id: " ",
      fcm_token: "fallback-token",
    },
    {
      ...base,
      uuid_notification_device: "device-denied",
      installation_id: "fid-4",
      fcm_token: "token-4",
      permission_status: "denied",
    },
  ];

  assertEquals(
    selectEligibleDevices(devices, new Set(["user-1"]))
      .map((device) => device.uuid_notification_device),
    [
      "device-1",
      "device-fid-only",
      "device-provisional",
      "device-token-fallback",
    ],
  );
});

Deno.test("idempotency retries only failed dispatches without successes", () => {
  assertEquals(decideIdempotency(null), "create");
  assertEquals(
    decideIdempotency({
      status: "failed",
      success_device_count: 0,
      target_device_count: 1,
    }),
    "retry",
  );
  assertEquals(
    decideIdempotency({
      status: "failed",
      success_device_count: 1,
      target_device_count: 1,
    }),
    "reuse",
  );
  assertEquals(
    decideIdempotency({
      status: "failed",
      success_device_count: 0,
      target_device_count: 0,
    }),
    "retry",
  );
  for (const status of ["pending", "processing", "completed", "partial"]) {
    assertEquals(
      decideIdempotency({
        status,
        success_device_count: 0,
        target_device_count: 1,
      }),
      "reuse",
    );
  }
});

Deno.test("dispatch aggregation maps terminal statuses and event completion", () => {
  assertEquals(aggregateDispatchResults(0, []), {
    status: "completed",
    successDeviceCount: 0,
    failureDeviceCount: 0,
    invalidTokenCount: 0,
    completeEvent: true,
    errorSummary: null,
  });
  assertEquals(
    aggregateDispatchResults(2, [{ kind: "success" }, { kind: "success" }]),
    {
      status: "completed",
      successDeviceCount: 2,
      failureDeviceCount: 0,
      invalidTokenCount: 0,
      completeEvent: true,
      errorSummary: null,
    },
  );
  assertEquals(
    aggregateDispatchResults(2, [
      { kind: "success" },
      { kind: "definitive", error: "FCM 400: INVALID_ARGUMENT" },
    ]),
    {
      status: "partial",
      successDeviceCount: 1,
      failureDeviceCount: 1,
      invalidTokenCount: 0,
      completeEvent: true,
      errorSummary: "FCM 400: INVALID_ARGUMENT",
    },
  );
  assertEquals(
    aggregateDispatchResults(1, [
      { kind: "invalid", error: "FCM 404: UNREGISTERED" },
    ]),
    {
      status: "failed",
      successDeviceCount: 0,
      failureDeviceCount: 1,
      invalidTokenCount: 1,
      completeEvent: false,
      errorSummary: "FCM 404: UNREGISTERED",
    },
  );
});

Deno.test("dispatch aggregation never retries an uncertain result", () => {
  assertEquals(
    aggregateDispatchResults(1, [
      { kind: "uncertain", error: "FCM network: timeout" },
    ]),
    {
      status: "partial",
      successDeviceCount: 0,
      failureDeviceCount: 1,
      invalidTokenCount: 0,
      completeEvent: true,
      errorSummary: "FCM network: timeout",
    },
  );

  assertEquals(
    aggregateDispatchResults(2, [
      { kind: "definitive", error: "FCM 400: INVALID_ARGUMENT" },
    ]).status,
    "partial",
  );
});

Deno.test("dispatch aggregation bounds its error summary", () => {
  const result = aggregateDispatchResults(
    20,
    Array.from({ length: 20 }, (_, i) => ({
      kind: "definitive" as const,
      error: `error-${i}-${"x".repeat(100)}`,
    })),
  );

  assertEquals(result.status, "failed");
  assertEquals((result.errorSummary?.length ?? 0) <= 1000, true);
});

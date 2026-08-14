import { assertEquals } from "jsr:@std/assert@1.0.14";

import { createDispatchProcessor } from "./processor.ts";
import type { DispatchWork } from "./service.ts";

Deno.test("processor completes zero-device dispatch without Firebase credentials", async () => {
  const calls: string[] = [];
  const processor = createDispatchProcessor({
    repository: processorRepository(calls),
    getAccessToken: () =>
      Promise.reject(new Error("must not load credentials")),
    send: () => Promise.reject(new Error("must not send")),
  });

  await processor(work([]));

  assertEquals(calls, [
    "finalize:completed:0:0:0",
    "event:event-1",
  ]);
});

Deno.test("processor deactivates exact FID and token targets only for UNREGISTERED", async () => {
  const calls: string[] = [];
  const processor = createDispatchProcessor({
    repository: processorRepository(calls),
    getAccessToken: () => Promise.resolve("access-token"),
    concurrency: 1,
    send: (request: { message: { fid?: string; token?: string } }) =>
      Promise.resolve(
        request.message.fid === "fid-1"
          ? {
            classification: { kind: "success", code: null, message: null },
            attempts: 1,
            httpStatus: 200,
          }
          : {
            classification: {
              kind: "invalid",
              code: "UNREGISTERED",
              message: "not found",
            },
            attempts: 1,
            httpStatus: 404,
          },
      ),
  });

  await processor(
    work([
      device("device-1", "fid-1", "token-1"),
      device("device-2", "fid-2", "token-2"),
      device("device-3", null, "token-3"),
      device("device-4", "", "token-4"),
    ]),
  );

  assertEquals(calls, [
    "deactivate:device-2:token:token-2:installation:fid-2",
    "deactivate:device-3:token:token-3:installation:null",
    "deactivate:device-4:token:token-4:installation:",
    "finalize:partial:1:3:3",
    "event:event-1",
  ]);
});

Deno.test("processor falls back from an invalid FID to its registration token", async () => {
  const calls: string[] = [];
  const targets: string[] = [];
  const processor = createDispatchProcessor({
    repository: processorRepository(calls),
    getAccessToken: () => Promise.resolve("access-token"),
    concurrency: 1,
    send: (request: { message: { fid?: string; token?: string } }) => {
      const target = request.message.fid === undefined
        ? `token:${request.message.token}`
        : `fid:${request.message.fid}`;
      targets.push(target);
      return Promise.resolve(
        request.message.fid === undefined
          ? {
            classification: { kind: "success", code: null, message: null },
            attempts: 1,
            httpStatus: 200,
          }
          : {
            classification: {
              kind: "invalid",
              code: "UNREGISTERED",
              message: "not found",
            },
            attempts: 1,
            httpStatus: 404,
          },
      );
    },
  });

  await processor(work([device("device-1", "fid-1", "token-1")]));

  assertEquals(targets, ["fid:fid-1", "token:token-1"]);
  assertEquals(calls, [
    "finalize:completed:1:0:0",
    "event:event-1",
  ]);
});

Deno.test("processor leaves event active when every device fails", async () => {
  const calls: string[] = [];
  const processor = createDispatchProcessor({
    repository: processorRepository(calls),
    getAccessToken: () => Promise.resolve("access-token"),
    send: () =>
      Promise.resolve({
        classification: {
          kind: "permanent",
          code: "UNAUTHENTICATED",
          message: null,
        },
        attempts: 1,
        httpStatus: 401,
      }),
  });

  await processor(work([device("device-1", "fid-1", "token-1")]));

  assertEquals(calls, [
    "finalize:failed:0:1:0",
  ]);
});

Deno.test("processor finalizes uncertain transport results as partial without retry", async () => {
  const calls: string[] = [];
  const processor = createDispatchProcessor({
    repository: processorRepository(calls),
    getAccessToken: () => Promise.resolve("access-token"),
    send: () =>
      Promise.resolve({
        classification: {
          kind: "uncertain",
          code: "NETWORK_ERROR",
          message: "timeout",
        },
        attempts: 1,
        httpStatus: null,
      }),
  });

  await processor(work([device("device-1", "fid-1", "token-1")]));

  assertEquals(calls, [
    "finalize:partial:0:1:0",
    "event:event-1",
  ]);
});

Deno.test("processor treats an exception after starting FCM as uncertain", async () => {
  const calls: string[] = [];
  const processor = createDispatchProcessor({
    repository: processorRepository(calls),
    getAccessToken: () => Promise.resolve("access-token"),
    send: () => Promise.reject(new Error("socket closed after write")),
  });

  await processor(work([device("device-1", "fid-1", "token-1")]));

  assertEquals(calls, [
    "finalize:partial:0:1:0",
    "event:event-1",
  ]);
});

Deno.test("processor falls back to uncertain partial when finalization fails after FCM", async () => {
  const calls: string[] = [];
  const processor = createDispatchProcessor({
    repository: processorRepository(calls, { failFinalize: true }),
    getAccessToken: () => Promise.resolve("access-token"),
    logError: () => {},
    send: () =>
      Promise.resolve({
        classification: { kind: "success", code: null, message: null },
        attempts: 1,
        httpStatus: 200,
      }),
  });

  await processor(work([device("device-1", "fid-1", "token-1")]));

  assertEquals(calls, [
    "finalize:completed:1:0:0",
    "partial:1:0:0",
    "event:event-1",
  ]);
});

Deno.test("processor leaves processing when both finalization attempts fail", async () => {
  const calls: string[] = [];
  const processor = createDispatchProcessor({
    repository: processorRepository(calls, {
      failFinalize: true,
      failPartialFinalize: true,
    }),
    getAccessToken: () => Promise.resolve("access-token"),
    logError: () => {},
    send: () =>
      Promise.resolve({
        classification: { kind: "success", code: null, message: null },
        attempts: 1,
        httpStatus: 200,
      }),
  });

  await processor(work([device("device-1", "fid-1", "token-1")]));

  assertEquals(calls, [
    "finalize:completed:1:0:0",
    "partial:1:0:0",
  ]);
});

Deno.test("processor bounds concurrent FCM sends", async () => {
  let active = 0;
  let maximumActive = 0;
  const processor = createDispatchProcessor({
    repository: processorRepository([]),
    getAccessToken: () => Promise.resolve("access-token"),
    concurrency: 2,
    send: async () => {
      active += 1;
      maximumActive = Math.max(maximumActive, active);
      await new Promise((resolve) => setTimeout(resolve, 5));
      active -= 1;
      return {
        classification: { kind: "success", code: null, message: null },
        attempts: 1,
        httpStatus: 200,
      };
    },
  });

  await processor(
    work(
      Array.from(
        { length: 5 },
        (_, index) =>
          device(`device-${index}`, `fid-${index}`, `token-${index}`),
      ),
    ),
  );

  assertEquals(maximumActive, 2);
});

function processorRepository(
  calls: string[],
  options: { failFinalize?: boolean; failPartialFinalize?: boolean } = {},
) {
  return {
    claimProcessing: (uuid: string) => {
      calls.push(`claim:${uuid}`);
      return Promise.resolve(true);
    },
    deactivateDevice: (
      uuid: string,
      target:
        | { kind: "fid"; value: string }
        | {
          kind: "token";
          value: string;
          installationId: string | null;
        },
    ) => {
      calls.push(
        target.kind === "fid"
          ? `deactivate:${uuid}:fid:${target.value}`
          : `deactivate:${uuid}:token:${target.value}:installation:${target.installationId}`,
      );
      return Promise.resolve();
    },
    finalizeDispatch: (_uuid: string, aggregation: {
      status: string;
      successDeviceCount: number;
      failureDeviceCount: number;
      invalidTokenCount: number;
    }) => {
      calls.push(
        `finalize:${aggregation.status}:${aggregation.successDeviceCount}:${aggregation.failureDeviceCount}:${aggregation.invalidTokenCount}`,
      );
      if (options.failFinalize) {
        return Promise.reject(new Error("conditional update returned no row"));
      }
      return Promise.resolve();
    },
    finalizeProcessingAsPartial: (_uuid: string, aggregation: {
      successDeviceCount: number;
      failureDeviceCount: number;
      invalidTokenCount: number;
    }) => {
      calls.push(
        `partial:${aggregation.successDeviceCount}:${aggregation.failureDeviceCount}:${aggregation.invalidTokenCount}`,
      );
      if (options.failPartialFinalize) {
        return Promise.reject(new Error("database remains unavailable"));
      }
      return Promise.resolve(true);
    },
    completeEvent: (uuid: string) => {
      calls.push(`event:${uuid}`);
      return Promise.resolve();
    },
    appendDispatchError: () => Promise.resolve(),
    markBackgroundFailed: () => {
      calls.push("background-failed");
      return Promise.resolve();
    },
  };
}

function device(
  uuid: string,
  installationId: string | null,
  fcmToken: string,
) {
  return {
    uuid_notification_device: uuid,
    uuid_profile: "profile-1",
    installation_id: installationId,
    fcm_token: fcmToken,
    is_active: true,
    permission_status: "authorized",
    deleted_at: null,
  };
}

function work(devices: ReturnType<typeof device>[]): DispatchWork {
  return {
    dispatch: {
      uuid_notification_dispatch: "dispatch-1",
      uuid_notification_event: "event-1",
      idempotency_key: "manual:event-1",
      title_snapshot: "Título",
      body_snapshot: "Mensaje",
      category_snapshot: "general",
      audience_type_snapshot: "all",
      action_type_snapshot: "none",
      action_payload_snapshot: {},
      status: "processing",
      target_profile_count: 1,
      target_device_count: devices.length,
      success_device_count: 0,
      started_at: null,
    },
    devices,
    inboxByProfile: new Map([["profile-1", "inbox-1"]]),
  };
}

import type { SupabaseClient } from "npm:@supabase/supabase-js@2.110.7";
import { assertEquals, assertRejects } from "jsr:@std/assert@1.0.14";

import { SupabaseNotificationRepository } from "./supabase_repository.ts";

Deno.test("finalizeDispatch requires a processing row returned by PostgREST", async () => {
  const calls: string[] = [];
  const repository = new SupabaseNotificationRepository(
    fakeClient(calls, {
      data: { uuid_notification_dispatch: "dispatch-1" },
      error: null,
    }),
  );

  await repository.finalizeDispatch("dispatch-1", aggregation());

  assertEquals(calls, [
    "from:notification_dispatches",
    "update",
    "eq:uuid_notification_dispatch:dispatch-1",
    "eq:status:processing",
    "select:uuid_notification_dispatch",
    "maybeSingle",
  ]);
});

Deno.test("finalizeDispatch rejects when the processing precondition updates no row", async () => {
  const repository = new SupabaseNotificationRepository(
    fakeClient([], { data: null, error: null }),
  );

  await assertRejects(
    () => repository.finalizeDispatch("dispatch-1", aggregation()),
    Error,
    "ya no estaba processing",
  );
});

Deno.test("finalizeProcessingAsPartial uses processing and stale CAS", async () => {
  const calls: string[] = [];
  const repository = new SupabaseNotificationRepository(
    fakeClient(calls, {
      data: { uuid_notification_dispatch: "dispatch-1" },
      error: null,
    }),
  );

  const finalized = await repository.finalizeProcessingAsPartial(
    "dispatch-1",
    { ...aggregation(), status: "partial" },
    "2026-07-16T11:50:00.000Z",
  );

  assertEquals(finalized, true);
  assertEquals(calls, [
    "from:notification_dispatches",
    "update",
    "eq:uuid_notification_dispatch:dispatch-1",
    "eq:status:processing",
    "lt:started_at:2026-07-16T11:50:00.000Z",
    "select:uuid_notification_dispatch",
    "maybeSingle",
  ]);
});

Deno.test("claimProcessing only claims a pending dispatch", async () => {
  const calls: string[] = [];
  const repository = new SupabaseNotificationRepository(
    fakeClient(calls, { data: null, error: null }),
  );

  const claimed = await repository.claimProcessing("dispatch-1", 3, 5);

  assertEquals(claimed, null);
  assertEquals(calls.slice(0, 4), [
    "from:notification_dispatches",
    "update",
    "eq:uuid_notification_dispatch:dispatch-1",
    "eq:status:pending",
  ]);
  assertEquals(calls.at(-1), "maybeSingle");
});

Deno.test("markSetupFailed only fails a processing dispatch with no success", async () => {
  const calls: string[] = [];
  const repository = new SupabaseNotificationRepository(
    fakeClient(calls, {
      data: { uuid_notification_dispatch: "dispatch-1" },
      error: null,
    }),
  );

  await repository.markSetupFailed("dispatch-1", "setup failed");

  assertEquals(calls, [
    "from:notification_dispatches",
    "update",
    "eq:uuid_notification_dispatch:dispatch-1",
    "eq:status:processing",
    "eq:success_device_count:0",
    "select:uuid_notification_dispatch",
    "maybeSingle",
  ]);
});

Deno.test("markSetupFailed rejects when its processing CAS updates no row", async () => {
  const repository = new SupabaseNotificationRepository(
    fakeClient([], { data: null, error: null }),
  );

  await assertRejects(
    () => repository.markSetupFailed("dispatch-1", "setup failed"),
    Error,
    "ya no estaba processing",
  );
});

Deno.test("completeEvent is idempotent when the event is already completed", async () => {
  const calls: string[] = [];
  const repository = new SupabaseNotificationRepository(
    fakeClient(calls, { data: null, error: null }),
  );

  await repository.completeEvent("event-1");

  assertEquals(calls, [
    "from:notification_events",
    "update",
    "eq:uuid_notification_event:event-1",
    "eq:status:active",
    "is:deleted_at:null",
    "select:uuid_notification_event",
    "maybeSingle",
  ]);
});

Deno.test("deactivateDevice compares the exact sent FID or fallback token", async () => {
  for (
    const [target, expectedCas] of [
      [
        { kind: "fid", value: "fid-1" } as const,
        ["eq:installation_id:fid-1"],
      ],
      [
        { kind: "token", value: "token-1", installationId: null } as const,
        ["eq:fcm_token:token-1", "is:installation_id:null"],
      ],
      [
        { kind: "token", value: "token-2", installationId: "" } as const,
        ["eq:fcm_token:token-2", "eq:installation_id:"],
      ],
    ] as const
  ) {
    const calls: string[] = [];
    const repository = new SupabaseNotificationRepository(
      fakeClient(calls, { data: null, error: null }),
    );

    await repository.deactivateDevice("device-1", target);

    assertEquals(calls, [
      "from:notification_devices",
      "update",
      "eq:uuid_notification_device:device-1",
      "eq:is_active:true",
      "is:deleted_at:null",
      ...expectedCas,
    ]);
  }
});

Deno.test("fallback token does not deactivate a device that acquired a new FID", async () => {
  const device = {
    uuid_notification_device: "device-1",
    installation_id: "new-fid",
    fcm_token: "token-1",
    is_active: true,
    deleted_at: null,
  };
  const repository = new SupabaseNotificationRepository(
    statefulDeviceClient(device),
  );

  await repository.deactivateDevice("device-1", {
    kind: "token",
    value: "token-1",
    installationId: null,
  });

  assertEquals(device.is_active, true);
});

function aggregation() {
  return {
    status: "completed" as const,
    successDeviceCount: 1,
    failureDeviceCount: 0,
    invalidTokenCount: 0,
    completeEvent: true,
    errorSummary: null,
  };
}

function fakeClient(
  calls: string[],
  result: { data: Record<string, unknown> | null; error: null },
): SupabaseClient {
  const query = {
    update: (_value: unknown) => {
      calls.push("update");
      return query;
    },
    eq: (column: string, value: unknown) => {
      calls.push(`eq:${column}:${String(value)}`);
      return query;
    },
    is: (column: string, value: unknown) => {
      calls.push(`is:${column}:${String(value)}`);
      return query;
    },
    lt: (column: string, value: unknown) => {
      calls.push(`lt:${column}:${String(value)}`);
      return query;
    },
    select: (columns: string) => {
      calls.push(`select:${columns}`);
      return query;
    },
    maybeSingle: () => {
      calls.push("maybeSingle");
      return Promise.resolve(result);
    },
    then: <TResult1 = typeof result, TResult2 = never>(
      onfulfilled?:
        | ((value: typeof result) => TResult1 | PromiseLike<TResult1>)
        | null,
      onrejected?:
        | ((reason: unknown) => TResult2 | PromiseLike<TResult2>)
        | null,
    ) => Promise.resolve(result).then(onfulfilled, onrejected),
  };
  return {
    from: (table: string) => {
      calls.push(`from:${table}`);
      return query;
    },
  } as unknown as SupabaseClient;
}

function statefulDeviceClient(
  row: {
    uuid_notification_device: string;
    installation_id: string | null;
    fcm_token: string;
    is_active: boolean;
    deleted_at: string | null;
  },
): SupabaseClient {
  let update: Partial<typeof row> = {};
  const matches: Array<() => boolean> = [];
  const query = {
    update: (value: Partial<typeof row>) => {
      update = value;
      return query;
    },
    eq: (column: keyof typeof row, value: unknown) => {
      matches.push(() => row[column] === value);
      return query;
    },
    is: (column: keyof typeof row, value: unknown) => {
      matches.push(() => row[column] === value);
      return query;
    },
    then: <TResult1 = { data: null; error: null }, TResult2 = never>(
      onfulfilled?:
        | ((
          value: { data: null; error: null },
        ) => TResult1 | PromiseLike<TResult1>)
        | null,
      onrejected?:
        | ((reason: unknown) => TResult2 | PromiseLike<TResult2>)
        | null,
    ) => {
      if (matches.every((matchesRow) => matchesRow())) {
        Object.assign(row, update);
      }
      return Promise.resolve({ data: null, error: null }).then(
        onfulfilled,
        onrejected,
      );
    },
  };
  return { from: () => query } as unknown as SupabaseClient;
}

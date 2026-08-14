import { assertEquals, assertRejects } from "jsr:@std/assert@1.0.14";

import { HttpError } from "./handler.ts";
import {
  type DispatchWork,
  ManualDispatchService,
  type NotificationDispatchRow,
  type NotificationEventRow,
  type NotificationRepository,
} from "./service.ts";

const eventUuid = "7f72daff-8ab4-4ed8-a302-51f49b249804";

Deno.test("preview is read-only and returns target counts", async () => {
  const writes: string[] = [];
  const repository = fakeRepository({
    writeObserved: (operation) => writes.push(operation),
  });
  const service = new ManualDispatchService(
    repository,
    () => Promise.resolve(),
  );

  const result = await service.preview(eventUuid);

  assertEquals(result.targetProfileCount, 1);
  assertEquals(result.targetDeviceCount, 1);
  assertEquals(writes, []);
});

Deno.test("manual dispatch renders title and body for each profile", async () => {
  const works: DispatchWork[] = [];
  const repository = fakeRepository({
    profiles: [{
      uuid_profile: "user-1",
      nombre: "Ana",
      email: "ana@aiki.com",
      role: "user",
      activo: true,
      deleted_at: null,
    }],
    event: eventRow({
      title_template: "Hola {profile_name}",
      body_template: "Tu correo es {profile_email}.",
    }),
  });
  const service = new ManualDispatchService(repository, (work) => {
    works.push(work);
    return Promise.resolve();
  });

  const preview = await service.preview(eventUuid);
  assertEquals(preview.title, "Hola Ana");
  assertEquals(preview.body, "Tu correo es ana@aiki.com.");

  const result = await service.send(eventUuid, "admin-1");
  await result.background;
  assertEquals(
    works[0]?.renderedByProfile?.get("user-1")?.titleSnapshot,
    "Hola Ana",
  );
  assertEquals(
    works[0]?.renderedByProfile?.get("user-1")?.bodySnapshot,
    "Tu correo es ana@aiki.com.",
  );
});

Deno.test("send rejects zero profiles before creating a dispatch", async () => {
  const writes: string[] = [];
  const repository = fakeRepository({
    profiles: [],
    devices: [],
    writeObserved: (operation) => writes.push(operation),
  });
  const service = new ManualDispatchService(
    repository,
    () => Promise.resolve(),
  );

  const error = await assertRejects(
    () => service.send(eventUuid, "admin-1"),
    HttpError,
  ) as HttpError;

  assertEquals(error.status, 409);
  assertEquals(writes, []);
});

Deno.test("send claims a new dispatch before inbox and scheduling", async () => {
  const writes: string[] = [];
  const works: DispatchWork[] = [];
  const repository = fakeRepository({
    writeObserved: (operation) => writes.push(operation),
  });
  const service = new ManualDispatchService(repository, (work) => {
    works.push(work);
    return Promise.resolve();
  });

  const result = await service.send(eventUuid, "admin-1");
  await result.background;

  assertEquals(result.reused, false);
  assertEquals(result.status, "processing");
  assertEquals(writes, [
    "createDispatch",
    "claimProcessing:1:1",
    "ensureInbox",
  ]);
  assertEquals(works.length, 1);
  assertEquals(works[0]?.dispatch.status, "processing");
});

Deno.test("send claims an existing pending dispatch before scheduling", async () => {
  const writes: string[] = [];
  const repository = fakeRepository({
    existingDispatch: {
      ...dispatchRow(),
      status: "pending",
      success_device_count: 0,
    },
    writeObserved: (operation) => writes.push(operation),
  });
  let processed = 0;
  const service = new ManualDispatchService(repository, () => {
    processed += 1;
    return Promise.resolve();
  });

  const result = await service.send(eventUuid, "admin-1");

  assertEquals(result.reused, true);
  assertEquals(result.status, "processing");
  assertEquals(result.background instanceof Promise, true);
  await result.background;
  assertEquals(processed, 1);
  assertEquals(writes, ["claimProcessing:1:1", "ensureInbox"]);
});

Deno.test("send race loser reuses processing without inbox or background", async () => {
  const writes: string[] = [];
  const repository = fakeRepository({
    existingDispatch: {
      ...dispatchRow(),
      status: "pending",
      success_device_count: 0,
    },
    processingDispatch: null,
    writeObserved: (operation) => writes.push(operation),
  });
  let processed = 0;
  const service = new ManualDispatchService(repository, () => {
    processed += 1;
    return Promise.resolve();
  });

  const result = await service.send(eventUuid, "admin-1");

  assertEquals(result.reused, true);
  assertEquals(result.status, "processing");
  assertEquals(result.background, null);
  assertEquals(processed, 0);
  assertEquals(writes, ["claimProcessing:1:1"]);
});

Deno.test("send reuses a recent processing dispatch without scheduling", async () => {
  const writes: string[] = [];
  const repository = fakeRepository({
    existingDispatch: {
      ...dispatchRow(),
      status: "processing",
      started_at: "2026-07-16T11:55:00.000Z",
    },
    writeObserved: (operation) => writes.push(operation),
  });
  let processed = 0;
  const service = new ManualDispatchService(
    repository,
    () => {
      processed += 1;
      return Promise.resolve();
    },
    () => new Date("2026-07-16T12:00:00.000Z"),
  );

  const result = await service.send(eventUuid, "admin-1");

  assertEquals(result.status, "processing");
  assertEquals(result.reused, true);
  assertEquals(result.background, null);
  assertEquals(processed, 0);
  assertEquals(writes, []);
});

Deno.test("send terminalizes stale processing as uncertain partial", async () => {
  const writes: string[] = [];
  const repository = fakeRepository({
    existingDispatch: {
      ...dispatchRow(),
      status: "processing",
      started_at: "2026-07-16T11:49:59.000Z",
      target_device_count: 3,
      success_device_count: 0,
    },
    writeObserved: (operation) => writes.push(operation),
  });
  let processed = 0;
  const service = new ManualDispatchService(
    repository,
    () => {
      processed += 1;
      return Promise.resolve();
    },
    () => new Date("2026-07-16T12:00:00.000Z"),
  );

  const result = await service.send(eventUuid, "admin-1");

  assertEquals(result.status, "partial");
  assertEquals(result.reused, true);
  assertEquals(result.background, null);
  assertEquals(processed, 0);
  assertEquals(writes, [
    "finalizeProcessingAsPartial:2026-07-16T11:50:00.000Z:0:3",
    "reconcileEventCompletedIfActive",
  ]);
});

Deno.test("send claims a failed zero-success dispatch and reuses its inbox", async () => {
  const writes: string[] = [];
  const existing = {
    ...dispatchRow(),
    status: "failed",
    success_device_count: 0,
  };
  const repository = fakeRepository({
    existingDispatch: existing,
    claimedDispatch: { ...existing, status: "pending" },
    writeObserved: (operation) => writes.push(operation),
  });
  let processed = 0;
  const service = new ManualDispatchService(repository, () => {
    processed += 1;
    return Promise.resolve();
  });

  const result = await service.send(eventUuid, "admin-1");

  assertEquals(result.reused, true);
  assertEquals(result.status, "processing");
  assertEquals(result.background instanceof Promise, true);
  await result.background;
  assertEquals(processed, 1);
  assertEquals(writes, [
    "claimFailedDispatch",
    "claimProcessing:1:1",
    "ensureInbox",
  ]);
});

Deno.test("setup failure marks claimed processing as retryable failed", async () => {
  const writes: string[] = [];
  const repository = fakeRepository({
    ensureInboxError: new Error("inbox unavailable"),
    writeObserved: (operation) => writes.push(operation),
  });
  const service = new ManualDispatchService(
    repository,
    () => Promise.reject(new Error("must not schedule")),
  );

  await assertRejects(
    () => service.send(eventUuid, "admin-1"),
    Error,
    "inbox unavailable",
  );

  assertEquals(writes, [
    "createDispatch",
    "claimProcessing:1:1",
    "ensureInbox",
    "markSetupFailed",
  ]);
});

Deno.test("setup failure leaves processing when failure update also fails", async () => {
  const writes: string[] = [];
  const repository = fakeRepository({
    ensureInboxError: new Error("inbox unavailable"),
    markSetupFailedError: new Error("database unavailable"),
    writeObserved: (operation) => writes.push(operation),
  });
  const service = new ManualDispatchService(
    repository,
    () => Promise.reject(new Error("must not schedule")),
  );

  await assertRejects(
    () => service.send(eventUuid, "admin-1"),
    Error,
    "database unavailable",
  );

  assertEquals(writes, [
    "createDispatch",
    "claimProcessing:1:1",
    "ensureInbox",
    "markSetupFailed",
  ]);
});

Deno.test("send reconciles completed and partial dispatch events without background", async () => {
  for (const status of ["completed", "partial"]) {
    const writes: string[] = [];
    let processed = 0;
    const repository = fakeRepository({
      existingDispatch: { ...dispatchRow(), status },
      writeObserved: (operation) => writes.push(operation),
    });
    const service = new ManualDispatchService(repository, () => {
      processed += 1;
      return Promise.resolve();
    });

    const result = await service.send(eventUuid, "admin-1");

    assertEquals(result.reused, true);
    assertEquals(result.background, null);
    assertEquals(processed, 0);
    assertEquals(writes, ["reconcileEventCompletedIfActive"]);
  }
});

Deno.test("send creates a new dispatch from a completed snapshot resend", async () => {
  const writes: string[] = [];
  const source = {
    ...dispatchRow(),
    status: "completed",
    title_snapshot: "TÃ­tulo original",
    body_snapshot: "Mensaje original",
    category_snapshot: "content",
    audience_type_snapshot: "all_users",
    action_type_snapshot: "open_content_item",
    action_payload_snapshot: { uuid_content_item: "snapshot-content" },
  };
  const repository = fakeRepository({
    existingDispatch: null,
    loadedDispatch: source,
    claimedDispatch: {
      ...source,
      status: "pending",
      source_entity_type: "notification_dispatch",
      source_entity_uuid: source.uuid_notification_dispatch,
    },
    event: {
      ...eventRow(),
      status: "completed",
      title_template: "TÃ­tulo editado",
      body_template: "Mensaje editado",
      category: "admin",
      audience_type: "all_admins",
      action_type: "none",
      action_payload_template: {},
    },
    writeObserved: (operation) => writes.push(operation),
    contentItemIsPublished: (uuid) =>
      Promise.resolve(uuid === "snapshot-content"),
  });
  const service = new ManualDispatchService(
    repository,
    () => Promise.resolve(),
  );

  const result = await service.send(
    eventUuid,
    "admin-1",
    "8f72daff-8ab4-4ed8-a302-51f49b249804",
    source.uuid_notification_dispatch,
  );

  assertEquals(result.reused, false);
  assertEquals(result.sourceDispatchUuid, source.uuid_notification_dispatch);
  assertEquals(writes, [
    "createDispatch",
    "claimProcessing:1:1",
    "ensureInbox",
  ]);
});

Deno.test("send retries a selected failed dispatch in place", async () => {
  const writes: string[] = [];
  const failed = {
    ...dispatchRow(),
    status: "failed",
    success_device_count: 0,
  };
  const repository = fakeRepository({
    existingDispatch: null,
    loadedDispatch: failed,
    claimedDispatch: { ...failed, status: "pending" },
    writeObserved: (operation) => writes.push(operation),
  });
  const service = new ManualDispatchService(
    repository,
    () => Promise.resolve(),
  );

  const result = await service.send(
    eventUuid,
    "admin-1",
    "8f72daff-8ab4-4ed8-a302-51f49b249804",
    null,
    failed.uuid_notification_dispatch,
  );

  assertEquals(
    result.uuidNotificationDispatch,
    failed.uuid_notification_dispatch,
  );
  assertEquals(result.reused, true);
  assertEquals(writes, [
    "claimFailedDispatch",
    "claimProcessing:1:1",
    "ensureInbox",
  ]);
});

Deno.test("failed retry validates the immutable action snapshot", async () => {
  const checkedContent: string[] = [];
  const existing = {
    ...dispatchRow(),
    status: "failed",
    success_device_count: 0,
    action_type_snapshot: "open_content_item",
    action_payload_snapshot: { uuid_content_item: "snapshot-content" },
  };
  const repository = fakeRepository({
    event: {
      ...eventRow(),
      action_type: "open_content_item",
      action_payload_template: { uuid_content_item: "mutable-content" },
    },
    existingDispatch: existing,
    claimedDispatch: { ...existing, status: "pending" },
    contentItemIsPublished: (uuid) => {
      checkedContent.push(uuid);
      return Promise.resolve(uuid === "snapshot-content");
    },
  });
  const service = new ManualDispatchService(
    repository,
    () => Promise.resolve(),
  );

  const result = await service.send(eventUuid, "admin-1");

  assertEquals(result.status, "processing");
  assertEquals(checkedContent, ["snapshot-content"]);
});

Deno.test("failed retry resolves audience, inbox and work from snapshots", async () => {
  const loadedAudiences: string[] = [];
  const inboxProfiles: string[][] = [];
  const checkedContent: string[] = [];
  const capturedWorks: DispatchWork[] = [];
  const existing = {
    ...dispatchRow(),
    status: "failed",
    success_device_count: 0,
    title_snapshot: "Título snapshot",
    body_snapshot: "Mensaje snapshot",
    category_snapshot: "content",
    audience_type_snapshot: "all_users",
    action_type_snapshot: "open_content_item",
    action_payload_snapshot: { uuid_content_item: "snapshot-content" },
  };
  const repository = fakeRepository({
    event: {
      ...eventRow(),
      title_template: "Título mutable",
      body_template: "Mensaje mutable",
      category: "admin",
      audience_type: "all_admins",
      action_type: "none",
      action_payload_template: {},
    },
    profiles: [
      {
        uuid_profile: "user-1",
        role: "user",
        activo: true,
        deleted_at: null,
      },
      {
        uuid_profile: "admin-1",
        role: "admin",
        activo: true,
        deleted_at: null,
      },
    ],
    existingDispatch: existing,
    claimedDispatch: { ...existing, status: "pending" },
    inboxMap: new Map(),
    profileAudienceObserved: (audience) => loadedAudiences.push(audience),
    ensureInboxProfilesObserved: (profiles) =>
      inboxProfiles.push([...profiles]),
    contentItemIsPublished: (uuid) => {
      checkedContent.push(uuid);
      return Promise.resolve(uuid === "snapshot-content");
    },
  });
  const service = new ManualDispatchService(repository, (work) => {
    capturedWorks.push(work);
    return Promise.resolve();
  });

  const result = await service.send(eventUuid, "admin-1");
  await result.background;

  assertEquals(loadedAudiences, ["all_users"]);
  assertEquals(inboxProfiles, [["user-1"]]);
  assertEquals(checkedContent, ["snapshot-content"]);
  assertEquals(capturedWorks[0]?.dispatch.title_snapshot, "Título snapshot");
  assertEquals(capturedWorks[0]?.dispatch.body_snapshot, "Mensaje snapshot");
  assertEquals(capturedWorks[0]?.dispatch.category_snapshot, "content");
  assertEquals(
    capturedWorks[0]?.dispatch.action_type_snapshot,
    "open_content_item",
  );
  assertEquals(capturedWorks[0]?.dispatch.action_payload_snapshot, {
    uuid_content_item: "snapshot-content",
  });
});

function dispatchRow(): NotificationDispatchRow {
  return {
    uuid_notification_dispatch: "dispatch-1",
    uuid_notification_event: eventUuid,
    idempotency_key: `manual:${eventUuid}`,
    title_snapshot: "Título",
    body_snapshot: "Mensaje",
    category_snapshot: "general",
    audience_type_snapshot: "all",
    action_type_snapshot: "none",
    action_payload_snapshot: {},
    status: "completed",
    target_profile_count: 1,
    target_device_count: 1,
    success_device_count: 1,
    started_at: null,
  };
}

function eventRow(
  overrides: Partial<NotificationEventRow> = {},
): NotificationEventRow {
  return {
    uuid_notification_event: eventUuid,
    title_template: "Título",
    body_template: "Mensaje",
    category: "general",
    audience_type: "all",
    action_type: "none",
    action_payload_template: {},
    trigger_type: "manual",
    trigger_key: null,
    execution_mode: "once",
    status: "active",
    starts_at: "2026-07-16T00:00:00.000Z",
    ends_at: null,
    deleted_at: null,
    ...overrides,
  };
}

function fakeRepository(options: {
  profiles?: Array<
    {
      uuid_profile: string;
      nombre?: string | null;
      email?: string | null;
      role: string;
      activo: boolean;
      deleted_at: string | null;
    }
  >;
  devices?: Array<{
    uuid_notification_device: string;
    uuid_profile: string;
    installation_id: string;
    fcm_token: string;
    is_active: boolean;
    permission_status: string;
    deleted_at: string | null;
  }>;
  existingDispatch?: ReturnType<typeof dispatchRow> | null;
  loadedDispatch?: ReturnType<typeof dispatchRow> | null;
  claimedDispatch?: ReturnType<typeof dispatchRow> | null;
  processingDispatch?: ReturnType<typeof dispatchRow> | null;
  event?: NotificationEventRow;
  contentItemIsPublished?: (uuidContentItem: string) => Promise<boolean>;
  finalizeProcessingAsPartial?: boolean;
  inboxMap?: Map<string, string>;
  profileAudienceObserved?: (audienceType: string) => void;
  ensureInboxProfilesObserved?: (profileUuids: readonly string[]) => void;
  ensureInboxError?: Error;
  markSetupFailedError?: Error;
  writeObserved?: (operation: string) => void;
} = {}): NotificationRepository {
  const profiles = options.profiles ?? [{
    uuid_profile: "user-1",
    role: "user",
    activo: true,
    deleted_at: null,
  }];
  const devices = options.devices ?? [{
    uuid_notification_device: "device-1",
    uuid_profile: "user-1",
    installation_id: "fid-1",
    fcm_token: "token-1",
    is_active: true,
    permission_status: "authorized",
    deleted_at: null,
  }];
  const write = (operation: string) => options.writeObserved?.(operation);

  return {
    loadEvent: () => Promise.resolve(options.event ?? eventRow()),
    contentItemIsPublished: options.contentItemIsPublished ??
      (() => Promise.resolve(true)),
    loadProfiles: (audienceType) => {
      options.profileAudienceObserved?.(audienceType);
      return Promise.resolve(profiles);
    },
    loadDevices: () => Promise.resolve(devices),
    findDispatch: () => Promise.resolve(options.existingDispatch ?? null),
    loadDispatch: () =>
      Promise.resolve(
        options.loadedDispatch ?? options.existingDispatch ?? null,
      ),
    createDispatch: () => {
      write("createDispatch");
      return Promise.resolve({
        ...dispatchRow(),
        status: "pending",
        success_device_count: 0,
      });
    },
    claimFailedDispatch: () => {
      write("claimFailedDispatch");
      return Promise.resolve(options.claimedDispatch ?? null);
    },
    claimProcessing: (_uuid, targetProfileCount, targetDeviceCount) => {
      write(`claimProcessing:${targetProfileCount}:${targetDeviceCount}`);
      if (options.processingDispatch === null) {
        return Promise.resolve(null);
      }
      const source = options.processingDispatch ?? options.claimedDispatch ??
        options.existingDispatch ?? dispatchRow();
      return Promise.resolve({
        ...source,
        status: "processing",
        target_profile_count: targetProfileCount,
        target_device_count: targetDeviceCount,
        success_device_count: 0,
        started_at: "2026-07-17T00:00:00.000Z",
      });
    },
    ensureInbox: (_dispatch, profileUuids) => {
      write("ensureInbox");
      if (options.ensureInboxError !== undefined) {
        return Promise.reject(options.ensureInboxError);
      }
      options.ensureInboxProfilesObserved?.(profileUuids);
      return Promise.resolve(
        new Map(
          profileUuids.map((uuid, index) => [uuid, `inbox-${index + 1}`]),
        ),
      );
    },
    loadInboxMap: () =>
      Promise.resolve(
        options.inboxMap ?? new Map([["user-1", "inbox-1"]]),
      ),
    markSetupFailed: () => {
      write("markSetupFailed");
      if (options.markSetupFailedError !== undefined) {
        return Promise.reject(options.markSetupFailedError);
      }
      return Promise.resolve();
    },
    finalizeProcessingAsPartial: (_uuid, aggregation, startedBefore) => {
      write(
        `finalizeProcessingAsPartial:${startedBefore}:${aggregation.successDeviceCount}:${aggregation.failureDeviceCount}`,
      );
      return Promise.resolve(options.finalizeProcessingAsPartial ?? true);
    },
    reconcileEventCompletedIfActive: () => {
      write("reconcileEventCompletedIfActive");
      return Promise.resolve();
    },
    loadDispatchAnalytics: () =>
      Promise.reject(new Error("analytics not configured in this test")),
  };
}

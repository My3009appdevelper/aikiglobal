import type { SupabaseClient } from "npm:@supabase/supabase-js@2.110.7";

import type { AdminAuthGateway, AdminProfileRow } from "./auth.ts";
import type {
  AudienceType,
  DispatchAggregation,
  NotificationDeviceRow,
  ProfileRow,
} from "./domain.ts";
import type {
  DispatchProcessorRepository,
  FcmDeliveryTarget,
} from "./processor.ts";
import {
  type CreateDispatchInput,
  type NotificationDispatchRow,
  type NotificationEventRow,
  type NotificationRecipientSnapshot,
  type NotificationRepository,
  UniqueDispatchConflictError,
} from "./service.ts";

const eventColumns = [
  "uuid_notification_event",
  "title_template",
  "body_template",
  "category",
  "audience_type",
  "action_type",
  "action_payload_template",
  "trigger_type",
  "trigger_key",
  "execution_mode",
  "trigger_config",
  "status",
  "starts_at",
  "ends_at",
  "deleted_at",
].join(",");

const dispatchColumns = [
  "uuid_notification_dispatch",
  "uuid_notification_event",
  "idempotency_key",
  "title_snapshot",
  "body_snapshot",
  "category_snapshot",
  "audience_type_snapshot",
  "action_type_snapshot",
  "action_payload_snapshot",
  "status",
  "target_profile_count",
  "target_device_count",
  "success_device_count",
  "started_at",
  "source_entity_type",
  "source_entity_uuid",
].join(",");

const dispatchAnalyticsColumns = [
  "uuid_notification_dispatch",
  "target_profile_count",
  "target_device_count",
  "success_device_count",
  "failure_device_count",
  "invalid_token_count",
].join(",");

export class SupabaseAdminAuthGateway implements AdminAuthGateway {
  constructor(private readonly client: SupabaseClient) {}

  async getProfile(authUserId: string): Promise<AdminProfileRow | null> {
    const { data, error } = await this.client
      .from("profiles")
      .select("uuid_profile,role,activo,deleted_at")
      .eq("auth_user_id", authUserId)
      .maybeSingle();
    assertDatabaseResult(error, "consultar el perfil administrador");
    return data === null ? null : {
      uuid_profile: requiredString(data.uuid_profile),
      role: requiredString(data.role),
      activo: data.activo === true,
      deleted_at: nullableString(data.deleted_at),
    };
  }
}

export class SupabaseNotificationRepository
  implements NotificationRepository, DispatchProcessorRepository {
  constructor(protected readonly client: SupabaseClient) {}

  async loadEvent(
    uuidNotificationEvent: string,
  ): Promise<NotificationEventRow | null> {
    const { data, error } = await this.client
      .from("notification_events")
      .select(eventColumns)
      .eq("uuid_notification_event", uuidNotificationEvent)
      .maybeSingle();
    assertDatabaseResult(error, "consultar el evento de notificación");
    return data === null ? null : toEvent(recordValue(data));
  }

  async loadAutomationEvents(): Promise<NotificationEventRow[]> {
    const { data, error } = await this.client
      .from("notification_events")
      .select(eventColumns)
      .in("trigger_type", ["domain_event", "schedule", "progress_event"])
      .eq("status", "active")
      .is("deleted_at", null);
    assertDatabaseResult(error, "consultar reglas automáticas");
    return rowsValue(data).map((row) => toEvent(row));
  }

  async loadDomainEvents(limit = 100): Promise<Array<{
    uuid_notification_domain_event: string;
    event_key: string;
    source_entity_type: string;
    source_entity_uuid: string;
    payload: Record<string, unknown>;
    occurred_at: string;
  }>> {
    const { data, error } = await this.client
      .from("notification_domain_events")
      .select(
        "uuid_notification_domain_event,event_key,source_entity_type,source_entity_uuid,payload,occurred_at",
      )
      .is("processed_at", null)
      .order("occurred_at", { ascending: true })
      .limit(limit);
    assertDatabaseResult(error, "consultar eventos de dominio pendientes");
    return rowsValue(data).map((row) => ({
      uuid_notification_domain_event: requiredString(
        row.uuid_notification_domain_event,
      ),
      event_key: requiredString(row.event_key),
      source_entity_type: requiredString(row.source_entity_type),
      source_entity_uuid: requiredString(row.source_entity_uuid),
      payload: objectValue(row.payload),
      occurred_at: requiredString(row.occurred_at),
    }));
  }

  async markDomainEventProcessed(
    uuidNotificationDomainEvent: string,
  ): Promise<void> {
    const { error } = await this.client
      .from("notification_domain_events")
      .update({
        processed_at: new Date().toISOString(),
        processing_error: null,
      })
      .eq(
        "uuid_notification_domain_event",
        uuidNotificationDomainEvent,
      )
      .is("processed_at", null);
    assertDatabaseResult(error, "marcar evento de dominio procesado");
  }

  async markDomainEventFailed(
    uuidNotificationDomainEvent: string,
    errorSummary: string,
  ): Promise<void> {
    const { error } = await this.client
      .from("notification_domain_events")
      .update({
        attempt_count: 1,
        processing_error: errorSummary.slice(0, 1000),
      })
      .eq(
        "uuid_notification_domain_event",
        uuidNotificationDomainEvent,
      )
      .is("processed_at", null);
    assertDatabaseResult(error, "registrar error del evento de dominio");
  }

  async loadStreakStats(
    profileUuids: readonly string[],
  ): Promise<Array<{
    uuid_profile: string;
    current_streak: number;
    longest_streak: number;
    last_activity_date: string | null;
  }>> {
    const rows: Array<{
      uuid_profile: string;
      current_streak: number;
      longest_streak: number;
      last_activity_date: string | null;
    }> = [];
    for (const uuids of chunks([...new Set(profileUuids)], 100)) {
      if (uuids.length === 0) {
        continue;
      }
      const { data, error } = await this.client
        .from("wellness_profile_stats")
        .select("uuid_profile,current_streak,longest_streak,last_activity_date")
        .in("uuid_profile", uuids);
      assertDatabaseResult(error, "consultar rachas de bienestar");
      rows.push(
        ...rowsValue(data).map((row) => ({
          uuid_profile: requiredString(row.uuid_profile),
          current_streak: nonNegativeInteger(row.current_streak),
          longest_streak: nonNegativeInteger(row.longest_streak),
          last_activity_date: nullableString(row.last_activity_date),
        })),
      );
    }
    return rows;
  }

  async contentItemIsPublished(uuidContentItem: string): Promise<boolean> {
    const { data, error } = await this.client
      .from("content_items")
      .select("uuid_content_item")
      .eq("uuid_content_item", uuidContentItem)
      .eq("status", "published")
      .is("deleted_at", null)
      .maybeSingle();
    assertDatabaseResult(error, "validar el contenido publicado");
    return data !== null;
  }

  async loadProfiles(audienceType: AudienceType): Promise<ProfileRow[]> {
    let query = this.client
      .from("profiles")
      .select("uuid_profile,nombre,email,role,activo,deleted_at")
      .eq("activo", true)
      .is("deleted_at", null);
    query = audienceType === "all_users"
      ? query.eq("role", "user")
      : audienceType === "all_admins"
      ? query.eq("role", "admin")
      : query.in("role", ["user", "admin"]);

    const { data, error } = await query;
    assertDatabaseResult(error, "consultar la audiencia");
    return rowsValue(data).map((row) => ({
      uuid_profile: requiredString(row.uuid_profile),
      nombre: nullableString(row.nombre),
      email: nullableString(row.email),
      role: requiredString(row.role),
      activo: row.activo === true,
      deleted_at: nullableString(row.deleted_at),
    }));
  }

  async loadDevices(
    profileUuids: readonly string[],
  ): Promise<NotificationDeviceRow[]> {
    const rows: NotificationDeviceRow[] = [];
    for (const uuids of chunks([...new Set(profileUuids)], 100)) {
      const { data, error } = await this.client
        .from("notification_devices")
        .select(
          "uuid_notification_device,uuid_profile,installation_id,fcm_token,is_active,permission_status,timezone,registration_refreshed_at,deleted_at",
        )
        .in("uuid_profile", uuids)
        .eq("is_active", true)
        .in("permission_status", ["authorized", "provisional"])
        .is("deleted_at", null);
      assertDatabaseResult(error, "consultar dispositivos de notificación");
      rows.push(
        ...rowsValue(data).map((row) => ({
          uuid_notification_device: requiredString(
            row.uuid_notification_device,
          ),
          uuid_profile: requiredString(row.uuid_profile),
          installation_id: nullableString(row.installation_id),
          fcm_token: nullableString(row.fcm_token),
          is_active: row.is_active === true,
          permission_status: requiredString(row.permission_status),
          timezone: nullableString(row.timezone),
          registration_refreshed_at: nullableString(
            row.registration_refreshed_at,
          ),
          deleted_at: nullableString(row.deleted_at),
        })),
      );
    }
    return rows;
  }

  async findDispatch(
    idempotencyKey: string,
  ): Promise<NotificationDispatchRow | null> {
    const { data, error } = await this.client
      .from("notification_dispatches")
      .select(dispatchColumns)
      .eq("idempotency_key", idempotencyKey)
      .maybeSingle();
    assertDatabaseResult(error, "consultar el dispatch");
    return data === null ? null : toDispatch(recordValue(data));
  }

  async loadDispatch(
    uuidNotificationDispatch: string,
  ): Promise<NotificationDispatchRow | null> {
    const { data, error } = await this.client
      .from("notification_dispatches")
      .select(dispatchColumns)
      .eq("uuid_notification_dispatch", uuidNotificationDispatch)
      .maybeSingle();
    assertDatabaseResult(error, "consultar el dispatch de notificación");
    return data === null ? null : toDispatch(recordValue(data));
  }

  async createDispatch(
    input: CreateDispatchInput,
  ): Promise<NotificationDispatchRow> {
    const { data, error } = await this.client
      .from("notification_dispatches")
      .insert({
        uuid_notification_event: input.snapshot.uuidNotificationEvent,
        uuid_triggered_by_profile: input.uuidTriggeredByProfile,
        source_entity_type: input.sourceEntityType,
        source_entity_uuid: input.sourceEntityUuid,
        idempotency_key: input.idempotencyKey,
        trigger_source: input.triggerSource ?? "manual",
        title_snapshot: input.snapshot.titleSnapshot,
        body_snapshot: input.snapshot.bodySnapshot,
        category_snapshot: input.snapshot.categorySnapshot,
        audience_type_snapshot: input.snapshot.audienceTypeSnapshot,
        action_type_snapshot: input.snapshot.actionTypeSnapshot,
        action_payload_snapshot: input.snapshot.actionPayloadSnapshot,
        status: "pending",
        target_profile_count: input.targetProfileCount,
        target_device_count: input.targetDeviceCount,
        success_device_count: 0,
        failure_device_count: 0,
        invalid_token_count: 0,
      })
      .select(dispatchColumns)
      .single();
    if (error?.code === "23505") {
      throw new UniqueDispatchConflictError();
    }
    assertDatabaseResult(error, "crear el dispatch");
    return toDispatch(recordValue(data));
  }

  async loadDispatchAnalytics(
    uuidNotificationDispatch: string,
  ) {
    const { data: dispatchData, error: dispatchError } = await this.client
      .from("notification_dispatches")
      .select(dispatchAnalyticsColumns)
      .eq("uuid_notification_dispatch", uuidNotificationDispatch)
      .maybeSingle();
    assertDatabaseResult(dispatchError, "consultar el resumen del dispatch");
    if (dispatchData === null) {
      throw new Error("No existe el dispatch de notificación.");
    }
    const dispatchRowData = recordValue(dispatchData);

    const { data: inboxData, error: inboxError } = await this.client
      .from("notifications_inbox")
      .select("uuid_profile,opened_at,read_at")
      .eq("uuid_notification_dispatch", uuidNotificationDispatch)
      .is("deleted_at", null);
    assertDatabaseResult(inboxError, "consultar el seguimiento del inbox");
    const inboxRows = rowsValue(inboxData);
    const profileUuids = [
      ...new Set(inboxRows.map((row) => requiredString(row.uuid_profile))),
    ];

    let profileRows: Record<string, unknown>[] = [];
    if (profileUuids.length > 0) {
      const { data, error } = await this.client
        .from("profiles")
        .select("uuid_profile,nombre,email")
        .in("uuid_profile", profileUuids);
      assertDatabaseResult(error, "consultar perfiles del seguimiento");
      profileRows = rowsValue(data);
    }
    const profileByUuid = new Map(
      profileRows.map((row) => [requiredString(row.uuid_profile), row]),
    );
    const recipients = inboxRows.map((row) => {
      const uuidProfile = requiredString(row.uuid_profile);
      const profile = profileByUuid.get(uuidProfile);
      return {
        uuidProfile,
        displayName: nullableText(profile?.nombre),
        email: requiredString(profile?.email),
        openedAt: nullableString(row.opened_at),
        readAt: nullableString(row.read_at),
      };
    }).sort((left, right) => {
      const leftLabel = (left.displayName ?? left.email).toLocaleLowerCase();
      const rightLabel = (right.displayName ?? right.email).toLocaleLowerCase();
      return leftLabel.localeCompare(rightLabel);
    });

    return {
      uuidNotificationDispatch,
      targetProfileCount: nonNegativeInteger(
        dispatchRowData.target_profile_count,
      ),
      targetDeviceCount: nonNegativeInteger(
        dispatchRowData.target_device_count,
      ),
      successDeviceCount: nonNegativeInteger(
        dispatchRowData.success_device_count,
      ),
      failureDeviceCount: nonNegativeInteger(
        dispatchRowData.failure_device_count,
      ),
      invalidTokenCount: nonNegativeInteger(
        dispatchRowData.invalid_token_count,
      ),
      inboxCount: recipients.length,
      openedCount: recipients.filter((recipient) => recipient.openedAt !== null)
        .length,
      readCount: recipients.filter((recipient) => recipient.readAt !== null)
        .length,
      recipients,
    };
  }

  async claimFailedDispatch(
    uuidNotificationDispatch: string,
    targetProfileCount: number,
    targetDeviceCount: number,
  ): Promise<NotificationDispatchRow | null> {
    const { data, error } = await this.client
      .from("notification_dispatches")
      .update({
        status: "pending",
        target_profile_count: targetProfileCount,
        target_device_count: targetDeviceCount,
        success_device_count: 0,
        failure_device_count: 0,
        invalid_token_count: 0,
        started_at: null,
        completed_at: null,
        error_summary: null,
      })
      .eq("uuid_notification_dispatch", uuidNotificationDispatch)
      .eq("status", "failed")
      .eq("success_device_count", 0)
      .select(dispatchColumns)
      .maybeSingle();
    assertDatabaseResult(error, "reclamar el reintento del dispatch");
    return data === null ? null : toDispatch(recordValue(data));
  }

  async ensureInbox(
    dispatch: NotificationDispatchRow,
    profileUuids: readonly string[],
    renderedByProfile?: ReadonlyMap<string, NotificationRecipientSnapshot>,
  ): Promise<Map<string, string>> {
    const uniqueProfiles = [...new Set(profileUuids)];
    if (uniqueProfiles.length === 0) {
      return new Map();
    }
    const { error } = await this.client
      .from("notifications_inbox")
      .upsert(
        uniqueProfiles.map((uuidProfile) => {
          const rendered = renderedByProfile?.get(uuidProfile);
          return {
            uuid_notification_dispatch: dispatch.uuid_notification_dispatch,
            uuid_profile: uuidProfile,
            title: rendered?.titleSnapshot ?? dispatch.title_snapshot,
            body: rendered?.bodySnapshot ?? dispatch.body_snapshot,
            category: rendered?.categorySnapshot ?? dispatch.category_snapshot,
            action_type: rendered?.actionTypeSnapshot ??
              dispatch.action_type_snapshot,
            action_payload: rendered?.actionPayloadSnapshot ??
              dispatch.action_payload_snapshot,
          };
        }),
        {
          onConflict: "uuid_notification_dispatch,uuid_profile",
          ignoreDuplicates: true,
        },
      );
    assertDatabaseResult(error, "crear los inbox del dispatch");

    const inboxByProfile = await this.loadInboxMap(
      dispatch.uuid_notification_dispatch,
    );
    if (uniqueProfiles.some((uuid) => !inboxByProfile.has(uuid))) {
      throw new Error("No fue posible mapear todos los inbox del dispatch.");
    }
    return inboxByProfile;
  }

  async loadInboxMap(
    uuidNotificationDispatch: string,
  ): Promise<Map<string, string>> {
    const { data, error } = await this.client
      .from("notifications_inbox")
      .select("uuid_notification_inbox,uuid_profile")
      .eq("uuid_notification_dispatch", uuidNotificationDispatch);
    assertDatabaseResult(error, "consultar los inbox del dispatch");
    return new Map(
      rowsValue(data).map((row): [string, string] => [
        requiredString(row.uuid_profile),
        requiredString(row.uuid_notification_inbox),
      ]),
    );
  }

  async loadInboxSnapshots(
    uuidNotificationDispatch: string,
  ): Promise<Map<string, NotificationRecipientSnapshot>> {
    const { data, error } = await this.client
      .from("notifications_inbox")
      .select(
        "uuid_profile,title,body,category,action_type,action_payload",
      )
      .eq("uuid_notification_dispatch", uuidNotificationDispatch)
      .is("deleted_at", null);
    assertDatabaseResult(error, "consultar los textos personalizados del inbox");
    return new Map(
      rowsValue(data).map((row) => [
        requiredString(row.uuid_profile),
        {
          uuidNotificationEvent: "",
          titleSnapshot: requiredString(row.title),
          bodySnapshot: requiredString(row.body),
          categorySnapshot: requiredString(row.category),
          audienceTypeSnapshot: "",
          actionTypeSnapshot: requiredString(row.action_type),
          actionPayloadSnapshot: objectValue(row.action_payload),
        },
      ]),
    );
  }

  async markSetupFailed(
    uuidNotificationDispatch: string,
    summary: string,
  ): Promise<void> {
    const { data, error } = await this.client
      .from("notification_dispatches")
      .update({
        status: "failed",
        completed_at: new Date().toISOString(),
        error_summary: summary.slice(0, 1000),
      })
      .eq("uuid_notification_dispatch", uuidNotificationDispatch)
      .eq("status", "processing")
      .eq("success_device_count", 0)
      .select("uuid_notification_dispatch")
      .maybeSingle();
    assertDatabaseResult(error, "marcar la preparación fallida");
    if (data === null) {
      throw new Error(
        "El dispatch ya no estaba processing al fallar el setup.",
      );
    }
  }

  async claimProcessing(
    uuidNotificationDispatch: string,
    targetProfileCount: number,
    targetDeviceCount: number,
  ): Promise<NotificationDispatchRow | null> {
    const { data, error } = await this.client
      .from("notification_dispatches")
      .update({
        status: "processing",
        target_profile_count: targetProfileCount,
        target_device_count: targetDeviceCount,
        success_device_count: 0,
        failure_device_count: 0,
        invalid_token_count: 0,
        started_at: new Date().toISOString(),
        completed_at: null,
        error_summary: null,
      })
      .eq("uuid_notification_dispatch", uuidNotificationDispatch)
      .eq("status", "pending")
      .select(dispatchColumns)
      .maybeSingle();
    assertDatabaseResult(error, "reclamar el procesamiento del dispatch");
    return data === null ? null : toDispatch(recordValue(data));
  }

  async finalizeProcessingAsPartial(
    uuidNotificationDispatch: string,
    aggregation: DispatchAggregation,
    startedBefore?: string,
  ): Promise<boolean> {
    let query = this.client
      .from("notification_dispatches")
      .update({
        status: "partial",
        success_device_count: aggregation.successDeviceCount,
        failure_device_count: aggregation.failureDeviceCount,
        invalid_token_count: aggregation.invalidTokenCount,
        completed_at: new Date().toISOString(),
        error_summary: aggregation.errorSummary?.slice(0, 1000) ?? null,
      })
      .eq("uuid_notification_dispatch", uuidNotificationDispatch)
      .eq("status", "processing");
    if (startedBefore !== undefined) {
      query = query.lt("started_at", startedBefore);
    }
    const { data, error } = await query
      .select("uuid_notification_dispatch")
      .maybeSingle();
    assertDatabaseResult(error, "finalizar processing con resultado incierto");
    return data !== null;
  }

  async deactivateDevice(
    uuidNotificationDevice: string,
    target: FcmDeliveryTarget,
  ): Promise<void> {
    let query = this.client
      .from("notification_devices")
      .update({ is_active: false })
      .eq("uuid_notification_device", uuidNotificationDevice)
      .eq("is_active", true)
      .is("deleted_at", null);
    if (target.kind === "fid") {
      query = query.eq("installation_id", target.value);
    } else {
      query = query.eq("fcm_token", target.value);
      query = target.installationId === null
        ? query.is("installation_id", null)
        : query.eq("installation_id", target.installationId);
    }
    const { error } = await query;
    assertDatabaseResult(error, "desactivar un dispositivo no registrado");
  }

  async finalizeDispatch(
    uuidNotificationDispatch: string,
    aggregation: DispatchAggregation,
  ): Promise<void> {
    const { data, error } = await this.client
      .from("notification_dispatches")
      .update({
        status: aggregation.status,
        success_device_count: aggregation.successDeviceCount,
        failure_device_count: aggregation.failureDeviceCount,
        invalid_token_count: aggregation.invalidTokenCount,
        completed_at: new Date().toISOString(),
        error_summary: aggregation.errorSummary,
      })
      .eq("uuid_notification_dispatch", uuidNotificationDispatch)
      .eq("status", "processing")
      .select("uuid_notification_dispatch")
      .maybeSingle();
    assertDatabaseResult(error, "finalizar el dispatch");
    if (data === null) {
      throw new Error("El dispatch ya no estaba processing al finalizar.");
    }
  }

  async reconcileEventCompletedIfActive(
    uuidNotificationEvent: string,
  ): Promise<void> {
    const { error } = await this.client
      .from("notification_events")
      .update({ status: "completed" })
      .eq("uuid_notification_event", uuidNotificationEvent)
      .eq("status", "active")
      .is("deleted_at", null);
    assertDatabaseResult(error, "reconciliar el evento completado");
  }

  async completeEvent(uuidNotificationEvent: string): Promise<void> {
    const { error } = await this.client
      .from("notification_events")
      .update({ status: "completed" })
      .eq("uuid_notification_event", uuidNotificationEvent)
      .eq("status", "active")
      .is("deleted_at", null)
      .select("uuid_notification_event")
    .maybeSingle();
    assertDatabaseResult(error, "completar el evento");
    // The dispatch may be finalized more than once by a retry or a concurrent
    // worker. Once FCM has accepted the delivery, a zero-row CAS means that
    // another path already completed the event (or its status changed). It is
    // not a delivery failure and must not be appended to error_summary.
  }

  async appendDispatchError(
    uuidNotificationDispatch: string,
    summary: string,
  ): Promise<void> {
    const { data, error: readError } = await this.client
      .from("notification_dispatches")
      .select("error_summary")
      .eq("uuid_notification_dispatch", uuidNotificationDispatch)
      .single();
    assertDatabaseResult(readError, "consultar el error del dispatch");
    const current = nullableString(recordValue(data).error_summary);
    const next = [current, summary].filter((value) => value !== null).join("; ")
      .slice(0, 1000);
    const { error } = await this.client
      .from("notification_dispatches")
      .update({ error_summary: next })
      .eq("uuid_notification_dispatch", uuidNotificationDispatch);
    assertDatabaseResult(error, "actualizar el error del dispatch");
  }

  async markBackgroundFailed(
    uuidNotificationDispatch: string,
    summary: string,
  ): Promise<void> {
    const { error } = await this.client
      .from("notification_dispatches")
      .update({
        status: "failed",
        completed_at: new Date().toISOString(),
        error_summary: summary.slice(0, 1000),
      })
      .eq("uuid_notification_dispatch", uuidNotificationDispatch)
      .in("status", ["pending", "processing"])
      .gt("target_device_count", 0)
      .eq("success_device_count", 0);
    assertDatabaseResult(error, "marcar el background fallido");
  }
}

function toEvent(row: Record<string, unknown>): NotificationEventRow {
  return {
    uuid_notification_event: requiredString(row.uuid_notification_event),
    title_template: requiredString(row.title_template),
    body_template: requiredString(row.body_template),
    category: requiredString(row.category),
    audience_type: requiredString(row.audience_type),
    action_type: requiredString(row.action_type),
    action_payload_template: objectValue(row.action_payload_template),
    trigger_config: objectValue(row.trigger_config),
    trigger_type: requiredString(row.trigger_type),
    trigger_key: nullableString(row.trigger_key),
    execution_mode: requiredString(row.execution_mode),
    status: requiredString(row.status),
    starts_at: requiredString(row.starts_at),
    ends_at: nullableString(row.ends_at),
    deleted_at: nullableString(row.deleted_at),
  };
}

function toDispatch(row: Record<string, unknown>): NotificationDispatchRow {
  return {
    uuid_notification_dispatch: requiredString(row.uuid_notification_dispatch),
    uuid_notification_event: requiredString(row.uuid_notification_event),
    idempotency_key: requiredString(row.idempotency_key),
    title_snapshot: requiredString(row.title_snapshot),
    body_snapshot: requiredString(row.body_snapshot),
    category_snapshot: requiredString(row.category_snapshot),
    audience_type_snapshot: requiredString(row.audience_type_snapshot),
    action_type_snapshot: requiredString(row.action_type_snapshot),
    action_payload_snapshot: objectValue(row.action_payload_snapshot),
    status: requiredString(row.status),
    target_profile_count: nonNegativeInteger(row.target_profile_count),
    target_device_count: nonNegativeInteger(row.target_device_count),
    success_device_count: nonNegativeInteger(row.success_device_count),
    started_at: nullableString(row.started_at),
    source_entity_type: nullableString(row.source_entity_type),
    source_entity_uuid: nullableString(row.source_entity_uuid),
  };
}

function requiredString(value: unknown): string {
  const text = typeof value === "string" ? value.trim() : "";
  if (text.length === 0) {
    throw new Error("Supabase devolvió un texto obligatorio vacío.");
  }
  return text;
}

function nullableString(value: unknown): string | null {
  return typeof value === "string" ? value : null;
}

function nullableText(value: unknown): string | null {
  const text = nullableString(value)?.trim() ?? "";
  return text.length === 0 ? null : text;
}

function objectValue(value: unknown): Record<string, unknown> {
  return typeof value === "object" && value !== null && !Array.isArray(value)
    ? value as Record<string, unknown>
    : {};
}

function recordValue(value: unknown): Record<string, unknown> {
  if (typeof value !== "object" || value === null || Array.isArray(value)) {
    throw new Error("Supabase devolvió una fila inválida.");
  }
  return value as Record<string, unknown>;
}

function rowsValue(value: unknown): Record<string, unknown>[] {
  if (!Array.isArray(value)) {
    return [];
  }
  return value.map(recordValue);
}

function nonNegativeInteger(value: unknown): number {
  const number = typeof value === "number" ? value : Number(value);
  if (!Number.isInteger(number) || number < 0) {
    throw new Error("Supabase devolvió un conteo inválido.");
  }
  return number;
}

function chunks<T>(values: T[], size: number): T[][] {
  const result: T[][] = [];
  for (let index = 0; index < values.length; index += size) {
    result.push(values.slice(index, index + size));
  }
  return result;
}

function assertDatabaseResult(
  error: { message?: string; code?: string } | null,
  operation: string,
): void {
  if (error !== null) {
    const code = error.code === undefined ? "" : ` (${error.code})`;
    throw new Error(
      `No fue posible ${operation}${code}: ${
        error.message ?? "error desconocido"
      }`,
    );
  }
}

import {
  type AudienceType,
  decideIdempotency,
  type DispatchAggregation,
  type ManualEventState,
  type NotificationDeviceRow,
  type ProfileRow,
  selectAudienceProfiles,
  selectEligibleDevices,
  validateManualEvent,
} from "./domain.ts";
import {
  type AnalyticsResult,
  HttpError,
  type PreviewResult,
  type SendResult,
} from "./handler.ts";
import {
  profileTemplateVariables,
  renderNotificationObject,
  renderNotificationText,
  sampleTemplateVariables,
} from "./notification_template.ts";

export interface NotificationEventRow extends ManualEventState {
  uuid_notification_event: string;
  title_template: string;
  body_template: string;
  category: string;
  audience_type: string;
  action_type: string;
  action_payload_template: Record<string, unknown>;
  trigger_config?: Record<string, unknown>;
}

export interface NotificationDispatchRow {
  uuid_notification_dispatch: string;
  uuid_notification_event: string;
  idempotency_key: string;
  title_snapshot: string;
  body_snapshot: string;
  category_snapshot: string;
  audience_type_snapshot: string;
  action_type_snapshot: string;
  action_payload_snapshot: Record<string, unknown>;
  status: string;
  target_profile_count: number;
  target_device_count: number;
  success_device_count: number;
  started_at: string | null;
  source_entity_type?: string | null;
  source_entity_uuid?: string | null;
}

export interface NotificationDispatchSnapshot {
  uuidNotificationEvent: string;
  titleSnapshot: string;
  bodySnapshot: string;
  categorySnapshot: string;
  audienceTypeSnapshot: string;
  actionTypeSnapshot: string;
  actionPayloadSnapshot: Record<string, unknown>;
}

export type NotificationRecipientSnapshot = NotificationDispatchSnapshot;

export interface CreateDispatchInput {
  snapshot: NotificationDispatchSnapshot;
  uuidTriggeredByProfile: string | null;
  idempotencyKey: string;
  targetProfileCount: number;
  targetDeviceCount: number;
  sourceEntityType: string | null;
  sourceEntityUuid: string | null;
  triggerSource?: "manual" | "scheduler" | "domain_event";
}

export interface DispatchWork {
  dispatch: NotificationDispatchRow;
  devices: NotificationDeviceRow[];
  inboxByProfile: Map<string, string>;
  renderedByProfile?: Map<string, NotificationRecipientSnapshot>;
  completeEvent?: boolean;
}

export interface NotificationRepository {
  loadEvent(
    uuidNotificationEvent: string,
  ): Promise<NotificationEventRow | null>;
  contentItemIsPublished(uuidContentItem: string): Promise<boolean>;
  loadProfiles(audienceType: AudienceType): Promise<ProfileRow[]>;
  loadDevices(
    profileUuids: readonly string[],
  ): Promise<NotificationDeviceRow[]>;
  findDispatch(idempotencyKey: string): Promise<NotificationDispatchRow | null>;
  loadDispatch(
    uuidNotificationDispatch: string,
  ): Promise<NotificationDispatchRow | null>;
  createDispatch(input: CreateDispatchInput): Promise<NotificationDispatchRow>;
  claimFailedDispatch(
    uuidNotificationDispatch: string,
    targetProfileCount: number,
    targetDeviceCount: number,
  ): Promise<NotificationDispatchRow | null>;
  claimProcessing(
    uuidNotificationDispatch: string,
    targetProfileCount: number,
    targetDeviceCount: number,
  ): Promise<NotificationDispatchRow | null>;
  ensureInbox(
    dispatch: NotificationDispatchRow,
    profileUuids: readonly string[],
    renderedByProfile?: ReadonlyMap<string, NotificationRecipientSnapshot>,
  ): Promise<Map<string, string>>;
  loadInboxSnapshots?(
    uuidNotificationDispatch: string,
  ): Promise<Map<string, NotificationRecipientSnapshot>>;
  loadInboxMap(uuidNotificationDispatch: string): Promise<Map<string, string>>;
  markSetupFailed(
    uuidNotificationDispatch: string,
    summary: string,
  ): Promise<void>;
  finalizeProcessingAsPartial(
    uuidNotificationDispatch: string,
    aggregation: DispatchAggregation,
    startedBefore?: string,
  ): Promise<boolean>;
  reconcileEventCompletedIfActive(
    uuidNotificationEvent: string,
  ): Promise<void>;
  loadDispatchAnalytics(
    uuidNotificationDispatch: string,
  ): Promise<AnalyticsResult>;
}

export type ProcessDispatch = (work: DispatchWork) => Promise<void>;

export class UniqueDispatchConflictError extends Error {
  constructor() {
    super("El dispatch ya existe.");
    this.name = "UniqueDispatchConflictError";
  }
}

export class ManualDispatchService {
  constructor(
    private readonly repository: NotificationRepository,
    private readonly processDispatch: ProcessDispatch,
    private readonly now: () => Date = () => new Date(),
  ) {}

  async preview(uuidNotificationEvent: string): Promise<PreviewResult> {
    const context = await this.loadAudienceContext(uuidNotificationEvent);
    return {
      uuidNotificationEvent,
      title: context.snapshot.titleSnapshot,
      body: context.snapshot.bodySnapshot,
      category: context.event.category,
      audienceType: context.event.audience_type,
      actionType: context.event.action_type,
      actionPayload: context.event.action_payload_template,
      targetProfileCount: context.profiles.length,
      targetDeviceCount: context.devices.length,
    };
  }

  async analytics(uuidNotificationDispatch: string): Promise<AnalyticsResult> {
    const dispatch = await this.repository.loadDispatch(
      uuidNotificationDispatch,
    );
    if (dispatch === null) {
      throw new HttpError(404, "No existe el dispatch de notificación.");
    }
    return await this.repository.loadDispatchAnalytics(
      uuidNotificationDispatch,
    );
  }

  async send(
    uuidNotificationEvent: string,
    uuidAdminProfile: string,
    requestId = "legacy",
    sourceDispatchUuid: string | null = null,
    retryDispatchUuid: string | null = null,
  ): Promise<SendResult> {
    if (sourceDispatchUuid !== null && retryDispatchUuid !== null) {
      throw new HttpError(
        400,
        "Un envío no puede ser reenvío y reintento al mismo tiempo.",
      );
    }

    if (retryDispatchUuid !== null) {
      const retryDispatch = await this.repository.loadDispatch(
        retryDispatchUuid,
      );
      if (retryDispatch === null) {
        throw new HttpError(404, "No existe el dispatch que se reintentará.");
      }
      if (retryDispatch.uuid_notification_event !== uuidNotificationEvent) {
        throw new HttpError(
          409,
          "El dispatch no pertenece al evento de notificación.",
        );
      }
      return await this.resolveExisting(
        retryDispatch,
        uuidNotificationEvent,
      );
    }

    const idempotencyKey = sourceDispatchUuid === null
      ? normalIdempotencyKey(uuidNotificationEvent, requestId)
      : resendIdempotencyKey(sourceDispatchUuid, requestId);
    const existing = await this.repository.findDispatch(idempotencyKey);
    if (existing !== null) {
      return await this.resolveExisting(existing, uuidNotificationEvent);
    }

    const sourceDispatch = sourceDispatchUuid === null
      ? null
      : await this.loadResendSource(
        sourceDispatchUuid,
        uuidNotificationEvent,
      );
    const context = sourceDispatch === null
      ? await this.loadAudienceContext(uuidNotificationEvent)
      : await this.loadSnapshotAudienceContext(sourceDispatch);
    if (context.profiles.length === 0) {
      throw new HttpError(409, "El evento no tiene perfiles objetivo.");
    }

    let dispatch: NotificationDispatchRow;
    try {
      dispatch = await this.repository.createDispatch({
        snapshot: context.snapshot,
        uuidTriggeredByProfile: uuidAdminProfile,
        idempotencyKey,
        targetProfileCount: context.profiles.length,
        targetDeviceCount: context.devices.length,
        sourceEntityType: sourceDispatch === null
          ? null
          : "notification_dispatch",
        sourceEntityUuid: sourceDispatch?.uuid_notification_dispatch ?? null,
      });
    } catch (error) {
      if (!(error instanceof UniqueDispatchConflictError)) {
        throw error;
      }
      const racedDispatch = await this.repository.findDispatch(idempotencyKey);
      if (racedDispatch === null) {
        throw new HttpError(500, "No fue posible recuperar el dispatch.");
      }
      return await this.resolveExisting(racedDispatch, uuidNotificationEvent);
    }

    return await this.claimAndPrepare(
      dispatch,
      context.profiles.map((profile) => profile.uuid_profile),
      context.devices,
      false,
      sourceDispatch?.uuid_notification_dispatch ?? null,
      context.renderedByProfile,
    );
  }

  private async resolveExisting(
    existing: NotificationDispatchRow,
    uuidNotificationEvent: string,
  ): Promise<SendResult> {
    if (existing.status === "completed" || existing.status === "partial") {
      await this.repository.reconcileEventCompletedIfActive(
        existing.uuid_notification_event,
      );
    }
    if (existing.status === "processing" && this.isStaleProcessing(existing)) {
      const startedBefore = new Date(
        this.now().getTime() - staleProcessingMilliseconds,
      ).toISOString();
      const aggregation: DispatchAggregation = {
        status: "partial",
        successDeviceCount: existing.success_device_count,
        failureDeviceCount: Math.max(
          0,
          existing.target_device_count - existing.success_device_count,
        ),
        invalidTokenCount: 0,
        completeEvent: true,
        errorSummary: staleProcessingSummary,
      };
      const finalized = await this.repository.finalizeProcessingAsPartial(
        existing.uuid_notification_dispatch,
        aggregation,
        startedBefore,
      );
      if (finalized) {
        await this.repository.reconcileEventCompletedIfActive(
          existing.uuid_notification_event,
        );
        return {
          uuidNotificationEvent,
          uuidNotificationDispatch: existing.uuid_notification_dispatch,
          status: "partial",
          targetProfileCount: existing.target_profile_count,
          targetDeviceCount: existing.target_device_count,
          reused: true,
          sourceDispatchUuid: existing.source_entity_uuid ?? null,
          background: null,
        };
      }
    }
    if (existing.status === "pending") {
      const context = await this.loadExistingSetupContext(
        existing,
        uuidNotificationEvent,
      );
      return await this.claimAndPrepare(
        existing,
        context.profileUuids,
        context.devices,
        true,
        existing.source_entity_uuid ?? null,
        context.renderedByProfile,
      );
    }
    const decision = decideIdempotency(existing);
    if (decision !== "retry") {
      return {
        uuidNotificationEvent,
        uuidNotificationDispatch: existing.uuid_notification_dispatch,
        status: existing.status,
        targetProfileCount: existing.target_profile_count,
        targetDeviceCount: existing.target_device_count,
        reused: true,
        sourceDispatchUuid: existing.source_entity_uuid ?? null,
        background: null,
      };
    }

    const context = await this.loadExistingSetupContext(
      existing,
      uuidNotificationEvent,
    );
    const claimed = await this.repository.claimFailedDispatch(
      existing.uuid_notification_dispatch,
      context.profileUuids.length,
      context.devices.length,
    );
    if (claimed === null) {
      const current = await this.repository.findDispatch(
        existing.idempotency_key,
      );
      if (current === null) {
        throw new HttpError(500, "No fue posible recuperar el dispatch.");
      }
      return await this.resolveExisting(current, uuidNotificationEvent);
    }

    return await this.claimAndPrepare(
      claimed,
      context.profileUuids,
      context.devices,
      true,
      existing.source_entity_uuid ?? null,
      context.renderedByProfile,
    );
  }

  private async loadExistingSetupContext(
    dispatch: NotificationDispatchRow,
    uuidNotificationEvent: string,
  ): Promise<{
    profileUuids: string[];
    devices: NotificationDeviceRow[];
    renderedByProfile?: Map<string, NotificationRecipientSnapshot>;
  }> {
    await this.loadManualEventDefinition(uuidNotificationEvent);
    await this.validateAction(
      dispatch.action_type_snapshot,
      dispatch.action_payload_snapshot,
    );
    const inboxByProfile = await this.repository.loadInboxMap(
      dispatch.uuid_notification_dispatch,
    );
    let profileUuids = [...inboxByProfile.keys()];
    if (profileUuids.length === 0) {
      const profiles = await this.loadTargetProfiles(
        dispatch.audience_type_snapshot,
      );
      if (profiles.length === 0) {
        throw new HttpError(409, "El evento no tiene perfiles objetivo.");
      }
      profileUuids = profiles.map((profile) => profile.uuid_profile);
    }
    return {
      profileUuids,
      devices: await this.loadTargetDevices(profileUuids),
      renderedByProfile: this.repository.loadInboxSnapshots === undefined
        ? undefined
        : await this.repository.loadInboxSnapshots(
          dispatch.uuid_notification_dispatch,
        ),
    };
  }

  private async claimAndPrepare(
    pending: NotificationDispatchRow,
    profileUuids: string[],
    devices: NotificationDeviceRow[],
    reused: boolean,
    sourceDispatchUuid: string | null,
    renderedByProfile?: ReadonlyMap<string, NotificationRecipientSnapshot>,
  ): Promise<SendResult> {
    const claimed = await this.repository.claimProcessing(
      pending.uuid_notification_dispatch,
      profileUuids.length,
      devices.length,
    );
    if (claimed === null) {
      return {
        uuidNotificationEvent: pending.uuid_notification_event,
        uuidNotificationDispatch: pending.uuid_notification_dispatch,
        status: "processing",
        targetProfileCount: pending.target_profile_count,
        targetDeviceCount: pending.target_device_count,
        reused: true,
        sourceDispatchUuid: sourceDispatchUuid ?? pending.source_entity_uuid ??
          null,
        background: null,
      };
    }

    try {
      const inboxByProfile = await this.repository.ensureInbox(
        claimed,
        profileUuids,
        renderedByProfile,
      );
      return this.accepted(
        claimed,
        devices,
        inboxByProfile,
        reused,
        sourceDispatchUuid ?? claimed.source_entity_uuid ?? null,
        renderedByProfile,
      );
    } catch (error) {
      await this.repository.markSetupFailed(
        claimed.uuid_notification_dispatch,
        boundedError(error),
      );
      throw error;
    }
  }

  private isStaleProcessing(dispatch: NotificationDispatchRow): boolean {
    if (dispatch.started_at === null) {
      return false;
    }
    const startedAt = Date.parse(dispatch.started_at);
    return Number.isFinite(startedAt) &&
      startedAt < this.now().getTime() - staleProcessingMilliseconds;
  }

  private accepted(
    dispatch: NotificationDispatchRow,
    devices: NotificationDeviceRow[],
    inboxByProfile: Map<string, string>,
    reused: boolean,
    sourceDispatchUuid: string | null,
    renderedByProfile?: ReadonlyMap<string, NotificationRecipientSnapshot>,
  ): SendResult {
    return {
      uuidNotificationEvent: dispatch.uuid_notification_event,
      uuidNotificationDispatch: dispatch.uuid_notification_dispatch,
      status: "processing",
      targetProfileCount: dispatch.target_profile_count,
      targetDeviceCount: dispatch.target_device_count,
      reused,
      sourceDispatchUuid: sourceDispatchUuid ?? dispatch.source_entity_uuid ??
        null,
      background: this.processDispatch({
        dispatch,
        devices,
        inboxByProfile,
        renderedByProfile: renderedByProfile === undefined
          ? undefined
          : new Map(renderedByProfile),
      }),
    };
  }

  private async loadAudienceContext(uuidNotificationEvent: string) {
    const event = await this.loadValidEvent(uuidNotificationEvent);
    const profiles = await this.loadTargetProfiles(event.audience_type);
    const devices = await this.loadTargetDevices(
      profiles.map((profile) => profile.uuid_profile),
    );
    const renderedByProfile = new Map<string, NotificationRecipientSnapshot>();
    for (const profile of profiles) {
      renderedByProfile.set(
        profile.uuid_profile,
        renderEventForProfile(event, profile),
      );
    }
    const snapshot = profiles.length > 0
      ? renderedByProfile.get(profiles[0].uuid_profile)!
      : renderEventForVariables(event, sampleTemplateVariables());
    return {
      event,
      snapshot,
      profiles,
      devices,
      renderedByProfile,
    };
  }

  private async loadResendSource(
    sourceDispatchUuid: string,
    uuidNotificationEvent: string,
  ): Promise<NotificationDispatchRow> {
    const source = await this.repository.loadDispatch(sourceDispatchUuid);
    if (source === null) {
      throw new HttpError(404, "No existe el dispatch que se reenviará.");
    }
    if (source.uuid_notification_event !== uuidNotificationEvent) {
      throw new HttpError(
        409,
        "El dispatch no pertenece al evento de notificación.",
      );
    }
    if (!new Set(["completed", "partial", "failed"]).has(source.status)) {
      throw new HttpError(409, "El dispatch todavía no puede reenviarse.");
    }
    await this.loadManualEventDefinition(uuidNotificationEvent);
    await this.validateAction(
      source.action_type_snapshot,
      source.action_payload_snapshot,
    );
    return source;
  }

  private async loadSnapshotAudienceContext(
    source: NotificationDispatchRow,
  ) {
    const profiles = await this.loadTargetProfiles(
      source.audience_type_snapshot,
    );
    const devices = await this.loadTargetDevices(
      profiles.map((profile) => profile.uuid_profile),
    );
    return {
      snapshot: snapshotFromDispatch(source),
      profiles,
      devices,
      renderedByProfile: this.repository.loadInboxSnapshots === undefined
        ? undefined
        : await this.repository.loadInboxSnapshots(
          source.uuid_notification_dispatch,
        ),
    };
  }

  private async loadValidEvent(
    uuidNotificationEvent: string,
    validateAction = true,
  ): Promise<NotificationEventRow> {
    const event = await this.repository.loadEvent(uuidNotificationEvent);
    if (event === null) {
      throw new HttpError(404, "No existe el evento de notificación.");
    }
    const validationError = validateManualEvent(event, this.now());
    if (validationError !== null) {
      throw new HttpError(409, validationError);
    }
    if (!isAudienceType(event.audience_type)) {
      throw new HttpError(409, "La audiencia del evento es inválida.");
    }
    if (validateAction) {
      await this.validateAction(
        event.action_type,
        event.action_payload_template,
      );
    }
    return event;
  }

  private async loadManualEventDefinition(
    uuidNotificationEvent: string,
  ): Promise<NotificationEventRow> {
    const event = await this.repository.loadEvent(uuidNotificationEvent);
    if (event === null) {
      throw new HttpError(404, "No existe el evento de notificación.");
    }
    if (
      event.deleted_at !== null || event.trigger_type !== "manual" ||
      event.trigger_key !== null || event.execution_mode !== "once"
    ) {
      throw new HttpError(409, "El evento no es una notificación manual.");
    }
    if (!isAudienceType(event.audience_type)) {
      throw new HttpError(409, "La audiencia del evento es inválida.");
    }
    return event;
  }

  private async validateAction(
    actionType: string,
    actionPayload: Record<string, unknown>,
  ): Promise<void> {
    if (!notificationActionTypes.has(actionType)) {
      throw new HttpError(409, "La acción de notificación es inválida.");
    }
    if (actionType === "open_content_item") {
      const uuidContentItem = actionPayload.uuid_content_item;
      if (
        typeof uuidContentItem !== "string" ||
        uuidContentItem.trim().length === 0 ||
        !await this.repository.contentItemIsPublished(uuidContentItem.trim())
      ) {
        throw new HttpError(
          409,
          "El contenido asociado no está publicado o fue eliminado.",
        );
      }
    }
  }

  private async loadTargetProfiles(
    audienceType: string,
  ): Promise<ProfileRow[]> {
    if (!isAudienceType(audienceType)) {
      throw new HttpError(409, "La audiencia del evento es inválida.");
    }
    return selectAudienceProfiles(
      await this.repository.loadProfiles(audienceType),
      audienceType,
    );
  }

  private async loadTargetDevices(
    profileUuids: readonly string[],
  ): Promise<NotificationDeviceRow[]> {
    if (profileUuids.length === 0) {
      return [];
    }
    return selectEligibleDevices(
      await this.repository.loadDevices(profileUuids),
      new Set(profileUuids),
    );
  }
}

function isAudienceType(value: string): value is AudienceType {
  return value === "all" || value === "all_users" || value === "all_admins";
}

function renderEventForProfile(
  event: NotificationEventRow,
  profile: ProfileRow,
): NotificationRecipientSnapshot {
  return renderEventForVariables(event, profileTemplateVariables(profile));
}

function renderEventForVariables(
  event: NotificationEventRow,
  variables: Record<string, unknown>,
): NotificationRecipientSnapshot {
  return {
    uuidNotificationEvent: event.uuid_notification_event,
    titleSnapshot: renderNotificationText(event.title_template, variables),
    bodySnapshot: renderNotificationText(event.body_template, variables),
    categorySnapshot: event.category,
    audienceTypeSnapshot: event.audience_type,
    actionTypeSnapshot: event.action_type,
    actionPayloadSnapshot: renderNotificationObject(
      event.action_payload_template,
      variables,
    ) as Record<string, unknown>,
  };
}

function snapshotFromDispatch(
  dispatch: NotificationDispatchRow,
): NotificationDispatchSnapshot {
  return {
    uuidNotificationEvent: dispatch.uuid_notification_event,
    titleSnapshot: dispatch.title_snapshot,
    bodySnapshot: dispatch.body_snapshot,
    categorySnapshot: dispatch.category_snapshot,
    audienceTypeSnapshot: dispatch.audience_type_snapshot,
    actionTypeSnapshot: dispatch.action_type_snapshot,
    actionPayloadSnapshot: dispatch.action_payload_snapshot,
  };
}

function normalIdempotencyKey(eventUuid: string, requestId: string): string {
  return requestId === "legacy"
    ? `manual:${eventUuid}`
    : `manual:${eventUuid}:${requestId}`;
}

function resendIdempotencyKey(
  sourceDispatchUuid: string,
  requestId: string,
): string {
  return `manual-resend:${sourceDispatchUuid}:${requestId}`;
}

const notificationActionTypes = new Set([
  "none",
  "open_content_item",
  "open_company_info",
  "open_home",
  "open_explore",
  "open_meditation",
]);

const staleProcessingMilliseconds = 10 * 60 * 1000;
const staleProcessingSummary =
  "Resultado incierto: el dispatch permaneció processing por más de 10 minutos; no se reenviará.";

function boundedError(error: unknown): string {
  const message = error instanceof Error ? error.message : String(error);
  return message.slice(0, 1000);
}

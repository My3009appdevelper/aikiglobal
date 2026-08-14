export type DispatchMode = "preview" | "analytics" | "send";
export type AudienceType = "all" | "all_users" | "all_admins";
export type DispatchStatus =
  | "pending"
  | "processing"
  | "completed"
  | "partial"
  | "failed"
  | "cancelled";

export interface DispatchRequest {
  mode: DispatchMode;
  uuidNotificationEvent: string | null;
  uuidNotificationDispatch: string | null;
  requestId: string | null;
  sourceDispatchUuid: string | null;
  retryDispatchUuid: string | null;
}

export interface ProfileRow {
  uuid_profile: string;
  role: string;
  activo: boolean;
  deleted_at: string | null;
  nombre?: string | null;
  email?: string | null;
}

export interface NotificationDeviceRow {
  uuid_notification_device: string;
  uuid_profile: string;
  installation_id: string | null;
  fcm_token: string | null;
  is_active: boolean;
  permission_status: string;
  timezone?: string | null;
  registration_refreshed_at?: string | null;
  deleted_at: string | null;
}

export interface ManualEventState {
  trigger_type: string;
  trigger_key: string | null;
  execution_mode: string;
  status: string;
  starts_at: string;
  ends_at: string | null;
  deleted_at: string | null;
}

export interface ExistingDispatchState {
  status: string;
  success_device_count: number;
  target_device_count: number;
}

export type IdempotencyDecision = "create" | "retry" | "reuse";

export type DeviceOutcome =
  | { kind: "success" }
  | { kind: "definitive"; error: string }
  | { kind: "uncertain"; error: string }
  | { kind: "invalid"; error: string };

export interface DispatchAggregation {
  status: "completed" | "partial" | "failed";
  successDeviceCount: number;
  failureDeviceCount: number;
  invalidTokenCount: number;
  completeEvent: boolean;
  errorSummary: string | null;
}

export class DispatchRequestError extends Error {
  constructor(message: string, readonly status = 400) {
    super(message);
    this.name = "DispatchRequestError";
  }
}

const UUID_PATTERN =
  /^[0-9a-f]{8}-[0-9a-f]{4}-[1-8][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i;
const MAX_ERROR_SUMMARY_LENGTH = 1000;

export function parseDispatchRequest(value: unknown): DispatchRequest {
  if (!isRecord(value)) {
    throw new DispatchRequestError("El cuerpo de la solicitud es inválido.");
  }

  const mode = value.mode;
  if (mode !== "preview" && mode !== "analytics" && mode !== "send") {
    throw new DispatchRequestError(
      "El modo debe ser preview, analytics o send.",
    );
  }

  if (mode === "analytics") {
    const uuidNotificationDispatch = typeof value.uuid_notification_dispatch ===
        "string"
      ? value.uuid_notification_dispatch.trim()
      : "";
    if (!UUID_PATTERN.test(uuidNotificationDispatch)) {
      throw new DispatchRequestError(
        "uuid_notification_dispatch debe ser un UUID válido.",
      );
    }
    if (
      value.uuid_notification_event !== undefined ||
      value.request_id !== undefined ||
      value.source_dispatch_uuid !== undefined ||
      value.retry_dispatch_uuid !== undefined
    ) {
      throw new DispatchRequestError(
        "El modo analytics sólo requiere uuid_notification_dispatch.",
      );
    }
    return {
      mode,
      uuidNotificationEvent: null,
      uuidNotificationDispatch,
      requestId: null,
      sourceDispatchUuid: null,
      retryDispatchUuid: null,
    };
  }

  const uuidNotificationEvent =
    typeof value.uuid_notification_event === "string"
      ? value.uuid_notification_event.trim()
      : "";
  if (!UUID_PATTERN.test(uuidNotificationEvent)) {
    throw new DispatchRequestError(
      "uuid_notification_event debe ser un UUID válido.",
    );
  }

  const requestId = optionalUuid(value.request_id, "request_id");
  const sourceDispatchUuid = optionalUuid(
    value.source_dispatch_uuid,
    "source_dispatch_uuid",
  );
  const retryDispatchUuid = optionalUuid(
    value.retry_dispatch_uuid,
    "retry_dispatch_uuid",
  );

  if (mode === "preview") {
    if (
      requestId !== null || sourceDispatchUuid !== null ||
      retryDispatchUuid !== null
    ) {
      throw new DispatchRequestError(
        "Los identificadores de envío sólo aplican al modo send.",
      );
    }
    return {
      mode,
      uuidNotificationEvent,
      uuidNotificationDispatch: null,
      requestId: null,
      sourceDispatchUuid: null,
      retryDispatchUuid: null,
    };
  }

  if (requestId === null) {
    throw new DispatchRequestError(
      "request_id debe ser un UUID válido para enviar.",
    );
  }
  if (sourceDispatchUuid !== null && retryDispatchUuid !== null) {
    throw new DispatchRequestError(
      "Un envío no puede ser reenvío y reintento al mismo tiempo.",
    );
  }

  return {
    mode,
    uuidNotificationEvent,
    uuidNotificationDispatch: null,
    requestId,
    sourceDispatchUuid,
    retryDispatchUuid,
  };
}

export function validateManualEvent(
  event: ManualEventState,
  now = new Date(),
): string | null {
  if (event.deleted_at !== null) {
    return "El evento fue eliminado.";
  }
  if (
    event.trigger_type !== "manual" || event.trigger_key !== null ||
    event.execution_mode !== "once"
  ) {
    return "El evento no es manual.";
  }
  if (event.status !== "active") {
    return "El evento no está activo.";
  }

  const startsAt = Date.parse(event.starts_at);
  const endsAt = event.ends_at === null ? null : Date.parse(event.ends_at);
  if (
    !Number.isFinite(startsAt) || startsAt > now.getTime() ||
    (endsAt !== null && (!Number.isFinite(endsAt) || endsAt <= now.getTime()))
  ) {
    return "El evento no está vigente.";
  }

  return null;
}

export function selectAudienceProfiles<T extends ProfileRow>(
  profiles: readonly T[],
  audienceType: AudienceType,
): T[] {
  return profiles.filter((profile) => {
    if (!profile.activo || profile.deleted_at !== null) {
      return false;
    }
    if (audienceType === "all_users") {
      return profile.role === "user";
    }
    if (audienceType === "all_admins") {
      return profile.role === "admin";
    }
    return profile.role === "user" || profile.role === "admin";
  });
}

export function selectEligibleDevices<T extends NotificationDeviceRow>(
  devices: readonly T[],
  targetProfileUuids: ReadonlySet<string>,
): T[] {
  const identities = new Set<string>();
  return devices.filter((device) => {
    const installationId = device.installation_id?.trim() ?? "";
    const fcmToken = device.fcm_token?.trim() ?? "";
    const identity = installationId.length > 0
      ? `fid:${installationId}`
      : fcmToken.length > 0
      ? `token:${fcmToken}`
      : null;
    const eligible = targetProfileUuids.has(device.uuid_profile) &&
      device.is_active && device.deleted_at === null &&
      (device.permission_status === "authorized" ||
        device.permission_status === "provisional") &&
      identity !== null && !identities.has(identity);
    if (eligible && identity !== null) {
      identities.add(identity);
    }
    return eligible;
  });
}

export function decideIdempotency(
  existing: ExistingDispatchState | null,
): IdempotencyDecision {
  if (existing === null) {
    return "create";
  }
  if (
    existing.status === "failed" && existing.success_device_count === 0
  ) {
    return "retry";
  }
  return "reuse";
}

export function aggregateDispatchResults(
  targetDeviceCount: number,
  outcomes: readonly DeviceOutcome[],
): DispatchAggregation {
  const successDeviceCount =
    outcomes.filter((outcome) => outcome.kind === "success").length;
  const invalidTokenCount =
    outcomes.filter((outcome) => outcome.kind === "invalid").length;
  const failureDeviceCount = Math.max(
    0,
    targetDeviceCount - successDeviceCount,
  );
  const hasUncertainResult =
    outcomes.some((outcome) => outcome.kind === "uncertain") ||
    outcomes.length < targetDeviceCount;
  const errors = outcomes.flatMap((outcome) =>
    outcome.kind === "success" ? [] : [outcome.error.trim()]
  ).filter((error) => error.length > 0);
  if (outcomes.length < targetDeviceCount) {
    errors.push("Uno o más resultados FCM quedaron inciertos.");
  }

  let status: DispatchAggregation["status"];
  let completeEvent: boolean;
  if (targetDeviceCount === 0 || failureDeviceCount === 0) {
    status = "completed";
    completeEvent = true;
  } else if (hasUncertainResult || successDeviceCount > 0) {
    status = "partial";
    completeEvent = true;
  } else {
    status = "failed";
    completeEvent = false;
  }

  const joinedErrors = errors.join("; ");
  return {
    status,
    successDeviceCount,
    failureDeviceCount,
    invalidTokenCount,
    completeEvent,
    errorSummary: joinedErrors.length === 0
      ? null
      : joinedErrors.slice(0, MAX_ERROR_SUMMARY_LENGTH),
  };
}

function isRecord(value: unknown): value is Record<string, unknown> {
  return typeof value === "object" && value !== null && !Array.isArray(value);
}

function optionalUuid(value: unknown, field: string): string | null {
  if (value === undefined || value === null) {
    return null;
  }
  if (typeof value !== "string" || !UUID_PATTERN.test(value.trim())) {
    throw new DispatchRequestError(`${field} debe ser un UUID válido.`);
  }
  return value.trim();
}

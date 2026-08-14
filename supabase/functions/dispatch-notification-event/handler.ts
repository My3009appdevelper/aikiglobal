import { DispatchRequestError, parseDispatchRequest } from "./domain.ts";

export interface AdminIdentity {
  uuidProfile: string;
}

export interface PreviewResult {
  uuidNotificationEvent: string;
  title: string;
  body: string;
  category: string;
  audienceType: string;
  actionType: string;
  actionPayload: Record<string, unknown>;
  targetProfileCount: number;
  targetDeviceCount: number;
}

export interface AnalyticsRecipient {
  uuidProfile: string;
  displayName: string | null;
  email: string;
  openedAt: string | null;
  readAt: string | null;
}

export interface AnalyticsResult {
  uuidNotificationDispatch: string;
  targetProfileCount: number;
  targetDeviceCount: number;
  successDeviceCount: number;
  failureDeviceCount: number;
  invalidTokenCount: number;
  inboxCount: number;
  openedCount: number;
  readCount: number;
  recipients: AnalyticsRecipient[];
}

export interface SendResult {
  uuidNotificationEvent: string;
  uuidNotificationDispatch: string;
  status: string;
  targetProfileCount: number;
  targetDeviceCount: number;
  reused: boolean;
  sourceDispatchUuid: string | null;
  background: Promise<void> | null;
}

export interface DispatchService {
  preview(uuidNotificationEvent: string): Promise<PreviewResult>;
  send(
    uuidNotificationEvent: string,
    uuidAdminProfile: string,
    requestId: string,
    sourceDispatchUuid: string | null,
    retryDispatchUuid: string | null,
  ): Promise<SendResult>;
  analytics(uuidNotificationDispatch: string): Promise<AnalyticsResult>;
}

export interface HandlerDependencies {
  authenticateAdmin(request: Request): Promise<AdminIdentity>;
  createService(): DispatchService;
  schedule(background: Promise<void>): void;
}

export class HttpError extends Error {
  constructor(readonly status: number, message: string) {
    super(message);
    this.name = "HttpError";
  }
}

const responseHeaders = {
  "access-control-allow-headers":
    "authorization, x-client-info, apikey, content-type",
  "access-control-allow-methods": "POST, OPTIONS",
  "access-control-allow-origin": "*",
  "content-type": "application/json; charset=utf-8",
};

export function createDispatchHandler(dependencies: HandlerDependencies) {
  return async (request: Request): Promise<Response> => {
    let uuidNotificationEvent: string | null = null;
    try {
      if (request.method === "OPTIONS") {
        return jsonResponse(200, { uuid_notification_event: null });
      }
      if (request.method !== "POST") {
        throw new HttpError(405, "Método no permitido.");
      }

      const rawBody = await readBody(request);
      uuidNotificationEvent = extractEventUuid(rawBody);
      const parsed = parseDispatchRequest(rawBody);
      uuidNotificationEvent = parsed.uuidNotificationEvent;

      const admin = await dependencies.authenticateAdmin(request);
      const service = dependencies.createService();
      if (parsed.mode === "preview") {
        const result = await service.preview(parsed.uuidNotificationEvent!);
        return jsonResponse(200, {
          uuid_notification_event: result.uuidNotificationEvent,
          title: result.title,
          body: result.body,
          category: result.category,
          audience_type: result.audienceType,
          action_type: result.actionType,
          action_payload: result.actionPayload,
          target_profile_count: result.targetProfileCount,
          target_device_count: result.targetDeviceCount,
        });
      }

      if (parsed.mode === "analytics") {
        const result = await service.analytics(
          parsed.uuidNotificationDispatch!,
        );
        return jsonResponse(200, {
          uuid_notification_dispatch: result.uuidNotificationDispatch,
          target_profile_count: result.targetProfileCount,
          target_device_count: result.targetDeviceCount,
          success_device_count: result.successDeviceCount,
          failure_device_count: result.failureDeviceCount,
          invalid_token_count: result.invalidTokenCount,
          inbox_count: result.inboxCount,
          opened_count: result.openedCount,
          read_count: result.readCount,
          recipients: result.recipients.map((recipient) => ({
            uuid_profile: recipient.uuidProfile,
            display_name: recipient.displayName,
            email: recipient.email,
            opened_at: recipient.openedAt,
            read_at: recipient.readAt,
          })),
        });
      }

      const result = await service.send(
        parsed.uuidNotificationEvent!,
        admin.uuidProfile,
        parsed.requestId!,
        parsed.sourceDispatchUuid,
        parsed.retryDispatchUuid,
      );
      if (result.background !== null) {
        dependencies.schedule(result.background);
      }
      return jsonResponse(202, {
        uuid_notification_event: result.uuidNotificationEvent,
        uuid_notification_dispatch: result.uuidNotificationDispatch,
        status: result.status,
        target_profile_count: result.targetProfileCount,
        target_device_count: result.targetDeviceCount,
        reused: result.reused,
        source_dispatch_uuid: result.sourceDispatchUuid,
      });
    } catch (error) {
      const httpError = toHttpError(error);
      return jsonResponse(httpError.status, {
        uuid_notification_event: uuidNotificationEvent,
        error: { message: httpError.message },
      });
    }
  };
}

async function readBody(request: Request): Promise<unknown> {
  try {
    return await request.json();
  } catch {
    throw new HttpError(400, "El cuerpo JSON es inválido.");
  }
}

function extractEventUuid(value: unknown): string | null {
  if (typeof value !== "object" || value === null || Array.isArray(value)) {
    return null;
  }
  const eventUuid = (value as Record<string, unknown>).uuid_notification_event;
  return typeof eventUuid === "string" && eventUuid.trim().length > 0
    ? eventUuid.trim()
    : null;
}

function toHttpError(error: unknown): HttpError {
  if (error instanceof HttpError) {
    return error;
  }
  if (error instanceof DispatchRequestError) {
    return new HttpError(error.status, error.message);
  }
  console.error("dispatch-notification-event request failed", error);
  return new HttpError(500, "No fue posible procesar la solicitud.");
}

function jsonResponse(status: number, body: Record<string, unknown>): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: responseHeaders,
  });
}

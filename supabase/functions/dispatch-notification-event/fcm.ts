export interface FcmRequestInput {
  installationId: string | null;
  fcmToken: string | null;
  title: string;
  body: string;
  uuidNotificationDispatch: string;
  uuidNotificationInbox: string;
  category: string;
  actionType: string;
  actionPayload: Record<string, unknown>;
}

export interface FcmClassification {
  kind: "success" | "retryable" | "invalid" | "permanent" | "uncertain";
  code: string | null;
  message: string | null;
}

export interface FcmRetryOptions {
  maxAttempts?: number;
  baseDelayMs?: number;
  random?: () => number;
  now?: () => number;
  sleep?: (milliseconds: number) => Promise<void>;
}

export interface FcmSendResult {
  classification: FcmClassification;
  attempts: number;
  httpStatus: number | null;
}

export function buildFcmRequest(input: FcmRequestInput) {
  const fid = input.installationId?.trim() ?? "";
  const token = input.fcmToken?.trim() ?? "";
  if (fid.length === 0 && token.length === 0) {
    throw new Error("El dispositivo no tiene FID ni token FCM.");
  }
  const target = fid.length > 0 ? { fid } : { token };
  return {
    message: {
      ...target,
      notification: { title: input.title, body: input.body },
      data: {
        schema_version: "1",
        uuid_notification_dispatch: input.uuidNotificationDispatch,
        uuid_notification_inbox: input.uuidNotificationInbox,
        category: input.category,
        action_type: input.actionType,
        action_payload: JSON.stringify(input.actionPayload),
      },
    },
  };
}

export type FcmRequest = ReturnType<typeof buildFcmRequest>;

export function classifyFcmResponse(
  httpStatus: number,
  body: unknown,
): FcmClassification {
  if (httpStatus >= 200 && httpStatus < 300) {
    return { kind: "success", code: null, message: null };
  }

  const error = getRecord(body, "error");
  const details = Array.isArray(error?.details) ? error.details : [];
  const fcmError = details.find((detail) => {
    const record = asRecord(detail);
    return typeof record?.errorCode === "string";
  });
  const detailCode = asRecord(fcmError)?.errorCode;
  const code = typeof detailCode === "string"
    ? detailCode
    : typeof error?.status === "string"
    ? error.status
    : null;
  const message = typeof error?.message === "string" ? error.message : null;

  if (code === "UNREGISTERED") {
    return { kind: "invalid", code, message };
  }
  if (httpStatus === 429 || httpStatus >= 500) {
    return { kind: "retryable", code, message };
  }
  return { kind: "permanent", code, message };
}

export async function sendFcmWithRetry(
  send: () => Promise<Response>,
  options: FcmRetryOptions = {},
): Promise<FcmSendResult> {
  const maxAttempts = Math.max(1, options.maxAttempts ?? 3);
  const baseDelayMs = Math.max(10_000, options.baseDelayMs ?? 10_000);
  const random = options.random ?? Math.random;
  const now = options.now ?? Date.now;
  const sleep = options.sleep ??
    ((milliseconds) =>
      new Promise((resolve) => setTimeout(resolve, milliseconds)));

  for (let attempt = 1; attempt <= maxAttempts; attempt += 1) {
    let response: Response;
    try {
      response = await send();
    } catch (error) {
      return {
        classification: {
          kind: "uncertain",
          code: "NETWORK_ERROR",
          message: error instanceof Error ? error.message : String(error),
        },
        attempts: attempt,
        httpStatus: null,
      };
    }

    const body = await readJson(response);
    const classification = classifyFcmResponse(response.status, body);
    if (classification.kind !== "retryable" || attempt === maxAttempts) {
      return {
        classification,
        attempts: attempt,
        httpStatus: response.status,
      };
    }

    const retryAfterMs = parseRetryAfterMs(
      response.headers.get("retry-after"),
      now(),
    );
    const jitter = Math.floor(Math.max(0, Math.min(1, random())) * 1_000);
    if (response.status === 429) {
      const exponentialDelay = 60_000 * 2 ** (attempt - 1);
      const retryAfterOrDefault = retryAfterMs ?? 60_000;
      await sleep(Math.max(retryAfterOrDefault, exponentialDelay) + jitter);
      continue;
    }

    const exponentialDelay = baseDelayMs * 2 ** (attempt - 1);
    const backoff = Math.max(10_000, exponentialDelay);
    await sleep(Math.max(backoff, retryAfterMs ?? 0) + jitter);
  }

  throw new Error("Estado de retry inalcanzable.");
}

export function parseRetryAfterMs(
  value: string | null,
  nowMs = Date.now(),
): number | null {
  const clean = value?.trim() ?? "";
  if (clean.length === 0) {
    return null;
  }

  const seconds = Number(clean);
  if (Number.isFinite(seconds) && seconds >= 0) {
    return Math.ceil(seconds * 1_000);
  }

  const dateMs = Date.parse(clean);
  return Number.isFinite(dateMs) ? Math.max(0, dateMs - nowMs) : null;
}

async function readJson(response: Response): Promise<unknown> {
  try {
    return await response.json();
  } catch {
    return null;
  }
}

function getRecord(
  value: unknown,
  key: string,
): Record<string, unknown> | null {
  return asRecord(value)?.[key] !== undefined
    ? asRecord(asRecord(value)?.[key])
    : null;
}

function asRecord(value: unknown): Record<string, unknown> | null {
  return typeof value === "object" && value !== null && !Array.isArray(value)
    ? value as Record<string, unknown>
    : null;
}

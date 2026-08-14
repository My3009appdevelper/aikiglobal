import {
  aggregateDispatchResults,
  type DeviceOutcome,
  type DispatchAggregation,
} from "./domain.ts";
import { buildFcmRequest, type FcmSendResult } from "./fcm.ts";
import type { DispatchWork, ProcessDispatch } from "./service.ts";

type FcmRequest = ReturnType<typeof buildFcmRequest>;

export type FcmDeliveryTarget =
  | { kind: "fid"; value: string }
  | {
    kind: "token";
    value: string;
    installationId: string | null;
  };

export interface DispatchProcessorRepository {
  deactivateDevice(
    uuidNotificationDevice: string,
    target: FcmDeliveryTarget,
  ): Promise<void>;
  finalizeDispatch(
    uuidNotificationDispatch: string,
    aggregation: DispatchAggregation,
  ): Promise<void>;
  finalizeProcessingAsPartial(
    uuidNotificationDispatch: string,
    aggregation: DispatchAggregation,
    startedBefore?: string,
  ): Promise<boolean>;
  completeEvent(uuidNotificationEvent: string): Promise<void>;
  appendDispatchError(
    uuidNotificationDispatch: string,
    summary: string,
  ): Promise<void>;
  markBackgroundFailed(
    uuidNotificationDispatch: string,
    summary: string,
  ): Promise<void>;
}

export interface DispatchProcessorDependencies {
  repository: DispatchProcessorRepository;
  getAccessToken(): Promise<string>;
  send(request: FcmRequest, accessToken: string): Promise<FcmSendResult>;
  concurrency?: number;
  logError?: (message: string, error: unknown) => void;
}

export function createDispatchProcessor(
  dependencies: DispatchProcessorDependencies,
): ProcessDispatch {
  const concurrency = Math.max(1, Math.floor(dependencies.concurrency ?? 10));
  const logError = dependencies.logError ?? console.error;

  return async (work: DispatchWork): Promise<void> => {
    const dispatchUuid = work.dispatch.uuid_notification_dispatch;
    let fcmRequestStarted = false;
    try {
      const outcomes = await sendToDevices(
        work,
        dependencies,
        concurrency,
        () => fcmRequestStarted = true,
      );
      const aggregation = aggregateDispatchResults(
        work.devices.length,
        outcomes,
      );
      try {
        await dependencies.repository.finalizeDispatch(
          dispatchUuid,
          aggregation,
        );
      } catch (error) {
        if (!fcmRequestStarted) {
          throw error;
        }
        logError(
          "dispatch-notification-event finalization failed after FCM",
          error,
        );
        try {
          const finalized = await dependencies.repository
            .finalizeProcessingAsPartial(
              dispatchUuid,
              uncertainPartialAggregation(aggregation, error),
            );
          if (finalized && (work.completeEvent ?? true)) {
            await completeEventBestEffort(work, dependencies, dispatchUuid);
          }
        } catch (fallbackError) {
          logError(
            "dispatch-notification-event uncertain fallback failed",
            fallbackError,
          );
        }
        return;
      }

      if (aggregation.completeEvent && (work.completeEvent ?? true)) {
        await completeEventBestEffort(work, dependencies, dispatchUuid);
      }
    } catch (error) {
      logError("dispatch-notification-event background failed", error);
      if (!fcmRequestStarted && work.devices.length > 0) {
        await dependencies.repository.markBackgroundFailed(
          dispatchUuid,
          boundedMessage(errorMessage(error)),
        );
      }
    }
  };
}

async function completeEventBestEffort(
  work: DispatchWork,
  dependencies: DispatchProcessorDependencies,
  dispatchUuid: string,
): Promise<void> {
  try {
    await dependencies.repository.completeEvent(
      work.dispatch.uuid_notification_event,
    );
  } catch (error) {
    await dependencies.repository.appendDispatchError(
      dispatchUuid,
      boundedMessage(`No se completó el evento: ${errorMessage(error)}`),
    );
  }
}

function uncertainPartialAggregation(
  aggregation: DispatchAggregation,
  error: unknown,
): DispatchAggregation {
  const uncertainty =
    `Resultado incierto: no fue posible confirmar la finalización después de iniciar FCM; no se reenviará: ${
      errorMessage(error)
    }`;
  const errorSummary = [aggregation.errorSummary, uncertainty]
    .filter((value): value is string => value !== null)
    .join("; ");
  return {
    ...aggregation,
    status: "partial",
    completeEvent: true,
    errorSummary: boundedMessage(errorSummary),
  };
}

async function sendToDevices(
  work: DispatchWork,
  dependencies: DispatchProcessorDependencies,
  concurrency: number,
  onFcmRequestStarted: () => void,
): Promise<DeviceOutcome[]> {
  if (work.devices.length === 0) {
    return [];
  }

  let accessToken: string;
  try {
    accessToken = await dependencies.getAccessToken();
  } catch (error) {
    const summary = `FCM configuración: ${errorMessage(error)}`;
    return work.devices.map(() => ({ kind: "definitive", error: summary }));
  }

  return await mapConcurrent(work.devices, concurrency, async (device) => {
    const uuidNotificationInbox = work.inboxByProfile.get(device.uuid_profile);
    if (uuidNotificationInbox === undefined) {
      return {
        kind: "definitive" as const,
        error: "No existe inbox para el perfil objetivo.",
      };
    }

    const rendered = work.renderedByProfile?.get(device.uuid_profile);
    const title = rendered?.titleSnapshot ?? work.dispatch.title_snapshot;
    const body = rendered?.bodySnapshot ?? work.dispatch.body_snapshot;
    const category = rendered?.categorySnapshot ??
      work.dispatch.category_snapshot;
    const actionType = rendered?.actionTypeSnapshot ??
      work.dispatch.action_type_snapshot;
    const actionPayload = rendered?.actionPayloadSnapshot ??
      work.dispatch.action_payload_snapshot;

    let request: FcmRequest;
    try {
      request = buildFcmRequest({
        installationId: device.installation_id,
        fcmToken: device.fcm_token,
        title,
        body,
        uuidNotificationDispatch: work.dispatch.uuid_notification_dispatch,
        uuidNotificationInbox,
        category,
        actionType,
        actionPayload,
      });
    } catch (error) {
      return {
        kind: "definitive" as const,
        error: `FCM request inválido: ${errorMessage(error)}`,
      };
    }

    onFcmRequestStarted();
    let result: FcmSendResult;
    try {
      result = await dependencies.send(request, accessToken);
    } catch (error) {
      return {
        kind: "uncertain" as const,
        error: `FCM network: ${errorMessage(error)}`,
      };
    }

    if (result.classification.kind === "success") {
      return { kind: "success" as const };
    }

    if (
      result.classification.kind === "invalid" &&
      "fid" in request.message &&
      typeof request.message.fid === "string" &&
      (device.fcm_token?.trim() ?? "").length > 0
    ) {
      let fallbackRequest: FcmRequest;
      try {
        fallbackRequest = buildFcmRequest({
          installationId: null,
          fcmToken: device.fcm_token,
          title,
          body,
          uuidNotificationDispatch: work.dispatch.uuid_notification_dispatch,
          uuidNotificationInbox,
          category,
          actionType,
          actionPayload,
        });
      } catch (error) {
        return {
          kind: "definitive" as const,
          error: `FCM fallback inválido: ${errorMessage(error)}`,
        };
      }

      onFcmRequestStarted();
      try {
        const fallbackResult = await dependencies.send(
          fallbackRequest,
          accessToken,
        );
        if (fallbackResult.classification.kind === "success") {
          return { kind: "success" as const };
        }
        request = fallbackRequest;
        result = fallbackResult;
      } catch (error) {
        return {
          kind: "uncertain" as const,
          error: `FCM fallback network: ${errorMessage(error)}`,
        };
      }
    }

    const summary = fcmErrorSummary(result);
    if (result.classification.kind === "invalid") {
      try {
        await dependencies.repository.deactivateDevice(
          device.uuid_notification_device,
          deliveryTarget(request, device.installation_id),
        );
      } catch (error) {
        return {
          kind: "invalid" as const,
          error: `${summary}; no se desactivó el dispositivo: ${
            errorMessage(error)
          }`,
        };
      }
      return { kind: "invalid" as const, error: summary };
    }
    if (result.classification.kind === "uncertain") {
      return { kind: "uncertain" as const, error: summary };
    }
    return { kind: "definitive" as const, error: summary };
  });
}

function deliveryTarget(
  request: FcmRequest,
  originalInstallationId: string | null,
): FcmDeliveryTarget {
  if ("fid" in request.message && typeof request.message.fid === "string") {
    return { kind: "fid", value: request.message.fid };
  }
  if (
    "token" in request.message && typeof request.message.token === "string"
  ) {
    return {
      kind: "token",
      value: request.message.token,
      installationId: originalInstallationId,
    };
  }
  throw new Error("El request FCM no contiene un target válido.");
}

async function mapConcurrent<T, R>(
  values: readonly T[],
  concurrency: number,
  operation: (value: T) => Promise<R>,
): Promise<R[]> {
  const results = new Array<R>(values.length);
  let nextIndex = 0;
  const workers = Array.from(
    { length: Math.min(concurrency, values.length) },
    async () => {
      while (true) {
        const index = nextIndex;
        nextIndex += 1;
        if (index >= values.length) {
          return;
        }
        results[index] = await operation(values[index]);
      }
    },
  );
  await Promise.all(workers);
  return results;
}

function fcmErrorSummary(result: FcmSendResult): string {
  const status = result.httpStatus === null
    ? "network"
    : String(result.httpStatus);
  const detail = result.classification.code ??
    result.classification.message ?? "UNKNOWN";
  return `FCM ${status}: ${detail}`;
}

function errorMessage(error: unknown): string {
  return error instanceof Error ? error.message : String(error);
}

function boundedMessage(message: string): string {
  return message.slice(0, 1000);
}

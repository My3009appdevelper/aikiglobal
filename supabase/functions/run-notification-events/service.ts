import type {
  AudienceType,
  NotificationDeviceRow,
  ProfileRow,
} from "../dispatch-notification-event/domain.ts";
import type {
  CreateDispatchInput,
  DispatchWork,
  NotificationDispatchRow,
  NotificationEventRow,
  NotificationRecipientSnapshot,
} from "../dispatch-notification-event/service.ts";
import type { ProcessDispatch } from "../dispatch-notification-event/service.ts";
import { SupabaseNotificationRepository } from "../dispatch-notification-event/supabase_repository.ts";
import {
  domainEventOccurrence,
  domainEventDedupeKey,
  dueProgressOccurrences,
  dueScheduleOccurrences,
  isActiveAutomation,
  renderObject,
  renderText,
  type AutomationOccurrence,
  type DomainEventRow,
} from "./evaluator.ts";

export interface RunnerSummary {
  evaluatedEvents: number;
  domainEvents: number;
  occurrences: number;
  createdDispatches: number;
  reusedDispatches: number;
  skippedDispatches: number;
  errors: string[];
  dryRun: boolean;
}

export interface RunnerOptions {
  dryRun?: boolean;
  now?: () => Date;
  domainEventLimit?: number;
}

export class AutomaticNotificationRunner {
  constructor(
    private readonly repository: SupabaseNotificationRepository,
    private readonly processDispatch: ProcessDispatch,
    private readonly options: RunnerOptions = {},
  ) {}

  async run(): Promise<RunnerSummary> {
    const now = this.options.now?.() ?? new Date();
    const summary: RunnerSummary = {
      evaluatedEvents: 0,
      domainEvents: 0,
      occurrences: 0,
      createdDispatches: 0,
      reusedDispatches: 0,
      skippedDispatches: 0,
      errors: [],
      dryRun: this.options.dryRun === true,
    };
    const events = await this.repository.loadAutomationEvents();
    summary.evaluatedEvents = events.length;
    const activeEvents = events.filter((event) =>
      isActiveAutomation(event, now)
    );

    await this.processDomainEvents(activeEvents, now, summary);
    for (const event of activeEvents) {
      try {
        const profiles = await this.loadAudienceProfiles(event);
        const devices = await this.repository.loadDevices(
          profiles.map((profile) => profile.uuid_profile),
        );
        if (event.trigger_type === "schedule") {
          const occurrences = dueScheduleOccurrences(
            event,
            profiles,
            devices,
            now,
          );
          for (const occurrence of occurrences) {
            summary.occurrences++;
            await this.processOccurrence(occurrence, devices, summary);
          }
        } else if (event.trigger_type === "progress_event") {
          const stats = await this.repository.loadStreakStats(
            profiles.map((profile) => profile.uuid_profile),
          );
          const occurrences = dueProgressOccurrences(
            event,
            profiles,
            devices,
            stats,
            now,
          );
          for (const occurrence of occurrences) {
            summary.occurrences++;
            await this.processOccurrence(occurrence, devices, summary);
          }
        }
      } catch (error) {
        summary.errors.push(errorMessage(error));
      }
    }
    return summary;
  }

  private async processDomainEvents(
    activeEvents: readonly NotificationEventRow[],
    now: Date,
    summary: RunnerSummary,
  ): Promise<void> {
    const domainEvents = await this.repository.loadDomainEvents(
      this.options.domainEventLimit ?? 100,
    );
    summary.domainEvents = domainEvents.length;
    const handledDomainEventKeys = new Set<string>();
    for (const domainEvent of domainEvents) {
      try {
        const dedupeKey = domainEventDedupeKey(domainEvent);
        if (handledDomainEventKeys.has(dedupeKey)) {
          summary.skippedDispatches++;
          if (!summary.dryRun) {
            await this.repository.markDomainEventProcessed(
              domainEvent.uuid_notification_domain_event,
            );
          }
          continue;
        }

        const matchingEvents = activeEvents.filter((event) =>
          event.trigger_type === "domain_event" &&
          event.trigger_key === domainEvent.event_key &&
          isActiveAutomation(event, now)
        );
        if (matchingEvents.length === 0) {
          handledDomainEventKeys.add(dedupeKey);
          if (!summary.dryRun) {
            await this.repository.markDomainEventProcessed(
              domainEvent.uuid_notification_domain_event,
            );
          }
          continue;
        }

        for (const event of matchingEvents) {
          const profiles = await this.loadAudienceProfiles(event);
          const occurrence = domainEventOccurrence(
            event,
            domainEvent,
            profiles,
          );
          if (occurrence === null) {
            continue;
          }
          const devices = await this.repository.loadDevices(
            occurrence.profileUuids,
          );
          summary.occurrences++;
          await this.processOccurrence(occurrence, devices, summary);
        }
        handledDomainEventKeys.add(dedupeKey);
        if (!summary.dryRun) {
          await this.repository.markDomainEventProcessed(
            domainEvent.uuid_notification_domain_event,
          );
        }
      } catch (error) {
        const message = errorMessage(error);
        summary.errors.push(message);
        if (!summary.dryRun) {
          try {
            await this.repository.markDomainEventFailed(
              domainEvent.uuid_notification_domain_event,
              message,
            );
          } catch (markError) {
            summary.errors.push(errorMessage(markError));
          }
        }
      }
    }
  }

  private async loadAudienceProfiles(
    event: NotificationEventRow,
  ): Promise<ProfileRow[]> {
    if (!isAudience(event.audience_type)) {
      throw new Error("La audiencia de la regla automática no es válida.");
    }
    return await this.repository.loadProfiles(event.audience_type);
  }

  private async processOccurrence(
    occurrence: AutomationOccurrence,
    devices: readonly NotificationDeviceRow[],
    summary: RunnerSummary,
  ): Promise<void> {
    if (occurrence.profileUuids.length === 0) {
      summary.skippedDispatches++;
      return;
    }

    const perProfile = occurrence.event.trigger_type === "progress_event";
    const groups = perProfile
      ? occurrence.profileUuids.map((profileUuid) => ({
        profileUuids: [profileUuid],
        idempotencyKey: occurrence.idempotencyKey,
      }))
      : [{
        profileUuids: occurrence.profileUuids,
        idempotencyKey: occurrence.idempotencyKey,
    }];

    for (const group of groups) {
      const renderedByProfile = new Map<
        string,
        NotificationRecipientSnapshot
      >();
      for (const profileUuid of group.profileUuids) {
        const variables = occurrence.variablesByProfile.get(profileUuid) ?? {};
        const rawActionPayload = occurrence.actionPayloadByProfile.get(
          profileUuid,
        ) ?? occurrence.event.action_payload_template ?? {};
        renderedByProfile.set(profileUuid, {
          uuidNotificationEvent: occurrence.event.uuid_notification_event,
          titleSnapshot: renderText(
            occurrence.event.title_template,
            variables,
          ),
          bodySnapshot: renderText(occurrence.event.body_template, variables),
          categorySnapshot: occurrence.event.category,
          audienceTypeSnapshot: occurrence.event.audience_type,
          actionTypeSnapshot: occurrence.event.action_type,
          actionPayloadSnapshot: renderObject(
            rawActionPayload,
            variables,
          ) as Record<string, unknown>,
        });
      }
      const snapshot = renderedByProfile.get(group.profileUuids[0])!;

      if (summary.dryRun) {
        summary.createdDispatches++;
        continue;
      }

      const existing = await this.repository.findDispatch(
        group.idempotencyKey,
      );
      if (existing !== null &&
        existing.status !== "failed" && existing.status !== "pending") {
        summary.reusedDispatches++;
        continue;
      }

      const dispatch = existing ?? await this.repository.createDispatch({
        snapshot,
        uuidTriggeredByProfile: null,
        idempotencyKey: group.idempotencyKey,
        targetProfileCount: group.profileUuids.length,
        targetDeviceCount: devices.filter((device) =>
          group.profileUuids.includes(device.uuid_profile)
        ).length,
        sourceEntityType: occurrence.sourceEntityType,
        sourceEntityUuid: occurrence.sourceEntityUuid,
        triggerSource: occurrence.triggerSource,
      } satisfies CreateDispatchInput);

      const groupDevices = devices.filter((device) =>
        group.profileUuids.includes(device.uuid_profile)
      );
      const inboxByProfile = await this.repository.ensureInbox(
        dispatch,
        group.profileUuids,
        renderedByProfile,
      );
      const pending = dispatch.status === "failed"
        ? await this.repository.claimFailedDispatch(
          dispatch.uuid_notification_dispatch,
          group.profileUuids.length,
          groupDevices.length,
        )
        : dispatch;
      if (pending === null) {
        summary.reusedDispatches++;
        continue;
      }
      const claimed = await this.repository.claimProcessing(
        pending.uuid_notification_dispatch,
        group.profileUuids.length,
        groupDevices.length,
      );
      if (claimed === null) {
        summary.reusedDispatches++;
        continue;
      }
      const work: DispatchWork = {
        dispatch: claimed,
        devices: groupDevices,
        inboxByProfile,
        renderedByProfile,
        completeEvent: occurrence.event.execution_mode === "once",
      };
      await this.processDispatch(work);
      summary.createdDispatches++;
    }
  }
}

function isAudience(value: string): value is AudienceType {
  return value === "all" || value === "all_users" || value === "all_admins";
}

function errorMessage(error: unknown): string {
  return error instanceof Error ? error.message : String(error);
}

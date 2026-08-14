import type {
  NotificationDeviceRow,
  ProfileRow,
} from "../dispatch-notification-event/domain.ts";
import type { NotificationEventRow } from "../dispatch-notification-event/service.ts";
import {
  profileTemplateVariables,
  renderNotificationObject,
  renderNotificationText,
} from "../notification_template.ts";

export const renderText = renderNotificationText;
export const renderObject = renderNotificationObject;

export interface DomainEventRow {
  uuid_notification_domain_event: string;
  event_key: string;
  source_entity_type: string;
  source_entity_uuid: string;
  payload: Record<string, unknown>;
  occurred_at: string;
}

export function domainEventDedupeKey(domainEvent: DomainEventRow): string {
  return [
    domainEvent.event_key,
    domainEvent.source_entity_type,
    domainEvent.source_entity_uuid,
    stableJson(domainEvent.payload),
  ].join("|");
}

function stableJson(value: unknown): string {
  if (Array.isArray(value)) {
    return `[${value.map(stableJson).join(",")}]`;
  }
  if (typeof value === "object" && value !== null) {
    const record = value as Record<string, unknown>;
    return `{${Object.keys(record).sort().map((key) =>
      `${JSON.stringify(key)}:${stableJson(record[key])}`
    ).join(",")}}`;
  }
  return JSON.stringify(value);
}

export interface StreakRow {
  uuid_profile: string;
  current_streak: number;
  longest_streak: number;
  last_activity_date: string | null;
}

export interface AutomationOccurrence {
  event: NotificationEventRow;
  idempotencyKey: string;
  triggerSource: "scheduler" | "domain_event";
  profileUuids: string[];
  variablesByProfile: Map<string, Record<string, unknown>>;
  actionPayloadByProfile: Map<string, Record<string, unknown>>;
  sourceEntityType: string | null;
  sourceEntityUuid: string | null;
}

const defaultTimezone = "UTC";

export function isActiveAutomation(
  event: NotificationEventRow,
  now: Date,
): boolean {
  if (event.deleted_at !== null || event.status !== "active") {
    return false;
  }
  const startsAt = Date.parse(event.starts_at);
  const endsAt = event.ends_at === null ? null : Date.parse(event.ends_at);
  return Number.isFinite(startsAt) && startsAt <= now.getTime() &&
    (endsAt === null || (Number.isFinite(endsAt) && endsAt > now.getTime()));
}

export function dueScheduleOccurrences(
  event: NotificationEventRow,
  profiles: readonly ProfileRow[],
  devices: readonly NotificationDeviceRow[],
  now: Date,
): AutomationOccurrence[] {
  if (!event.trigger_key || !isActiveAutomation(event, now)) {
    return [];
  }

  const contexts = profileContexts(profiles, devices);
  const groups = new Map<string, AutomationOccurrence>();
  for (const context of contexts) {
    const local = localParts(now, context.timezone);
    let occurrenceKey: string | null = null;
    if (event.trigger_key === "schedule.interval") {
      occurrenceKey = intervalOccurrenceKey(event, now, context.timezone);
    } else if (event.trigger_key === "schedule.at_time") {
      const localTime = configText(event, "local_time");
      if (localTime !== `${pad(local.hour)}:${pad(local.minute)}`) {
        continue;
      }
      const days = configNumberList(event, "days_of_week");
      if (days.length > 0 && !days.includes(local.weekday)) {
        continue;
      }
      occurrenceKey = `${localDateKey(local)}:${localTime}`;
    }
    if (occurrenceKey === null) {
      continue;
    }

    const groupKey = event.trigger_key === "schedule.interval"
      ? `${event.uuid_notification_event}:${occurrenceKey}`
      : `${event.uuid_notification_event}:${occurrenceKey}:${context.timezone}`;
    const idempotencyKey = event.trigger_key === "schedule.interval"
      ? intervalIdempotencyKey(event, occurrenceKey)
      : `schedule:${groupKey}`;
    const existing = groups.get(groupKey);
    if (existing === undefined) {
      groups.set(groupKey, {
        event,
        idempotencyKey,
        triggerSource: "scheduler",
        profileUuids: [context.profile.uuid_profile],
        variablesByProfile: new Map([
          [
            context.profile.uuid_profile,
            profileTemplateVariables(context.profile),
          ],
        ]),
        actionPayloadByProfile: new Map(),
        sourceEntityType: null,
        sourceEntityUuid: null,
      });
    } else {
      existing.profileUuids.push(context.profile.uuid_profile);
      existing.variablesByProfile.set(
        context.profile.uuid_profile,
        profileTemplateVariables(context.profile),
      );
    }
  }
  return [...groups.values()];
}

export function dueProgressOccurrences(
  event: NotificationEventRow,
  profiles: readonly ProfileRow[],
  devices: readonly NotificationDeviceRow[],
  stats: readonly StreakRow[],
  now: Date,
): AutomationOccurrence[] {
  if (!event.trigger_key || !isActiveAutomation(event, now)) {
    return [];
  }
  const statsByProfile = new Map(
    stats.map((row) => [row.uuid_profile, row]),
  );
  const occurrences: AutomationOccurrence[] = [];
  for (const context of profileContexts(profiles, devices)) {
    const local = localParts(now, context.timezone);
    const expectedTime = event.trigger_key === "progress.streak_reminder"
      ? configText(event, "reminder_time")
      : null;
    if (expectedTime !== null &&
      expectedTime !== `${pad(local.hour)}:${pad(local.minute)}`) {
      continue;
    }
    const profileStats = statsByProfile.get(context.profile.uuid_profile);
    if (profileStats === undefined || profileStats.current_streak < 1) {
      continue;
    }

    const config = event.trigger_config ?? {};
    if (event.trigger_key === "progress.streak_reminder") {
      const minStreak = configNumber(config, "min_streak", 1);
      if (profileStats.current_streak < minStreak) {
        continue;
      }
    } else {
      const milestones = numberList(config.milestones);
      if (!milestones.includes(profileStats.current_streak)) {
        continue;
      }
    }

    const variables = {
      ...profileTemplateVariables(context.profile),
      ...streakVariables(profileStats, event, now),
    };
    occurrences.push({
      event,
      idempotencyKey:
        progressIdempotencyKey(
          event,
          context.profile.uuid_profile,
          localDateKey(local),
          profileStats.current_streak,
        ),
      triggerSource: "scheduler",
      profileUuids: [context.profile.uuid_profile],
      variablesByProfile: new Map([
        [context.profile.uuid_profile, variables],
      ]),
      actionPayloadByProfile: new Map(),
      sourceEntityType: "profile",
      sourceEntityUuid: context.profile.uuid_profile,
    });
  }
  return occurrences;
}

export function domainEventOccurrence(
  event: NotificationEventRow,
  domainEvent: DomainEventRow,
  profiles: readonly ProfileRow[],
): AutomationOccurrence | null {
  if (!isActiveAutomation(event, new Date(domainEvent.occurred_at)) ||
    event.trigger_type !== "domain_event" ||
    event.trigger_key !== domainEvent.event_key) {
    return null;
  }
  const actionPayload = {
    ...(event.action_payload_template ?? {}),
  };
  if (event.action_type === "open_content_item" &&
    domainEvent.source_entity_type === "content_item") {
    actionPayload.uuid_content_item = domainEvent.source_entity_uuid;
  }
  const variablesByProfile = new Map<string, Record<string, unknown>>();
  const actionPayloadByProfile = new Map<string, Record<string, unknown>>();
  for (const profile of profiles) {
    variablesByProfile.set(profile.uuid_profile, {
      ...profileTemplateVariables(profile),
      ...contentVariables(domainEvent.payload, domainEvent.source_entity_uuid),
    });
    actionPayloadByProfile.set(
      profile.uuid_profile,
      renderObject(
        actionPayload,
        variablesByProfile.get(profile.uuid_profile)!,
      ) as Record<string, unknown>,
    );
  }
  return {
    event,
    idempotencyKey:
      `domain:${event.uuid_notification_event}:${domainEvent.uuid_notification_domain_event}`,
    triggerSource: "domain_event",
    profileUuids: profiles.map((profile) => profile.uuid_profile),
    variablesByProfile,
    actionPayloadByProfile,
    sourceEntityType: domainEvent.source_entity_type,
    sourceEntityUuid: domainEvent.source_entity_uuid,
  };
}

function intervalOccurrenceKey(
  event: NotificationEventRow,
  now: Date,
  _timezone: string,
): string | null {
  const startsAt = Date.parse(event.starts_at);
  if (!Number.isFinite(startsAt) || now.getTime() < startsAt) {
    return null;
  }
  const config = event.trigger_config ?? {};
  const value = configNumber(config, "interval_value", 0);
  const unit = configText(event, "interval_unit");
  const intervalMs = unit === "days"
    ? value * 24 * 60 * 60 * 1_000
    : value * 60 * 60 * 1_000;
  if (intervalMs <= 0) {
    return null;
  }
  const elapsed = now.getTime() - startsAt;
  const remainder = elapsed % intervalMs;
  if (remainder > 60_000) {
    return null;
  }
  const index = Math.floor(elapsed / intervalMs);
  return String(index);
}

function intervalIdempotencyKey(
  event: NotificationEventRow,
  occurrenceKey: string,
): string {
  const config = event.trigger_config ?? {};
  const startsAt = Date.parse(event.starts_at);
  const intervalValue = configNumber(config, "interval_value", 0);
  const intervalUnit = configText(event, "interval_unit");
  return [
    "schedule",
    event.uuid_notification_event,
    Number.isFinite(startsAt) ? String(startsAt) : event.starts_at,
    intervalValue,
    intervalUnit,
    occurrenceKey,
    "UTC",
  ].join(":");
}

function progressIdempotencyKey(
  event: NotificationEventRow,
  profileUuid: string,
  localDate: string,
  currentStreak: number,
): string {
  const config = event.trigger_config ?? {};
  const startsAt = Date.parse(event.starts_at);
  const generation = event.trigger_key === "progress.streak_reminder"
    ? [
      configText(event, "reminder_time"),
      configNumber(config, "min_streak", 1),
    ].join(":")
    : numberList(config.milestones).sort((a, b) => a - b).join(",");
  return [
    "progress",
    event.uuid_notification_event,
    profileUuid,
    localDate,
    currentStreak,
    Number.isFinite(startsAt) ? String(startsAt) : event.starts_at,
    generation,
  ].join(":");
}

function profileContexts(
  profiles: readonly ProfileRow[],
  devices: readonly NotificationDeviceRow[],
): Array<{ profile: ProfileRow; timezone: string }> {
  const byProfile = new Map<string, NotificationDeviceRow>();
  for (const device of devices) {
    const current = byProfile.get(device.uuid_profile);
    if (current === undefined ||
      device.registration_refreshed_at !== undefined &&
        (current.registration_refreshed_at === undefined ||
          (device.registration_refreshed_at ?? "") >
            (current.registration_refreshed_at ?? ""))) {
      byProfile.set(device.uuid_profile, device);
    }
  }
  return profiles.map((profile) => ({
    profile,
    timezone: validTimezone(byProfile.get(profile.uuid_profile)?.timezone),
  }));
}

function validTimezone(value: string | null | undefined): string {
  if (value === null || value === undefined || value.trim().length === 0) {
    return defaultTimezone;
  }
  try {
    new Intl.DateTimeFormat("en-US", { timeZone: value }).format();
    return value;
  } catch {
    return defaultTimezone;
  }
}

function localParts(date: Date, timezone: string) {
  const parts = new Intl.DateTimeFormat("en-US", {
    timeZone: timezone,
    year: "numeric",
    month: "2-digit",
    day: "2-digit",
    hour: "2-digit",
    minute: "2-digit",
    hourCycle: "h23",
    weekday: "short",
  }).formatToParts(date);
  const value = Object.fromEntries(
    parts.filter((part) => part.type !== "literal").map((part) => [
      part.type,
      part.value,
    ]),
  );
  const weekdayValues: Record<string, number> = {
    Mon: 1,
    Tue: 2,
    Wed: 3,
    Thu: 4,
    Fri: 5,
    Sat: 6,
    Sun: 7,
  };
  const weekday = weekdayValues[value.weekday] ?? 1;
  return {
    year: Number(value.year),
    month: Number(value.month),
    day: Number(value.day),
    hour: Number(value.hour),
    minute: Number(value.minute),
    weekday,
  };
}

function localDateKey(local: ReturnType<typeof localParts>): string {
  return `${local.year}-${pad(local.month)}-${pad(local.day)}`;
}

function contentVariables(
  payload: Record<string, unknown>,
  fallbackContentUuid = "",
) {
  return {
    content_title: payload.content_title ?? payload.titulo ?? "",
    content_subtitle: payload.content_subtitle ?? payload.subtitulo ?? "",
    content_type: payload.content_type ?? payload.tipo ?? "",
    content_description: payload.content_description ?? payload.descripcion ?? "",
    content_uuid: payload.content_uuid ?? payload.uuid_content_item ??
      fallbackContentUuid,
  };
}

function streakVariables(
  stats: StreakRow,
  event: NotificationEventRow,
  now: Date,
): Record<string, unknown> {
  const milestones = numberList((event.trigger_config ?? {}).milestones);
  const nextMilestone = milestones.find((value) => value > stats.current_streak) ??
    stats.current_streak;
  return {
    current_streak: stats.current_streak,
    longest_streak: stats.longest_streak,
    last_activity_date: stats.last_activity_date ?? now.toISOString().slice(0, 10),
    next_milestone: nextMilestone,
    remaining_to_milestone: Math.max(0, nextMilestone - stats.current_streak),
  };
}

function configText(event: NotificationEventRow, key: string): string {
  const value = (event.trigger_config ?? {})[key];
  return typeof value === "string" ? value : "";
}

function configNumber(
  config: Record<string, unknown>,
  key: string,
  fallback: number,
): number {
  const value = config[key];
  return typeof value === "number" && Number.isFinite(value) ? value : fallback;
}

function configNumberList(event: NotificationEventRow, key: string): number[] {
  return numberList((event.trigger_config ?? {})[key]);
}

function numberList(value: unknown): number[] {
  return Array.isArray(value)
    ? value.filter((entry): entry is number =>
      typeof entry === "number" && Number.isInteger(entry)
    )
    : [];
}

function pad(value: number): string {
  return String(value).padStart(2, "0");
}

function isRecord(value: unknown): value is Record<string, unknown> {
  return typeof value === "object" && value !== null && !Array.isArray(value);
}

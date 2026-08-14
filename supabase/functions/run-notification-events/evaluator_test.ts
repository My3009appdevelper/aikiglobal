import {
  assertEquals,
  assertStringIncludes,
} from "https://deno.land/std@0.224.0/assert/mod.ts";

import type {
  NotificationDeviceRow,
  ProfileRow,
} from "../dispatch-notification-event/domain.ts";
import type { NotificationEventRow } from "../dispatch-notification-event/service.ts";
import {
  domainEventDedupeKey,
  domainEventOccurrence,
  dueProgressOccurrences,
  dueScheduleOccurrences,
  renderObject,
  renderText,
} from "./evaluator.ts";

const now = new Date("2026-08-04T14:00:00.000Z");

Deno.test("schedule at_time groups profiles by their local timezone", () => {
  const event = eventRow({
    trigger_type: "schedule",
    trigger_key: "schedule.at_time",
    trigger_config: { local_time: "08:00", timezone_mode: "user_local" },
  });
  const profiles = [profile("profile-1"), profile("profile-2")];
  const devices = [device("profile-1", "America/Mexico_City"), device("profile-2", "UTC")];

  const occurrences = dueScheduleOccurrences(event, profiles, devices, now);

  assertEquals(occurrences.length, 1);
  assertEquals(occurrences[0].profileUuids, ["profile-1"]);
  assertStringIncludes(occurrences[0].idempotencyKey, "2026-08-04:08:00");
});

Deno.test("schedule interval creates one occurrence across timezones", () => {
  const event = eventRow({
    trigger_key: "schedule.interval",
    trigger_config: {
      interval_value: 12,
      interval_unit: "hours",
      timezone_mode: "user_local",
    },
    starts_at: "2026-08-04T02:00:00.000Z",
  });
  const profiles = [profile("profile-1"), profile("profile-2")];
  const devices = [
    device("profile-1", "America/Mexico_City"),
    device("profile-2", "UTC"),
  ];

  const occurrences = dueScheduleOccurrences(event, profiles, devices, now);

  assertEquals(occurrences.length, 1);
  assertEquals(occurrences[0].profileUuids, ["profile-1", "profile-2"]);
  assertStringIncludes(occurrences[0].idempotencyKey, "schedule:event-1:");
  assertStringIncludes(occurrences[0].idempotencyKey, ":1:UTC");
});

Deno.test("schedule interval uses a new idempotency generation after its start changes", () => {
  const firstEvent = eventRow({
    trigger_key: "schedule.interval",
    trigger_config: {
      interval_value: 12,
      interval_unit: "hours",
      timezone_mode: "user_local",
    },
    starts_at: "2026-08-04T02:00:00.000Z",
  });
  const editedEvent = {
    ...firstEvent,
    starts_at: "2026-08-04T02:00:30.000Z",
  };
  const profiles = [profile("profile-1")];
  const devices = [device("profile-1", "UTC")];

  const checkAt = new Date("2026-08-04T14:00:30.000Z");
  const first = dueScheduleOccurrences(firstEvent, profiles, devices, checkAt);
  const edited = dueScheduleOccurrences(editedEvent, profiles, devices, checkAt);

  assertEquals(first.length, 1);
  assertEquals(edited.length, 1);
  assertEquals(first[0].idempotencyKey === edited[0].idempotencyKey, false);
});

Deno.test("streak reminder uses a new idempotency generation after its time changes", () => {
  const firstEvent = eventRow({
    trigger_type: "progress_event",
    trigger_key: "progress.streak_reminder",
    trigger_config: {
      reminder_time: "08:00",
      min_streak: 1,
      timezone_mode: "user_local",
    },
  });
  const editedEvent = {
    ...firstEvent,
    trigger_config: {
      reminder_time: "09:00",
      min_streak: 1,
      timezone_mode: "user_local",
    },
  };
  const profiles = [profile("profile-1")];
  const devices = [device("profile-1", "UTC")];
  const stats = [{
    uuid_profile: "profile-1",
    current_streak: 2,
    longest_streak: 2,
    last_activity_date: "2026-08-04",
  }];
  const firstAtEight = dueProgressOccurrences(
    firstEvent,
    profiles,
    devices,
    stats,
    new Date("2026-08-04T08:00:00.000Z"),
  );
  const editedAtNine = dueProgressOccurrences(
    editedEvent,
    profiles,
    devices,
    stats,
    new Date("2026-08-04T09:00:00.000Z"),
  );

  assertEquals(firstAtEight.length, 1);
  assertEquals(editedAtNine.length, 1);
  assertEquals(
    firstAtEight[0].idempotencyKey === editedAtNine[0].idempotencyKey,
    false,
  );
});

Deno.test("progress milestone resolves the profile variables", () => {
  const event = eventRow({
    trigger_type: "progress_event",
    trigger_key: "progress.streak_milestone",
    category: "progress",
    trigger_config: {
      milestones: [3, 7],
      timezone_mode: "user_local",
    },
  });
  const occurrences = dueProgressOccurrences(
    event,
    [profile("profile-1")],
    [device("profile-1", "America/Mexico_City")],
    [{
      uuid_profile: "profile-1",
      current_streak: 3,
      longest_streak: 5,
      last_activity_date: "2026-08-04",
    }],
    now,
  );

  assertEquals(occurrences.length, 1);
  assertEquals(
    occurrences[0].variablesByProfile.get("profile-1")?.current_streak,
    3,
  );
});

Deno.test("domain content events override the content destination", () => {
  const event = eventRow({
    trigger_type: "domain_event",
    trigger_key: "content.published",
    action_type: "open_content_item",
    action_payload_template: { uuid_content_item: "old-content" },
  });
  const occurrence = domainEventOccurrence(
    event,
    {
      uuid_notification_domain_event: "domain-1",
      event_key: "content.published",
      source_entity_type: "content_item",
      source_entity_uuid: "new-content",
      payload: {
        content_title: "Meditación nueva",
        content_type: "meditacion",
      },
      occurred_at: "2026-08-04T13:59:00.000Z",
    },
    [profile("profile-1")],
  );

  assertEquals(
    occurrence?.actionPayloadByProfile.get("profile-1")?.uuid_content_item,
    "new-content",
  );
  assertEquals(
    occurrence?.variablesByProfile.get("profile-1")?.content_title,
    "Meditación nueva",
  );
});

Deno.test("automatic templates include the recipient profile variables", () => {
  const event = eventRow({
    trigger_type: "domain_event",
    trigger_key: "content.updated",
    title_template: "Hola {profile_name}",
    body_template: "{content_title} · {content_subtitle}",
  });
  const occurrence = domainEventOccurrence(
    event,
    {
      uuid_notification_domain_event: "domain-profile",
      event_key: "content.updated",
      source_entity_type: "content_item",
      source_entity_uuid: "content-1",
      payload: {
        content_title: "Dango",
        content_subtitle: "Vuelve a ti",
      },
      occurred_at: "2026-08-04T13:59:00.000Z",
    },
    [{
      ...profile("profile-1"),
      nombre: "Ana",
      email: "ana@aiki.com",
    }],
  );

  assertEquals(
    occurrence?.variablesByProfile.get("profile-1"),
    {
      profile_name: "Ana",
      profile_email: "ana@aiki.com",
      content_title: "Dango",
      content_subtitle: "Vuelve a ti",
      content_type: "",
      content_description: "",
      content_uuid: "content-1",
    },
  );
});

Deno.test("duplicate domain events with reordered payload keys share a key", () => {
  const first = {
    uuid_notification_domain_event: "domain-1",
    event_key: "content.updated",
    source_entity_type: "content_item",
    source_entity_uuid: "content-1",
    payload: { content_title: "Dango", content_type: "meditation" },
    occurred_at: "2026-08-04T13:59:00.000Z",
  };
  const second = {
    ...first,
    uuid_notification_domain_event: "domain-2",
    payload: { content_type: "meditation", content_title: "Dango" },
  };

  assertEquals(domainEventDedupeKey(first), domainEventDedupeKey(second));

  assertEquals(
    domainEventDedupeKey({
      ...first,
      payload: { ...first.payload, content_description: "Otra descripción" },
    }) === domainEventDedupeKey(first),
    false,
  );
});

Deno.test("template rendering handles nested payloads", () => {
  assertEquals(
    renderText("Meta {current_streak}: {missing}", { current_streak: 7 }),
    "Meta 7:",
  );
  assertEquals(
    renderObject({ text: "Día {current_streak}" }, { current_streak: 7 }),
    { text: "Día 7" },
  );
});

function profile(uuid: string): ProfileRow {
  return { uuid_profile: uuid, role: "user", activo: true, deleted_at: null };
}

function device(uuidProfile: string, timezone: string): NotificationDeviceRow {
  return {
    uuid_notification_device: `device-${uuidProfile}`,
    uuid_profile: uuidProfile,
    installation_id: null,
    fcm_token: `token-${uuidProfile}`,
    is_active: true,
    permission_status: "authorized",
    timezone,
    registration_refreshed_at: "2026-08-04T12:00:00.000Z",
    deleted_at: null,
  };
}

function eventRow(
  overrides: Partial<NotificationEventRow> = {},
): NotificationEventRow {
  return {
    uuid_notification_event: "event-1",
    title_template: "Título {content_title}",
    body_template: "Mensaje {current_streak}",
    category: "general",
    audience_type: "all_users",
    action_type: "none",
    action_payload_template: {},
    trigger_type: "schedule",
    trigger_key: "schedule.at_time",
    execution_mode: "per_occurrence",
    status: "active",
    starts_at: "2026-08-01T00:00:00.000Z",
    ends_at: null,
    deleted_at: null,
    trigger_config: { local_time: "08:00", timezone_mode: "user_local" },
    ...overrides,
  };
}

import 'package:aikiglobal/core/data/common/json_object_codec.dart';
import 'package:aikiglobal/core/data/local/app_database.dart';
import 'package:aikiglobal/core/data/sync/sync_mappers.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final eventJson = <String, dynamic>{
    'uuid_notification_event': 'event-1',
    'name': 'Nuevo contenido',
    'category': 'content',
    'title_template': 'Nuevo: {content_title}',
    'body_template': '{content_subtitle}',
    'trigger_type': 'domain_event',
    'trigger_key': 'content.published',
    'execution_mode': 'per_occurrence',
    'audience_type': 'all_users',
    'action_type': 'open_content_item',
    'action_payload_template': {
      'uuid_content_item': '{content_uuid}',
    },
    'trigger_config': {
      'interval_value': 12,
      'interval_unit': 'hours',
      'timezone_mode': 'user_local',
    },
    'starts_at': '2026-07-16T10:00:00.000Z',
    'ends_at': null,
    'status': 'active',
    'uuid_created_by_profile': 'profile-admin',
    'uuid_updated_by_profile': 'profile-admin',
    'created_at': '2026-07-16T09:00:00.000Z',
    'updated_at': '2026-07-16T10:00:00.000Z',
    'deleted_at': null,
  };

  final dispatchJson = <String, dynamic>{
    'uuid_notification_dispatch': 'dispatch-1',
    'uuid_notification_event': 'event-1',
    'trigger_source': 'domain_event',
    'uuid_triggered_by_profile': null,
    'source_entity_type': 'content_item',
    'source_entity_uuid': 'content-1',
    'idempotency_key': 'event-1:content-1',
    'title_snapshot': 'Nuevo contenido',
    'body_snapshot': 'Ya está disponible',
    'category_snapshot': 'content',
    'audience_type_snapshot': 'all_users',
    'action_type_snapshot': 'open_content_item',
    'action_payload_snapshot': {'uuid_content_item': 'content-1'},
    'status': 'completed',
    'target_profile_count': 10,
    'target_device_count': 8,
    'success_device_count': 7,
    'failure_device_count': 1,
    'invalid_token_count': 1,
    'started_at': '2026-07-16T10:00:00.000Z',
    'completed_at': '2026-07-16T10:00:03.000Z',
    'error_summary': null,
    'created_at': '2026-07-16T10:00:00.000Z',
    'updated_at': '2026-07-16T10:00:03.000Z',
    'deleted_at': null,
  };

  final inboxJson = <String, dynamic>{
    'uuid_notification_inbox': 'inbox-1',
    'uuid_notification_dispatch': 'dispatch-1',
    'uuid_profile': 'profile-1',
    'title': 'Nuevo contenido',
    'body': 'Ya está disponible',
    'category': 'content',
    'action_type': 'open_content_item',
    'action_payload': {'uuid_content_item': 'content-1'},
    'read_at': null,
    'opened_at': null,
    'created_at': '2026-07-16T10:00:00.000Z',
    'updated_at': '2026-07-16T10:00:00.000Z',
    'deleted_at': null,
  };

  test('maps notification event JSONB to Drift and app models', () {
    final companion = notificationEventRemoteToCompanion(eventJson);
    final model = notificationEventRemoteToApp(eventJson);

    expect(
      decodeJsonObject(companion.actionPayloadTemplateJson.value),
      {'uuid_content_item': '{content_uuid}'},
    );
    expect(companion.syncedAt.value, isNotNull);
    expect(model.actionPayloadTemplate, {
      'uuid_content_item': '{content_uuid}',
    });
    expect(model.triggerConfig, {
      'interval_value': 12,
      'interval_unit': 'hours',
      'timezone_mode': 'user_local',
    });
    expect(model.isActiveAt(DateTime.utc(2026, 7, 17)), isTrue);
  });

  test('notification event push excludes the local sync marker', () {
    final now = DateTime.utc(2026, 7, 16, 10);
    final event = LocalNotificationEvent(
      uuidNotificationEvent: 'event-1',
      name: 'Aviso',
      category: 'general',
      titleTemplate: 'Título',
      bodyTemplate: 'Mensaje',
      triggerType: 'manual',
      executionMode: 'once',
      audienceType: 'all',
      actionType: 'none',
      actionPayloadTemplateJson: '{}',
      triggerConfigJson: '{}',
      startsAt: now,
      status: 'draft',
      createdAt: now,
      updatedAt: now,
      syncedAt: now,
    );

    final remote = notificationEventToRemote(event);

    expect(remote['action_payload_template'], const <String, dynamic>{});
    expect(remote.containsKey('synced_at'), isFalse);
  });

  test('maps dispatch snapshots and aggregate counters', () {
    final companion = notificationDispatchRemoteToCompanion(dispatchJson);
    final model = notificationDispatchRemoteToApp(dispatchJson);

    expect(companion.successDeviceCount.value, 7);
    expect(companion.invalidTokenCount.value, 1);
    expect(model.actionPayloadSnapshot['uuid_content_item'], 'content-1');
    expect(model.isFinished, isTrue);
  });

  test('maps inbox snapshots and only emits mutable read state', () {
    final companion = notificationInboxRemoteToCompanion(inboxJson);
    final model = notificationInboxRemoteToApp(inboxJson);
    final readAt = DateTime.utc(2026, 7, 16, 11);
    final local = LocalNotificationInboxItem(
      uuidNotificationInbox: 'inbox-1',
      uuidNotificationDispatch: 'dispatch-1',
      uuidProfile: 'profile-1',
      title: 'Nuevo contenido',
      body: 'Ya está disponible',
      category: 'content',
      actionType: 'open_content_item',
      actionPayloadJson: encodeJsonObject({
        'uuid_content_item': 'content-1',
      }),
      readAt: readAt,
      createdAt: readAt,
      updatedAt: readAt,
    );

    final patch = notificationInboxReadStateToRemote(local);

    expect(companion.syncedAt.value, isNotNull);
    expect(model.isRead, isFalse);
    expect(model.actionPayload['uuid_content_item'], 'content-1');
    expect(patch, {'read_at': readAt.toIso8601String(), 'opened_at': null});
  });
}

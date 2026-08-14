import 'package:aikiglobal/core/data/local/app_database.dart';
import 'package:aikiglobal/core/data/local/daos/notification_dispatches_dao.dart';
import 'package:aikiglobal/core/data/local/daos/notification_events_dao.dart';
import 'package:aikiglobal/core/data/local/daos/notifications_inbox_dao.dart';
import 'package:aikiglobal/core/data/remote/services/notification_dispatches_remote_service.dart';
import 'package:aikiglobal/core/data/remote/services/notification_events_remote_service.dart';
import 'package:aikiglobal/core/data/remote/services/notifications_inbox_remote_service.dart';
import 'package:aikiglobal/core/data/sync/notification_dispatches_sync_service.dart';
import 'package:aikiglobal/core/data/sync/notification_events_sync_service.dart';
import 'package:aikiglobal/core/data/sync/notifications_inbox_sync_service.dart';
import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  late AppDatabase database;

  setUp(() {
    database = AppDatabase(executor: NativeDatabase.memory());
  });

  tearDown(() => database.close());

  test('notification events sync pushes pending local changes', () async {
    final dao = NotificationEventsDao(database);
    final service = _FakeNotificationEventsRemoteService();
    final sync = NotificationEventsSyncService(dao: dao, service: service);
    final now = DateTime.utc(2026, 7, 16, 10);
    await dao.upsertNotificationEvent(
      NotificationEventsTableCompanion.insert(
        uuidNotificationEvent: 'event-1',
        name: 'Aviso',
        category: 'general',
        titleTemplate: 'Título',
        bodyTemplate: 'Mensaje',
        triggerType: 'manual',
        executionMode: 'once',
        audienceType: 'all',
        actionType: 'none',
        startsAt: Value(now),
        createdAt: Value(now),
        updatedAt: Value(now),
        syncedAt: const Value(null),
      ),
    );

    await sync.sync();

    expect(service.upserts, hasLength(1));
    expect(service.upserts.single['uuid_notification_event'], 'event-1');
    expect(service.upserts.single.containsKey('synced_at'), isFalse);
    expect((await dao.getByUuid('event-1'))?.syncedAt, isNotNull);
  });

  test('notification dispatches sync is pull-only', () async {
    final dao = NotificationDispatchesDao(database);
    final service = _FakeNotificationDispatchesRemoteService();
    final sync = NotificationDispatchesSyncService(dao: dao, service: service);
    service.heads = [
      {
        'uuid_notification_dispatch': 'dispatch-1',
        'updated_at': '2026-07-16T11:00:00.000Z',
      },
    ];
    service.rows = [_dispatchRemoteRow()];

    await sync.pull();

    expect(service.requestedIds, ['dispatch-1']);
    expect(
      (await dao.getByUuid('dispatch-1'))?.titleSnapshot,
      'Contenido nuevo',
    );
    expect(service.writeAttempts, 0);
  });

  test('inbox sync only pushes read state for the requested profile', () async {
    final dao = NotificationsInboxDao(database);
    final service = _FakeNotificationsInboxRemoteService();
    final sync = NotificationsInboxSyncService(dao: dao, service: service);
    final now = DateTime.utc(2026, 7, 16, 12);
    await dao.upsertNotifications([
      _inboxCompanion(
        uuid: 'inbox-own',
        profileUuid: 'profile-1',
        updatedAt: now,
      ),
      _inboxCompanion(
        uuid: 'inbox-other',
        profileUuid: 'profile-2',
        updatedAt: now,
      ),
    ]);

    await sync.syncForProfile('profile-1');

    expect(service.updatedIds, ['inbox-own']);
    expect(service.upsertAttempts, 0);
    expect((await dao.getByUuid('inbox-own'))?.syncedAt, isNotNull);
    expect((await dao.getByUuid('inbox-other'))?.syncedAt, isNull);
  });

  test('inbox pull is explicitly filtered by profile', () async {
    final dao = NotificationsInboxDao(database);
    final service = _FakeNotificationsInboxRemoteService()
      ..heads = [
        {
          'uuid_notification_inbox': 'inbox-1',
          'updated_at': '2026-07-16T12:00:00.000Z',
        },
      ]
      ..rows = [_inboxRemoteRow()];
    final sync = NotificationsInboxSyncService(dao: dao, service: service);

    await sync.pullForProfile('profile-1');

    expect(service.headProfiles, ['profile-1']);
    expect(service.rowProfiles, ['profile-1']);
    expect((await dao.getByUuid('inbox-1'))?.uuidProfile, 'profile-1');
  });
}

class _FakeNotificationEventsRemoteService
    extends NotificationEventsRemoteService {
  _FakeNotificationEventsRemoteService() : super(supabase: _supabaseClient());

  final List<Map<String, dynamic>> upserts = [];

  @override
  Future<void> upsertOnline(Map<String, dynamic> data) async {
    upserts.add(Map<String, dynamic>.from(data));
  }

  @override
  Future<List<Map<String, dynamic>>> getHeadsOnline() async => [];
}

class _FakeNotificationDispatchesRemoteService
    extends NotificationDispatchesRemoteService {
  _FakeNotificationDispatchesRemoteService()
    : super(supabase: _supabaseClient());

  List<Map<String, dynamic>> heads = [];
  List<Map<String, dynamic>> rows = [];
  List<String> requestedIds = [];
  int writeAttempts = 0;

  @override
  Future<List<Map<String, dynamic>>> getHeadsOnline() async => heads;

  @override
  Future<List<Map<String, dynamic>>> getByIdsOnline(
    List<String> ids, {
    String? filterColumn,
    String selectColumns = '*',
  }) async {
    requestedIds = List.of(ids);
    return rows;
  }

  @override
  Future<void> upsertOnline(Map<String, dynamic> data) async {
    writeAttempts++;
  }
}

class _FakeNotificationsInboxRemoteService
    extends NotificationsInboxRemoteService {
  _FakeNotificationsInboxRemoteService() : super(supabase: _supabaseClient());

  List<Map<String, dynamic>> heads = [];
  List<Map<String, dynamic>> rows = [];
  final List<String> headProfiles = [];
  final List<String> rowProfiles = [];
  final List<String> updatedIds = [];
  int upsertAttempts = 0;

  @override
  Future<List<Map<String, dynamic>>> getHeadsForProfileOnline(
    String uuidProfile,
  ) async {
    headProfiles.add(uuidProfile);
    return heads;
  }

  @override
  Future<List<Map<String, dynamic>>> getByIdsForProfileOnline(
    String uuidProfile,
    List<String> ids,
  ) async {
    rowProfiles.add(uuidProfile);
    return rows;
  }

  @override
  Future<void> updateReadStateOnline(
    String uuidNotificationInbox, {
    required DateTime? readAt,
    required DateTime? openedAt,
  }) async {
    updatedIds.add(uuidNotificationInbox);
  }

  @override
  Future<void> upsertOnline(Map<String, dynamic> data) async {
    upsertAttempts++;
  }
}

SupabaseClient _supabaseClient() {
  return SupabaseClient('http://localhost:54321', 'test-anon-key');
}

NotificationsInboxTableCompanion _inboxCompanion({
  required String uuid,
  required String profileUuid,
  required DateTime updatedAt,
}) {
  return NotificationsInboxTableCompanion.insert(
    uuidNotificationInbox: uuid,
    uuidNotificationDispatch: 'dispatch-$uuid',
    uuidProfile: profileUuid,
    title: 'Aviso',
    body: 'Mensaje',
    category: 'general',
    actionType: 'none',
    readAt: Value(updatedAt),
    createdAt: Value(updatedAt),
    updatedAt: Value(updatedAt),
    syncedAt: const Value(null),
  );
}

Map<String, dynamic> _dispatchRemoteRow() {
  return {
    'uuid_notification_dispatch': 'dispatch-1',
    'uuid_notification_event': 'event-1',
    'trigger_source': 'domain_event',
    'idempotency_key': 'event-1:content-1',
    'title_snapshot': 'Contenido nuevo',
    'body_snapshot': 'Ya está disponible',
    'category_snapshot': 'content',
    'audience_type_snapshot': 'all_users',
    'action_type_snapshot': 'open_content_item',
    'action_payload_snapshot': {'uuid_content_item': 'content-1'},
    'status': 'completed',
    'target_profile_count': 1,
    'target_device_count': 1,
    'success_device_count': 1,
    'failure_device_count': 0,
    'invalid_token_count': 0,
    'created_at': '2026-07-16T10:00:00.000Z',
    'updated_at': '2026-07-16T11:00:00.000Z',
  };
}

Map<String, dynamic> _inboxRemoteRow() {
  return {
    'uuid_notification_inbox': 'inbox-1',
    'uuid_notification_dispatch': 'dispatch-1',
    'uuid_profile': 'profile-1',
    'title': 'Contenido nuevo',
    'body': 'Ya está disponible',
    'category': 'content',
    'action_type': 'open_content_item',
    'action_payload': {'uuid_content_item': 'content-1'},
    'read_at': null,
    'opened_at': null,
    'created_at': '2026-07-16T11:00:00.000Z',
    'updated_at': '2026-07-16T12:00:00.000Z',
  };
}

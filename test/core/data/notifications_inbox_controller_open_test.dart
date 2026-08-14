import 'package:aikiglobal/core/data/local/app_database.dart';
import 'package:aikiglobal/core/data/local/daos/notifications_inbox_dao.dart';
import 'package:aikiglobal/core/data/providers/notifications_inbox_controller.dart';
import 'package:aikiglobal/core/data/remote/services/notifications_inbox_remote_service.dart';
import 'package:aikiglobal/core/data/sync/notifications_inbox_sync_service.dart';
import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:async';

void main() {
  late AppDatabase database;
  late NotificationsInboxDao dao;

  setUp(() {
    database = AppDatabase(executor: NativeDatabase.memory());
    dao = NotificationsInboxDao(database);
  });

  tearDown(() async {
    await database.close();
  });

  test(
    'pulls the active profile and retries when the inbox UUID is missing',
    () async {
      final syncService = _PullingNotificationsInboxSyncService(
        inboxDao: dao,
        pulledItem: _inboxCompanion(
          uuid: 'inbox-remote',
          profileUuid: 'profile-1',
        ),
      );
      final controller = NotificationsInboxController(
        notificationsInboxDao: dao,
        syncService: syncService,
      );
      addTearDown(controller.dispose);
      await controller.loadForProfile('profile-1');

      final opened = await controller.openNotification('inbox-remote');
      await _waitUntil(() => !controller.isSyncing);

      expect(syncService.pulledProfiles, ['profile-1']);
      expect(opened?.uuidNotificationInbox, 'inbox-remote');
      expect(opened?.uuidProfile, 'profile-1');
      expect(opened?.readAt, isNotNull);
      expect(opened?.openedAt, isNotNull);
    },
  );

  test(
    'does not open or pull a local notification from another profile',
    () async {
      await dao.upsertNotification(
        _inboxCompanion(uuid: 'inbox-other', profileUuid: 'profile-2'),
      );
      final syncService = _PullingNotificationsInboxSyncService(
        inboxDao: dao,
        pulledItem: _inboxCompanion(
          uuid: 'inbox-other',
          profileUuid: 'profile-1',
        ),
      );
      final controller = NotificationsInboxController(
        notificationsInboxDao: dao,
        syncService: syncService,
      );
      addTearDown(controller.dispose);
      await controller.loadForProfile('profile-1');

      final opened = await controller.openNotification('inbox-other');

      expect(opened, isNull);
      expect(syncService.pulledProfiles, isEmpty);
      expect((await dao.getByUuid('inbox-other'))?.openedAt, isNull);
    },
  );

  test(
    'ignores a remote result from a profile that is no longer active',
    () async {
      final remote = _DelayedNotificationsInboxRemoteService();
      final controller = NotificationsInboxController(
        notificationsInboxDao: null,
        notificationsInboxRemoteService: remote,
      );
      addTearDown(controller.dispose);

      final first = controller.loadForProfile('profile-1');
      final second = controller.loadForProfile('profile-2');
      remote.complete('profile-2', [_remoteRow('inbox-2', 'profile-2')]);
      await second;
      remote.complete('profile-1', [_remoteRow('inbox-1', 'profile-1')]);
      await first;

      expect(controller.activeProfileUuid, 'profile-2');
      expect(controller.notifications.map((item) => item.uuidProfile), [
        'profile-2',
      ]);
    },
  );
}

Future<void> _waitUntil(bool Function() predicate) async {
  for (var attempt = 0; attempt < 100; attempt++) {
    if (predicate()) {
      return;
    }
    await Future<void>.delayed(const Duration(milliseconds: 1));
  }
  fail('La operación asíncrona no terminó a tiempo.');
}

NotificationsInboxTableCompanion _inboxCompanion({
  required String uuid,
  required String profileUuid,
}) {
  final now = DateTime.utc(2026, 7, 17, 12);
  return NotificationsInboxTableCompanion.insert(
    uuidNotificationInbox: uuid,
    uuidNotificationDispatch: 'dispatch-$uuid',
    uuidProfile: profileUuid,
    title: 'Aviso',
    body: 'Mensaje',
    category: 'general',
    actionType: 'open_home',
    createdAt: Value(now),
    updatedAt: Value(now),
    syncedAt: Value(now),
  );
}

class _PullingNotificationsInboxSyncService
    extends NotificationsInboxSyncService {
  _PullingNotificationsInboxSyncService({
    required NotificationsInboxDao inboxDao,
    required this.pulledItem,
  }) : _dao = inboxDao,
       super(
         dao: inboxDao,
         service: NotificationsInboxRemoteService(
           supabase: SupabaseClient('http://localhost', 'test-anon-key'),
         ),
       );

  final NotificationsInboxDao _dao;
  final NotificationsInboxTableCompanion pulledItem;
  final List<String> pulledProfiles = [];

  @override
  Future<void> pullForProfile(String uuidProfile) async {
    pulledProfiles.add(uuidProfile);
    await _dao.upsertNotification(pulledItem);
  }

  @override
  Future<void> syncForProfile(String uuidProfile) async {}
}

class _DelayedNotificationsInboxRemoteService
    extends NotificationsInboxRemoteService {
  _DelayedNotificationsInboxRemoteService()
    : super(supabase: SupabaseClient('http://localhost', 'test-anon-key'));

  final Map<String, Completer<List<Map<String, dynamic>>>> _requests = {};

  @override
  Future<List<Map<String, dynamic>>> getForProfileOnline(String uuidProfile) {
    return (_requests[uuidProfile] ??= Completer()).future;
  }

  void complete(String profileUuid, List<Map<String, dynamic>> rows) {
    (_requests[profileUuid] ??= Completer()).complete(rows);
  }
}

Map<String, dynamic> _remoteRow(String inboxUuid, String profileUuid) {
  const dispatchUuid = '11111111-1111-4111-8111-111111111111';
  final now = DateTime.utc(2026, 7, 17, 12).toIso8601String();
  return {
    'uuid_notification_inbox': inboxUuid,
    'uuid_notification_dispatch': dispatchUuid,
    'uuid_profile': profileUuid,
    'title': 'Aviso',
    'body': 'Mensaje',
    'category': 'general',
    'action_type': 'none',
    'action_payload': <String, dynamic>{},
    'read_at': null,
    'opened_at': null,
    'created_at': now,
    'updated_at': now,
    'deleted_at': null,
    'synced_at': now,
  };
}

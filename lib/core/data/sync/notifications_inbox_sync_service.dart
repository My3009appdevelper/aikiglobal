import 'dart:async';
import 'dart:developer';
import 'dart:io';

import '../common/base_pull_sync.dart';
import '../local/app_database.dart';
import '../local/daos/notifications_inbox_dao.dart';
import '../remote/services/notifications_inbox_remote_service.dart';
import 'sync_mappers.dart';

class NotificationsInboxSyncService {
  NotificationsInboxSyncService({
    required NotificationsInboxDao dao,
    required NotificationsInboxRemoteService service,
  }) : _dao = dao,
       _service = service;

  final NotificationsInboxDao _dao;
  final NotificationsInboxRemoteService _service;

  Future<void> pullForProfile(String uuidProfile) {
    final profileUuid = _requiredProfileUuid(uuidProfile);
    return BasePullSync<
          LocalNotificationInboxItem,
          NotificationsInboxTableCompanion
        >(
          idColumnRemote: 'uuid_notification_inbox',
          updatedAtColumnRemote: _service.updatedAtColumn,
          getRemoteHeads: () => _service.getHeadsForProfileOnline(profileUuid),
          getRemoteRows: (ids) =>
              _service.getByIdsForProfileOnline(profileUuid, ids),
          getAllLocal: () => _dao.getAllForProfile(profileUuid),
          upsertBatchLocal: _dao.upsertNotifications,
          getId: (row) => row.uuidNotificationInbox,
          getUpdatedAt: (row) => row.updatedAt,
          getSyncedAt: (row) => row.syncedAt,
          remoteToCompanion: notificationInboxRemoteToCompanion,
          logTag: 'NotificationsInboxSyncService.$profileUuid',
        )
        .pull();
  }

  Future<void> pushForProfile(String uuidProfile) async {
    final profileUuid = _requiredProfileUuid(uuidProfile);
    final pending = await _dao.getPendingSyncForProfile(profileUuid);

    for (final item in pending) {
      try {
        await _service.updateReadStateOnline(
          item.uuidNotificationInbox,
          readAt: item.readAt,
          openedAt: item.openedAt,
        );
        await _dao.markSyncedByUuid(item.uuidNotificationInbox);
      } catch (error) {
        if (error is TimeoutException || error is SocketException) {
          log(
            'push skipped id=${item.uuidNotificationInbox} error=$error',
            name: 'NotificationsInboxSyncService.$profileUuid',
          );
          continue;
        }
        rethrow;
      }
    }
  }

  Future<void> syncForProfile(String uuidProfile) async {
    await pushForProfile(uuidProfile);
    await pullForProfile(uuidProfile);
  }

  String _requiredProfileUuid(String value) {
    final clean = value.trim();
    if (clean.isEmpty) {
      throw ArgumentError('El perfil del inbox no puede estar vacío.');
    }
    return clean;
  }
}

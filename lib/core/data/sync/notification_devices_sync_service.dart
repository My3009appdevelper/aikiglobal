import '../common/base_sync.dart';
import '../local/app_database.dart';
import '../local/daos/notification_devices_dao.dart';
import '../remote/services/notification_devices_remote_service.dart';
import 'sync_mappers.dart';

class NotificationDevicesSyncService
    extends
        BaseSync<LocalNotificationDevice, NotificationDevicesTableCompanion> {
  NotificationDevicesSyncService({
    required NotificationDevicesDao dao,
    required NotificationDevicesRemoteService service,
  }) : _dao = dao,
       _service = service,
       super(
         service: service,
         idColumnRemote: 'uuid_notification_device',
         getAllLocal: dao.listAll,
         getPendingLocal: dao.getPendingSync,
         upsertBatchLocal: dao.upsertBatch,
         markSyncedLocal: (id) async {
           await dao.markSyncedByUuid(id);
         },
         getId: (row) => row.uuidNotificationDevice,
         getUpdatedAt: (row) => row.updatedAt,
         getSyncedAt: (row) => row.syncedAt,
         localToRemote: notificationDeviceToRemote,
         remoteToCompanion: notificationDeviceRemoteToCompanion,
         logTag: 'NotificationDevicesSyncService',
       );

  final NotificationDevicesDao _dao;
  final NotificationDevicesRemoteService _service;

  Future<void> pullForProfile(String uuidProfile) {
    return _forProfile(uuidProfile).pull();
  }

  Future<void> syncForProfile(String uuidProfile) {
    return _forProfile(uuidProfile).sync();
  }

  BaseSync<LocalNotificationDevice, NotificationDevicesTableCompanion>
  _forProfile(String uuidProfile) {
    final cleanProfile = uuidProfile.trim();

    return BaseSync<LocalNotificationDevice, NotificationDevicesTableCompanion>(
      service: _service,
      idColumnRemote: 'uuid_notification_device',
      getAllLocal: () => _dao.getAllForProfile(cleanProfile),
      getPendingLocal: () => _dao.getPendingSyncForProfile(cleanProfile),
      upsertBatchLocal: _dao.upsertBatch,
      markSyncedLocal: (id) async {
        await _dao.markSyncedByUuid(id);
      },
      getId: (row) => row.uuidNotificationDevice,
      getUpdatedAt: (row) => row.updatedAt,
      getSyncedAt: (row) => row.syncedAt,
      localToRemote: notificationDeviceToRemote,
      remoteToCompanion: notificationDeviceRemoteToCompanion,
      logTag: 'NotificationDevicesSyncService.$cleanProfile',
    );
  }
}

import '../common/base_pull_sync.dart';
import '../local/app_database.dart';
import '../local/daos/notification_dispatches_dao.dart';
import '../remote/services/notification_dispatches_remote_service.dart';
import 'sync_mappers.dart';

class NotificationDispatchesSyncService {
  NotificationDispatchesSyncService({
    required NotificationDispatchesDao dao,
    required NotificationDispatchesRemoteService service,
  }) : _pullSync =
           BasePullSync<
             LocalNotificationDispatch,
             NotificationDispatchesTableCompanion
           >(
             idColumnRemote: 'uuid_notification_dispatch',
             updatedAtColumnRemote: service.updatedAtColumn,
             getRemoteHeads: service.getHeadsOnline,
             getRemoteRows: (ids) => service.getByIdsOnline(
               ids,
               filterColumn: 'uuid_notification_dispatch',
             ),
             getAllLocal: dao.listAll,
             upsertBatchLocal: dao.upsertNotificationDispatches,
             getId: (row) => row.uuidNotificationDispatch,
             getUpdatedAt: (row) => row.updatedAt,
             getSyncedAt: (row) => row.syncedAt,
             remoteToCompanion: notificationDispatchRemoteToCompanion,
             logTag: 'NotificationDispatchesSyncService',
           );

  final BasePullSync<
    LocalNotificationDispatch,
    NotificationDispatchesTableCompanion
  >
  _pullSync;

  Future<void> pull() => _pullSync.pull();
}

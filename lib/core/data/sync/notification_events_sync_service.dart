import '../common/base_sync.dart';
import '../local/app_database.dart';
import '../local/daos/notification_events_dao.dart';
import '../remote/services/notification_events_remote_service.dart';
import 'sync_mappers.dart';

class NotificationEventsSyncService
    extends BaseSync<LocalNotificationEvent, NotificationEventsTableCompanion> {
  NotificationEventsSyncService({
    required NotificationEventsDao dao,
    required NotificationEventsRemoteService service,
  }) : super(
         service: service,
         idColumnRemote: 'uuid_notification_event',
         getAllLocal: dao.listAll,
         getPendingLocal: dao.getPendingSync,
         upsertBatchLocal: dao.upsertNotificationEvents,
         markSyncedLocal: (id) async {
           await dao.markSyncedByUuid(id);
         },
         getId: (row) => row.uuidNotificationEvent,
         getUpdatedAt: (row) => row.updatedAt,
         getSyncedAt: (row) => row.syncedAt,
         localToRemote: notificationEventToRemote,
         remoteToCompanion: notificationEventRemoteToCompanion,
         logTag: 'NotificationEventsSyncService',
       );
}

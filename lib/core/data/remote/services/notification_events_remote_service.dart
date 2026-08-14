import '../../common/base_service.dart';
import '../supabase_tables.dart';

class NotificationEventsRemoteService extends BaseService {
  NotificationEventsRemoteService({super.supabase})
    : super(
        table: SupabaseTables.notificationEvents,
        idColumn: 'uuid_notification_event',
        headSelect: 'uuid_notification_event, updated_at',
        onConflict: 'uuid_notification_event',
        logTag: 'NotificationEventsRemoteService',
      );
}

import '../../common/base_service.dart';
import '../supabase_tables.dart';

class NotificationDispatchesRemoteService extends BaseService {
  NotificationDispatchesRemoteService({super.supabase})
    : super(
        table: SupabaseTables.notificationDispatches,
        idColumn: 'uuid_notification_dispatch',
        headSelect: 'uuid_notification_dispatch, updated_at',
        logTag: 'NotificationDispatchesRemoteService',
      );

  Future<List<Map<String, dynamic>>> getRecentOnline({int? limit}) async {
    final rows = await selectPaginated(
      '*',
      apply: (query) => query.isFilter('deleted_at', null),
      orderByColumn: 'created_at',
      ascending: false,
    );
    if (limit == null || rows.length <= limit) {
      return rows;
    }
    return rows.take(limit).toList(growable: false);
  }

  Future<List<Map<String, dynamic>>> getForEventOnline(
    String uuidNotificationEvent,
  ) {
    return selectPaginated(
      '*',
      apply: (query) => query
          .eq('uuid_notification_event', uuidNotificationEvent.trim())
          .isFilter('deleted_at', null),
      orderByColumn: 'created_at',
      ascending: false,
    );
  }
}

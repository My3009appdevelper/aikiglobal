import '../../common/base_service.dart';
import '../supabase_tables.dart';

class NotificationsInboxRemoteService extends BaseService {
  NotificationsInboxRemoteService({super.supabase})
    : super(
        table: SupabaseTables.notificationsInbox,
        idColumn: 'uuid_notification_inbox',
        headSelect: 'uuid_notification_inbox, updated_at',
        logTag: 'NotificationsInboxRemoteService',
      );

  Future<List<Map<String, dynamic>>> getForProfileOnline(String uuidProfile) {
    return selectPaginated(
      '*',
      apply: (query) => query
          .eq('uuid_profile', uuidProfile.trim())
          .isFilter('deleted_at', null),
      orderByColumn: 'created_at',
      ascending: false,
    );
  }

  Future<List<Map<String, dynamic>>> getHeadsForProfileOnline(
    String uuidProfile,
  ) {
    return selectPaginated(
      headSelect,
      apply: (query) => query.eq('uuid_profile', uuidProfile.trim()),
      ascending: true,
    );
  }

  Future<List<Map<String, dynamic>>> getByIdsForProfileOnline(
    String uuidProfile,
    List<String> ids,
  ) async {
    if (ids.isEmpty) {
      return const [];
    }

    final rows = <Map<String, dynamic>>[];
    for (var index = 0; index < ids.length; index += idsChunk) {
      final end = index + idsChunk > ids.length ? ids.length : index + idsChunk;
      final chunk = ids.sublist(index, end);
      rows.addAll(
        await selectPaginated(
          '*',
          apply: (query) => query
              .eq('uuid_profile', uuidProfile.trim())
              .inFilter(idColumn, chunk),
          ascending: true,
        ),
      );
    }
    return rows;
  }

  Future<void> updateReadStateOnline(
    String uuidNotificationInbox, {
    required DateTime? readAt,
    required DateTime? openedAt,
  }) {
    return updateOnlineById(uuidNotificationInbox.trim(), {
      'read_at': readAt == null ? null : isoUtc(readAt),
      'opened_at': openedAt == null ? null : isoUtc(openedAt),
    }, touchUpdatedAt: false);
  }
}

import 'package:drift/drift.dart';

import '../../common/base_dao.dart';
import '../app_database.dart';

class NotificationsInboxDao
    extends BaseDao<$NotificationsInboxTableTable, LocalNotificationInboxItem> {
  NotificationsInboxDao(super.db) : super(table: db.notificationsInboxTable);

  Future<LocalNotificationInboxItem?> getByUuid(
    String uuidNotificationInbox,
  ) {
    return getSingleWhere(
      (table) =>
          table.uuidNotificationInbox.equals(uuidNotificationInbox.trim()),
    );
  }

  Future<List<LocalNotificationInboxItem>> getForProfile(String uuidProfile) {
    return listWhere(
      where: (table) =>
          table.uuidProfile.equals(uuidProfile.trim()) &
          table.deletedAt.isNull(),
      orderBy: [
        (table) => OrderingTerm.desc(table.createdAt),
        (table) => OrderingTerm.desc(table.uuidNotificationInbox),
      ],
    );
  }

  Future<List<LocalNotificationInboxItem>> getAllForProfile(
    String uuidProfile,
  ) {
    return listWhere(
      where: (table) => table.uuidProfile.equals(uuidProfile.trim()),
      orderBy: [
        (table) => OrderingTerm.desc(table.createdAt),
        (table) => OrderingTerm.desc(table.uuidNotificationInbox),
      ],
    );
  }

  Stream<List<LocalNotificationInboxItem>> watchForProfile(
    String uuidProfile,
  ) {
    return watchWhere(
      where: (table) =>
          table.uuidProfile.equals(uuidProfile.trim()) &
          table.deletedAt.isNull(),
      orderBy: [
        (table) => OrderingTerm.desc(table.createdAt),
        (table) => OrderingTerm.desc(table.uuidNotificationInbox),
      ],
    );
  }

  Future<void> upsertNotification(NotificationsInboxTableCompanion item) {
    return upsertOne(item);
  }

  Future<void> upsertNotifications(
    List<NotificationsInboxTableCompanion> items,
  ) {
    return upsertBatch(items);
  }

  Future<int> markOpened(String uuidNotificationInbox) async {
    final cleanUuid = uuidNotificationInbox.trim();
    final current = await getByUuid(cleanUuid);
    if (current == null) {
      return 0;
    }
    if (current.readAt != null && current.openedAt != null) {
      return 0;
    }

    final now = nowUtc();
    return writeWhere(
      where: (table) => table.uuidNotificationInbox.equals(cleanUuid),
      companion: NotificationsInboxTableCompanion(
        readAt: Value(current.readAt ?? now),
        openedAt: Value(current.openedAt ?? now),
        updatedAt: Value(now),
        syncedAt: const Value(null),
      ),
    );
  }

  Future<int> markAllRead(String uuidProfile) {
    return writeWhereNow(
      where: (table) =>
          table.uuidProfile.equals(uuidProfile.trim()) &
          table.readAt.isNull() &
          table.deletedAt.isNull(),
      patch: (now) => NotificationsInboxTableCompanion(
        readAt: Value(now),
        updatedAt: Value(now),
        syncedAt: const Value(null),
      ),
    );
  }

  Future<List<LocalNotificationInboxItem>> getPendingSyncForProfile(
    String uuidProfile,
  ) {
    return listWhere(
      where: (table) {
        final pending =
            table.syncedAt.isNull() |
            table.syncedAt.isSmallerThan(table.updatedAt);
        return table.uuidProfile.equals(uuidProfile.trim()) & pending;
      },
    );
  }

  Future<int> markSyncedByUuid(
    String uuidNotificationInbox, {
    DateTime? syncedAt,
  }) {
    return writeWhere(
      where: (table) =>
          table.uuidNotificationInbox.equals(uuidNotificationInbox.trim()),
      companion: NotificationsInboxTableCompanion(
        syncedAt: Value(syncedAt?.toUtc() ?? nowUtc()),
      ),
    );
  }
}

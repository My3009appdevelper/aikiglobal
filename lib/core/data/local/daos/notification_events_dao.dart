import 'package:drift/drift.dart';

import '../../common/base_dao.dart';
import '../app_database.dart';

class NotificationEventsDao
    extends BaseDao<$NotificationEventsTableTable, LocalNotificationEvent> {
  NotificationEventsDao(super.db) : super(table: db.notificationEventsTable);

  Future<LocalNotificationEvent?> getByUuid(String uuidNotificationEvent) {
    return getSingleWhere(
      (table) =>
          table.uuidNotificationEvent.equals(uuidNotificationEvent.trim()),
    );
  }

  Future<List<LocalNotificationEvent>> getAllNotDeleted() {
    return listNotDeleted(
      deletedAt: (table) => table.deletedAt,
      orderBy: [
        (table) => OrderingTerm.desc(table.startsAt),
        (table) => OrderingTerm.desc(table.updatedAt),
      ],
    );
  }

  Stream<List<LocalNotificationEvent>> watchAllNotDeleted() {
    return watchNotDeleted(
      deletedAt: (table) => table.deletedAt,
      orderBy: [
        (table) => OrderingTerm.desc(table.startsAt),
        (table) => OrderingTerm.desc(table.updatedAt),
      ],
    );
  }

  Future<void> upsertNotificationEvent(
    NotificationEventsTableCompanion event,
  ) {
    return upsertOne(event);
  }

  Future<void> upsertNotificationEvents(
    List<NotificationEventsTableCompanion> events,
  ) {
    return upsertBatch(events);
  }

  Future<int> softDeleteByUuid(String uuidNotificationEvent) {
    return softDelete(
      byId: (table) =>
          table.uuidNotificationEvent.equals(uuidNotificationEvent.trim()),
      patch: (now) => NotificationEventsTableCompanion(
        status: const Value('cancelled'),
        deletedAt: Value(now),
        updatedAt: Value(now),
        syncedAt: const Value(null),
      ),
    );
  }

  Future<List<LocalNotificationEvent>> getPendingSync() {
    return listPendingSync(
      syncedAt: (table) => table.syncedAt,
      updatedAt: (table) => table.updatedAt,
      deletedAt: (table) => table.deletedAt,
    );
  }

  Future<int> markSyncedByUuid(
    String uuidNotificationEvent, {
    DateTime? syncedAt,
  }) {
    return writeWhere(
      where: (table) =>
          table.uuidNotificationEvent.equals(uuidNotificationEvent.trim()),
      companion: NotificationEventsTableCompanion(
        syncedAt: Value(syncedAt?.toUtc() ?? nowUtc()),
      ),
    );
  }
}

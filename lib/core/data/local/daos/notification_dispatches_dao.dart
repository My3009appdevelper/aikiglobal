import 'package:drift/drift.dart';

import '../../common/base_dao.dart';
import '../app_database.dart';

class NotificationDispatchesDao
    extends
        BaseDao<
          $NotificationDispatchesTableTable,
          LocalNotificationDispatch
        > {
  NotificationDispatchesDao(super.db)
    : super(table: db.notificationDispatchesTable);

  Future<LocalNotificationDispatch?> getByUuid(
    String uuidNotificationDispatch,
  ) {
    return getSingleWhere(
      (table) => table.uuidNotificationDispatch.equals(
        uuidNotificationDispatch.trim(),
      ),
    );
  }

  Future<LocalNotificationDispatch?> getByIdempotencyKey(
    String idempotencyKey,
  ) {
    return getSingleWhere(
      (table) => table.idempotencyKey.equals(idempotencyKey.trim()),
    );
  }

  Future<List<LocalNotificationDispatch>> getAllNotDeleted({
    int? limit,
    int? offset,
  }) {
    return listWhere(
      where: (table) => table.deletedAt.isNull(),
      orderBy: [
        (table) => OrderingTerm.desc(table.createdAt),
        (table) => OrderingTerm.desc(table.uuidNotificationDispatch),
      ],
      limit: limit,
      offset: offset,
    );
  }

  Future<List<LocalNotificationDispatch>> getByEvent(
    String uuidNotificationEvent,
  ) {
    return listWhere(
      where: (table) =>
          table.uuidNotificationEvent.equals(uuidNotificationEvent.trim()) &
          table.deletedAt.isNull(),
      orderBy: [
        (table) => OrderingTerm.desc(table.createdAt),
        (table) => OrderingTerm.desc(table.uuidNotificationDispatch),
      ],
    );
  }

  Stream<List<LocalNotificationDispatch>> watchRecent({int? limit}) {
    return watchWhere(
      where: (table) => table.deletedAt.isNull(),
      orderBy: [
        (table) => OrderingTerm.desc(table.createdAt),
        (table) => OrderingTerm.desc(table.uuidNotificationDispatch),
      ],
      limit: limit,
    );
  }

  Stream<List<LocalNotificationDispatch>> watchForEvent(
    String uuidNotificationEvent,
  ) {
    return watchWhere(
      where: (table) =>
          table.uuidNotificationEvent.equals(uuidNotificationEvent.trim()) &
          table.deletedAt.isNull(),
      orderBy: [
        (table) => OrderingTerm.desc(table.createdAt),
        (table) => OrderingTerm.desc(table.uuidNotificationDispatch),
      ],
    );
  }

  Future<void> upsertNotificationDispatch(
    NotificationDispatchesTableCompanion dispatch,
  ) async {
    await _validateIdempotency(dispatch);
    await upsertOne(dispatch);
  }

  Future<void> upsertNotificationDispatches(
    List<NotificationDispatchesTableCompanion> dispatches,
  ) async {
    for (final dispatch in dispatches) {
      await _validateIdempotency(dispatch);
    }
    await upsertBatch(dispatches);
  }

  Future<int> markSyncedByUuid(
    String uuidNotificationDispatch, {
    DateTime? syncedAt,
  }) {
    return writeWhere(
      where: (table) => table.uuidNotificationDispatch.equals(
        uuidNotificationDispatch.trim(),
      ),
      companion: NotificationDispatchesTableCompanion(
        syncedAt: Value(syncedAt?.toUtc() ?? nowUtc()),
      ),
    );
  }

  Future<void> _validateIdempotency(
    NotificationDispatchesTableCompanion dispatch,
  ) async {
    if (!dispatch.idempotencyKey.present ||
        !dispatch.uuidNotificationDispatch.present) {
      return;
    }

    final existing = await getByIdempotencyKey(dispatch.idempotencyKey.value);
    if (existing != null &&
        existing.uuidNotificationDispatch !=
            dispatch.uuidNotificationDispatch.value) {
      throw StateError('La llave de idempotencia ya está registrada.');
    }
  }
}

import 'package:drift/drift.dart';

import '../../common/base_dao.dart';
import '../app_database.dart';

class WellnessDailyLogsDao
    extends BaseDao<$WellnessDailyLogsTableTable, LocalWellnessDailyLog> {
  // ignore: use_super_parameters
  WellnessDailyLogsDao(AppDatabase db)
    : super(db, table: db.wellnessDailyLogsTable);

  Future<LocalWellnessDailyLog?> getByUuid(String uuidDailyLog) {
    return getSingleWhere(
      (table) => table.uuidDailyLog.equals(uuidDailyLog.trim()),
    );
  }

  Future<LocalWellnessDailyLog?> getByProfileAndDate(
    String uuidProfile,
    String fecha,
  ) {
    final cleanProfile = uuidProfile.trim();
    final cleanDate = fecha.trim();

    return getSingleWhere(
      (table) =>
          table.uuidProfile.equals(cleanProfile) &
          table.fecha.equals(cleanDate) &
          table.deletedAt.isNull(),
    );
  }

  Future<List<LocalWellnessDailyLog>> getForProfile(String uuidProfile) {
    final cleanProfile = uuidProfile.trim();

    return listWhere(
      where: (table) =>
          table.uuidProfile.equals(cleanProfile) & table.deletedAt.isNull(),
      orderBy: [
        (table) => OrderingTerm.desc(table.fecha),
        (table) => OrderingTerm.desc(table.updatedAt),
      ],
    );
  }

  Future<List<LocalWellnessDailyLog>> getAllForProfile(
    String uuidProfile, {
    bool includeDeleted = true,
  }) {
    final cleanProfile = uuidProfile.trim();

    return listWhere(
      where: (table) {
        final base = table.uuidProfile.equals(cleanProfile);

        if (includeDeleted) {
          return base;
        }

        return base & table.deletedAt.isNull();
      },
      orderBy: [
        (table) => OrderingTerm.desc(table.fecha),
        (table) => OrderingTerm.desc(table.updatedAt),
      ],
    );
  }

  Stream<List<LocalWellnessDailyLog>> watchForProfile(String uuidProfile) {
    final cleanProfile = uuidProfile.trim();

    return watchWhere(
      where: (table) =>
          table.uuidProfile.equals(cleanProfile) & table.deletedAt.isNull(),
      orderBy: [
        (table) => OrderingTerm.desc(table.fecha),
        (table) => OrderingTerm.desc(table.updatedAt),
      ],
    );
  }

  Future<void> upsertDailyLog(WellnessDailyLogsTableCompanion log) {
    return upsertOne(log);
  }

  Future<void> upsertDailyLogs(List<WellnessDailyLogsTableCompanion> logs) {
    return upsertBatch(logs);
  }

  Future<int> updatePartialByUuid(
    String uuidDailyLog,
    WellnessDailyLogsTableCompanion patch,
  ) {
    return updatePartialById(
      byId: (table) => table.uuidDailyLog.equals(uuidDailyLog.trim()),
      patch: patch,
    );
  }

  Future<int> updatePartialByUuidNow(
    String uuidDailyLog,
    WellnessDailyLogsTableCompanion Function(DateTime nowUtc) patch,
  ) {
    return updatePartialByIdNow(
      byId: (table) => table.uuidDailyLog.equals(uuidDailyLog.trim()),
      patch: patch,
    );
  }

  Future<int> softDeleteByUuid(String uuidDailyLog) {
    return softDelete(
      byId: (table) => table.uuidDailyLog.equals(uuidDailyLog.trim()),
      patch: (now) => WellnessDailyLogsTableCompanion(
        deletedAt: Value(now),
        updatedAt: Value(now),
      ),
    );
  }

  Future<DateTime?> getLatestUpdatedAt({bool includeDeleted = false}) {
    return latestUpdatedAt(
      updatedAt: (table) => table.updatedAt,
      deletedAt: (table) => table.deletedAt,
      includeDeleted: includeDeleted,
    );
  }

  Future<List<LocalWellnessDailyLog>> getPendingSync() {
    return listPendingSync(
      syncedAt: (table) => table.syncedAt,
      updatedAt: (table) => table.updatedAt,
      deletedAt: (table) => table.deletedAt,
    );
  }

  Future<List<LocalWellnessDailyLog>> getPendingSyncForProfile(
    String uuidProfile,
  ) {
    final cleanProfile = uuidProfile.trim();

    return listWhere(
      where: (table) {
        final pending =
            table.syncedAt.isNull() |
            table.syncedAt.isSmallerThan(table.updatedAt);

        return table.uuidProfile.equals(cleanProfile) & pending;
      },
      orderBy: [
        (table) => OrderingTerm.desc(table.updatedAt),
        (table) => OrderingTerm.asc(table.uuidDailyLog),
      ],
    );
  }

  Future<int> markSyncedByUuid(String uuidDailyLog, {DateTime? syncedAt}) {
    final now = syncedAt ?? nowUtc();

    return writeWhere(
      where: (table) => table.uuidDailyLog.equals(uuidDailyLog.trim()),
      companion: WellnessDailyLogsTableCompanion(syncedAt: Value(now)),
    );
  }
}

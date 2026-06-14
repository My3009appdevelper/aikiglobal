import 'package:drift/drift.dart';

import '../../common/base_dao.dart';
import '../app_database.dart';

class WellnessProfileStatsDao
    extends
        BaseDao<$WellnessProfileStatsTableTable, LocalWellnessProfileStats> {
  // ignore: use_super_parameters
  WellnessProfileStatsDao(AppDatabase db)
    : super(db, table: db.wellnessProfileStatsTable);

  Future<LocalWellnessProfileStats?> getByProfile(String uuidProfile) {
    return getSingleWhere(
      (table) => table.uuidProfile.equals(uuidProfile.trim()),
    );
  }

  Future<List<LocalWellnessProfileStats>> getAllForProfile(String uuidProfile) {
    final cleanProfile = uuidProfile.trim();

    return listWhere(where: (table) => table.uuidProfile.equals(cleanProfile));
  }

  Stream<LocalWellnessProfileStats?> watchByProfile(String uuidProfile) {
    final cleanProfile = uuidProfile.trim();

    return (select(table)
          ..where((table) => table.uuidProfile.equals(cleanProfile)))
        .watchSingleOrNull();
  }

  Future<void> upsertStats(WellnessProfileStatsTableCompanion stats) {
    return upsertOne(stats);
  }

  Future<void> upsertStatsBatch(
    List<WellnessProfileStatsTableCompanion> stats,
  ) {
    return upsertBatch(stats);
  }

  Future<int> updatePartialByProfile(
    String uuidProfile,
    WellnessProfileStatsTableCompanion patch,
  ) {
    return updatePartialById(
      byId: (table) => table.uuidProfile.equals(uuidProfile.trim()),
      patch: patch,
    );
  }

  Future<int> updatePartialByProfileNow(
    String uuidProfile,
    WellnessProfileStatsTableCompanion Function(DateTime nowUtc) patch,
  ) {
    return updatePartialByIdNow(
      byId: (table) => table.uuidProfile.equals(uuidProfile.trim()),
      patch: patch,
    );
  }

  Future<DateTime?> getLatestUpdatedAt() {
    return latestUpdatedAt(updatedAt: (table) => table.updatedAt);
  }

  Future<List<LocalWellnessProfileStats>> getPendingSync() {
    return listPendingSync(
      syncedAt: (table) => table.syncedAt,
      updatedAt: (table) => table.updatedAt,
    );
  }

  Future<List<LocalWellnessProfileStats>> getPendingSyncForProfile(
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
    );
  }

  Future<int> markSyncedByProfile(String uuidProfile, {DateTime? syncedAt}) {
    final now = syncedAt ?? nowUtc();

    return writeWhere(
      where: (table) => table.uuidProfile.equals(uuidProfile.trim()),
      companion: WellnessProfileStatsTableCompanion(syncedAt: Value(now)),
    );
  }
}

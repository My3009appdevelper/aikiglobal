import 'package:drift/drift.dart';

import '../../common/base_dao.dart';
import '../app_database.dart';

class ProfilesDao extends BaseDao<$ProfilesTableTable, LocalProfile> {
  ProfilesDao(AppDatabase db) : super(db, table: db.profilesTable);

  // ---------------------------------------------------------------------------
  // CONSULTAS BÁSICAS
  // ---------------------------------------------------------------------------

  Future<LocalProfile?> getByUuid(String uuidProfile) {
    return getSingleWhere(
      (table) => table.uuidProfile.equals(uuidProfile.trim()),
    );
  }

  Future<LocalProfile?> getByAuthUserId(String authUserId) {
    return getSingleWhere(
      (table) =>
          table.authUserId.equals(authUserId.trim()) & table.deletedAt.isNull(),
    );
  }

  Future<LocalProfile?> getByEmail(String email) {
    return getSingleWhere(
      (table) =>
          table.email.collate(Collate.noCase).equals(email.trim()) &
          table.deletedAt.isNull(),
    );
  }

  Future<List<LocalProfile>> getAllActive() {
    return listWhere(
      where: (table) => table.deletedAt.isNull() & table.activo.equals(true),
      orderBy: [
        (table) => OrderingTerm.asc(table.nombre),
        (table) => OrderingTerm.asc(table.email),
      ],
    );
  }

  Future<List<LocalProfile>> getAllNotDeleted() {
    return listNotDeleted(
      deletedAt: (table) => table.deletedAt,
      orderBy: [
        (table) => OrderingTerm.asc(table.nombre),
        (table) => OrderingTerm.asc(table.email),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // WATCHERS
  // ---------------------------------------------------------------------------

  Stream<LocalProfile?> watchByAuthUserId(String authUserId) {
    final clean = authUserId.trim();

    return (select(table)..where(
          (table) => table.authUserId.equals(clean) & table.deletedAt.isNull(),
        ))
        .watchSingleOrNull();
  }

  Stream<List<LocalProfile>> watchActiveProfiles() {
    return watchWhere(
      where: (table) => table.deletedAt.isNull() & table.activo.equals(true),
      orderBy: [
        (table) => OrderingTerm.asc(table.nombre),
        (table) => OrderingTerm.asc(table.email),
      ],
    );
  }

  Stream<List<LocalProfile>> watchAllNotDeleted() {
    return watchNotDeleted(
      deletedAt: (table) => table.deletedAt,
      orderBy: [
        (table) => OrderingTerm.asc(table.nombre),
        (table) => OrderingTerm.asc(table.email),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // UPSERT / UPDATE
  // ---------------------------------------------------------------------------

  Future<void> upsertProfile(ProfilesTableCompanion profile) {
    return upsertOne(profile);
  }

  Future<void> upsertProfiles(List<ProfilesTableCompanion> profiles) {
    return upsertBatch(profiles);
  }

  Future<int> updatePartialByUuid(
    String uuidProfile,
    ProfilesTableCompanion patch,
  ) {
    return updatePartialById(
      byId: (table) => table.uuidProfile.equals(uuidProfile.trim()),
      patch: patch,
    );
  }

  Future<int> updatePartialByUuidNow(
    String uuidProfile,
    ProfilesTableCompanion Function(DateTime nowUtc) patch,
  ) {
    return updatePartialByIdNow(
      byId: (table) => table.uuidProfile.equals(uuidProfile.trim()),
      patch: patch,
    );
  }

  Future<int> updateOnboardingCompleted(
    String uuidProfile, {
    required bool completed,
  }) {
    return updatePartialByUuidNow(
      uuidProfile,
      (now) => ProfilesTableCompanion(
        onboardingCompletado: Value(completed),
        updatedAt: Value(now),
      ),
    );
  }

  Future<int> updateFotoPathLocal(
    String uuidProfile, {
    required String? fotoPathLocal,
  }) {
    return updatePartialByUuid(
      uuidProfile,
      ProfilesTableCompanion(fotoPathLocal: Value(fotoPathLocal)),
    );
  }

  Future<int> updateFotoPathSupabase(
    String uuidProfile, {
    required String? fotoPathSupabase,
  }) {
    return updatePartialByUuidNow(
      uuidProfile,
      (now) => ProfilesTableCompanion(
        fotoPathSupabase: Value(fotoPathSupabase),
        updatedAt: Value(now),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // SOFT DELETE
  // ---------------------------------------------------------------------------

  Future<int> softDeleteByUuid(String uuidProfile) {
    return softDelete(
      byId: (table) => table.uuidProfile.equals(uuidProfile.trim()),
      patch: (now) => ProfilesTableCompanion(
        deletedAt: Value(now),
        updatedAt: Value(now),
        activo: const Value(false),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // HELPERS
  // ---------------------------------------------------------------------------

  Future<DateTime?> getLatestUpdatedAt({bool includeDeleted = false}) {
    return latestUpdatedAt(
      updatedAt: (table) => table.updatedAt,
      deletedAt: (table) => table.deletedAt,
      includeDeleted: includeDeleted,
    );
  }

  Future<List<LocalProfile>> searchProfiles(String query) {
    return listLikeAnyNoCase(
      columns: [
        (table) => table.nombre,
        (table) => table.email,
        (table) => table.role,
      ],
      query: query,
      baseWhere: (table) => table.deletedAt.isNull(),
      orderBy: [
        (table) => OrderingTerm.asc(table.nombre),
        (table) => OrderingTerm.asc(table.email),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // SYNC
  // ---------------------------------------------------------------------------

  Future<List<LocalProfile>> getPendingSync() {
    return listPendingSync(
      syncedAt: (table) => table.syncedAt,
      updatedAt: (table) => table.updatedAt,
      deletedAt: (table) => table.deletedAt,
    );
  }

  Future<int> markSyncedByUuid(String uuidProfile, {DateTime? syncedAt}) {
    final now = syncedAt ?? nowUtc();

    return writeWhere(
      where: (table) => table.uuidProfile.equals(uuidProfile.trim()),
      companion: ProfilesTableCompanion(syncedAt: Value(now)),
    );
  }
}

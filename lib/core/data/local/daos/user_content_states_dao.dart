import 'package:drift/drift.dart';

import '../../common/base_dao.dart';
import '../app_database.dart';

class UserContentStatesDao
    extends BaseDao<$UserContentStatesTableTable, LocalUserContentState> {
  // ignore: use_super_parameters
  UserContentStatesDao(AppDatabase db)
    : super(db, table: db.userContentStatesTable);

  // ---------------------------------------------------------------------------
  // CONSULTAS BÁSICAS
  // ---------------------------------------------------------------------------

  Future<LocalUserContentState?> getByUuid(String uuidUserContentState) {
    return getSingleWhere(
      (table) => table.uuidUserContentState.equals(uuidUserContentState.trim()),
    );
  }

  Future<LocalUserContentState?> getByProfileAndContent(
    String uuidProfile,
    String uuidContentItem,
  ) {
    final cleanProfile = uuidProfile.trim();
    final cleanContent = uuidContentItem.trim();

    return getSingleWhere(
      (table) =>
          table.uuidProfile.equals(cleanProfile) &
          table.uuidContentItem.equals(cleanContent) &
          table.deletedAt.isNull(),
    );
  }

  Future<List<LocalUserContentState>> getForProfile(String uuidProfile) {
    final cleanProfile = uuidProfile.trim();

    return listWhere(
      where: (table) =>
          table.uuidProfile.equals(cleanProfile) & table.deletedAt.isNull(),
      orderBy: [
        (table) => OrderingTerm.desc(table.updatedAt),
        (table) => OrderingTerm.asc(table.uuidContentItem),
      ],
    );
  }

  Future<List<LocalUserContentState>> getAllForProfile(
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
        (table) => OrderingTerm.desc(table.updatedAt),
        (table) => OrderingTerm.asc(table.uuidContentItem),
      ],
    );
  }

  Future<List<LocalUserContentState>> getFavoritesForProfile(
    String uuidProfile,
  ) {
    final cleanProfile = uuidProfile.trim();

    return listWhere(
      where: (table) =>
          table.uuidProfile.equals(cleanProfile) &
          table.favorito.equals(true) &
          table.deletedAt.isNull(),
      orderBy: [
        (table) => OrderingTerm.desc(table.updatedAt),
        (table) => OrderingTerm.asc(table.uuidContentItem),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // WATCHERS
  // ---------------------------------------------------------------------------

  Stream<List<LocalUserContentState>> watchForProfile(String uuidProfile) {
    final cleanProfile = uuidProfile.trim();

    return watchWhere(
      where: (table) =>
          table.uuidProfile.equals(cleanProfile) & table.deletedAt.isNull(),
      orderBy: [
        (table) => OrderingTerm.desc(table.updatedAt),
        (table) => OrderingTerm.asc(table.uuidContentItem),
      ],
    );
  }

  Stream<List<LocalUserContentState>> watchFavoritesForProfile(
    String uuidProfile,
  ) {
    final cleanProfile = uuidProfile.trim();

    return watchWhere(
      where: (table) =>
          table.uuidProfile.equals(cleanProfile) &
          table.favorito.equals(true) &
          table.deletedAt.isNull(),
      orderBy: [
        (table) => OrderingTerm.desc(table.updatedAt),
        (table) => OrderingTerm.asc(table.uuidContentItem),
      ],
    );
  }

  Stream<LocalUserContentState?> watchByProfileAndContent(
    String uuidProfile,
    String uuidContentItem,
  ) {
    final cleanProfile = uuidProfile.trim();
    final cleanContent = uuidContentItem.trim();

    return (select(table)..where(
          (table) =>
              table.uuidProfile.equals(cleanProfile) &
              table.uuidContentItem.equals(cleanContent) &
              table.deletedAt.isNull(),
        ))
        .watchSingleOrNull();
  }

  // ---------------------------------------------------------------------------
  // UPSERT / UPDATE
  // ---------------------------------------------------------------------------

  Future<void> upsertUserContentState(UserContentStatesTableCompanion state) {
    return upsertOne(state);
  }

  Future<void> upsertUserContentStates(
    List<UserContentStatesTableCompanion> states,
  ) {
    return upsertBatch(states);
  }

  Future<int> updatePartialByUuid(
    String uuidUserContentState,
    UserContentStatesTableCompanion patch,
  ) {
    return updatePartialById(
      byId: (table) =>
          table.uuidUserContentState.equals(uuidUserContentState.trim()),
      patch: patch,
    );
  }

  Future<int> updatePartialByUuidNow(
    String uuidUserContentState,
    UserContentStatesTableCompanion Function(DateTime nowUtc) patch,
  ) {
    return updatePartialByIdNow(
      byId: (table) =>
          table.uuidUserContentState.equals(uuidUserContentState.trim()),
      patch: patch,
    );
  }

  Future<int> updateFavorite(
    String uuidUserContentState, {
    required bool favorito,
  }) {
    return updatePartialByUuidNow(
      uuidUserContentState,
      (now) => UserContentStatesTableCompanion(
        favorito: Value(favorito),
        updatedAt: Value(now),
        deletedAt: const Value(null),
      ),
    );
  }

  Future<int> updateProgress(
    String uuidUserContentState, {
    required int progresoPorcentaje,
    required int ultimaPosicionSegundos,
    required bool completado,
    DateTime? startedAt,
    DateTime? completedAt,
  }) {
    return updatePartialByUuidNow(
      uuidUserContentState,
      (now) => UserContentStatesTableCompanion(
        progresoPorcentaje: Value(progresoPorcentaje),
        ultimaPosicionSegundos: Value(ultimaPosicionSegundos),
        completado: Value(completado),
        startedAt: startedAt == null ? const Value.absent() : Value(startedAt),
        completedAt: completedAt == null
            ? const Value.absent()
            : Value(completedAt),
        updatedAt: Value(now),
        deletedAt: const Value(null),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // SOFT DELETE
  // ---------------------------------------------------------------------------

  Future<int> softDeleteByUuid(String uuidUserContentState) {
    return softDelete(
      byId: (table) =>
          table.uuidUserContentState.equals(uuidUserContentState.trim()),
      patch: (now) => UserContentStatesTableCompanion(
        deletedAt: Value(now),
        updatedAt: Value(now),
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

  // ---------------------------------------------------------------------------
  // SYNC
  // ---------------------------------------------------------------------------

  Future<List<LocalUserContentState>> getPendingSync() {
    return listPendingSync(
      syncedAt: (table) => table.syncedAt,
      updatedAt: (table) => table.updatedAt,
      deletedAt: (table) => table.deletedAt,
    );
  }

  Future<List<LocalUserContentState>> getPendingSyncForProfile(
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

  Future<int> markSyncedByUuid(
    String uuidUserContentState, {
    DateTime? syncedAt,
  }) {
    final now = syncedAt ?? nowUtc();

    return writeWhere(
      where: (table) =>
          table.uuidUserContentState.equals(uuidUserContentState.trim()),
      companion: UserContentStatesTableCompanion(syncedAt: Value(now)),
    );
  }
}

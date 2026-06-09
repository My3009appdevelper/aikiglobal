import 'package:drift/drift.dart';

import '../../common/base_dao.dart';
import '../app_database.dart';

class ContentItemsDao
    extends BaseDao<$ContentItemsTableTable, LocalContentItem> {
  ContentItemsDao(AppDatabase db) : super(db, table: db.contentItemsTable);

  // ---------------------------------------------------------------------------
  // CONSULTAS BÁSICAS
  // ---------------------------------------------------------------------------

  Future<LocalContentItem?> getByUuid(String uuidContentItem) {
    return getSingleWhere(
      (table) => table.uuidContentItem.equals(uuidContentItem.trim()),
    );
  }

  Future<List<LocalContentItem>> getAllNotDeleted() {
    return listNotDeleted(
      deletedAt: (table) => table.deletedAt,
      orderBy: [
        (table) => OrderingTerm.asc(table.orden),
        (table) => OrderingTerm.asc(table.titulo),
      ],
    );
  }

  Future<List<LocalContentItem>> getPublished({
    String? tipo,
    int? limit,
    int? offset,
  }) {
    final cleanTipo = tipo?.trim();

    return listWhere(
      where: (table) {
        final base =
            table.deletedAt.isNull() & table.status.equals('published');

        if (cleanTipo == null || cleanTipo.isEmpty) {
          return base;
        }

        return base & table.tipo.equals(cleanTipo);
      },
      orderBy: [
        (table) => OrderingTerm.asc(table.orden),
        (table) => OrderingTerm.asc(table.titulo),
      ],
      limit: limit,
      offset: offset,
    );
  }

  Future<List<LocalContentItem>> getFeaturedPublished({
    String? tipo,
    int? limit,
    int? offset,
  }) {
    final cleanTipo = tipo?.trim();

    return listWhere(
      where: (table) {
        final base =
            table.deletedAt.isNull() &
            table.status.equals('published') &
            table.destacado.equals(true);

        if (cleanTipo == null || cleanTipo.isEmpty) {
          return base;
        }

        return base & table.tipo.equals(cleanTipo);
      },
      orderBy: [
        (table) => OrderingTerm.asc(table.orden),
        (table) => OrderingTerm.asc(table.titulo),
      ],
      limit: limit,
      offset: offset,
    );
  }

  Future<List<LocalContentItem>> getByTipo(
    String tipo, {
    bool onlyPublished = true,
    int? limit,
    int? offset,
  }) {
    final cleanTipo = tipo.trim();

    return listWhere(
      where: (table) {
        final base = table.deletedAt.isNull() & table.tipo.equals(cleanTipo);

        if (!onlyPublished) {
          return base;
        }

        return base & table.status.equals('published');
      },
      orderBy: [
        (table) => OrderingTerm.asc(table.orden),
        (table) => OrderingTerm.asc(table.titulo),
      ],
      limit: limit,
      offset: offset,
    );
  }

  // ---------------------------------------------------------------------------
  // WATCHERS
  // ---------------------------------------------------------------------------

  Stream<List<LocalContentItem>> watchAllNotDeleted() {
    return watchNotDeleted(
      deletedAt: (table) => table.deletedAt,
      orderBy: [
        (table) => OrderingTerm.asc(table.orden),
        (table) => OrderingTerm.asc(table.titulo),
      ],
    );
  }

  Stream<List<LocalContentItem>> watchPublished({String? tipo}) {
    final cleanTipo = tipo?.trim();

    return watchWhere(
      where: (table) {
        final base =
            table.deletedAt.isNull() & table.status.equals('published');

        if (cleanTipo == null || cleanTipo.isEmpty) {
          return base;
        }

        return base & table.tipo.equals(cleanTipo);
      },
      orderBy: [
        (table) => OrderingTerm.asc(table.orden),
        (table) => OrderingTerm.asc(table.titulo),
      ],
    );
  }

  Stream<List<LocalContentItem>> watchFeaturedPublished({String? tipo}) {
    final cleanTipo = tipo?.trim();

    return watchWhere(
      where: (table) {
        final base =
            table.deletedAt.isNull() &
            table.status.equals('published') &
            table.destacado.equals(true);

        if (cleanTipo == null || cleanTipo.isEmpty) {
          return base;
        }

        return base & table.tipo.equals(cleanTipo);
      },
      orderBy: [
        (table) => OrderingTerm.asc(table.orden),
        (table) => OrderingTerm.asc(table.titulo),
      ],
    );
  }

  Stream<List<LocalContentItem>> watchByTipo(
    String tipo, {
    bool onlyPublished = true,
  }) {
    final cleanTipo = tipo.trim();

    return watchWhere(
      where: (table) {
        final base = table.deletedAt.isNull() & table.tipo.equals(cleanTipo);

        if (!onlyPublished) {
          return base;
        }

        return base & table.status.equals('published');
      },
      orderBy: [
        (table) => OrderingTerm.asc(table.orden),
        (table) => OrderingTerm.asc(table.titulo),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // SEARCH
  // ---------------------------------------------------------------------------

  Future<List<LocalContentItem>> searchPublished(
    String query, {
    String? tipo,
    int? limit,
    int? offset,
  }) {
    final cleanTipo = tipo?.trim();

    return listLikeAnyNoCase(
      columns: [
        (table) => table.titulo,
        (table) => table.subtitulo,
        (table) => table.descripcion,
        (table) => table.tipo,
      ],
      query: query,
      baseWhere: (table) {
        final base =
            table.deletedAt.isNull() & table.status.equals('published');

        if (cleanTipo == null || cleanTipo.isEmpty) {
          return base;
        }

        return base & table.tipo.equals(cleanTipo);
      },
      orderBy: [
        (table) => OrderingTerm.asc(table.orden),
        (table) => OrderingTerm.asc(table.titulo),
      ],
      limit: limit,
      offset: offset,
    );
  }

  Future<List<LocalContentItem>> searchAllNotDeleted(
    String query, {
    int? limit,
    int? offset,
  }) {
    return listLikeAnyNoCase(
      columns: [
        (table) => table.titulo,
        (table) => table.subtitulo,
        (table) => table.descripcion,
        (table) => table.tipo,
        (table) => table.status,
      ],
      query: query,
      baseWhere: (table) => table.deletedAt.isNull(),
      orderBy: [
        (table) => OrderingTerm.asc(table.orden),
        (table) => OrderingTerm.asc(table.titulo),
      ],
      limit: limit,
      offset: offset,
    );
  }

  Stream<List<LocalContentItem>> watchSearchPublished(
    String query, {
    String? tipo,
    int? limit,
    int? offset,
  }) {
    final cleanTipo = tipo?.trim();

    return watchLikeAnyNoCase(
      columns: [
        (table) => table.titulo,
        (table) => table.subtitulo,
        (table) => table.descripcion,
        (table) => table.tipo,
      ],
      query: query,
      baseWhere: (table) {
        final base =
            table.deletedAt.isNull() & table.status.equals('published');

        if (cleanTipo == null || cleanTipo.isEmpty) {
          return base;
        }

        return base & table.tipo.equals(cleanTipo);
      },
      orderBy: [
        (table) => OrderingTerm.asc(table.orden),
        (table) => OrderingTerm.asc(table.titulo),
      ],
      limit: limit,
      offset: offset,
    );
  }

  // ---------------------------------------------------------------------------
  // UPSERT / UPDATE
  // ---------------------------------------------------------------------------

  Future<void> upsertContentItem(ContentItemsTableCompanion item) {
    return upsertOne(item);
  }

  Future<void> upsertContentItems(List<ContentItemsTableCompanion> items) {
    return upsertBatch(items);
  }

  Future<int> updatePartialByUuid(
    String uuidContentItem,
    ContentItemsTableCompanion patch,
  ) {
    return updatePartialById(
      byId: (table) => table.uuidContentItem.equals(uuidContentItem.trim()),
      patch: patch,
    );
  }

  Future<int> updatePartialByUuidNow(
    String uuidContentItem,
    ContentItemsTableCompanion Function(DateTime nowUtc) patch,
  ) {
    return updatePartialByIdNow(
      byId: (table) => table.uuidContentItem.equals(uuidContentItem.trim()),
      patch: patch,
    );
  }

  Future<int> updateCoverPathLocal(
    String uuidContentItem, {
    required String? coverPathLocal,
  }) {
    return updatePartialByUuid(
      uuidContentItem,
      ContentItemsTableCompanion(coverPathLocal: Value(coverPathLocal)),
    );
  }

  Future<int> updateCoverPathSupabase(
    String uuidContentItem, {
    required String? coverPathSupabase,
  }) {
    return updatePartialByUuidNow(
      uuidContentItem,
      (now) => ContentItemsTableCompanion(
        coverPathSupabase: Value(coverPathSupabase),
        updatedAt: Value(now),
      ),
    );
  }

  Future<int> updateStatus(String uuidContentItem, {required String status}) {
    return updatePartialByUuidNow(
      uuidContentItem,
      (now) => ContentItemsTableCompanion(
        status: Value(status.trim()),
        updatedAt: Value(now),
      ),
    );
  }

  Future<int> updateDestacado(
    String uuidContentItem, {
    required bool destacado,
  }) {
    return updatePartialByUuidNow(
      uuidContentItem,
      (now) => ContentItemsTableCompanion(
        destacado: Value(destacado),
        updatedAt: Value(now),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // SOFT DELETE
  // ---------------------------------------------------------------------------

  Future<int> softDeleteByUuid(String uuidContentItem) {
    return softDelete(
      byId: (table) => table.uuidContentItem.equals(uuidContentItem.trim()),
      patch: (now) => ContentItemsTableCompanion(
        deletedAt: Value(now),
        updatedAt: Value(now),
        status: const Value('archived'),
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
  Future<List<LocalContentItem>> getPendingSync() {
    return listPendingSync(
      syncedAt: (table) => table.syncedAt,
      updatedAt: (table) => table.updatedAt,
      deletedAt: (table) => table.deletedAt,
    );
  }

  Future<int> markSyncedByUuid(String uuidContentItem, {DateTime? syncedAt}) {
    final now = syncedAt ?? nowUtc();

    return writeWhere(
      where: (table) => table.uuidContentItem.equals(uuidContentItem.trim()),
      companion: ContentItemsTableCompanion(syncedAt: Value(now)),
    );
  }
}

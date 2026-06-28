import 'package:drift/drift.dart';

import '../../common/base_dao.dart';
import '../app_database.dart';

class ContentMediaDao
    extends BaseDao<$ContentMediaTableTable, LocalContentMedia> {
  ContentMediaDao(super.db) : super(table: db.contentMediaTable);

  Future<LocalContentMedia?> getByUuid(String uuidContentMedia) {
    return getSingleWhere(
      (table) => table.uuidContentMedia.equals(uuidContentMedia.trim()),
    );
  }

  Future<List<LocalContentMedia>> getByContent(String uuidContentItem) {
    return listWhere(
      where: (table) =>
          table.uuidContentItem.equals(uuidContentItem.trim()) &
          table.deletedAt.isNull(),
      orderBy: [
        (table) => OrderingTerm.asc(table.orden),
        (table) => OrderingTerm.asc(table.createdAt),
      ],
    );
  }

  Stream<List<LocalContentMedia>> watchByContent(String uuidContentItem) {
    return watchWhere(
      where: (table) =>
          table.uuidContentItem.equals(uuidContentItem.trim()) &
          table.deletedAt.isNull(),
      orderBy: [
        (table) => OrderingTerm.asc(table.orden),
        (table) => OrderingTerm.asc(table.createdAt),
      ],
    );
  }

  Future<int> getPublishableCountByContent(String uuidContentItem) async {
    final rows = await listWhere(
      where: (table) =>
          table.uuidContentItem.equals(uuidContentItem.trim()) &
          table.deletedAt.isNull() &
          table.storagePathSupabase.equals('').not(),
      limit: 1,
    );

    return rows.length;
  }

  Future<void> upsertContentMedia(ContentMediaTableCompanion media) {
    return upsertOne(media);
  }

  Future<void> upsertContentMediaBatch(List<ContentMediaTableCompanion> media) {
    return upsertBatch(media);
  }

  Future<int> updateMetadata(
    String uuidContentMedia, {
    required String tipo,
    required String? titulo,
    required int? duracionSegundos,
    required int orden,
  }) {
    return updatePartialByIdNow(
      byId: (table) => table.uuidContentMedia.equals(uuidContentMedia.trim()),
      patch: (now) => ContentMediaTableCompanion(
        tipo: Value(tipo.trim()),
        titulo: Value(_cleanNullableText(titulo)),
        duracionSegundos: Value(duracionSegundos),
        orden: Value(orden),
        updatedAt: Value(now),
        syncedAt: const Value(null),
      ),
    );
  }

  Future<int> updateStoragePathLocal(
    String uuidContentMedia, {
    required String? storagePathLocal,
  }) {
    return updatePartialById(
      byId: (table) => table.uuidContentMedia.equals(uuidContentMedia.trim()),
      patch: ContentMediaTableCompanion(
        storagePathLocal: Value(_cleanNullableText(storagePathLocal)),
      ),
    );
  }

  Future<int> softDeleteByUuid(String uuidContentMedia) {
    return softDelete(
      byId: (table) => table.uuidContentMedia.equals(uuidContentMedia.trim()),
      patch: (now) => ContentMediaTableCompanion(
        deletedAt: Value(now),
        updatedAt: Value(now),
        syncedAt: const Value(null),
      ),
    );
  }

  Future<List<LocalContentMedia>> getPendingSync() {
    return listPendingSync(
      syncedAt: (table) => table.syncedAt,
      updatedAt: (table) => table.updatedAt,
      deletedAt: (table) => table.deletedAt,
    );
  }

  Future<int> markSyncedByUuid(String uuidContentMedia, {DateTime? syncedAt}) {
    final now = syncedAt ?? nowUtc();

    return writeWhere(
      where: (table) => table.uuidContentMedia.equals(uuidContentMedia.trim()),
      companion: ContentMediaTableCompanion(syncedAt: Value(now)),
    );
  }
}

String? _cleanNullableText(String? value) {
  if (value == null) {
    return null;
  }
  final clean = value.trim();
  return clean.isEmpty ? null : clean;
}

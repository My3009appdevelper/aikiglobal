import 'package:drift/drift.dart';

import '../../common/base_dao.dart';
import '../app_database.dart';

class ContentDownloadsDao
    extends BaseDao<$ContentDownloadsTableTable, LocalContentDownload> {
  ContentDownloadsDao(AppDatabase db)
    : super(db, table: db.contentDownloadsTable);

  Future<LocalContentDownload?> getByProfileAndMedia(
    String uuidProfile,
    String uuidContentMedia,
  ) {
    return getSingleWhere(
      (table) =>
          table.uuidProfile.equals(uuidProfile.trim()) &
          table.uuidContentMedia.equals(uuidContentMedia.trim()),
    );
  }

  Future<List<LocalContentDownload>> getForProfile(String uuidProfile) {
    return listWhere(
      where: (table) => table.uuidProfile.equals(uuidProfile.trim()),
      orderBy: [(table) => OrderingTerm.desc(table.updatedAt)],
    );
  }

  Stream<List<LocalContentDownload>> watchForProfile(String uuidProfile) {
    return watchWhere(
      where: (table) => table.uuidProfile.equals(uuidProfile.trim()),
      orderBy: [(table) => OrderingTerm.desc(table.updatedAt)],
    );
  }

  Future<void> upsertDownload(ContentDownloadsTableCompanion download) {
    return upsertOne(download);
  }

  Future<int> updateByUuid(
    String uuidContentDownload,
    ContentDownloadsTableCompanion patch,
  ) {
    return updatePartialById(
      byId: (table) =>
          table.uuidContentDownload.equals(uuidContentDownload.trim()),
      patch: patch,
    );
  }

  Future<int> deleteByUuid(String uuidContentDownload) {
    return (delete(table)..where(
          (row) => row.uuidContentDownload.equals(uuidContentDownload.trim()),
        ))
        .go();
  }
}

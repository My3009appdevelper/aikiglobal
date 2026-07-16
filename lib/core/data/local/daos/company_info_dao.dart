import 'package:drift/drift.dart';

import '../../common/base_dao.dart';
import '../app_database.dart';

class CompanyInfoDao extends BaseDao<$CompanyInfoTableTable, LocalCompanyInfo> {
  CompanyInfoDao(super.db) : super(table: db.companyInfoTable);

  static const mainSlug = 'main';

  Future<LocalCompanyInfo?> getMain() {
    return getSingleWhere(
      (table) => table.slug.equals(mainSlug) & table.deletedAt.isNull(),
    );
  }

  Stream<LocalCompanyInfo?> watchMain() {
    return watchWhere(
      where: (table) => table.slug.equals(mainSlug) & table.deletedAt.isNull(),
      limit: 1,
    ).map((rows) => rows.isEmpty ? null : rows.first);
  }

  Future<void> upsertCompanyInfo(CompanyInfoTableCompanion info) {
    return upsertOne(info);
  }

  Future<void> upsertCompanyInfoBatch(List<CompanyInfoTableCompanion> items) {
    return upsertBatch(items);
  }

  Future<DateTime?> getLatestUpdatedAt({bool includeDeleted = false}) {
    return latestUpdatedAt(
      updatedAt: (table) => table.updatedAt,
      deletedAt: (table) => table.deletedAt,
      includeDeleted: includeDeleted,
    );
  }

  Future<List<LocalCompanyInfo>> getPendingSync() {
    return listPendingSync(
      syncedAt: (table) => table.syncedAt,
      updatedAt: (table) => table.updatedAt,
      deletedAt: (table) => table.deletedAt,
    );
  }

  Future<int> markSyncedByUuid(String uuidCompanyInfo, {DateTime? syncedAt}) {
    final now = syncedAt ?? nowUtc();

    return writeWhere(
      where: (table) => table.uuidCompanyInfo.equals(uuidCompanyInfo.trim()),
      companion: CompanyInfoTableCompanion(syncedAt: Value(now)),
    );
  }
}

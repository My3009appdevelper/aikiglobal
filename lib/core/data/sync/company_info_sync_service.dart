import '../common/base_sync.dart';
import '../local/app_database.dart';
import '../local/daos/company_info_dao.dart';
import '../remote/services/company_info_remote_service.dart';
import 'sync_mappers.dart';

class CompanyInfoSyncService
    extends BaseSync<LocalCompanyInfo, CompanyInfoTableCompanion> {
  CompanyInfoSyncService({
    required CompanyInfoDao dao,
    required CompanyInfoRemoteService service,
  }) : super(
         service: service,
         idColumnRemote: 'uuid_company_info',
         getAllLocal: dao.listAll,
         getPendingLocal: dao.getPendingSync,
         upsertBatchLocal: dao.upsertCompanyInfoBatch,
         markSyncedLocal: (id) async {
           await dao.markSyncedByUuid(id);
         },
         getId: (row) => row.uuidCompanyInfo,
         getUpdatedAt: (row) => row.updatedAt,
         getSyncedAt: (row) => row.syncedAt,
         localToRemote: companyInfoToRemote,
         remoteToCompanion: companyInfoRemoteToCompanion,
         logTag: 'CompanyInfoSyncService',
       );
}

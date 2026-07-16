import '../../common/base_service.dart';
import '../supabase_tables.dart';

class CompanyInfoRemoteService extends BaseService {
  CompanyInfoRemoteService({super.supabase})
    : super(
        table: SupabaseTables.companyInfo,
        idColumn: 'uuid_company_info',
        headSelect: 'uuid_company_info, updated_at',
        onConflict: 'slug',
        logTag: 'CompanyInfoRemoteService',
      );

  Future<Map<String, dynamic>?> getMainOnline() {
    return getSingleOnlineWhere(
      '*',
      apply: (query) => query.eq('slug', 'main').isFilter('deleted_at', null),
    );
  }
}

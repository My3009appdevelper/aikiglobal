import 'package:supabase_flutter/supabase_flutter.dart';

import '../../common/base_service.dart';
import '../supabase_tables.dart';

class WellnessProfileStatsRemoteService extends BaseService {
  // ignore: use_super_parameters
  WellnessProfileStatsRemoteService({SupabaseClient? supabase})
    : super(
        table: SupabaseTables.wellnessProfileStats,
        idColumn: 'uuid_profile',
        headSelect: 'uuid_profile, updated_at',
        onConflict: 'uuid_profile',
        logTag: 'WellnessProfileStatsRemoteService',
        supabase: supabase,
      );

  Future<Map<String, dynamic>?> getByProfileOnline(String uuidProfile) {
    return getSingleOnlineWhere(
      '*',
      apply: (query) => query.eq('uuid_profile', uuidProfile.trim()),
      orderByColumn: 'updated_at',
      ascending: false,
    );
  }

  Future<List<Map<String, dynamic>>> getForProfileOnline(String uuidProfile) {
    return selectPaginated(
      '*',
      apply: (query) => query.eq('uuid_profile', uuidProfile.trim()),
    );
  }
}

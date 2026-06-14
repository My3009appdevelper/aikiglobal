import 'package:supabase_flutter/supabase_flutter.dart';

import '../../common/base_service.dart';
import '../supabase_tables.dart';

class WellnessDailyLogsRemoteService extends BaseService {
  // ignore: use_super_parameters
  WellnessDailyLogsRemoteService({SupabaseClient? supabase})
    : super(
        table: SupabaseTables.wellnessDailyLogs,
        idColumn: 'uuid_daily_log',
        headSelect: 'uuid_daily_log, updated_at',
        onConflict: 'uuid_daily_log',
        logTag: 'WellnessDailyLogsRemoteService',
        supabase: supabase,
      );

  Future<List<Map<String, dynamic>>> getForProfileOnline(String uuidProfile) {
    return selectPaginated(
      '*',
      apply: (query) => query
          .eq('uuid_profile', uuidProfile.trim())
          .isFilter('deleted_at', null),
      orderByColumn: 'fecha',
      ascending: false,
    );
  }

  Future<Map<String, dynamic>?> getByProfileAndDateOnline({
    required String uuidProfile,
    required String fecha,
  }) {
    return getSingleOnlineWhere(
      '*',
      apply: (query) => query
          .eq('uuid_profile', uuidProfile.trim())
          .eq('fecha', fecha.trim())
          .isFilter('deleted_at', null),
      orderByColumn: 'fecha',
      ascending: false,
    );
  }

  Future<void> archiveOnline(String uuidDailyLog) {
    return softDeleteOnline(uuidDailyLog.trim());
  }
}

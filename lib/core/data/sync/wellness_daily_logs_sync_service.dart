import '../common/base_sync.dart';
import '../local/app_database.dart';
import '../local/daos/wellness_daily_logs_dao.dart';
import '../remote/services/wellness_daily_logs_remote_service.dart';
import 'sync_mappers.dart';

class WellnessDailyLogsSyncService
    extends BaseSync<LocalWellnessDailyLog, WellnessDailyLogsTableCompanion> {
  WellnessDailyLogsSyncService({
    required WellnessDailyLogsDao dao,
    required WellnessDailyLogsRemoteService service,
  }) : _dao = dao,
       _service = service,
       super(
         service: service,
         idColumnRemote: 'uuid_daily_log',
         getAllLocal: dao.listAll,
         getPendingLocal: dao.getPendingSync,
         upsertBatchLocal: dao.upsertBatch,
         markSyncedLocal: (id) async {
           await dao.markSyncedByUuid(id);
         },
         getId: (row) => row.uuidDailyLog,
         getUpdatedAt: (row) => row.updatedAt,
         getSyncedAt: (row) => row.syncedAt,
         localToRemote: wellnessDailyLogToRemote,
         remoteToCompanion: wellnessDailyLogRemoteToCompanion,
         logTag: 'WellnessDailyLogsSyncService',
       );

  final WellnessDailyLogsDao _dao;
  final WellnessDailyLogsRemoteService _service;

  Future<void> pullForProfile(String uuidProfile) {
    return _forProfile(uuidProfile).pull();
  }

  Future<void> syncForProfile(String uuidProfile) {
    return _forProfile(uuidProfile).sync();
  }

  BaseSync<LocalWellnessDailyLog, WellnessDailyLogsTableCompanion> _forProfile(
    String uuidProfile,
  ) {
    final cleanProfile = uuidProfile.trim();

    return BaseSync<LocalWellnessDailyLog, WellnessDailyLogsTableCompanion>(
      service: _service,
      idColumnRemote: 'uuid_daily_log',
      getAllLocal: () => _dao.getAllForProfile(cleanProfile),
      getPendingLocal: () => _dao.getPendingSyncForProfile(cleanProfile),
      upsertBatchLocal: _dao.upsertBatch,
      markSyncedLocal: (id) async {
        await _dao.markSyncedByUuid(id);
      },
      getId: (row) => row.uuidDailyLog,
      getUpdatedAt: (row) => row.updatedAt,
      getSyncedAt: (row) => row.syncedAt,
      localToRemote: wellnessDailyLogToRemote,
      remoteToCompanion: wellnessDailyLogRemoteToCompanion,
      logTag: 'WellnessDailyLogsSyncService.$cleanProfile',
    );
  }
}

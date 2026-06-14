import '../common/base_sync.dart';
import '../local/app_database.dart';
import '../local/daos/wellness_profile_stats_dao.dart';
import '../remote/services/wellness_profile_stats_remote_service.dart';
import 'sync_mappers.dart';

class WellnessProfileStatsSyncService
    extends
        BaseSync<
          LocalWellnessProfileStats,
          WellnessProfileStatsTableCompanion
        > {
  WellnessProfileStatsSyncService({
    required WellnessProfileStatsDao dao,
    required WellnessProfileStatsRemoteService service,
  }) : _dao = dao,
       _service = service,
       super(
         service: service,
         idColumnRemote: 'uuid_profile',
         getAllLocal: dao.listAll,
         getPendingLocal: dao.getPendingSync,
         upsertBatchLocal: dao.upsertBatch,
         markSyncedLocal: (id) async {
           await dao.markSyncedByProfile(id);
         },
         getId: (row) => row.uuidProfile,
         getUpdatedAt: (row) => row.updatedAt,
         getSyncedAt: (row) => row.syncedAt,
         localToRemote: wellnessProfileStatsToRemote,
         remoteToCompanion: wellnessProfileStatsRemoteToCompanion,
         logTag: 'WellnessProfileStatsSyncService',
       );

  final WellnessProfileStatsDao _dao;
  final WellnessProfileStatsRemoteService _service;

  Future<void> pullForProfile(String uuidProfile) {
    return _forProfile(uuidProfile).pull();
  }

  Future<void> syncForProfile(String uuidProfile) {
    return _forProfile(uuidProfile).sync();
  }

  BaseSync<LocalWellnessProfileStats, WellnessProfileStatsTableCompanion>
  _forProfile(String uuidProfile) {
    final cleanProfile = uuidProfile.trim();

    return BaseSync<
      LocalWellnessProfileStats,
      WellnessProfileStatsTableCompanion
    >(
      service: _service,
      idColumnRemote: 'uuid_profile',
      getAllLocal: () => _dao.getAllForProfile(cleanProfile),
      getPendingLocal: () => _dao.getPendingSyncForProfile(cleanProfile),
      upsertBatchLocal: _dao.upsertBatch,
      markSyncedLocal: (id) async {
        await _dao.markSyncedByProfile(id);
      },
      getId: (row) => row.uuidProfile,
      getUpdatedAt: (row) => row.updatedAt,
      getSyncedAt: (row) => row.syncedAt,
      localToRemote: wellnessProfileStatsToRemote,
      remoteToCompanion: wellnessProfileStatsRemoteToCompanion,
      logTag: 'WellnessProfileStatsSyncService.$cleanProfile',
    );
  }
}

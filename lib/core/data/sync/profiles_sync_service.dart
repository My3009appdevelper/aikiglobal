import '../common/base_sync.dart';
import '../local/app_database.dart';
import '../local/daos/profiles_dao.dart';
import '../remote/services/profiles_remote_service.dart';
import 'sync_mappers.dart';

class ProfilesSyncService
    extends BaseSync<LocalProfile, ProfilesTableCompanion> {
  ProfilesSyncService({
    required ProfilesDao dao,
    required ProfilesRemoteService service,
  }) : _dao = dao,
       _service = service,
       super(
         service: service,
         idColumnRemote: 'uuid_profile',
         getAllLocal: dao.listAll,
         getPendingLocal: dao.getPendingSync,
         upsertBatchLocal: dao.upsertBatch,
         markSyncedLocal: (id) async {
           await dao.markSyncedByUuid(id);
         },
         getId: (row) => row.uuidProfile,
         getUpdatedAt: (row) => row.updatedAt,
         getSyncedAt: (row) => row.syncedAt,
         localToRemote: profileToRemote,
         remoteToCompanion: profileRemoteToCompanion,
         logTag: 'ProfilesSyncService',
       );

  final ProfilesDao _dao;
  final ProfilesRemoteService _service;

  @override
  Future<void> push() async {
    final pendingProfiles = await _dao.getPendingSync();
    if (pendingProfiles.isEmpty) {
      return;
    }

    for (final profile in pendingProfiles) {
      await _service.updateUserEditableOnline(
        profile.uuidProfile,
        profileToUserRemotePatch(profile),
      );
      await _dao.markSyncedByUuid(profile.uuidProfile);
    }
  }
}

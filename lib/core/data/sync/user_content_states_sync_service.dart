import '../common/base_sync.dart';
import '../local/app_database.dart';
import '../local/daos/user_content_states_dao.dart';
import '../remote/services/user_content_states_remote_service.dart';
import 'sync_mappers.dart';

class UserContentStatesSyncService
    extends BaseSync<LocalUserContentState, UserContentStatesTableCompanion> {
  UserContentStatesSyncService({
    required UserContentStatesDao dao,
    required UserContentStatesRemoteService service,
  }) : _dao = dao,
       _service = service,
       super(
         service: service,
         idColumnRemote: 'uuid_user_content_state',
         getAllLocal: dao.listAll,
         getPendingLocal: dao.getPendingSync,
         upsertBatchLocal: dao.upsertBatch,
         markSyncedLocal: (id) async {
           await dao.markSyncedByUuid(id);
         },
         getId: (row) => row.uuidUserContentState,
         getUpdatedAt: (row) => row.updatedAt,
         getSyncedAt: (row) => row.syncedAt,
         localToRemote: userContentStateToRemote,
         remoteToCompanion: userContentStateRemoteToCompanion,
         logTag: 'UserContentStatesSyncService',
       );

  final UserContentStatesDao _dao;
  final UserContentStatesRemoteService _service;

  Future<void> pullForProfile(String uuidProfile) {
    return _forProfile(uuidProfile).pull();
  }

  Future<void> syncForProfile(String uuidProfile) {
    return _forProfile(uuidProfile).sync();
  }

  BaseSync<LocalUserContentState, UserContentStatesTableCompanion> _forProfile(
    String uuidProfile,
  ) {
    final cleanProfile = uuidProfile.trim();

    return BaseSync<LocalUserContentState, UserContentStatesTableCompanion>(
      service: _service,
      idColumnRemote: 'uuid_user_content_state',
      getAllLocal: () => _dao.getAllForProfile(cleanProfile),
      getPendingLocal: () => _dao.getPendingSyncForProfile(cleanProfile),
      upsertBatchLocal: _dao.upsertBatch,
      markSyncedLocal: (id) async {
        await _dao.markSyncedByUuid(id);
      },
      getId: (row) => row.uuidUserContentState,
      getUpdatedAt: (row) => row.updatedAt,
      getSyncedAt: (row) => row.syncedAt,
      localToRemote: userContentStateToRemote,
      remoteToCompanion: userContentStateRemoteToCompanion,
      logTag: 'UserContentStatesSyncService.$cleanProfile',
    );
  }
}

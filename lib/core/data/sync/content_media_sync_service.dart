import '../common/base_sync.dart';
import '../local/app_database.dart';
import '../local/daos/content_media_dao.dart';
import '../remote/services/content_media_remote_service.dart';
import 'sync_mappers.dart';

class ContentMediaSyncService
    extends BaseSync<LocalContentMedia, ContentMediaTableCompanion> {
  ContentMediaSyncService({
    required ContentMediaDao dao,
    required ContentMediaRemoteService service,
  }) : super(
         service: service,
         idColumnRemote: 'uuid_content_media',
         getAllLocal: dao.listAll,
         getPendingLocal: dao.getPendingSync,
         upsertBatchLocal: dao.upsertBatch,
         markSyncedLocal: (id) async {
           await dao.markSyncedByUuid(id);
         },
         getId: (row) => row.uuidContentMedia,
         getUpdatedAt: (row) => row.updatedAt,
         getSyncedAt: (row) => row.syncedAt,
         localToRemote: contentMediaToRemote,
         remoteToCompanion: contentMediaRemoteToCompanion,
         logTag: 'ContentMediaSyncService',
       );
}

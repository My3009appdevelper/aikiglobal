import '../common/base_sync.dart';
import '../local/app_database.dart';
import '../local/daos/content_items_dao.dart';
import '../remote/services/content_items_remote_service.dart';
import 'sync_mappers.dart';

class ContentItemsSyncService
    extends BaseSync<LocalContentItem, ContentItemsTableCompanion> {
  ContentItemsSyncService({
    required ContentItemsDao dao,
    required ContentItemsRemoteService service,
  }) : super(
         service: service,
         idColumnRemote: 'uuid_content_item',
         getAllLocal: dao.listAll,
         getPendingLocal: dao.getPendingSync,
         upsertBatchLocal: dao.upsertBatch,
         markSyncedLocal: (id) async {
           await dao.markSyncedByUuid(id);
         },
         getId: (row) => row.uuidContentItem,
         getUpdatedAt: (row) => row.updatedAt,
         getSyncedAt: (row) => row.syncedAt,
         localToRemote: contentItemToRemote,
         remoteToCompanion: contentItemRemoteToCompanion,
         logTag: 'ContentItemsSyncService',
       );
}

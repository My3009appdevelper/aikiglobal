import '../../common/base_service.dart';
import '../supabase_tables.dart';

class ContentMediaRemoteService extends BaseService {
  ContentMediaRemoteService({super.supabase})
    : super(
        table: SupabaseTables.contentMedia,
        idColumn: 'uuid_content_media',
        headSelect: 'uuid_content_media, updated_at',
        onConflict: 'uuid_content_media',
        logTag: 'ContentMediaRemoteService',
      );

  Future<List<Map<String, dynamic>>> getByContentOnline(
    String uuidContentItem,
  ) {
    return selectPaginated(
      '*',
      apply: (query) => query
          .eq('uuid_content_item', uuidContentItem.trim())
          .isFilter('deleted_at', null),
      orderByColumn: 'sort_order',
    );
  }

  Future<List<Map<String, dynamic>>> getAllNotDeletedOnline() {
    return selectPaginated(
      '*',
      apply: (query) => query.isFilter('deleted_at', null),
      orderByColumn: 'sort_order',
    );
  }

  Future<void> updateMetadataOnline(
    String uuidContentMedia, {
    required String tipo,
    required String? titulo,
    required int? duracionSegundos,
    required int orden,
  }) {
    return updateOnlineById(uuidContentMedia.trim(), {
      'type': tipo.trim(),
      'title': titulo,
      'duration_seconds': duracionSegundos,
      'sort_order': orden,
    });
  }

  Future<void> archiveOnline(String uuidContentMedia) {
    return softDeleteOnline(uuidContentMedia.trim());
  }
}

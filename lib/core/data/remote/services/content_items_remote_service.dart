import '../../common/base_service.dart';
import '../supabase_tables.dart';

class ContentItemsRemoteService extends BaseService {
  ContentItemsRemoteService({super.supabase})
    : super(
        table: SupabaseTables.contentItems,
        idColumn: 'uuid_content_item',
        headSelect: 'uuid_content_item, updated_at',
        onConflict: 'uuid_content_item',
        logTag: 'ContentItemsRemoteService',
      );

  Future<List<Map<String, dynamic>>> getPublishedOnline({String? tipo}) {
    final cleanTipo = tipo?.trim().toLowerCase();

    return selectPaginated(
      '*',
      apply: (query) {
        var q = query.ilike('status', 'published').isFilter('deleted_at', null);

        if (cleanTipo != null && cleanTipo.isNotEmpty) {
          q = q.ilike('tipo', cleanTipo);
        }

        return q;
      },
      orderByColumn: 'orden',
    );
  }

  Future<List<Map<String, dynamic>>> getPublishedOnlineFallback({
    String? tipo,
  }) {
    return getAllNotDeletedOnline(tipo: tipo).then(
      (rows) => rows.where((row) => _isPublishedStatus(row['status'])).toList(),
    );
  }

  Future<List<Map<String, dynamic>>> getFeaturedPublishedOnline({
    String? tipo,
  }) {
    final cleanTipo = tipo?.trim().toLowerCase();

    return selectPaginated(
      '*',
      apply: (query) {
        var q = query
            .ilike('status', 'published')
            .eq('destacado', true)
            .isFilter('deleted_at', null);

        if (cleanTipo != null && cleanTipo.isNotEmpty) {
          q = q.ilike('tipo', cleanTipo);
        }

        return q;
      },
      orderByColumn: 'orden',
    );
  }

  Future<List<Map<String, dynamic>>> getAllNotDeletedOnline({String? tipo}) {
    final cleanTipo = tipo?.trim().toLowerCase();

    return selectPaginated(
      '*',
      apply: (query) {
        if (cleanTipo != null && cleanTipo.isNotEmpty) {
          return query.ilike('tipo', cleanTipo).isFilter('deleted_at', null);
        }

        return query.isFilter('deleted_at', null);
      },
      orderByColumn: 'orden',
    );
  }

  bool _isPublishedStatus(Object? status) {
    final value = status?.toString().toLowerCase().trim();
    return value == 'published';
  }

  Future<List<Map<String, dynamic>>> getByTipoOnline(
    String tipo, {
    bool onlyPublished = true,
  }) {
    final cleanTipo = tipo.trim().toLowerCase();

    return selectPaginated(
      '*',
      apply: (query) {
        var q = query.ilike('tipo', cleanTipo).isFilter('deleted_at', null);

        if (onlyPublished) {
          q = q.ilike('status', 'published');
        }

        return q;
      },
      orderByColumn: 'orden',
    );
  }

  Future<List<Map<String, dynamic>>> getByIdOnline(String uuidContentItem) {
    return getSingleOnlineWhere(
      '*',
      apply: (query) => query.eq('uuid_content_item', uuidContentItem.trim()),
    ).then((value) => value == null ? const [] : [value]);
  }

  Future<void> updateStatusOnline(
    String uuidContentItem,
    String status, {
    bool touchUpdatedAt = true,
  }) {
    return updateOnlineById(uuidContentItem.trim(), {
      'status': status.trim(),
    }, touchUpdatedAt: touchUpdatedAt);
  }

  Future<void> updateFeaturedOnline(
    String uuidContentItem,
    bool destacado, {
    bool touchUpdatedAt = true,
  }) {
    return updateOnlineById(uuidContentItem.trim(), {
      'destacado': destacado,
    }, touchUpdatedAt: touchUpdatedAt);
  }

  Future<void> archiveOnline(String uuidContentItem) {
    return updateStatusOnline(
      uuidContentItem,
      'archived',
      touchUpdatedAt: true,
    );
  }

  Future<void> updateCoverPathSupabaseOnline(
    String uuidContentItem,
    String? coverPathSupabase, {
    bool touchUpdatedAt = true,
  }) {
    return updateOnlineById(uuidContentItem.trim(), {
      'cover_path_supabase': coverPathSupabase,
    }, touchUpdatedAt: touchUpdatedAt);
  }
}

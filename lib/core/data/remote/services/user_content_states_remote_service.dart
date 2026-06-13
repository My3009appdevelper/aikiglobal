import 'package:supabase_flutter/supabase_flutter.dart';

import '../../common/base_service.dart';
import '../supabase_tables.dart';

class UserContentStatesRemoteService extends BaseService {
  // ignore: use_super_parameters
  UserContentStatesRemoteService({SupabaseClient? supabase})
    : super(
        table: SupabaseTables.userContentStates,
        idColumn: 'uuid_user_content_state',
        headSelect: 'uuid_user_content_state, updated_at',
        onConflict: 'uuid_user_content_state',
        logTag: 'UserContentStatesRemoteService',
        supabase: supabase,
      );

  Future<List<Map<String, dynamic>>> getForProfileOnline(String uuidProfile) {
    return selectPaginated(
      '*',
      apply: (query) => query
          .eq('uuid_profile', uuidProfile.trim())
          .isFilter('deleted_at', null),
    );
  }

  Future<List<Map<String, dynamic>>> getFavoritesForProfileOnline(
    String uuidProfile,
  ) {
    return selectPaginated(
      '*',
      apply: (query) => query
          .eq('uuid_profile', uuidProfile.trim())
          .eq('favorito', true)
          .isFilter('deleted_at', null),
    );
  }

  Future<Map<String, dynamic>?> getByProfileAndContentOnline({
    required String uuidProfile,
    required String uuidContentItem,
  }) {
    return getSingleOnlineWhere(
      '*',
      apply: (query) => query
          .eq('uuid_profile', uuidProfile.trim())
          .eq('uuid_content_item', uuidContentItem.trim())
          .isFilter('deleted_at', null),
    );
  }

  Future<void> updateFavoriteOnline(
    String uuidUserContentState, {
    required bool favorito,
    bool touchUpdatedAt = true,
  }) {
    return updateOnlineById(uuidUserContentState.trim(), {
      'favorito': favorito,
      'deleted_at': null,
    }, touchUpdatedAt: touchUpdatedAt);
  }

  Future<void> updateProgressOnline(
    String uuidUserContentState, {
    required int progresoPorcentaje,
    required int ultimaPosicionSegundos,
    required bool completado,
    DateTime? startedAt,
    DateTime? completedAt,
    bool touchUpdatedAt = true,
  }) {
    return updateOnlineById(uuidUserContentState.trim(), {
      'progreso_porcentaje': progresoPorcentaje,
      'ultima_posicion_segundos': ultimaPosicionSegundos,
      'completado': completado,
      if (startedAt != null) 'started_at': isoUtc(startedAt),
      if (completedAt != null) 'completed_at': isoUtc(completedAt),
      'deleted_at': null,
    }, touchUpdatedAt: touchUpdatedAt);
  }

  Future<void> archiveOnline(String uuidUserContentState) {
    return softDeleteOnline(uuidUserContentState.trim());
  }
}

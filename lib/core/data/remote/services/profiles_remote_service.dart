import 'package:supabase_flutter/supabase_flutter.dart';

import '../../common/base_service.dart';
import '../supabase_tables.dart';

class ProfilesRemoteService extends BaseService {
  ProfilesRemoteService({SupabaseClient? supabase})
    : super(
        table: SupabaseTables.profiles,
        idColumn: 'uuid_profile',
        headSelect: 'uuid_profile, updated_at',
        onConflict: 'uuid_profile',
        logTag: 'ProfilesRemoteService',
        supabase: supabase,
      );

  Future<Map<String, dynamic>?> getByAuthUserIdOnline(String authUserId) {
    return getSingleOnlineWhere(
      '*',
      apply: (query) => query
          .eq('auth_user_id', authUserId.trim())
          .isFilter('deleted_at', null),
    );
  }

  Future<Map<String, dynamic>?> getByEmailOnline(String email) {
    return getSingleOnlineWhere(
      '*',
      apply: (query) =>
          query.eq('email', email.trim()).isFilter('deleted_at', null),
    );
  }

  Future<List<Map<String, dynamic>>> getActiveProfilesOnline() {
    return selectPaginated(
      '*',
      apply: (query) => query.eq('activo', true).isFilter('deleted_at', null),
      orderByColumn: 'email',
    );
  }

  Future<List<Map<String, dynamic>>> getAllProfilesNotDeletedOnline() {
    return selectPaginated(
      '*',
      apply: (query) => query.isFilter('deleted_at', null),
      orderByColumn: 'nombre',
    );
  }

  Future<void> updateUserEditableOnline(
    String uuidProfile,
    Map<String, dynamic> patch,
  ) async {
    final cleanUuid = uuidProfile.trim();
    final body = patch.containsKey(updatedAtColumn)
        ? patch
        : <String, dynamic>{...patch, updatedAtColumn: isoUtc(nowUtc())};

    final response = await runRemote(
      'updateUserEditableOnline',
      () => supabase
          .from(table)
          .update(body)
          .eq(idColumn, cleanUuid)
          .select(idColumn)
          .limit(1),
    );

    if (List<Map<String, dynamic>>.from(response).isEmpty) {
      throw StateError(
        'No se pudo actualizar el perfil remoto. Verifica sesión y permisos.',
      );
    }
  }
}

import 'package:supabase_flutter/supabase_flutter.dart';

class AuthRemoteService {
  AuthRemoteService({SupabaseClient? supabase})
    : _supabase = _resolveSupabaseClient(supabase);

  final SupabaseClient _supabase;

  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) {
    return _supabase.auth.signInWithPassword(
      email: email.trim(),
      password: password,
    );
  }

  Future<void> signOut() {
    return _supabase.auth.signOut(scope: SignOutScope.local);
  }

  User? currentUser() {
    return _supabase.auth.currentUser;
  }

  Stream<AuthState> authChanges() {
    return _supabase.auth.onAuthStateChange;
  }

  static SupabaseClient _resolveSupabaseClient(SupabaseClient? client) {
    if (client != null) {
      return client;
    }

    throw StateError(
      'No hay cliente de Supabase inyectado en AuthRemoteService. '
      'Inicializa Supabase en el arranque y pasa el cliente desde la composición.',
    );
  }
}

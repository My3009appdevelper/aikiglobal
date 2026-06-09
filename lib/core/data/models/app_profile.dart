import '../local/app_database.dart';

class AppProfile {
  const AppProfile({
    required this.uuidProfile,
    required this.authUserId,
    required this.email,
    required this.role,
    required this.activo,
    required this.onboardingCompletado,
    required this.createdAt,
    required this.updatedAt,
    this.nombre,
    this.fotoPathSupabase,
    this.fotoPathLocal,
    this.deletedAt,
    this.syncedAt,
  });

  factory AppProfile.fromLocal(LocalProfile profile) {
    return AppProfile(
      uuidProfile: profile.uuidProfile,
      authUserId: profile.authUserId,
      nombre: profile.nombre,
      email: profile.email,
      fotoPathSupabase: profile.fotoPathSupabase,
      fotoPathLocal: profile.fotoPathLocal,
      role: profile.role,
      activo: profile.activo,
      onboardingCompletado: profile.onboardingCompletado,
      createdAt: profile.createdAt,
      updatedAt: profile.updatedAt,
      deletedAt: profile.deletedAt,
      syncedAt: profile.syncedAt,
    );
  }

  final String uuidProfile;
  final String authUserId;
  final String? nombre;
  final String email;
  final String? fotoPathSupabase;
  final String? fotoPathLocal;
  final String role;
  final bool activo;
  final bool onboardingCompletado;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final DateTime? syncedAt;

  bool get isAdmin => role == 'admin' && activo && deletedAt == null;
  bool get isUser => role == 'user' && activo && deletedAt == null;
  bool get isDeleted => deletedAt != null;
  bool get hasPendingSync => syncedAt == null || syncedAt!.isBefore(updatedAt);
}

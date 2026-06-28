import 'dart:async';

import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../local/app_database.dart';
import '../local/daos/profiles_dao.dart';
import '../models/app_profile.dart';
import '../remote/services/auth_remote_service.dart';
import '../remote/services/profile_photo_storage_service.dart';
import '../remote/services/profiles_remote_service.dart';
import '../remote/supabase_config.dart';
import '../sync/profiles_sync_service.dart';
import '../sync/sync_mappers.dart';

enum AppViewMode { user, admin }

class CurrentProfileController extends ChangeNotifier {
  static const String _onboardingCompletedKey = 'aiki_onboarding_completed_v1';
  static const String _rememberMeKey = 'aiki_remember_user';
  static const int _signupProfileRetryAttempts = 5;
  static const Duration _signupProfileRetryDelay = Duration(milliseconds: 450);

  CurrentProfileController({
    required ProfilesDao? profilesDao,
    ProfilesRemoteService? remoteService,
    ProfilesSyncService? syncService,
    AuthRemoteService? authService,
    ProfilePhotoStorageService? profilePhotoStorageService,
  }) : _profilesDao = profilesDao,
       _remoteService = remoteService,
       _syncService = syncService,
       _authService = authService,
       _profilePhotoStorageService = profilePhotoStorageService;

  final ProfilesDao? _profilesDao;
  final ProfilesRemoteService? _remoteService;
  final ProfilesSyncService? _syncService;
  final AuthRemoteService? _authService;
  final ProfilePhotoStorageService? _profilePhotoStorageService;

  StreamSubscription<LocalProfile?>? _profileSubscription;
  StreamSubscription<AuthState>? _authSubscription;

  AppProfile? _profile;
  String? _authUserId;
  bool _isLoading = false;
  bool _isSyncing = false;
  AppViewMode _viewMode = AppViewMode.user;
  Object? _error;
  SharedPreferences? _prefs;

  AppProfile? get profile => _profile;
  String? get authUserId => _authUserId;
  bool get isLoading => _isLoading;
  bool get isSyncing => _isSyncing;
  Object? get error => _error;
  bool get hasRemote => _remoteService != null;
  bool get isAuthenticated => _authUserId != null;
  bool get hasSession => _authUserId != null;
  bool get isAdmin => _profile?.isAdmin ?? false;
  bool get isUser => _profile?.isUser ?? false;
  AppViewMode get viewMode => isAdmin ? _viewMode : AppViewMode.user;
  bool get isUserView => viewMode == AppViewMode.user;
  bool get isAdminView => viewMode == AppViewMode.admin;
  bool get onboardingCompletado => _profile?.onboardingCompletado ?? false;

  void setViewMode(AppViewMode mode) {
    final nextMode = isAdmin ? mode : AppViewMode.user;
    if (_viewMode == nextMode) {
      return;
    }

    _viewMode = nextMode;
    notifyListeners();
  }

  Future<void> loadCurrentSession() async {
    final user = SupabaseConfig.clientOrNull?.auth.currentUser;
    if (user == null) {
      await clear();
      return;
    }

    await loadByAuthUserId(user.id, refreshRemote: true);
  }

  void startAuthListener() {
    if (_authService == null || _authSubscription != null) {
      return;
    }

    _authSubscription = _authService.authChanges().listen((event) {
      final session = event.session;
      if (session == null) {
        unawaited(clear());
        return;
      }

      if (session.user.id == _authUserId) {
        return;
      }

      unawaited(loadByAuthUserId(session.user.id, refreshRemote: true));
    });
  }

  void stopAuthListener() {
    _authSubscription?.cancel();
    _authSubscription = null;
  }

  Future<void> signIn({
    required String email,
    required String password,
    bool rememberMe = true,
  }) async {
    final authService = _authService;
    if (authService == null) {
      throw StateError(
        'No hay servicio de autenticación configurado para iniciar sesión.',
      );
    }

    _setLoading(true);
    _error = null;

    try {
      final response = await authService.signIn(
        email: email,
        password: password,
      );
      final user = response.user;
      if (user == null) {
        throw StateError('No se pudo iniciar sesión en este momento.');
      }

      if (!rememberMe) {
        await _setRememberPreference(false);
      } else {
        await _setRememberPreference(true);
      }
      await loadByAuthUserId(user.id, refreshRemote: true);
    } catch (error) {
      _error = error;
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String nombre,
    bool rememberMe = true,
  }) async {
    final authService = _authService;
    if (authService == null) {
      throw StateError(
        'No hay servicio de autenticación configurado para crear la cuenta.',
      );
    }

    _setLoading(true);
    _error = null;

    try {
      final response = await authService.signUp(
        email: email,
        password: password,
        nombre: nombre,
      );

      final user = response.user;
      if (user == null) {
        throw StateError('No se pudo crear la cuenta en este momento.');
      }

      await _setRememberPreference(rememberMe);
      await loadByAuthUserId(user.id, refreshRemote: false);
      await _waitForRemoteProfile(user.id);

      return response;
    } catch (error) {
      _error = error;
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> enforceRememberPreferenceOnStartup() async {
    final rememberSession = await rememberSessionEnabled();
    if (rememberSession) return;

    final authService = _authService;
    try {
      if (authService != null) {
        await authService.signOut();
      }
    } finally {
      await clear();
    }
  }

  Future<void> signOut() async {
    final authService = _authService;
    _setLoading(true);

    try {
      if (authService != null) {
        await authService.signOut();
      }
      await clear();
    } catch (error) {
      _error = error;
      await clear();
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadByAuthUserId(
    String authUserId, {
    bool refreshRemote = true,
  }) async {
    final cleanAuthUserId = authUserId.trim();
    if (cleanAuthUserId.isEmpty) {
      await clear();
      return;
    }

    _setLoading(true);
    _authUserId = cleanAuthUserId;
    _error = null;

    await _profileSubscription?.cancel();
    _profileSubscription = null;

    final dao = _profilesDao;
    if (dao == null) {
      await _loadProfileRemote(authUserId: cleanAuthUserId);
      _setLoading(false);
      return;
    }

    _profileSubscription = dao
        .watchByAuthUserId(cleanAuthUserId)
        .listen(
          (localProfile) {
            _profile = localProfile == null
                ? null
                : AppProfile.fromLocal(localProfile);
            if (!isAdmin && _viewMode != AppViewMode.user) {
              _viewMode = AppViewMode.user;
            }
            notifyListeners();
          },
          onError: (Object error) {
            _error = error;
            notifyListeners();
          },
        );

    _profile = (await dao.getByAuthUserId(
      cleanAuthUserId,
    ))?.let(AppProfile.fromLocal);
    if (!isAdmin && _viewMode != AppViewMode.user) {
      _viewMode = AppViewMode.user;
    }
    _setLoading(false);

    if (refreshRemote) {
      await pullFromRemote();
    }
  }

  Future<void> pullFromRemote() async {
    final authUserId = _authUserId;
    final remoteService = _remoteService;
    final dao = _profilesDao;
    if (authUserId == null || remoteService == null) {
      return;
    }

    _setSyncing(true);
    _error = null;

    try {
      final remoteProfile = await remoteService.getByAuthUserIdOnline(
        authUserId,
      );
      if (remoteProfile != null) {
        final appProfile = profileRemoteToApp(remoteProfile);
        if (dao == null) {
          _profile = appProfile;
          notifyListeners();
        } else {
          await dao.upsertProfile(profileRemoteToCompanion(remoteProfile));
        }
      }
    } catch (error) {
      _error = error;
    } finally {
      _setSyncing(false);
    }
  }

  @Deprecated('Usa syncWithRemote() para mayor semántica.')
  Future<void> sync() async {
    await syncWithRemote();
  }

  Future<void> syncWithRemote({bool throwOnError = false}) async {
    final syncService = _syncService;
    if (syncService == null) {
      await pullFromRemote();
      return;
    }

    _setSyncing(true);
    _error = null;

    try {
      await syncService.sync();
    } catch (error) {
      _error = error;
      if (throwOnError) {
        rethrow;
      }
    } finally {
      _setSyncing(false);
    }
  }

  @Deprecated('Usa pullFromRemote() para mayor semántica.')
  Future<void> refreshFromRemote() async {
    await pullFromRemote();
  }

  Future<void> updateEditableProfile({
    String? nombre,
    String? fotoPathSupabase,
    bool? onboardingCompletado,
    bool syncAfterUpdate = false,
  }) async {
    final current = _profile;
    if (current == null) {
      throw StateError('No hay perfil local cargado.');
    }

    final now = DateTime.now().toUtc();
    final dao = _profilesDao;
    final remoteService = _remoteService;

    if (dao != null) {
      await dao.updatePartialByUuid(
        current.uuidProfile,
        ProfilesTableCompanion(
          nombre: nombre == null
              ? const Value.absent()
              : Value(_cleanText(nombre)),
          fotoPathSupabase: fotoPathSupabase == null
              ? const Value.absent()
              : Value(_cleanNullableText(fotoPathSupabase)),
          onboardingCompletado: onboardingCompletado == null
              ? const Value.absent()
              : Value(onboardingCompletado),
          updatedAt: Value(now),
          syncedAt: const Value(null),
        ),
      );
    } else {
      if (remoteService == null) {
        return;
      }

      final patch = <String, dynamic>{};
      if (nombre != null) {
        patch['nombre'] = _cleanText(nombre);
      }
      if (fotoPathSupabase != null) {
        patch['foto_path_supabase'] = _cleanNullableText(fotoPathSupabase);
      }
      if (onboardingCompletado != null) {
        patch['onboarding_completado'] = onboardingCompletado;
      }

      if (patch.isNotEmpty) {
        await remoteService.updateUserEditableOnline(
          current.uuidProfile,
          patch,
        );
        await _loadProfileRemote(authUserId: current.authUserId);
      }
    }

    if (syncAfterUpdate) {
      await syncWithRemote(throwOnError: true);
    }
  }

  Future<void> completeOnboarding({bool syncAfterUpdate = false}) {
    return updateEditableProfile(
      onboardingCompletado: true,
      syncAfterUpdate: syncAfterUpdate,
    );
  }

  Future<void> updateLocalPhotoPath(String? fotoPathLocal) async {
    final current = _profile;
    if (current == null) {
      throw StateError('No hay perfil local cargado.');
    }

    final dao = _profilesDao;
    final remoteService = _remoteService;

    if (dao != null) {
      await dao.updateFotoPathLocal(
        current.uuidProfile,
        fotoPathLocal: _cleanNullableText(fotoPathLocal),
      );
      return;
    }

    if (remoteService != null && _authUserId != null) {
      // En web todavía no existe tabla local para persistir la ruta del archivo,
      // y esa ruta nunca debe enviarse a Supabase.
      return;
    }
  }

  Future<void> updateProfilePhoto({
    required Uint8List bytes,
    required String fileName,
    String? contentType,
  }) async {
    final current = _profile;
    final storageService = _profilePhotoStorageService;
    if (current == null) {
      throw StateError('No hay perfil local cargado.');
    }
    if (storageService == null) {
      throw StateError('No hay servicio de Storage configurado.');
    }

    final previousPath = current.fotoPathSupabase;
    final nextPath = await storageService.uploadProfilePhoto(
      authUserId: current.authUserId,
      bytes: bytes,
      fileName: fileName,
      contentType: contentType,
    );

    try {
      await updateLocalPhotoPath(null);
      await updateEditableProfile(
        fotoPathSupabase: nextPath,
        syncAfterUpdate: true,
      );
      if (previousPath != null && previousPath.trim() != nextPath) {
        unawaited(storageService.deleteProfilePhoto(previousPath));
      }
    } catch (_) {
      unawaited(storageService.deleteProfilePhoto(nextPath));
      rethrow;
    }
  }

  Future<void> removeProfilePhoto() async {
    final current = _profile;
    final storageService = _profilePhotoStorageService;
    if (current == null) {
      throw StateError('No hay perfil local cargado.');
    }

    final previousPath = current.fotoPathSupabase;
    await updateLocalPhotoPath(null);
    await updateEditableProfile(fotoPathSupabase: '', syncAfterUpdate: true);

    if (storageService != null && previousPath != null) {
      unawaited(storageService.deleteProfilePhoto(previousPath));
    }
  }

  Future<String?> createProfilePhotoSignedUrl(String? remotePath) {
    final storageService = _profilePhotoStorageService;
    if (storageService == null) {
      return Future<String?>.value(null);
    }

    return storageService.createSignedUrl(remotePath);
  }

  Future<void> clear() async {
    _authUserId = null;
    _profile = null;
    _error = null;
    _isLoading = false;
    _isSyncing = false;
    _viewMode = AppViewMode.user;
    await _profileSubscription?.cancel();
    _profileSubscription = null;
    notifyListeners();
  }

  Future<bool> hasSeenOnboarding() async {
    final prefs = await _getPrefs();
    return prefs.getBool(_onboardingCompletedKey) ?? false;
  }

  Future<void> markOnboardingCompleted() async {
    final prefs = await _getPrefs();
    await prefs.setBool(_onboardingCompletedKey, true);
  }

  Future<void> _setRememberPreference(bool enabled) async {
    final prefs = await _getPrefs();
    await prefs.setBool(_rememberMeKey, enabled);
  }

  Future<void> clearRememberPreference() async {
    final prefs = await _getPrefs();
    await prefs.remove(_rememberMeKey);
  }

  Future<bool> rememberSessionEnabled() async {
    final prefs = await _getPrefs();
    return prefs.getBool(_rememberMeKey) ?? true;
  }

  Future<SharedPreferences> _getPrefs() async {
    final local = _prefs;
    if (local != null) {
      return local;
    }
    final prefs = await SharedPreferences.getInstance();
    _prefs = prefs;
    return prefs;
  }

  void _setLoading(bool value) {
    if (_isLoading == value) {
      return;
    }
    _isLoading = value;
    notifyListeners();
  }

  void _setSyncing(bool value) {
    if (_isSyncing == value) {
      return;
    }
    _isSyncing = value;
    notifyListeners();
  }

  String? _cleanText(String value) {
    final clean = value.trim();
    return clean.isEmpty ? null : clean;
  }

  String? _cleanNullableText(String? value) {
    if (value == null) {
      return null;
    }
    final clean = value.trim();
    return clean.isEmpty ? null : clean;
  }

  @override
  void dispose() {
    _profileSubscription?.cancel();
    _authSubscription?.cancel();
    super.dispose();
  }

  Future<void> _loadProfileRemote({required String authUserId}) async {
    final remoteService = _remoteService;
    if (remoteService == null) {
      return;
    }

    _setSyncing(true);
    _error = null;

    try {
      final remoteProfile = await remoteService.getByAuthUserIdOnline(
        authUserId,
      );
      if (remoteProfile != null) {
        _profile = profileRemoteToApp(remoteProfile);
      } else {
        _profile = null;
      }
      if (!isAdmin && _viewMode != AppViewMode.user) {
        _viewMode = AppViewMode.user;
      }
      notifyListeners();
    } catch (error) {
      _error = error;
    } finally {
      _setSyncing(false);
    }
  }

  Future<void> _waitForRemoteProfile(String authUserId) async {
    final remoteService = _remoteService;
    final dao = _profilesDao;
    if (remoteService == null) {
      return;
    }

    final cleanAuthUserId = authUserId.trim();
    Object? lastError;
    for (var attempt = 0; attempt < _signupProfileRetryAttempts; attempt += 1) {
      try {
        final remoteProfile = await remoteService.getByAuthUserIdOnline(
          cleanAuthUserId,
        );

        if (remoteProfile != null) {
          final appProfile = profileRemoteToApp(remoteProfile);
          if (dao != null) {
            await dao.upsertProfile(profileRemoteToCompanion(remoteProfile));
          } else {
            _profile = appProfile;
          }

          _profile = appProfile;
          if (!isAdmin && _viewMode != AppViewMode.user) {
            _viewMode = AppViewMode.user;
          }
          notifyListeners();
          return;
        }
      } catch (error) {
        lastError = error;
      }

      if (attempt < _signupProfileRetryAttempts - 1) {
        await Future<void>.delayed(_signupProfileRetryDelay);
      }
    }

    if (lastError != null) {
      _error = lastError;
    }
  }
}

extension _NullableLocalProfileMap on LocalProfile? {
  T? let<T>(T Function(LocalProfile profile) map) {
    final value = this;
    return value == null ? null : map(value);
  }
}

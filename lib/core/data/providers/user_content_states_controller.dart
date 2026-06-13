import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;

import 'package:crypto/crypto.dart';
import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';

import '../local/app_database.dart';
import '../local/daos/user_content_states_dao.dart';
import '../models/app_user_content_state.dart';
import '../remote/services/user_content_states_remote_service.dart';
import '../sync/sync_mappers.dart';
import '../sync/user_content_states_sync_service.dart';

class UserContentStatesController extends ChangeNotifier {
  UserContentStatesController({
    required UserContentStatesDao? userContentStatesDao,
    UserContentStatesRemoteService? userContentStatesRemoteService,
    UserContentStatesSyncService? syncService,
  }) : _userContentStatesDao = userContentStatesDao,
       _userContentStatesRemoteService = userContentStatesRemoteService,
       _syncService = syncService;

  final UserContentStatesDao? _userContentStatesDao;
  final UserContentStatesRemoteService? _userContentStatesRemoteService;
  final UserContentStatesSyncService? _syncService;

  StreamSubscription<List<LocalUserContentState>>? _statesSubscription;

  List<AppUserContentState> _states = const [];
  String? _activeProfileUuid;
  bool _isLoading = false;
  bool _isSyncing = false;
  Object? _error;

  List<AppUserContentState> get states => _states;
  String? get activeProfileUuid => _activeProfileUuid;
  bool get isLoading => _isLoading;
  bool get isSyncing => _isSyncing;
  Object? get error => _error;
  bool get hasRemote => _userContentStatesRemoteService != null;

  Map<String, AppUserContentState> get statesByContentId {
    return {
      for (final state in _states)
        if (state.deletedAt == null && state.uuidProfile == _activeProfileUuid)
          state.uuidContentItem: state,
    };
  }

  Set<String> get favoriteContentIds {
    return {
      for (final state in _states)
        if (state.deletedAt == null && state.favorito) state.uuidContentItem,
    };
  }

  int get favoriteCount => favoriteContentIds.length;

  AppUserContentState? stateForContent(String uuidContentItem) {
    return statesByContentId[uuidContentItem.trim()];
  }

  bool isFavorite(String uuidContentItem) {
    return stateForContent(uuidContentItem)?.favorito ?? false;
  }

  void watchForProfile(String uuidProfile) {
    final cleanProfile = uuidProfile.trim();
    if (cleanProfile.isEmpty) {
      clear();
      return;
    }

    _activeProfileUuid = cleanProfile;
    _cancelSubscription();

    final dao = _userContentStatesDao;
    if (dao == null) {
      unawaited(loadForProfile(cleanProfile));
      return;
    }

    _statesSubscription = dao
        .watchForProfile(cleanProfile)
        .listen(
          (localStates) {
            _states = _toAppStates(localStates);
            _error = null;
            notifyListeners();
          },
          onError: (Object error) {
            _error = error;
            notifyListeners();
          },
        );

    unawaited(pullFromRemote(uuidProfile: cleanProfile));
  }

  Future<void> loadForProfile(String uuidProfile) async {
    final cleanProfile = uuidProfile.trim();
    if (cleanProfile.isEmpty) {
      clear();
      return;
    }

    _activeProfileUuid = cleanProfile;

    final dao = _userContentStatesDao;
    if (dao == null) {
      await _loadRemoteForProfile(cleanProfile);
      return;
    }

    await _loadFromLocal(() => dao.getForProfile(cleanProfile));
  }

  Future<void> pullFromRemote({String? uuidProfile}) async {
    final cleanProfile = _resolveProfileUuid(uuidProfile);
    if (cleanProfile == null) {
      return;
    }

    final dao = _userContentStatesDao;
    if (dao == null) {
      await _loadRemoteForProfile(cleanProfile);
      return;
    }

    final syncService = _syncService;
    if (syncService == null) {
      return;
    }

    _setSyncing(true);
    _error = null;

    try {
      await syncService.pullForProfile(cleanProfile);
      if (_statesSubscription == null) {
        await _loadFromLocal(
          () => dao.getForProfile(cleanProfile),
          keepPreviousError: true,
        );
      }
    } catch (error) {
      _error = error;
      notifyListeners();
    } finally {
      _setSyncing(false);
    }
  }

  Future<void> syncWithRemote({String? uuidProfile}) async {
    final cleanProfile = _resolveProfileUuid(uuidProfile);
    if (cleanProfile == null) {
      return;
    }

    final dao = _userContentStatesDao;
    if (dao == null) {
      await _loadRemoteForProfile(cleanProfile);
      return;
    }

    final syncService = _syncService;
    if (syncService == null) {
      return;
    }

    _setSyncing(true);
    _error = null;

    try {
      await syncService.syncForProfile(cleanProfile);
      if (_statesSubscription == null) {
        await _loadFromLocal(
          () => dao.getForProfile(cleanProfile),
          keepPreviousError: true,
        );
      }
    } catch (error) {
      _error = error;
      notifyListeners();
    } finally {
      _setSyncing(false);
    }
  }

  Future<void> toggleFavorito(
    String uuidProfile,
    String uuidContentItem,
  ) async {
    final cleanProfile = uuidProfile.trim();
    final cleanContent = uuidContentItem.trim();
    if (cleanProfile.isEmpty || cleanContent.isEmpty) {
      return;
    }

    final current = await _findState(cleanProfile, cleanContent);
    final nextFavorite = !(current?.favorito ?? false);
    final now = DateTime.now().toUtc();

    await _upsertState(
      uuidProfile: cleanProfile,
      uuidContentItem: cleanContent,
      favorito: nextFavorite,
      progresoPorcentaje: current?.progresoPorcentaje ?? 0,
      ultimaPosicionSegundos: current?.ultimaPosicionSegundos ?? 0,
      completado: current?.completado ?? false,
      startedAt: current?.startedAt,
      completedAt: current?.completedAt,
      createdAt: current?.createdAt ?? now,
      updatedAt: now,
    );
  }

  Future<void> updateProgress(
    String uuidProfile,
    String uuidContentItem,
    int progresoPorcentaje,
    int ultimaPosicionSegundos,
  ) async {
    final cleanProfile = uuidProfile.trim();
    final cleanContent = uuidContentItem.trim();
    if (cleanProfile.isEmpty || cleanContent.isEmpty) {
      return;
    }

    final current = await _findState(cleanProfile, cleanContent);
    final now = DateTime.now().toUtc();
    final cleanProgress = _clampProgress(progresoPorcentaje);
    final cleanPosition = math.max(0, ultimaPosicionSegundos);
    final nextCompleted =
        (current?.completado ?? false) || cleanProgress >= 100;
    final nextCompletedAt = nextCompleted
        ? (current?.completedAt ?? now)
        : current?.completedAt;

    await _upsertState(
      uuidProfile: cleanProfile,
      uuidContentItem: cleanContent,
      favorito: current?.favorito ?? false,
      progresoPorcentaje: cleanProgress,
      ultimaPosicionSegundos: cleanPosition,
      completado: nextCompleted,
      startedAt: current?.startedAt ?? now,
      completedAt: nextCompletedAt,
      createdAt: current?.createdAt ?? now,
      updatedAt: now,
    );
  }

  Future<void> markCompleted(String uuidProfile, String uuidContentItem) async {
    final cleanProfile = uuidProfile.trim();
    final cleanContent = uuidContentItem.trim();
    if (cleanProfile.isEmpty || cleanContent.isEmpty) {
      return;
    }

    final current = await _findState(cleanProfile, cleanContent);
    final now = DateTime.now().toUtc();

    await _upsertState(
      uuidProfile: cleanProfile,
      uuidContentItem: cleanContent,
      favorito: current?.favorito ?? false,
      progresoPorcentaje: 100,
      ultimaPosicionSegundos: current?.ultimaPosicionSegundos ?? 0,
      completado: true,
      startedAt: current?.startedAt ?? now,
      completedAt: now,
      createdAt: current?.createdAt ?? now,
      updatedAt: now,
    );
  }

  void clear() {
    _activeProfileUuid = null;
    _states = const [];
    _error = null;
    _isLoading = false;
    _isSyncing = false;
    _cancelSubscription();
    notifyListeners();
  }

  Future<AppUserContentState?> _findState(
    String uuidProfile,
    String uuidContentItem,
  ) async {
    final current = stateForContent(uuidContentItem);
    if (current != null && current.uuidProfile == uuidProfile) {
      return current;
    }

    final dao = _userContentStatesDao;
    if (dao != null) {
      final local = await dao.getByProfileAndContent(
        uuidProfile,
        uuidContentItem,
      );
      return local == null ? null : AppUserContentState.fromLocal(local);
    }

    final remoteService = _userContentStatesRemoteService;
    if (remoteService == null) {
      return null;
    }

    final remote = await remoteService.getByProfileAndContentOnline(
      uuidProfile: uuidProfile,
      uuidContentItem: uuidContentItem,
    );

    return remote == null ? null : userContentStateRemoteToApp(remote);
  }

  Future<void> _upsertState({
    required String uuidProfile,
    required String uuidContentItem,
    required bool favorito,
    required int progresoPorcentaje,
    required int ultimaPosicionSegundos,
    required bool completado,
    required DateTime createdAt,
    required DateTime updatedAt,
    DateTime? startedAt,
    DateTime? completedAt,
  }) async {
    final uuidUserContentState = _buildUserContentStateUuid(
      uuidProfile: uuidProfile,
      uuidContentItem: uuidContentItem,
    );

    final dao = _userContentStatesDao;
    if (dao != null) {
      await dao.upsertUserContentState(
        UserContentStatesTableCompanion.insert(
          uuidUserContentState: uuidUserContentState,
          uuidProfile: uuidProfile,
          uuidContentItem: uuidContentItem,
          favorito: Value(favorito),
          progresoPorcentaje: Value(_clampProgress(progresoPorcentaje)),
          ultimaPosicionSegundos: Value(math.max(0, ultimaPosicionSegundos)),
          completado: Value(completado),
          startedAt: Value(startedAt),
          completedAt: Value(completedAt),
          createdAt: Value(createdAt),
          updatedAt: Value(updatedAt),
          deletedAt: const Value(null),
          syncedAt: const Value(null),
        ),
      );
      unawaited(syncWithRemote(uuidProfile: uuidProfile));
      return;
    }

    final remoteService = _userContentStatesRemoteService;
    if (remoteService == null) {
      return;
    }

    await remoteService.upsertOnline({
      'uuid_user_content_state': uuidUserContentState,
      'uuid_profile': uuidProfile,
      'uuid_content_item': uuidContentItem,
      'favorito': favorito,
      'progreso_porcentaje': _clampProgress(progresoPorcentaje),
      'ultima_posicion_segundos': math.max(0, ultimaPosicionSegundos),
      'completado': completado,
      'started_at': startedAt?.toUtc().toIso8601String(),
      'completed_at': completedAt?.toUtc().toIso8601String(),
      'created_at': createdAt.toUtc().toIso8601String(),
      'updated_at': updatedAt.toUtc().toIso8601String(),
      'deleted_at': null,
      'synced_at': DateTime.now().toUtc().toIso8601String(),
    });
    await _loadRemoteForProfile(uuidProfile);
  }

  Future<void> _loadRemoteForProfile(String uuidProfile) async {
    final service = _userContentStatesRemoteService;
    if (service == null) {
      _error = StateError('No hay servicio remoto para estados de contenido.');
      notifyListeners();
      return;
    }

    await _load(() async {
      final rows = await service.getForProfileOnline(uuidProfile);
      return rows.map(userContentStateRemoteToApp).toList();
    });
  }

  Future<void> _loadFromLocal(
    Future<List<LocalUserContentState>> Function() load, {
    bool keepPreviousError = false,
  }) async {
    await _load(
      () async => _toAppStates(await load()),
      keepPreviousError: keepPreviousError,
    );
  }

  Future<void> _load(
    Future<List<AppUserContentState>> Function() load, {
    bool keepPreviousError = false,
  }) async {
    _setLoading(true);
    final previousError = _error;
    if (!keepPreviousError) {
      _error = null;
    }

    try {
      _states = List.unmodifiable(await load());
    } catch (error) {
      _error = error;
    } finally {
      _setLoading(false);
      if (keepPreviousError && _error == null) {
        _error = previousError;
      }
    }
  }

  List<AppUserContentState> _toAppStates(List<LocalUserContentState> states) {
    return List.unmodifiable(states.map(AppUserContentState.fromLocal));
  }

  String? _resolveProfileUuid(String? uuidProfile) {
    final clean = uuidProfile?.trim();
    if (clean != null && clean.isNotEmpty) {
      _activeProfileUuid = clean;
      return clean;
    }

    final active = _activeProfileUuid?.trim();
    return active == null || active.isEmpty ? null : active;
  }

  int _clampProgress(int progresoPorcentaje) {
    return progresoPorcentaje.clamp(0, 100).toInt();
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

  void _cancelSubscription() {
    _statesSubscription?.cancel();
    _statesSubscription = null;
  }

  @override
  void dispose() {
    _statesSubscription?.cancel();
    super.dispose();
  }
}

String _buildUserContentStateUuid({
  required String uuidProfile,
  required String uuidContentItem,
}) {
  final source =
      '${uuidProfile.trim().toLowerCase()}|${uuidContentItem.trim().toLowerCase()}';
  final hash = sha256.convert(utf8.encode(source)).toString();
  final value = hash.substring(0, 32);

  return [
    value.substring(0, 8),
    value.substring(8, 12),
    value.substring(12, 16),
    value.substring(16, 20),
    value.substring(20, 32),
  ].join('-');
}

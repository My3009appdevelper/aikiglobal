import 'dart:async';

import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';

import '../local/app_database.dart';
import '../local/daos/wellness_profile_stats_dao.dart';
import '../models/app_wellness_profile_stats.dart';
import '../remote/services/wellness_profile_stats_remote_service.dart';
import '../sync/sync_mappers.dart';
import '../sync/wellness_profile_stats_sync_service.dart';

class WellnessProfileStatsController extends ChangeNotifier {
  WellnessProfileStatsController({
    required WellnessProfileStatsDao? wellnessProfileStatsDao,
    WellnessProfileStatsRemoteService? wellnessProfileStatsRemoteService,
    WellnessProfileStatsSyncService? syncService,
  }) : _wellnessProfileStatsDao = wellnessProfileStatsDao,
       _wellnessProfileStatsRemoteService = wellnessProfileStatsRemoteService,
       _syncService = syncService;

  final WellnessProfileStatsDao? _wellnessProfileStatsDao;
  final WellnessProfileStatsRemoteService? _wellnessProfileStatsRemoteService;
  final WellnessProfileStatsSyncService? _syncService;

  StreamSubscription<LocalWellnessProfileStats?>? _statsSubscription;

  AppWellnessProfileStats? _stats;
  String? _activeProfileUuid;
  bool _isLoading = false;
  bool _isSyncing = false;
  Object? _error;

  AppWellnessProfileStats? get stats => _stats;
  String? get activeProfileUuid => _activeProfileUuid;
  int get currentStreak => _effectiveCurrentStreak(_stats);
  int get longestStreak => _stats?.longestStreak ?? 0;
  int get totalActiveDays => _stats?.totalActiveDays ?? 0;
  String? get lastActivityDate => _stats?.lastActivityDate;
  bool get isLoading => _isLoading;
  bool get isSyncing => _isSyncing;
  Object? get error => _error;
  bool get hasRemote => _wellnessProfileStatsRemoteService != null;

  void watchForProfile(String uuidProfile) {
    final cleanProfile = uuidProfile.trim();
    if (cleanProfile.isEmpty) {
      clear();
      return;
    }

    _activeProfileUuid = cleanProfile;
    _cancelSubscription();

    final dao = _wellnessProfileStatsDao;
    if (dao == null) {
      unawaited(loadForProfile(cleanProfile));
      return;
    }

    _statsSubscription = dao
        .watchByProfile(cleanProfile)
        .listen(
          (localStats) {
            _stats = localStats == null
                ? null
                : AppWellnessProfileStats.fromLocal(localStats);
            _error = null;
            notifyListeners();
            if (localStats != null) {
              unawaited(_expireCurrentStreakIfNeeded(cleanProfile));
            }
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

    final dao = _wellnessProfileStatsDao;
    if (dao == null) {
      await _loadRemoteForProfile(cleanProfile);
      await _expireCurrentStreakIfNeeded(cleanProfile);
      return;
    }

    await _loadFromLocal(() => dao.getByProfile(cleanProfile));
    await _expireCurrentStreakIfNeeded(cleanProfile);
  }

  Future<void> pullFromRemote({String? uuidProfile}) async {
    final cleanProfile = _resolveProfileUuid(uuidProfile);
    if (cleanProfile == null) {
      return;
    }

    final dao = _wellnessProfileStatsDao;
    if (dao == null) {
      await _loadRemoteForProfile(cleanProfile);
      await _expireCurrentStreakIfNeeded(cleanProfile);
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
      if (_statsSubscription == null) {
        await _loadFromLocal(
          () => dao.getByProfile(cleanProfile),
          keepPreviousError: true,
        );
        await _expireCurrentStreakIfNeeded(cleanProfile);
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

    final dao = _wellnessProfileStatsDao;
    if (dao == null) {
      await _loadRemoteForProfile(cleanProfile);
      await _expireCurrentStreakIfNeeded(cleanProfile);
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
      if (_statsSubscription == null) {
        await _loadFromLocal(
          () => dao.getByProfile(cleanProfile),
          keepPreviousError: true,
        );
        await _expireCurrentStreakIfNeeded(cleanProfile);
      }
    } catch (error) {
      _error = error;
      notifyListeners();
    } finally {
      _setSyncing(false);
    }
  }

  Future<int?> registerActivity({
    required String uuidProfile,
    required String fecha,
  }) async {
    final cleanProfile = uuidProfile.trim();
    final cleanDate = _normalizeDateKey(fecha);
    if (cleanProfile.isEmpty || cleanDate.isEmpty) {
      return null;
    }

    final current = await _findStats(cleanProfile);
    final next = _nextStats(fecha: cleanDate, current: current);

    if (next == null) {
      return null;
    }

    await _upsertStats(
      uuidProfile: cleanProfile,
      currentStreak: next.currentStreak,
      longestStreak: next.longestStreak,
      lastActivityDate: next.lastActivityDate,
      totalActiveDays: next.totalActiveDays,
      updatedAt: DateTime.now().toUtc(),
    );

    final previousStreak = _effectiveCurrentStreak(current);
    return next.currentStreak > previousStreak ? next.currentStreak : null;
  }

  void clear() {
    _activeProfileUuid = null;
    _stats = null;
    _error = null;
    _isLoading = false;
    _isSyncing = false;
    _cancelSubscription();
    notifyListeners();
  }

  Future<void> _expireCurrentStreakIfNeeded(String uuidProfile) async {
    final current = await _findStats(uuidProfile);
    if (!_shouldExpireCurrentStreak(current)) {
      return;
    }

    await _upsertStats(
      uuidProfile: uuidProfile,
      currentStreak: 0,
      longestStreak: current!.longestStreak,
      lastActivityDate: current.lastActivityDate,
      totalActiveDays: current.totalActiveDays,
      updatedAt: DateTime.now().toUtc(),
    );
  }

  Future<AppWellnessProfileStats?> _findStats(String uuidProfile) async {
    final current = _stats;
    if (current != null && current.uuidProfile == uuidProfile) {
      return current;
    }

    final dao = _wellnessProfileStatsDao;
    if (dao != null) {
      final local = await dao.getByProfile(uuidProfile);
      return local == null ? null : AppWellnessProfileStats.fromLocal(local);
    }

    final remoteService = _wellnessProfileStatsRemoteService;
    if (remoteService == null) {
      return null;
    }

    final remote = await remoteService.getByProfileOnline(uuidProfile);
    return remote == null ? null : wellnessProfileStatsRemoteToApp(remote);
  }

  _NextStats? _nextStats({
    required String fecha,
    required AppWellnessProfileStats? current,
  }) {
    if (current == null) {
      return _NextStats(
        currentStreak: 1,
        longestStreak: 1,
        lastActivityDate: fecha,
        totalActiveDays: 1,
      );
    }

    final lastDate = current.lastActivityDate;
    if (lastDate == fecha) {
      return null;
    }

    if (lastDate != null && _isAfter(lastDate, fecha)) {
      return null;
    }

    final currentStreak = _isYesterday(lastDate, fecha)
        ? current.currentStreak + 1
        : 1;
    final longestStreak = currentStreak > current.longestStreak
        ? currentStreak
        : current.longestStreak;

    return _NextStats(
      currentStreak: currentStreak,
      longestStreak: longestStreak,
      lastActivityDate: fecha,
      totalActiveDays: current.totalActiveDays + 1,
    );
  }

  Future<void> _upsertStats({
    required String uuidProfile,
    required int currentStreak,
    required int longestStreak,
    required String? lastActivityDate,
    required int totalActiveDays,
    required DateTime updatedAt,
  }) async {
    final dao = _wellnessProfileStatsDao;
    if (dao != null) {
      await dao.upsertStats(
        WellnessProfileStatsTableCompanion.insert(
          uuidProfile: uuidProfile,
          currentStreak: Value(_positiveValue(currentStreak)),
          longestStreak: Value(_positiveValue(longestStreak)),
          lastActivityDate: Value(lastActivityDate),
          totalActiveDays: Value(_positiveValue(totalActiveDays)),
          updatedAt: Value(updatedAt),
          syncedAt: const Value(null),
        ),
      );
      unawaited(syncWithRemote(uuidProfile: uuidProfile));
      return;
    }

    final remoteService = _wellnessProfileStatsRemoteService;
    if (remoteService == null) {
      return;
    }

    await remoteService.upsertOnline({
      'uuid_profile': uuidProfile,
      'current_streak': _positiveValue(currentStreak),
      'longest_streak': _positiveValue(longestStreak),
      'last_activity_date': lastActivityDate,
      'total_active_days': _positiveValue(totalActiveDays),
      'updated_at': updatedAt.toUtc().toIso8601String(),
      'synced_at': DateTime.now().toUtc().toIso8601String(),
    });
    await _loadRemoteForProfile(uuidProfile);
  }

  Future<void> _loadRemoteForProfile(String uuidProfile) async {
    final service = _wellnessProfileStatsRemoteService;
    if (service == null) {
      _error = StateError(
        'No hay servicio remoto para estadísticas de bienestar.',
      );
      notifyListeners();
      return;
    }

    await _load(() async {
      final row = await service.getByProfileOnline(uuidProfile);
      return row == null ? null : wellnessProfileStatsRemoteToApp(row);
    });
  }

  Future<void> _loadFromLocal(
    Future<LocalWellnessProfileStats?> Function() load, {
    bool keepPreviousError = false,
  }) async {
    await _load(() async {
      final local = await load();
      return local == null ? null : AppWellnessProfileStats.fromLocal(local);
    }, keepPreviousError: keepPreviousError);
  }

  Future<void> _load(
    Future<AppWellnessProfileStats?> Function() load, {
    bool keepPreviousError = false,
  }) async {
    _setLoading(true);
    final previousError = _error;
    if (!keepPreviousError) {
      _error = null;
    }

    try {
      _stats = await load();
    } catch (error) {
      _error = error;
    } finally {
      _setLoading(false);
      if (keepPreviousError && _error == null) {
        _error = previousError;
      }
    }
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
    _statsSubscription?.cancel();
    _statsSubscription = null;
  }

  @override
  void dispose() {
    _statsSubscription?.cancel();
    super.dispose();
  }
}

class _NextStats {
  const _NextStats({
    required this.currentStreak,
    required this.longestStreak,
    required this.lastActivityDate,
    required this.totalActiveDays,
  });

  final int currentStreak;
  final int longestStreak;
  final String lastActivityDate;
  final int totalActiveDays;
}

String _normalizeDateKey(String value) {
  final clean = value.trim();
  if (clean.isEmpty) {
    return '';
  }
  return clean.length >= 10 ? clean.substring(0, 10) : clean;
}

bool _isYesterday(String? lastDate, String currentDate) {
  if (lastDate == null) {
    return false;
  }

  final current = DateTime.tryParse(currentDate);
  if (current == null) {
    return false;
  }

  final yesterday = current.subtract(const Duration(days: 1));
  return _dateKey(yesterday) == _normalizeDateKey(lastDate);
}

int _effectiveCurrentStreak(AppWellnessProfileStats? stats) {
  if (_shouldExpireCurrentStreak(stats)) {
    return 0;
  }

  return _positiveValue(stats?.currentStreak ?? 0);
}

bool _shouldExpireCurrentStreak(AppWellnessProfileStats? stats) {
  if (stats == null || stats.currentStreak <= 0) {
    return false;
  }

  return !_keepsStreakAlive(stats.lastActivityDate);
}

bool _keepsStreakAlive(String? lastActivityDate) {
  final lastDate = _normalizeDateKey(lastActivityDate ?? '');
  if (lastDate.isEmpty) {
    return false;
  }

  final today = _dateKey(DateTime.now());
  if (lastDate == today || _isYesterday(lastDate, today)) {
    return true;
  }

  return _isAfter(lastDate, today);
}

bool _isAfter(String firstDate, String secondDate) {
  final first = DateTime.tryParse(_normalizeDateKey(firstDate));
  final second = DateTime.tryParse(_normalizeDateKey(secondDate));
  if (first == null || second == null) {
    return false;
  }
  return first.isAfter(second);
}

String _dateKey(DateTime date) {
  final local = date.toLocal();
  final month = local.month.toString().padLeft(2, '0');
  final day = local.day.toString().padLeft(2, '0');

  return '${local.year}-$month-$day';
}

int _positiveValue(int value) => value < 0 ? 0 : value;

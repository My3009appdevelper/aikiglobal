import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;

import 'package:crypto/crypto.dart';
import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';

import '../local/app_database.dart';
import '../local/daos/wellness_daily_logs_dao.dart';
import '../models/app_wellness_daily_log.dart';
import '../remote/services/wellness_daily_logs_remote_service.dart';
import '../sync/sync_mappers.dart';
import '../sync/wellness_daily_logs_sync_service.dart';
import 'wellness_profile_stats_controller.dart';

class WellnessDailyLogsController extends ChangeNotifier {
  WellnessDailyLogsController({
    required WellnessDailyLogsDao? wellnessDailyLogsDao,
    WellnessDailyLogsRemoteService? wellnessDailyLogsRemoteService,
    WellnessDailyLogsSyncService? syncService,
    WellnessProfileStatsController? wellnessProfileStatsController,
  }) : _wellnessDailyLogsDao = wellnessDailyLogsDao,
       _wellnessDailyLogsRemoteService = wellnessDailyLogsRemoteService,
       _syncService = syncService,
       _wellnessProfileStatsController = wellnessProfileStatsController;

  final WellnessDailyLogsDao? _wellnessDailyLogsDao;
  final WellnessDailyLogsRemoteService? _wellnessDailyLogsRemoteService;
  final WellnessDailyLogsSyncService? _syncService;
  final WellnessProfileStatsController? _wellnessProfileStatsController;

  StreamSubscription<List<LocalWellnessDailyLog>>? _logsSubscription;

  List<AppWellnessDailyLog> _logs = const [];
  String? _activeProfileUuid;
  bool _isLoading = false;
  bool _isSyncing = false;
  Object? _error;

  List<AppWellnessDailyLog> get logs => _logs;
  String? get activeProfileUuid => _activeProfileUuid;
  bool get isLoading => _isLoading;
  bool get isSyncing => _isSyncing;
  Object? get error => _error;
  bool get hasRemote => _wellnessDailyLogsRemoteService != null;

  AppWellnessDailyLog? get todayLog {
    return logForDate(DateTime.now());
  }

  List<AppWellnessDailyLog> get weekLogs {
    final now = DateTime.now();
    final start = DateTime(
      now.year,
      now.month,
      now.day,
    ).subtract(Duration(days: now.weekday - DateTime.monday));
    final weekDates = {
      for (var index = 0; index < 7; index++)
        _dateKey(start.add(Duration(days: index))),
    };

    final items = _logs.where((log) {
      return log.deletedAt == null && weekDates.contains(log.fecha);
    }).toList();

    items.sort((a, b) => a.fecha.compareTo(b.fecha));
    return List.unmodifiable(items);
  }

  int get currentStreak {
    final activeDates = {
      for (final log in _logs)
        if (log.deletedAt == null && log.hasActivity) log.fecha,
    };

    var date = DateTime.now();
    var streak = 0;

    while (activeDates.contains(_dateKey(date))) {
      streak++;
      date = date.subtract(const Duration(days: 1));
    }

    return streak;
  }

  AppWellnessDailyLog? logForDate(DateTime date) {
    final key = _dateKey(date);
    for (final log in _logs) {
      if (log.deletedAt == null && log.fecha == key) {
        return log;
      }
    }
    return null;
  }

  void watchForProfile(String uuidProfile) {
    final cleanProfile = uuidProfile.trim();
    if (cleanProfile.isEmpty) {
      clear();
      return;
    }

    _activeProfileUuid = cleanProfile;
    _cancelSubscription();

    final dao = _wellnessDailyLogsDao;
    if (dao == null) {
      unawaited(loadForProfile(cleanProfile));
      return;
    }

    _logsSubscription = dao
        .watchForProfile(cleanProfile)
        .listen(
          (localLogs) {
            _logs = _toAppLogs(localLogs);
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

    final dao = _wellnessDailyLogsDao;
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

    final dao = _wellnessDailyLogsDao;
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
      if (_logsSubscription == null) {
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

    final dao = _wellnessDailyLogsDao;
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
      if (_logsSubscription == null) {
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

  Future<void> saveCheckIn({
    required String uuidProfile,
    DateTime? date,
    String? mood,
    int energia = 0,
    int calma = 0,
    int descanso = 0,
    int conexion = 0,
    String? nota,
  }) async {
    final cleanProfile = uuidProfile.trim();
    if (cleanProfile.isEmpty) {
      return;
    }

    final fecha = _dateKey(date ?? DateTime.now());
    final current = await _findLog(cleanProfile, fecha);
    final now = DateTime.now().toUtc();

    await _upsertLog(
      uuidProfile: cleanProfile,
      fecha: fecha,
      mood: _cleanNullableText(mood),
      energia: _clampMetric(energia),
      calma: _clampMetric(calma),
      descanso: _clampMetric(descanso),
      conexion: _clampMetric(conexion),
      meditacionCompletada: current?.meditacionCompletada ?? false,
      minutosBienestar: current?.minutosBienestar ?? 0,
      nota: _cleanNullableText(nota),
      createdAt: current?.createdAt ?? now,
      updatedAt: now,
    );

    if (_hasActivity(
      mood: mood,
      energia: energia,
      calma: calma,
      descanso: descanso,
      conexion: conexion,
      nota: nota,
    )) {
      await _registerActivity(uuidProfile: cleanProfile, fecha: fecha);
    }
  }

  Future<void> addWellnessMinutes({
    required String uuidProfile,
    DateTime? date,
    required int minutes,
  }) async {
    final cleanProfile = uuidProfile.trim();
    if (cleanProfile.isEmpty) {
      return;
    }

    final fecha = _dateKey(date ?? DateTime.now());
    final current = await _findLog(cleanProfile, fecha);
    final now = DateTime.now().toUtc();
    final cleanMinutes = math.max(0, minutes);

    await _upsertLog(
      uuidProfile: cleanProfile,
      fecha: fecha,
      mood: current?.mood,
      energia: current?.energia ?? 0,
      calma: current?.calma ?? 0,
      descanso: current?.descanso ?? 0,
      conexion: current?.conexion ?? 0,
      meditacionCompletada: current?.meditacionCompletada ?? false,
      minutosBienestar: (current?.minutosBienestar ?? 0) + cleanMinutes,
      nota: current?.nota,
      createdAt: current?.createdAt ?? now,
      updatedAt: now,
    );

    if (cleanMinutes > 0) {
      await _registerActivity(uuidProfile: cleanProfile, fecha: fecha);
    }
  }

  Future<WellnessStreakChangeEvent?> markMeditationCompleted({
    required String uuidProfile,
    DateTime? date,
    int minutes = 0,
  }) async {
    final cleanProfile = uuidProfile.trim();
    if (cleanProfile.isEmpty) {
      return null;
    }

    final fecha = _dateKey(date ?? DateTime.now());
    final current = await _findLog(cleanProfile, fecha);
    final now = DateTime.now().toUtc();
    final cleanMinutes = math.max(0, minutes);

    await _upsertLog(
      uuidProfile: cleanProfile,
      fecha: fecha,
      mood: current?.mood,
      energia: current?.energia ?? 0,
      calma: current?.calma ?? 0,
      descanso: current?.descanso ?? 0,
      conexion: current?.conexion ?? 0,
      meditacionCompletada: true,
      minutosBienestar: (current?.minutosBienestar ?? 0) + cleanMinutes,
      nota: current?.nota,
      createdAt: current?.createdAt ?? now,
      updatedAt: now,
    );

    return _registerActivity(uuidProfile: cleanProfile, fecha: fecha);
  }

  void clear() {
    _activeProfileUuid = null;
    _logs = const [];
    _error = null;
    _isLoading = false;
    _isSyncing = false;
    _cancelSubscription();
    notifyListeners();
  }

  Future<AppWellnessDailyLog?> _findLog(
    String uuidProfile,
    String fecha,
  ) async {
    AppWellnessDailyLog? current;
    for (final log in _logs) {
      if (log.uuidProfile == uuidProfile &&
          log.fecha == fecha &&
          log.deletedAt == null) {
        current = log;
        break;
      }
    }

    if (current != null) {
      return current;
    }

    final dao = _wellnessDailyLogsDao;
    if (dao != null) {
      final local = await dao.getByProfileAndDate(uuidProfile, fecha);
      return local == null ? null : AppWellnessDailyLog.fromLocal(local);
    }

    final remoteService = _wellnessDailyLogsRemoteService;
    if (remoteService == null) {
      return null;
    }

    final remote = await remoteService.getByProfileAndDateOnline(
      uuidProfile: uuidProfile,
      fecha: fecha,
    );

    return remote == null ? null : wellnessDailyLogRemoteToApp(remote);
  }

  Future<void> _upsertLog({
    required String uuidProfile,
    required String fecha,
    required int energia,
    required int calma,
    required int descanso,
    required int conexion,
    required bool meditacionCompletada,
    required int minutosBienestar,
    required DateTime createdAt,
    required DateTime updatedAt,
    String? mood,
    String? nota,
  }) async {
    final uuidDailyLog = _buildDailyLogUuid(
      uuidProfile: uuidProfile,
      fecha: fecha,
    );

    final dao = _wellnessDailyLogsDao;
    if (dao != null) {
      await dao.upsertDailyLog(
        WellnessDailyLogsTableCompanion.insert(
          uuidDailyLog: uuidDailyLog,
          uuidProfile: uuidProfile,
          fecha: fecha,
          mood: Value(mood),
          energia: Value(_clampMetric(energia)),
          calma: Value(_clampMetric(calma)),
          descanso: Value(_clampMetric(descanso)),
          conexion: Value(_clampMetric(conexion)),
          meditacionCompletada: Value(meditacionCompletada),
          minutosBienestar: Value(math.max(0, minutosBienestar)),
          nota: Value(nota),
          createdAt: Value(createdAt),
          updatedAt: Value(updatedAt),
          deletedAt: const Value(null),
          syncedAt: const Value(null),
        ),
      );
      unawaited(syncWithRemote(uuidProfile: uuidProfile));
      return;
    }

    final remoteService = _wellnessDailyLogsRemoteService;
    if (remoteService == null) {
      return;
    }

    await remoteService.upsertOnline({
      'uuid_daily_log': uuidDailyLog,
      'uuid_profile': uuidProfile,
      'fecha': fecha,
      'mood': mood,
      'energia': _clampMetric(energia),
      'calma': _clampMetric(calma),
      'descanso': _clampMetric(descanso),
      'conexion': _clampMetric(conexion),
      'meditacion_completada': meditacionCompletada,
      'minutos_bienestar': math.max(0, minutosBienestar),
      'nota': nota,
      'created_at': createdAt.toUtc().toIso8601String(),
      'updated_at': updatedAt.toUtc().toIso8601String(),
      'deleted_at': null,
      'synced_at': DateTime.now().toUtc().toIso8601String(),
    });
    await _loadRemoteForProfile(uuidProfile);
  }

  Future<void> _loadRemoteForProfile(String uuidProfile) async {
    final service = _wellnessDailyLogsRemoteService;
    if (service == null) {
      _error = StateError(
        'No hay servicio remoto para registros diarios de bienestar.',
      );
      notifyListeners();
      return;
    }

    await _load(() async {
      final rows = await service.getForProfileOnline(uuidProfile);
      return rows.map(wellnessDailyLogRemoteToApp).toList();
    });
  }

  Future<void> _loadFromLocal(
    Future<List<LocalWellnessDailyLog>> Function() load, {
    bool keepPreviousError = false,
  }) async {
    await _load(
      () async => _toAppLogs(await load()),
      keepPreviousError: keepPreviousError,
    );
  }

  Future<void> _load(
    Future<List<AppWellnessDailyLog>> Function() load, {
    bool keepPreviousError = false,
  }) async {
    _setLoading(true);
    final previousError = _error;
    if (!keepPreviousError) {
      _error = null;
    }

    try {
      _logs = List.unmodifiable(await load());
    } catch (error) {
      _error = error;
    } finally {
      _setLoading(false);
      if (keepPreviousError && _error == null) {
        _error = previousError;
      }
    }
  }

  List<AppWellnessDailyLog> _toAppLogs(List<LocalWellnessDailyLog> logs) {
    return List.unmodifiable(logs.map(AppWellnessDailyLog.fromLocal));
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

  int _clampMetric(int value) {
    return value.clamp(0, 5).toInt();
  }

  String? _cleanNullableText(String? value) {
    final clean = value?.trim();
    return clean == null || clean.isEmpty ? null : clean;
  }

  bool _hasActivity({
    String? mood,
    required int energia,
    required int calma,
    required int descanso,
    required int conexion,
    String? nota,
  }) {
    return _cleanNullableText(mood) != null ||
        _clampMetric(energia) > 0 ||
        _clampMetric(calma) > 0 ||
        _clampMetric(descanso) > 0 ||
        _clampMetric(conexion) > 0 ||
        _cleanNullableText(nota) != null;
  }

  Future<WellnessStreakChangeEvent?> _registerActivity({
    required String uuidProfile,
    required String fecha,
  }) async {
    return _wellnessProfileStatsController?.registerActivity(
      uuidProfile: uuidProfile,
      fecha: fecha,
    );
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
    _logsSubscription?.cancel();
    _logsSubscription = null;
  }

  @override
  void dispose() {
    _logsSubscription?.cancel();
    super.dispose();
  }
}

String _dateKey(DateTime date) {
  final local = date.toLocal();
  final month = local.month.toString().padLeft(2, '0');
  final day = local.day.toString().padLeft(2, '0');

  return '${local.year}-$month-$day';
}

String _buildDailyLogUuid({
  required String uuidProfile,
  required String fecha,
}) {
  final source =
      '${uuidProfile.trim().toLowerCase()}|${fecha.trim().toLowerCase()}';
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

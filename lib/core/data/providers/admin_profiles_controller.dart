import 'dart:async';

import 'package:flutter/foundation.dart';

import '../local/daos/profiles_dao.dart';
import '../local/daos/wellness_profile_stats_dao.dart';
import '../local/app_database.dart';
import '../models/app_profile.dart';
import '../models/app_wellness_profile_stats.dart';
import '../remote/services/profiles_remote_service.dart';
import '../remote/services/wellness_profile_stats_remote_service.dart';
import '../sync/profiles_sync_service.dart';
import '../sync/sync_mappers.dart';

class AdminProfilesController extends ChangeNotifier {
  AdminProfilesController({
    required ProfilesDao? profilesDao,
    ProfilesRemoteService? profilesRemoteService,
    WellnessProfileStatsDao? wellnessProfileStatsDao,
    WellnessProfileStatsRemoteService? wellnessProfileStatsRemoteService,
    ProfilesSyncService? profilesSyncService,
  }) : _profilesDao = profilesDao,
       _profilesRemoteService = profilesRemoteService,
       _wellnessProfileStatsDao = wellnessProfileStatsDao,
       _wellnessProfileStatsRemoteService = wellnessProfileStatsRemoteService,
       _profilesSyncService = profilesSyncService;

  final ProfilesDao? _profilesDao;
  final ProfilesRemoteService? _profilesRemoteService;
  final WellnessProfileStatsDao? _wellnessProfileStatsDao;
  final WellnessProfileStatsRemoteService? _wellnessProfileStatsRemoteService;
  final ProfilesSyncService? _profilesSyncService;

  StreamSubscription<List<LocalProfile>>? _profilesSubscription;

  List<AppProfile> _profiles = const [];
  Map<String, int> _currentStreakByProfileUuid = const {};
  bool _isLoading = false;
  bool _isSyncing = false;
  Object? _error;

  List<AppProfile> get profiles => _profiles;
  bool get isLoading => _isLoading;
  bool get isSyncing => _isSyncing;
  Object? get error => _error;
  bool get hasRemote =>
      _profilesRemoteService != null ||
      _wellnessProfileStatsRemoteService != null;

  int get totalUsers => _profiles.length;
  int get activeUsers => _profiles.where((profile) => profile.activo).length;

  int currentStreakForProfile(String uuidProfile) {
    return _currentStreakByProfileUuid[_cleanUuid(uuidProfile)] ?? 0;
  }

  void watchProfiles() {
    final dao = _profilesDao;
    if (dao == null) {
      unawaited(loadFromRemote());
      return;
    }

    _cancelSubscriptions();
    _error = null;

    _profilesSubscription = dao.watchAllNotDeleted().listen(
      (rows) async {
        final nextProfiles = rows
            .map((row) => AppProfile.fromLocal(row))
            .toList(growable: false);
        _profiles = List.unmodifiable(_sortProfiles(nextProfiles));
        _error = null;
        await _loadStreaksForProfiles(_profiles);
        notifyListeners();
      },
      onError: (Object error) {
        _error = error;
        notifyListeners();
      },
    );

    unawaited(pullFromRemote());
  }

  Future<void> loadFromRemote() async {
    await _loadAllProfilesFromRemote();
  }

  Future<void> pullFromRemote() async {
    final dao = _profilesDao;
    if (dao == null) {
      await _loadAllProfilesFromRemote();
      return;
    }

    final syncService = _profilesSyncService;
    if (syncService == null) {
      await _loadFromLocal(dao.getAllNotDeleted);
      return;
    }

    _setSyncing(true);
    _error = null;
    try {
      await syncService.sync();
      if (_profilesSubscription == null) {
        await _loadFromLocal(dao.getAllNotDeleted);
      }
    } catch (error) {
      _error = error;
      notifyListeners();
    } finally {
      _setSyncing(false);
    }
  }

  Future<void> refreshFromRemote() async {
    await pullFromRemote();
  }

  void clear() {
    _profiles = const [];
    _currentStreakByProfileUuid = const {};
    _error = null;
    _isLoading = false;
    _isSyncing = false;
    notifyListeners();
  }

  Future<void> _loadAllProfilesFromRemote() async {
    final remoteService = _profilesRemoteService;
    if (remoteService == null) {
      _error = StateError('No hay servicio remoto para perfiles.');
      notifyListeners();
      return;
    }

    await _load(() async {
      final rows = await remoteService.getAllProfilesNotDeletedOnline();
      final nextProfiles = rows.map(profileRemoteToApp).toList();
      await _setProfiles(nextProfiles);
    });
  }

  Future<void> _loadFromLocal(
    Future<List<LocalProfile>> Function() load,
  ) async {
    await _load(() async {
      final rows = await load();
      await _setProfiles(rows.map(AppProfile.fromLocal).toList());
    });
  }

  Future<void> _load(Future<void> Function() loader) async {
    _setLoading(true);
    try {
      await loader();
    } catch (error) {
      _error = error;
    } finally {
      _setLoading(false);
      if (_profiles.isEmpty) {
        _currentStreakByProfileUuid = const {};
      }
    }
  }

  Future<void> _setProfiles(List<AppProfile> nextProfiles) async {
    _profiles = List.unmodifiable(_sortProfiles(nextProfiles));
    await _loadStreaksForProfiles(_profiles);
    notifyListeners();
  }

  Future<void> _loadStreaksForProfiles(List<AppProfile> profiles) async {
    if (profiles.isEmpty) {
      _currentStreakByProfileUuid = const {};
      return;
    }

    final rows = await Future.wait(
      profiles.map((profile) async {
        final uuid = _cleanUuid(profile.uuidProfile);
        final streak = await _loadCurrentStreakForProfile(uuid);
        return MapEntry(uuid, streak);
      }),
    );

    _currentStreakByProfileUuid = Map.unmodifiable({
      for (final row in rows) row.key: row.value,
    });
  }

  Future<int> _loadCurrentStreakForProfile(String uuidProfile) async {
    if (uuidProfile.isEmpty) {
      return 0;
    }

    final localStatsDao = _wellnessProfileStatsDao;
    if (localStatsDao != null) {
      final localStats = await localStatsDao.getByProfile(uuidProfile);
      if (localStats != null) {
        return _effectiveCurrentStreak(
          AppWellnessProfileStats.fromLocal(localStats),
        );
      }
    }

    final remoteStatsService = _wellnessProfileStatsRemoteService;
    if (remoteStatsService == null) {
      return 0;
    }

    final remoteStats = await remoteStatsService.getByProfileOnline(uuidProfile);
    if (remoteStats == null) {
      return 0;
    }

    return _effectiveCurrentStreak(
      wellnessProfileStatsRemoteToApp(remoteStats),
    );
  }

  int _effectiveCurrentStreak(AppWellnessProfileStats stats) {
    if (stats.currentStreak <= 0) {
      return 0;
    }
    if (_keepsStreakAlive(stats.lastActivityDate)) {
      return stats.currentStreak;
    }
    return 0;
  }

  bool _keepsStreakAlive(String? lastActivityDate) {
    final last = _normalizeDateKey(lastActivityDate);
    if (last.isEmpty) {
      return false;
    }

    final today = _dateKey(DateTime.now());
    final yesterday = _dateKey(DateTime.now().subtract(const Duration(days: 1)));

    if (last == today || last == yesterday) {
      return true;
    }

    final lastDate = DateTime.tryParse(last);
    final todayDate = DateTime.tryParse(today);
    if (lastDate == null || todayDate == null) {
      return false;
    }

    return lastDate.isAfter(todayDate);
  }

  String _normalizeDateKey(String? value) {
    if (value == null || value.isEmpty) {
      return '';
    }
    return value.length >= 10 ? value.substring(0, 10) : value;
  }

  String _dateKey(DateTime date) {
    final local = date.toLocal();
    final month = local.month.toString().padLeft(2, '0');
    final day = local.day.toString().padLeft(2, '0');
    return '${local.year}-$month-$day';
  }

  List<AppProfile> _sortProfiles(List<AppProfile> profiles) {
    final sorted = List<AppProfile>.from(profiles);
    sorted.sort((left, right) {
      final leftName = (left.nombre ?? left.email).toLowerCase();
      final rightName = (right.nombre ?? right.email).toLowerCase();
      return leftName.compareTo(rightName);
    });
    return sorted;
  }

  String _cleanUuid(String value) => value.trim();

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

  void _cancelSubscriptions() {
    _profilesSubscription?.cancel();
    _profilesSubscription = null;
  }

  @override
  void dispose() {
    _cancelSubscriptions();
    super.dispose();
  }
}

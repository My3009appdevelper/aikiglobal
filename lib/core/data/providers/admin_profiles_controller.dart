import 'dart:async';

import 'package:flutter/foundation.dart';

import '../local/daos/profiles_dao.dart';
import '../local/daos/wellness_profile_stats_dao.dart';
import '../local/app_database.dart';
import '../models/app_profile.dart';
import '../models/app_subscription.dart';
import '../models/app_wellness_profile_stats.dart';
import '../remote/services/profiles_remote_service.dart';
import '../remote/services/subscription_remote_service.dart';
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
    SubscriptionRemoteService? subscriptionRemoteService,
  }) : _profilesDao = profilesDao,
       _profilesRemoteService = profilesRemoteService,
       _wellnessProfileStatsDao = wellnessProfileStatsDao,
       _wellnessProfileStatsRemoteService = wellnessProfileStatsRemoteService,
       _profilesSyncService = profilesSyncService,
       _subscriptionRemoteService = subscriptionRemoteService;

  final ProfilesDao? _profilesDao;
  final ProfilesRemoteService? _profilesRemoteService;
  final WellnessProfileStatsDao? _wellnessProfileStatsDao;
  final WellnessProfileStatsRemoteService? _wellnessProfileStatsRemoteService;
  final ProfilesSyncService? _profilesSyncService;
  final SubscriptionRemoteService? _subscriptionRemoteService;

  StreamSubscription<List<LocalProfile>>? _profilesSubscription;

  List<AppProfile> _profiles = const [];
  Map<String, int> _currentStreakByProfileUuid = const {};
  List<AppSubscriptionProduct> _subscriptionProducts = const [];
  Map<String, AppUserSubscription> _subscriptionByProfileUuid = const {};
  bool _isLoading = false;
  bool _isSyncing = false;
  Object? _error;
  Object? _subscriptionError;

  List<AppProfile> get profiles => _profiles;
  bool get isLoading => _isLoading;
  bool get isSyncing => _isSyncing;
  Object? get error => _error;
  Object? get subscriptionError => _subscriptionError;
  List<AppSubscriptionProduct> get subscriptionProducts =>
      _subscriptionProducts;
  bool get hasRemote =>
      _profilesRemoteService != null ||
      _wellnessProfileStatsRemoteService != null;

  int get totalUsers => _profiles.length;
  int get activeUsers => _profiles.where((profile) => profile.activo).length;

  int currentStreakForProfile(String uuidProfile) {
    return _currentStreakByProfileUuid[_cleanUuid(uuidProfile)] ?? 0;
  }

  AppUserSubscription? subscriptionForProfile(String uuidProfile) {
    return _subscriptionByProfileUuid[_cleanUuid(uuidProfile)];
  }

  bool hasActiveSubscriptionForProfile(String uuidProfile) {
    return subscriptionForProfile(uuidProfile)?.hasPremiumAccess ?? false;
  }

  String? subscriptionProductCodeForProfile(String uuidProfile) {
    final subscription = subscriptionForProfile(uuidProfile);
    if (subscription == null || !subscription.hasPremiumAccess) {
      return null;
    }

    for (final product in _subscriptionProducts) {
      if (product.uuidSubscriptionProduct ==
          subscription.uuidSubscriptionProduct) {
        return product.codigo;
      }
    }
    return null;
  }

  void watchProfiles({bool pullRemote = true}) {
    final dao = _profilesDao;
    if (dao == null) {
      if (pullRemote) {
        unawaited(loadFromRemote());
      }
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

    if (pullRemote) {
      unawaited(pullFromRemote());
    }
  }

  Future<void> loadFromRemote() async {
    await _loadAllProfilesFromRemote();
    await _loadSubscriptionData();
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
      await _loadSubscriptionData();
      return;
    }

    _setSyncing(true);
    _error = null;
    try {
      await syncService.sync();
      if (_profilesSubscription == null) {
        await _loadFromLocal(dao.getAllNotDeleted);
      }
      await _loadSubscriptionData();
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

  Future<void> syncWithRemote() async {
    await pullFromRemote();
  }

  Future<void> grantSubscription({
    required String uuidProfile,
    required AppSubscriptionProduct product,
    DateTime? currentPeriodEnd,
  }) async {
    final service = _subscriptionRemoteService;
    if (service == null) {
      _subscriptionError = StateError(
        'No hay servicio remoto para suscripciones.',
      );
      notifyListeners();
      return;
    }

    _setSyncing(true);
    _subscriptionError = null;
    try {
      await service.grantManualSubscription(
        uuidProfile: uuidProfile,
        uuidSubscriptionProduct: product.uuidSubscriptionProduct,
        currentPeriodEnd: currentPeriodEnd,
      );
      await _loadSubscriptionData();
    } catch (error) {
      _subscriptionError = error;
      notifyListeners();
      rethrow;
    } finally {
      _setSyncing(false);
    }
  }

  Future<void> revokeSubscription(String uuidUserSubscription) async {
    final service = _subscriptionRemoteService;
    if (service == null) {
      _subscriptionError = StateError(
        'No hay servicio remoto para suscripciones.',
      );
      notifyListeners();
      return;
    }

    _setSyncing(true);
    _subscriptionError = null;
    try {
      await service.revokeSubscription(uuidUserSubscription);
      await _loadSubscriptionData();
    } catch (error) {
      _subscriptionError = error;
      notifyListeners();
      rethrow;
    } finally {
      _setSyncing(false);
    }
  }

  void clear() {
    _profiles = const [];
    _currentStreakByProfileUuid = const {};
    _subscriptionProducts = const [];
    _subscriptionByProfileUuid = const {};
    _error = null;
    _subscriptionError = null;
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

  Future<void> _loadSubscriptionData() async {
    final service = _subscriptionRemoteService;
    if (service == null) {
      return;
    }

    try {
      final results = await Future.wait([
        service.getAvailableProductsOnline(),
        service.getAllSubscriptionsOnline(),
      ]);
      final products = results[0] as List<AppSubscriptionProduct>;
      final subscriptions = results[1] as List<AppUserSubscription>;
      final byProfile = <String, AppUserSubscription>{};

      for (final subscription in subscriptions) {
        final profileUuid = _cleanUuid(subscription.uuidProfile);
        final current = byProfile[profileUuid];
        if (current == null ||
            _isPreferredSubscription(subscription, current)) {
          byProfile[profileUuid] = subscription;
        }
      }

      _subscriptionProducts = List.unmodifiable(products);
      _subscriptionByProfileUuid = Map.unmodifiable(byProfile);
      _subscriptionError = null;
      notifyListeners();
    } catch (error) {
      _subscriptionError = error;
      notifyListeners();
    }
  }

  bool _isPreferredSubscription(
    AppUserSubscription candidate,
    AppUserSubscription current,
  ) {
    if (candidate.hasPremiumAccess != current.hasPremiumAccess) {
      return candidate.hasPremiumAccess;
    }

    final candidateEnd = candidate.currentPeriodEnd;
    final currentEnd = current.currentPeriodEnd;
    if (candidateEnd == null && currentEnd != null) {
      return true;
    }
    if (candidateEnd != null && currentEnd == null) {
      return false;
    }
    if (candidateEnd != null && currentEnd != null) {
      final byEnd = candidateEnd.compareTo(currentEnd);
      if (byEnd != 0) {
        return byEnd > 0;
      }
    }
    return candidate.updatedAt.isAfter(current.updatedAt);
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

    final profileUuids = profiles
        .map((profile) => _cleanUuid(profile.uuidProfile))
        .where((uuid) => uuid.isNotEmpty)
        .toList(growable: false);
    final remoteStatsService = _wellnessProfileStatsRemoteService;
    final remoteStatsByProfile = <String, AppWellnessProfileStats>{};
    var remoteStatsLoaded = false;

    if (remoteStatsService != null) {
      try {
        final remoteRows = await remoteStatsService.getForProfilesOnline(
          profileUuids,
        );
        for (final row in remoteRows) {
          final stats = wellnessProfileStatsRemoteToApp(row);
          remoteStatsByProfile[stats.uuidProfile] = stats;
        }
        remoteStatsLoaded = true;
      } catch (_) {
        // En modo offline se conserva el ultimo valor local disponible.
      }
    }

    final rows = await Future.wait(
      profiles.map((profile) async {
        final uuid = _cleanUuid(profile.uuidProfile);
        final remoteStats = remoteStatsByProfile[uuid];
        final streak = remoteStatsLoaded
            ? remoteStats == null
                  ? 0
                  : _effectiveCurrentStreak(remoteStats)
            : await _loadCurrentStreakForProfile(uuid);
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

    final remoteStats = await remoteStatsService.getByProfileOnline(
      uuidProfile,
    );
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
    final yesterday = _dateKey(
      DateTime.now().subtract(const Duration(days: 1)),
    );

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

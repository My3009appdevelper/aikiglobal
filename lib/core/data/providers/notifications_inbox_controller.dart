import 'dart:async';

import 'package:flutter/foundation.dart';

import '../local/app_database.dart';
import '../local/daos/notifications_inbox_dao.dart';
import '../models/app_notification_inbox_item.dart';
import '../remote/services/notifications_inbox_remote_service.dart';
import '../sync/notifications_inbox_sync_service.dart';
import '../sync/sync_mappers.dart';

class NotificationsInboxController extends ChangeNotifier {
  NotificationsInboxController({
    required NotificationsInboxDao? notificationsInboxDao,
    NotificationsInboxRemoteService? notificationsInboxRemoteService,
    NotificationsInboxSyncService? syncService,
  }) : _dao = notificationsInboxDao,
       _remoteService = notificationsInboxRemoteService,
       _syncService = syncService;

  final NotificationsInboxDao? _dao;
  final NotificationsInboxRemoteService? _remoteService;
  final NotificationsInboxSyncService? _syncService;

  StreamSubscription<List<LocalNotificationInboxItem>>? _subscription;
  List<AppNotificationInboxItem> _notifications = const [];
  String? _activeProfileUuid;
  bool _isLoading = false;
  bool _isSyncing = false;
  Object? _error;
  int _profileGeneration = 0;
  int _loadOperationId = 0;
  int _syncOperationId = 0;

  List<AppNotificationInboxItem> get notifications => _notifications;
  String? get activeProfileUuid => _activeProfileUuid;
  int get unreadCount =>
      _notifications.where((notification) => !notification.isRead).length;
  bool get isLoading => _isLoading;
  bool get isSyncing => _isSyncing;
  Object? get error => _error;

  void watchForProfile(String uuidProfile, {bool pullRemote = true}) {
    final cleanProfile = uuidProfile.trim();
    if (cleanProfile.isEmpty) {
      clear();
      return;
    }

    _activateProfile(cleanProfile);
    final generation = _profileGeneration;
    _cancelSubscription();
    final dao = _dao;
    if (dao == null) {
      unawaited(loadForProfile(cleanProfile));
      return;
    }

    _subscription = dao
        .watchForProfile(cleanProfile)
        .listen(
          (rows) {
            if (!_isCurrentProfile(cleanProfile, generation)) {
              return;
            }
            _notifications = _toApp(rows);
            _error = null;
            notifyListeners();
          },
          onError: (Object error) {
            if (!_isCurrentProfile(cleanProfile, generation)) {
              return;
            }
            _error = error;
            notifyListeners();
          },
        );

    if (pullRemote) {
      unawaited(pullFromRemote(uuidProfile: cleanProfile));
    }
  }

  Future<void> loadForProfile(String uuidProfile) async {
    final cleanProfile = uuidProfile.trim();
    if (cleanProfile.isEmpty) {
      clear();
      return;
    }
    _activateProfile(cleanProfile);
    final generation = _profileGeneration;
    final dao = _dao;
    if (dao != null) {
      await _load(
        cleanProfile,
        generation,
        () async => _toApp(await dao.getForProfile(cleanProfile)),
      );
      return;
    }
    await _loadRemoteForProfile(cleanProfile, generation: generation);
  }

  Future<void> pullFromRemote({String? uuidProfile}) async {
    final profileUuid = _resolveProfileUuid(uuidProfile);
    if (profileUuid == null || profileUuid != _activeProfileUuid) {
      return;
    }
    final generation = _profileGeneration;
    final syncService = _syncService;
    if (_dao == null || syncService == null) {
      await _loadRemoteForProfile(profileUuid, generation: generation);
      return;
    }
    await _runSync(
      () => syncService.pullForProfile(profileUuid),
      profileUuid,
      generation,
    );
  }

  Future<void> syncWithRemote({String? uuidProfile}) async {
    final profileUuid = _resolveProfileUuid(uuidProfile);
    if (profileUuid == null || profileUuid != _activeProfileUuid) {
      return;
    }
    final generation = _profileGeneration;
    final syncService = _syncService;
    if (_dao == null || syncService == null) {
      await _loadRemoteForProfile(profileUuid, generation: generation);
      return;
    }
    await _runSync(
      () => syncService.syncForProfile(profileUuid),
      profileUuid,
      generation,
    );
  }

  Future<AppNotificationInboxItem?> openNotification(
    String uuidNotificationInbox,
  ) async {
    final profileUuid = _resolveProfileUuid(null);
    final cleanUuid = uuidNotificationInbox.trim();
    if (profileUuid == null || cleanUuid.isEmpty) {
      return null;
    }
    final generation = _profileGeneration;

    final dao = _dao;
    if (dao != null) {
      var item = await dao.getByUuid(cleanUuid);
      if (item == null) {
        await pullFromRemote(uuidProfile: profileUuid);
        if (!_isCurrentProfile(profileUuid, generation)) {
          return null;
        }
        item = await dao.getByUuid(cleanUuid);
      }
      if (item == null || item.uuidProfile != profileUuid) {
        return null;
      }
      await dao.markOpened(cleanUuid);
      if (!_isCurrentProfile(profileUuid, generation)) {
        return null;
      }
      await _reloadLocal(profileUuid, generation: generation);
      if (_syncService != null) {
        unawaited(syncWithRemote(uuidProfile: profileUuid));
      }
      final opened = await dao.getByUuid(cleanUuid);
      return opened == null ? null : AppNotificationInboxItem.fromLocal(opened);
    }

    var item = _notificationByUuid(cleanUuid);
    final service = _remoteService;
    if (item == null && service != null) {
      await _loadRemoteForProfile(profileUuid, generation: generation);
      if (!_isCurrentProfile(profileUuid, generation)) {
        return null;
      }
      item = _notificationByUuid(cleanUuid);
    }
    if (item == null || item.uuidProfile != profileUuid || service == null) {
      return null;
    }
    final now = DateTime.now().toUtc();
    await service.updateReadStateOnline(
      cleanUuid,
      readAt: item.readAt ?? now,
      openedAt: item.openedAt ?? now,
    );
    await _loadRemoteForProfile(profileUuid, generation: generation);
    if (!_isCurrentProfile(profileUuid, generation)) {
      return null;
    }
    return _notificationByUuid(cleanUuid);
  }

  Future<void> markAllRead() async {
    final profileUuid = _resolveProfileUuid(null);
    if (profileUuid == null) {
      return;
    }
    final generation = _profileGeneration;

    final dao = _dao;
    if (dao != null) {
      await dao.markAllRead(profileUuid);
      await _reloadLocal(profileUuid, generation: generation);
      if (_syncService != null) {
        unawaited(syncWithRemote(uuidProfile: profileUuid));
      }
      return;
    }

    final service = _remoteService;
    if (service == null) {
      return;
    }
    final now = DateTime.now().toUtc();
    for (final item in _notifications.where((item) => !item.isRead)) {
      await service.updateReadStateOnline(
        item.uuidNotificationInbox,
        readAt: now,
        openedAt: item.openedAt,
      );
    }
    await _loadRemoteForProfile(profileUuid, generation: generation);
  }

  void clear() {
    _cancelSubscription();
    _notifications = const [];
    _activeProfileUuid = null;
    _profileGeneration++;
    _loadOperationId++;
    _syncOperationId++;
    _isLoading = false;
    _isSyncing = false;
    _error = null;
    notifyListeners();
  }

  Future<void> _reloadLocal(
    String profileUuid, {
    required int generation,
  }) async {
    final dao = _dao;
    if (dao == null) {
      return;
    }
    final rows = await dao.getForProfile(profileUuid);
    if (!_isCurrentProfile(profileUuid, generation)) {
      return;
    }
    _notifications = _toApp(rows);
    _error = null;
    notifyListeners();
  }

  Future<void> _loadRemoteForProfile(
    String profileUuid, {
    required int generation,
  }) async {
    final service = _remoteService;
    if (service == null) {
      return;
    }
    await _load(profileUuid, generation, () async {
      final rows = await service.getForProfileOnline(profileUuid);
      return List.unmodifiable(rows.map(notificationInboxRemoteToApp));
    });
  }

  Future<void> _load(
    String profileUuid,
    int generation,
    Future<List<AppNotificationInboxItem>> Function() operation,
  ) async {
    if (!_isCurrentProfile(profileUuid, generation)) {
      return;
    }
    final operationId = ++_loadOperationId;
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final notifications = await operation();
      if (_isCurrentProfile(profileUuid, generation) &&
          operationId == _loadOperationId) {
        _notifications = notifications;
      }
    } catch (error) {
      if (_isCurrentProfile(profileUuid, generation) &&
          operationId == _loadOperationId) {
        _error = error;
      }
    } finally {
      if (_isCurrentProfile(profileUuid, generation) &&
          operationId == _loadOperationId) {
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  Future<void> _runSync(
    Future<void> Function() operation,
    String profileUuid,
    int generation,
  ) async {
    if (!_isCurrentProfile(profileUuid, generation)) {
      return;
    }
    final operationId = ++_syncOperationId;
    _isSyncing = true;
    _error = null;
    notifyListeners();
    try {
      await operation();
      await _reloadLocal(profileUuid, generation: generation);
    } catch (error) {
      if (_isCurrentProfile(profileUuid, generation) &&
          operationId == _syncOperationId) {
        _error = error;
      }
    } finally {
      if (_isCurrentProfile(profileUuid, generation) &&
          operationId == _syncOperationId) {
        _isSyncing = false;
        notifyListeners();
      }
    }
  }

  AppNotificationInboxItem? _notificationByUuid(String uuid) {
    for (final item in _notifications) {
      if (item.uuidNotificationInbox == uuid) {
        return item;
      }
    }
    return null;
  }

  String? _resolveProfileUuid(String? value) {
    final clean = (value ?? _activeProfileUuid ?? '').trim();
    return clean.isEmpty ? null : clean;
  }

  void _activateProfile(String profileUuid) {
    _activeProfileUuid = profileUuid;
    _profileGeneration++;
    _notifications = const [];
    _isLoading = false;
    _isSyncing = false;
    _error = null;
  }

  bool _isCurrentProfile(String profileUuid, int generation) {
    return _activeProfileUuid == profileUuid &&
        _profileGeneration == generation;
  }

  List<AppNotificationInboxItem> _toApp(List<LocalNotificationInboxItem> rows) {
    return List.unmodifiable(rows.map(AppNotificationInboxItem.fromLocal));
  }

  void _cancelSubscription() {
    _subscription?.cancel();
    _subscription = null;
  }

  @override
  void dispose() {
    _cancelSubscription();
    super.dispose();
  }
}

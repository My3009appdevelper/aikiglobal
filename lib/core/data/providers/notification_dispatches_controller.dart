import 'dart:async';

import 'package:flutter/foundation.dart';

import '../local/app_database.dart';
import '../local/daos/notification_dispatches_dao.dart';
import '../models/app_notification_dispatch.dart';
import '../models/manual_notification_dispatch_result.dart';
import '../models/notification_dispatch_analytics.dart';
import '../remote/services/manual_notification_dispatch_remote_service.dart';
import '../remote/services/notification_dispatches_remote_service.dart';
import '../sync/notification_dispatches_sync_service.dart';
import '../sync/sync_mappers.dart';

class NotificationDispatchesController extends ChangeNotifier {
  NotificationDispatchesController({
    required NotificationDispatchesDao? notificationDispatchesDao,
    NotificationDispatchesRemoteService? notificationDispatchesRemoteService,
    ManualNotificationDispatchRemoteService?
    manualNotificationDispatchRemoteService,
    NotificationDispatchesSyncService? syncService,
  }) : _dao = notificationDispatchesDao,
       _remoteService = notificationDispatchesRemoteService,
       _manualRemoteService = manualNotificationDispatchRemoteService,
       _syncService = syncService;

  final NotificationDispatchesDao? _dao;
  final NotificationDispatchesRemoteService? _remoteService;
  final ManualNotificationDispatchRemoteService? _manualRemoteService;
  final NotificationDispatchesSyncService? _syncService;

  StreamSubscription<List<LocalNotificationDispatch>>? _subscription;
  List<AppNotificationDispatch> _dispatches = const [];
  String? _activeEventUuid;
  int? _recentLimit;
  bool _isLoading = false;
  bool _isSyncing = false;
  Object? _error;
  bool _isManualCommandInFlight = false;
  Object? _manualCommandError;
  ManualNotificationAudiencePreview? _manualAudiencePreview;
  ManualNotificationDispatchAcceptance? _manualDispatchAcceptance;
  final Map<String, _CachedDispatchAnalytics> _analyticsCache = {};

  List<AppNotificationDispatch> get dispatches => _dispatches;
  String? get activeEventUuid => _activeEventUuid;
  bool get isLoading => _isLoading;
  bool get isSyncing => _isSyncing;
  Object? get error => _error;
  bool get isManualCommandInFlight => _isManualCommandInFlight;
  Object? get manualCommandError => _manualCommandError;
  ManualNotificationAudiencePreview? get manualAudiencePreview =>
      _manualAudiencePreview;
  ManualNotificationDispatchAcceptance? get manualDispatchAcceptance =>
      _manualDispatchAcceptance;

  Future<ManualNotificationAudiencePreview> previewManualEvent(
    String uuidNotificationEvent,
  ) {
    final cleanUuid = uuidNotificationEvent.trim();
    return _runManualCommand(
      (service) => service.previewManualEvent(cleanUuid),
      onSuccess: (preview) {
        _manualAudiencePreview = preview;
      },
    );
  }

  Future<ManualNotificationDispatchAcceptance> requestManualDispatch(
    String uuidNotificationEvent, {
    String? requestId,
  }) {
    final cleanUuid = uuidNotificationEvent.trim();
    return _runManualCommand(
      (service) =>
          service.requestManualDispatch(cleanUuid, requestId: requestId),
      onSuccess: (acceptance) {
        _manualDispatchAcceptance = acceptance;
      },
    );
  }

  Future<ManualNotificationDispatchAcceptance> requestManualResend(
    AppNotificationDispatch dispatch, {
    String? requestId,
  }) {
    if (!const {'completed', 'partial'}.contains(dispatch.status)) {
      throw StateError(
        'Sólo se pueden reenviar envíos completados o parciales.',
      );
    }
    return _runManualCommand(
      (service) => service.requestManualResend(
        dispatch.uuidNotificationEvent,
        dispatch.uuidNotificationDispatch,
        requestId: requestId,
      ),
      onSuccess: (acceptance) {
        _manualDispatchAcceptance = acceptance;
      },
    );
  }

  Future<ManualNotificationDispatchAcceptance> requestManualRetry(
    AppNotificationDispatch dispatch, {
    String? requestId,
  }) {
    if (dispatch.status != 'failed' || dispatch.successDeviceCount != 0) {
      throw StateError(
        'Sólo se pueden reintentar fallos sin éxitos aceptados por FCM.',
      );
    }
    return _runManualCommand(
      (service) => service.requestManualDispatch(
        dispatch.uuidNotificationEvent,
        requestId: requestId,
        retryDispatchUuid: dispatch.uuidNotificationDispatch,
      ),
      onSuccess: (acceptance) {
        _manualDispatchAcceptance = acceptance;
      },
    );
  }

  Future<NotificationDispatchAnalytics> loadAnalytics(
    AppNotificationDispatch dispatch,
  ) {
    final cached = cachedAnalyticsFor(dispatch);
    if (cached != null) {
      return Future<NotificationDispatchAnalytics>.value(cached);
    }
    return _runManualCommand(
      (service) => service.loadAnalytics(dispatch.uuidNotificationDispatch),
      onSuccess: (analytics) => _cacheAnalytics(dispatch, analytics),
    );
  }

  NotificationDispatchAnalytics? cachedAnalyticsFor(
    AppNotificationDispatch dispatch,
  ) {
    final cached = _analyticsCache[dispatch.uuidNotificationDispatch];
    if (cached == null || cached.dispatchUpdatedAt != dispatch.updatedAt) {
      return null;
    }
    return cached.analytics;
  }

  /// Calienta las analÃ­ticas de los envÃ­os recientes sin bloquear la carga
  /// local ni mezclar este trabajo con una acciÃ³n manual del administrador.
  Future<void> prefetchAnalytics({int limit = 20}) async {
    final service = _manualRemoteService;
    if (service == null || limit <= 0) {
      return;
    }
    final candidates = _dispatches.take(limit);
    for (final dispatch in candidates) {
      if (cachedAnalyticsFor(dispatch) != null) {
        continue;
      }
      try {
        final analytics = await service.loadAnalytics(
          dispatch.uuidNotificationDispatch,
        );
        _cacheAnalytics(dispatch, analytics);
      } catch (_) {
        // El detalle harÃ¡ el intento bajo demanda si el precalentamiento falla.
      }
    }
  }

  void watchRecent({int? limit, bool pullRemote = false}) {
    _activeEventUuid = null;
    _recentLimit = limit;
    _cancelSubscription();
    final dao = _dao;
    if (dao == null) {
      unawaited(loadRecent(limit: limit));
      return;
    }
    _subscription = dao
        .watchRecent(limit: limit)
        .listen(_onRows, onError: _onError);
    if (pullRemote) {
      unawaited(pullFromRemote());
    }
  }

  void watchForEvent(String uuidNotificationEvent, {bool pullRemote = false}) {
    final cleanUuid = uuidNotificationEvent.trim();
    _activeEventUuid = cleanUuid;
    _recentLimit = null;
    _cancelSubscription();
    final dao = _dao;
    if (dao == null) {
      unawaited(loadForEvent(cleanUuid));
      return;
    }
    _subscription = dao
        .watchForEvent(cleanUuid)
        .listen(_onRows, onError: _onError);
    if (pullRemote) {
      unawaited(pullFromRemote());
    }
  }

  Future<void> loadRecent({int? limit}) async {
    _activeEventUuid = null;
    _recentLimit = limit;
    final dao = _dao;
    if (dao != null) {
      await _load(() async => _toApp(await dao.getAllNotDeleted(limit: limit)));
      return;
    }
    await _loadRemoteRecent(limit: limit);
  }

  Future<void> loadForEvent(String uuidNotificationEvent) async {
    final cleanUuid = uuidNotificationEvent.trim();
    _activeEventUuid = cleanUuid;
    _recentLimit = null;
    final dao = _dao;
    if (dao != null) {
      await _load(() async => _toApp(await dao.getByEvent(cleanUuid)));
      return;
    }
    await _loadRemoteForEvent(cleanUuid);
  }

  Future<bool> hasDispatchForEvent(String uuidNotificationEvent) async {
    final cleanUuid = uuidNotificationEvent.trim();
    if (cleanUuid.isEmpty) {
      return false;
    }
    final dao = _dao;
    if (dao != null) {
      return (await dao.getByEvent(cleanUuid)).isNotEmpty;
    }
    final service = _remoteService;
    if (service != null) {
      return (await service.getForEventOnline(cleanUuid)).isNotEmpty;
    }
    return _dispatches.any(
      (dispatch) => dispatch.uuidNotificationEvent == cleanUuid,
    );
  }

  Future<void> pullFromRemote() async {
    final syncService = _syncService;
    if (_dao == null || syncService == null) {
      await _reloadRemoteView();
      return;
    }

    _isSyncing = true;
    _error = null;
    notifyListeners();
    try {
      await syncService.pull();
      await _reloadLocalView();
    } catch (error) {
      _error = error;
    } finally {
      _isSyncing = false;
      notifyListeners();
    }
  }

  /// Este modulo es generado por el servidor; su sync solo hace pull.
  Future<void> syncWithRemote() => pullFromRemote();

  void clear() {
    _cancelSubscription();
    _dispatches = const [];
    _activeEventUuid = null;
    _recentLimit = null;
    _isLoading = false;
    _isSyncing = false;
    _error = null;
    _isManualCommandInFlight = false;
    _manualCommandError = null;
    _manualAudiencePreview = null;
    _manualDispatchAcceptance = null;
    _analyticsCache.clear();
    notifyListeners();
  }

  void _cacheAnalytics(
    AppNotificationDispatch dispatch,
    NotificationDispatchAnalytics analytics,
  ) {
    _analyticsCache[dispatch.uuidNotificationDispatch] =
        _CachedDispatchAnalytics(
          dispatchUpdatedAt: dispatch.updatedAt,
          analytics: analytics,
        );
  }

  void _onRows(List<LocalNotificationDispatch> rows) {
    _dispatches = _toApp(rows);
    _error = null;
    notifyListeners();
  }

  void _onError(Object error) {
    _error = error;
    notifyListeners();
  }

  Future<void> _reloadLocalView() async {
    final eventUuid = _activeEventUuid;
    if (eventUuid != null) {
      await loadForEvent(eventUuid);
    } else {
      await loadRecent(limit: _recentLimit);
    }
  }

  Future<void> _reloadRemoteView() async {
    final eventUuid = _activeEventUuid;
    if (eventUuid != null) {
      await _loadRemoteForEvent(eventUuid);
    } else {
      await _loadRemoteRecent(limit: _recentLimit);
    }
  }

  Future<void> _loadRemoteRecent({int? limit}) async {
    final service = _remoteService;
    if (service == null) {
      return;
    }
    await _load(() async {
      final rows = await service.getRecentOnline(limit: limit);
      return List.unmodifiable(rows.map(notificationDispatchRemoteToApp));
    });
  }

  Future<void> _loadRemoteForEvent(String eventUuid) async {
    final service = _remoteService;
    if (service == null) {
      return;
    }
    await _load(() async {
      final rows = await service.getForEventOnline(eventUuid);
      return List.unmodifiable(rows.map(notificationDispatchRemoteToApp));
    });
  }

  Future<void> _load(
    Future<List<AppNotificationDispatch>> Function() operation,
  ) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _dispatches = await operation();
    } catch (error) {
      _error = error;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<T> _runManualCommand<T>(
    Future<T> Function(ManualNotificationDispatchRemoteService service)
    operation, {
    required void Function(T result) onSuccess,
  }) async {
    _isManualCommandInFlight = true;
    _manualCommandError = null;
    notifyListeners();
    try {
      final service = _manualRemoteService;
      if (service == null) {
        throw StateError(
          'No hay servicio remoto configurado para notificaciones manuales.',
        );
      }
      final result = await operation(service);
      onSuccess(result);
      return result;
    } catch (error) {
      _manualCommandError = error;
      rethrow;
    } finally {
      _isManualCommandInFlight = false;
      notifyListeners();
    }
  }

  List<AppNotificationDispatch> _toApp(List<LocalNotificationDispatch> rows) {
    return List.unmodifiable(rows.map(AppNotificationDispatch.fromLocal));
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

class _CachedDispatchAnalytics {
  const _CachedDispatchAnalytics({
    required this.dispatchUpdatedAt,
    required this.analytics,
  });

  final DateTime dispatchUpdatedAt;
  final NotificationDispatchAnalytics analytics;
}

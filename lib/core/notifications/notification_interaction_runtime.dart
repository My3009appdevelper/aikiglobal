import 'dart:async';
import 'dart:collection';

import 'package:flutter/foundation.dart';

import '../data/models/app_notification_inbox_item.dart';
import '../data/providers/notifications_inbox_controller.dart';
import 'notification_message.dart';
import 'notification_navigation_controller.dart';
import 'notification_payload_codec.dart';

typedef NotificationRetryScheduler =
    Timer Function(Duration delay, void Function() callback);

class NotificationInteractionRuntime {
  static const _pendingOpenedLimit = 20;

  NotificationInteractionRuntime({
    required NotificationMessageClient messageClient,
    required NotificationsInboxController inboxController,
    required NotificationNavigationCoordinator navigationCoordinator,
    NotificationPayloadCodec codec = const NotificationPayloadCodec(),
    List<Duration> retryDelays = const [
      Duration(seconds: 2),
      Duration(seconds: 5),
      Duration(seconds: 10),
      Duration(seconds: 30),
    ],
    NotificationRetryScheduler retryScheduler = _defaultRetryScheduler,
  }) : _messageClient = messageClient,
       _inboxController = inboxController,
       _navigationCoordinator = navigationCoordinator,
       _codec = codec,
       _retryDelays = List.unmodifiable(retryDelays),
       _retryScheduler = retryScheduler;

  final NotificationMessageClient _messageClient;
  final NotificationsInboxController _inboxController;
  final NotificationNavigationCoordinator _navigationCoordinator;
  final NotificationPayloadCodec _codec;
  final List<Duration> _retryDelays;
  final NotificationRetryScheduler _retryScheduler;
  final StreamController<NotificationPayload> _presentationsController =
      StreamController<NotificationPayload>.broadcast();

  StreamSubscription<NotificationMessage>? _foregroundSubscription;
  StreamSubscription<NotificationMessage>? _openedSubscription;
  Future<void> _eventQueue = Future<void>.value();
  Future<void>? _startFuture;
  final ListQueue<NotificationPayload> _pendingOpenedPayloads = ListQueue();
  final Set<String> _pendingInboxUuids = {};
  final Set<String> _pendingDispatchUuids = {};
  Timer? _retryTimer;
  int _retryAttempt = 0;
  String? _activeProfileUuid;
  int _profileGeneration = 0;
  Object? _lastError;
  bool _disposed = false;

  Stream<NotificationPayload> get presentations =>
      _presentationsController.stream;
  String? get activeProfileUuid => _activeProfileUuid;
  Object? get lastError => _lastError;
  NotificationPayload? get _pendingOpenedPayload =>
      _pendingOpenedPayloads.isEmpty ? null : _pendingOpenedPayloads.first;

  Future<void> start() {
    final existing = _startFuture;
    if (existing != null) {
      return existing;
    }
    if (_disposed) {
      return Future<void>.value();
    }

    _foregroundSubscription = _messageClient.onMessage.listen(
      (message) => unawaited(_enqueue(() => _handleForeground(message))),
      onError: _handleStreamError,
    );
    _openedSubscription = _messageClient.onMessageOpenedApp.listen(
      (message) => unawaited(_enqueue(() => _handleOpenedMessage(message))),
      onError: _handleStreamError,
    );
    _inboxController.addListener(_handleInboxChanged);
    return _startFuture = _loadInitialMessage();
  }

  Future<void> activateProfile(String uuidProfile) {
    final cleanProfile = uuidProfile.trim();
    if (cleanProfile.isEmpty) {
      clearProfile();
      return Future<void>.value();
    }

    final previousProfile = _activeProfileUuid;
    if (previousProfile != cleanProfile) {
      _activeProfileUuid = cleanProfile;
      _profileGeneration++;
      _cancelRetry();
      if (previousProfile != null) {
        _clearPendingOpened();
      }
      _navigationCoordinator.activateProfile(cleanProfile);
    }

    final pending = _pendingOpenedPayload;
    if (pending == null) {
      return Future<void>.value();
    }
    return _enqueue(() => _openPayload(pending));
  }

  void clearProfile() {
    _activeProfileUuid = null;
    _profileGeneration++;
    _clearPendingOpened();
    _cancelRetry();
    _navigationCoordinator.activateProfile(null);
  }

  Future<void> retryPendingOpen() {
    final pending = _pendingOpenedPayload;
    if (pending == null || _activeProfileUuid == null) {
      return Future<void>.value();
    }
    _retryTimer?.cancel();
    _retryTimer = null;
    return _enqueue(() => _openPayload(pending));
  }

  Future<void> openForegroundNotification(NotificationPayload payload) {
    return _enqueue(() => _openPayload(payload));
  }

  Future<void> _loadInitialMessage() async {
    try {
      final initialMessage = await _messageClient.getInitialMessage();
      if (initialMessage != null) {
        await _enqueue(() => _handleOpenedMessage(initialMessage));
      }
    } catch (error, stackTrace) {
      _recordError(error, stackTrace);
    }
  }

  Future<void> _handleForeground(NotificationMessage message) async {
    final payload = _codec.tryDecode(message);
    final profileUuid = _activeProfileUuid;
    final generation = _profileGeneration;
    if (payload == null || profileUuid == null) {
      return;
    }

    await _inboxController.pullFromRemote(uuidProfile: profileUuid);
    if (!_isCurrentProfile(profileUuid, generation) || _disposed) {
      return;
    }

    _lastError = null;
    _presentationsController.add(payload);
  }

  Future<void> _handleOpenedMessage(NotificationMessage message) async {
    final payload = _codec.tryDecode(message);
    if (payload == null) {
      return;
    }
    await _openPayload(payload);
  }

  Future<void> _openPayload(NotificationPayload payload) async {
    if (!_enqueuePendingOpened(payload)) {
      return;
    }
    final pending = _pendingOpenedPayload;
    if (pending == null || !_samePayload(pending, payload)) {
      return;
    }

    final profileUuid = _activeProfileUuid;
    final generation = _profileGeneration;
    if (profileUuid == null) {
      _cancelRetry(resetAttempt: false);
      return;
    }

    final item = await _inboxController.openNotification(
      payload.uuidNotificationInbox,
    );
    if (!_isCurrentProfile(profileUuid, generation) || _disposed) {
      return;
    }
    if (item == null) {
      _scheduleRetry();
      return;
    }
    if (!_matchesMessage(item, payload, profileUuid)) {
      _removePendingOpened(payload);
      _cancelRetry();
      _drainNextPending();
      return;
    }

    _removePendingOpened(payload);
    _cancelRetry();
    _lastError = null;
    _navigationCoordinator.openPayload(
      NotificationPayload(
        schemaVersion: payload.schemaVersion,
        uuidNotificationDispatch: item.uuidNotificationDispatch,
        uuidNotificationInbox: item.uuidNotificationInbox,
        category: item.category,
        actionType: item.actionType,
        actionPayload: Map.unmodifiable(item.actionPayload),
        title: payload.title,
        body: payload.body,
      ),
    );
    _drainNextPending();
  }

  bool _matchesMessage(
    AppNotificationInboxItem item,
    NotificationPayload payload,
    String profileUuid,
  ) {
    return item.uuidProfile == profileUuid &&
        item.uuidNotificationInbox == payload.uuidNotificationInbox &&
        item.uuidNotificationDispatch == payload.uuidNotificationDispatch &&
        item.category == payload.category &&
        item.actionType == payload.actionType;
  }

  bool _isCurrentProfile(String profileUuid, int generation) {
    return _activeProfileUuid == profileUuid &&
        _profileGeneration == generation;
  }

  void _handleInboxChanged() {
    final pending = _pendingOpenedPayload;
    final profileUuid = _activeProfileUuid;
    if (_disposed || pending == null || profileUuid == null) {
      return;
    }

    final isAvailable = _inboxController.notifications.any(
      (item) =>
          item.uuidProfile == profileUuid &&
          item.uuidNotificationInbox == pending.uuidNotificationInbox,
    );
    if (isAvailable) {
      _retryTimer?.cancel();
      _retryTimer = null;
      unawaited(_enqueue(() => _openPayload(pending)));
      return;
    }
    _scheduleRetry();
  }

  bool _enqueuePendingOpened(NotificationPayload payload) {
    if (_pendingInboxUuids.contains(payload.uuidNotificationInbox) ||
        _pendingDispatchUuids.contains(payload.uuidNotificationDispatch)) {
      return true;
    }
    if (_pendingOpenedPayloads.length >= _pendingOpenedLimit) {
      return false;
    }
    _pendingOpenedPayloads.add(payload);
    _pendingInboxUuids.add(payload.uuidNotificationInbox);
    _pendingDispatchUuids.add(payload.uuidNotificationDispatch);
    return true;
  }

  void _removePendingOpened(NotificationPayload payload) {
    final pending = _pendingOpenedPayload;
    if (pending == null || !_samePayload(pending, payload)) {
      return;
    }
    _pendingOpenedPayloads.removeFirst();
    _pendingInboxUuids.remove(payload.uuidNotificationInbox);
    _pendingDispatchUuids.remove(payload.uuidNotificationDispatch);
  }

  void _clearPendingOpened() {
    _pendingOpenedPayloads.clear();
    _pendingInboxUuids.clear();
    _pendingDispatchUuids.clear();
  }

  bool _samePayload(NotificationPayload left, NotificationPayload right) {
    return left.uuidNotificationInbox == right.uuidNotificationInbox &&
        left.uuidNotificationDispatch == right.uuidNotificationDispatch;
  }

  void _drainNextPending() {
    final next = _pendingOpenedPayload;
    if (next == null || _activeProfileUuid == null || _disposed) {
      return;
    }
    unawaited(_enqueue(() => _openPayload(next)));
  }

  void _scheduleRetry() {
    if (_disposed ||
        _pendingOpenedPayload == null ||
        _activeProfileUuid == null ||
        _retryTimer != null ||
        _retryDelays.isEmpty) {
      return;
    }

    final index = _retryAttempt.clamp(0, _retryDelays.length - 1);
    final delay = _retryDelays[index];
    _retryAttempt++;
    _retryTimer = _retryScheduler(delay, () {
      _retryTimer = null;
      unawaited(retryPendingOpen());
    });
  }

  void _cancelRetry({bool resetAttempt = true}) {
    _retryTimer?.cancel();
    _retryTimer = null;
    if (resetAttempt) {
      _retryAttempt = 0;
    }
  }

  Future<void> _enqueue(Future<void> Function() operation) {
    final queued = _eventQueue.then((_) async {
      if (_disposed) {
        return;
      }
      try {
        await operation();
      } catch (error, stackTrace) {
        _recordError(error, stackTrace);
      }
    });
    _eventQueue = queued;
    return queued;
  }

  void _handleStreamError(Object error, StackTrace stackTrace) {
    _recordError(error, stackTrace);
  }

  void _recordError(Object error, StackTrace stackTrace) {
    _lastError = error;
    debugPrint('NotificationInteractionRuntime error: $error');
    debugPrintStack(stackTrace: stackTrace);
  }

  Future<void> dispose() async {
    if (_disposed) {
      return;
    }
    _disposed = true;
    _inboxController.removeListener(_handleInboxChanged);
    clearProfile();
    await _foregroundSubscription?.cancel();
    await _openedSubscription?.cancel();
    _foregroundSubscription = null;
    _openedSubscription = null;
    await _eventQueue;
    await _presentationsController.close();
  }
}

Timer _defaultRetryScheduler(Duration delay, void Function() callback) {
  return Timer(delay, callback);
}

import 'dart:collection';

import 'package:flutter/foundation.dart';

import '../data/models/app_notification_inbox_item.dart';
import 'notification_payload_codec.dart';

enum NotificationDestination {
  dialog,
  home,
  explore,
  meditation,
  companyInfo,
  contentItem,
}

NotificationDestination? notificationDestinationForAction(String actionType) {
  return switch (actionType) {
    'none' => NotificationDestination.dialog,
    'open_home' => NotificationDestination.home,
    'open_explore' => NotificationDestination.explore,
    'open_meditation' => NotificationDestination.meditation,
    'open_company_info' => NotificationDestination.companyInfo,
    'open_content_item' => NotificationDestination.contentItem,
    _ => null,
  };
}

int? homeIndexForNotificationDestination(NotificationDestination destination) {
  return switch (destination) {
    NotificationDestination.explore => 0,
    NotificationDestination.home || NotificationDestination.meditation => 1,
    _ => null,
  };
}

class NotificationNavigationIntent {
  const NotificationNavigationIntent({
    required this.uuidProfile,
    required this.payload,
  });

  final String uuidProfile;
  final NotificationPayload payload;

  NotificationDestination? get destination =>
      notificationDestinationForAction(payload.actionType);
}

class NotificationNavigationController extends ChangeNotifier {
  static const _handledHistoryLimit = 100;
  static const _pendingLimit = 20;

  final ListQueue<NotificationNavigationIntent> _pending = ListQueue();
  String? _activeProfileUuid;
  final Set<String> _queuedInboxUuids = {};
  final Set<String> _queuedDispatchUuids = {};
  final LinkedHashSet<String> _handledInboxUuids = LinkedHashSet();
  final LinkedHashSet<String> _handledDispatchUuids = LinkedHashSet();

  NotificationNavigationIntent? get pending =>
      _pending.isEmpty ? null : _pending.first;
  int get pendingCount => _pending.length;
  String? get activeProfileUuid => _activeProfileUuid;

  void activateProfile(String? uuidProfile) {
    final cleanProfile = _cleanNullableText(uuidProfile);
    if (_activeProfileUuid == cleanProfile) {
      return;
    }

    _activeProfileUuid = cleanProfile;
    _pending.clear();
    _queuedInboxUuids.clear();
    _queuedDispatchUuids.clear();
    _handledInboxUuids.clear();
    _handledDispatchUuids.clear();
    notifyListeners();
  }

  bool enqueue(NotificationPayload payload, {bool allowHandled = false}) {
    final profileUuid = _activeProfileUuid;
    if (profileUuid == null ||
        (!allowHandled &&
            (_handledInboxUuids.contains(payload.uuidNotificationInbox) ||
                _handledDispatchUuids.contains(
                  payload.uuidNotificationDispatch,
                )))) {
      return false;
    }
    if (_queuedInboxUuids.contains(payload.uuidNotificationInbox) ||
        _queuedDispatchUuids.contains(payload.uuidNotificationDispatch)) {
      notifyListeners();
      return false;
    }
    if (_pending.length >= _pendingLimit) {
      return false;
    }

    _pending.add(
      NotificationNavigationIntent(uuidProfile: profileUuid, payload: payload),
    );
    _queuedInboxUuids.add(payload.uuidNotificationInbox);
    _queuedDispatchUuids.add(payload.uuidNotificationDispatch);
    notifyListeners();
    return true;
  }

  NotificationNavigationIntent? peekPendingForProfile(String? uuidProfile) {
    final cleanProfile = _cleanNullableText(uuidProfile);
    final pending = this.pending;
    if (cleanProfile == null || pending?.uuidProfile != cleanProfile) {
      return null;
    }

    return pending;
  }

  bool acknowledgePendingForProfile(
    String? uuidProfile,
    NotificationNavigationIntent intent,
  ) {
    final pending = peekPendingForProfile(uuidProfile);
    if (pending == null || !identical(pending, intent)) {
      return false;
    }

    _pending.removeFirst();
    final payload = intent.payload;
    _queuedInboxUuids.remove(payload.uuidNotificationInbox);
    _queuedDispatchUuids.remove(payload.uuidNotificationDispatch);
    _addBounded(_handledInboxUuids, payload.uuidNotificationInbox);
    _addBounded(_handledDispatchUuids, payload.uuidNotificationDispatch);
    notifyListeners();
    return true;
  }

  void _addBounded(LinkedHashSet<String> values, String value) {
    values.add(value);
    while (values.length > _handledHistoryLimit) {
      values.remove(values.first);
    }
  }
}

class NotificationNavigationCoordinator extends ChangeNotifier {
  NotificationNavigationCoordinator({
    required NotificationNavigationController controller,
    required VoidCallback activateUserMode,
    VoidCallback? returnToHomeShell,
  }) : _controller = controller,
       _activateUserMode = activateUserMode,
       _returnToHomeShell = returnToHomeShell {
    _controller.addListener(_relayChange);
  }

  final NotificationNavigationController _controller;
  final VoidCallback _activateUserMode;
  VoidCallback? _returnToHomeShell;
  bool _homeShellAttached = false;

  NotificationNavigationIntent? get pending => _controller.pending;
  String? get activeProfileUuid => _controller.activeProfileUuid;
  bool get isHomeShellAttached => _homeShellAttached;

  void activateProfile(String? uuidProfile) {
    _controller.activateProfile(uuidProfile);
  }

  void attachRootNavigation(VoidCallback returnToHomeShell) {
    _returnToHomeShell = returnToHomeShell;
  }

  void detachRootNavigation(VoidCallback returnToHomeShell) {
    if (identical(_returnToHomeShell, returnToHomeShell)) {
      _returnToHomeShell = null;
    }
  }

  void attachHomeShell() {
    _homeShellAttached = true;
  }

  void detachHomeShell() {
    _homeShellAttached = false;
  }

  /// Reintenta entregar un destino que quedo pendiente cuando la app vuelve
  /// de segundo plano. El HomeShell puede haber perdido el primer aviso de
  /// cambio mientras Android reanudaba la actividad.
  void refreshPendingNavigationOnResume() {
    if (_controller.pending == null || !_homeShellAttached) {
      return;
    }

    _returnToHomeShell?.call();
    notifyListeners();
  }

  bool openPayload(NotificationPayload payload) {
    if (notificationDestinationForAction(payload.actionType) == null) {
      return false;
    }

    final accepted = _controller.enqueue(payload);
    if (!accepted) {
      return false;
    }

    if (payload.actionType != 'none') {
      _activateUserMode();
    }
    if (_homeShellAttached) {
      _returnToHomeShell?.call();
    }
    return true;
  }

  bool openInboxItem(AppNotificationInboxItem item) {
    if (item.uuidProfile != activeProfileUuid) {
      return false;
    }

    final payload = NotificationPayload(
      schemaVersion: '1',
      uuidNotificationDispatch: item.uuidNotificationDispatch,
      uuidNotificationInbox: item.uuidNotificationInbox,
      category: item.category,
      actionType: item.actionType,
      actionPayload: Map.unmodifiable(item.actionPayload),
      title: item.title,
      body: item.body,
    );
    if (notificationDestinationForAction(payload.actionType) == null) {
      return false;
    }
    final accepted = _controller.enqueue(payload, allowHandled: true);
    if (!accepted) {
      return false;
    }
    if (payload.actionType != 'none') {
      _activateUserMode();
    }
    if (_homeShellAttached) {
      _returnToHomeShell?.call();
    }
    return true;
  }

  NotificationNavigationIntent? peekPendingForActiveProfile() {
    return _controller.peekPendingForProfile(activeProfileUuid);
  }

  bool acknowledgePendingForActiveProfile(NotificationNavigationIntent intent) {
    return _controller.acknowledgePendingForProfile(activeProfileUuid, intent);
  }

  void _relayChange() {
    notifyListeners();
  }

  @override
  void dispose() {
    _controller.removeListener(_relayChange);
    super.dispose();
  }
}

String? _cleanNullableText(String? value) {
  final clean = value?.trim();
  return clean == null || clean.isEmpty ? null : clean;
}

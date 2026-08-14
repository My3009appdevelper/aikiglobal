import 'dart:async';

import 'package:flutter/foundation.dart';

import '../data/providers/notification_devices_controller.dart';
import 'notification_device_registration.dart';

abstract interface class NotificationDeviceLifecycle {
  Future<void> refreshCurrentProfile();
}

class NotificationDeviceRuntime implements NotificationDeviceLifecycle {
  NotificationDeviceRuntime({
    required NotificationDevicesController devicesController,
    required NotificationDeviceRegistrationClient registrationClient,
  }) : _devicesController = devicesController,
       _registrationClient = registrationClient {
    _tokenSubscription = _registrationClient.onTokenRefresh.listen(
      _handleTokenRefresh,
      onError: _handleTokenStreamError,
    );
  }

  final NotificationDevicesController _devicesController;
  final NotificationDeviceRegistrationClient _registrationClient;

  StreamSubscription<String>? _tokenSubscription;
  Future<void> _registrationQueue = Future<void>.value();
  String? _activeProfileUuid;
  int _profileGeneration = 0;
  Object? _lastError;

  String? get activeProfileUuid => _activeProfileUuid;
  Object? get lastError => _lastError;

  Future<void> activateProfile(String uuidProfile) {
    final cleanProfile = uuidProfile.trim();
    if (cleanProfile.isEmpty) {
      clearProfile();
      return Future<void>.value();
    }

    if (_activeProfileUuid != cleanProfile) {
      _activeProfileUuid = cleanProfile;
      _profileGeneration++;
    }

    return _enqueueRegistration(
      profileUuid: cleanProfile,
      generation: _profileGeneration,
      requestPermission: true,
      pullBeforeRegistration: true,
    );
  }

  @override
  Future<void> refreshCurrentProfile() {
    final profileUuid = _activeProfileUuid;
    if (profileUuid == null) {
      return Future<void>.value();
    }

    return _enqueueRegistration(
      profileUuid: profileUuid,
      generation: _profileGeneration,
      requestPermission: false,
      pullBeforeRegistration: false,
    );
  }

  void clearProfile() {
    _activeProfileUuid = null;
    _profileGeneration++;
    _lastError = null;
  }

  Future<void> _enqueueRegistration({
    required String profileUuid,
    required int generation,
    required bool requestPermission,
    required bool pullBeforeRegistration,
    String? fcmTokenOverride,
  }) {
    final operation = _registrationQueue.then(
      (_) => _register(
        profileUuid: profileUuid,
        generation: generation,
        requestPermission: requestPermission,
        pullBeforeRegistration: pullBeforeRegistration,
        fcmTokenOverride: fcmTokenOverride,
      ),
    );
    _registrationQueue = operation;
    return operation;
  }

  Future<void> _register({
    required String profileUuid,
    required int generation,
    required bool requestPermission,
    required bool pullBeforeRegistration,
    String? fcmTokenOverride,
  }) async {
    if (!_isCurrentProfile(profileUuid, generation)) {
      return;
    }

    try {
      if (pullBeforeRegistration) {
        await _devicesController.pullFromRemote(uuidProfile: profileUuid);
        if (!_isCurrentProfile(profileUuid, generation)) {
          return;
        }
      }

      final registration = await _registrationClient.loadRegistration(
        requestPermission: requestPermission,
        fcmTokenOverride: fcmTokenOverride,
      );
      if (!_isCurrentProfile(profileUuid, generation) ||
          _devicesController.activeProfileUuid != profileUuid) {
        return;
      }

      await _devicesController.registerCurrentInstallation(
        installationId: registration.installationId,
        fcmToken: registration.fcmToken,
        platform: registration.platform,
        permissionStatus: registration.permissionStatus,
        appVersion: registration.appVersion,
        timeZone: registration.timeZone,
        registrationRefreshedAt: registration.registrationRefreshedAt,
      );
      _lastError = null;
    } catch (error, stackTrace) {
      _lastError = error;
      debugPrint('NotificationDeviceRuntime registration error: $error');
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  bool _isCurrentProfile(String profileUuid, int generation) {
    return _activeProfileUuid == profileUuid &&
        _profileGeneration == generation;
  }

  void _handleTokenRefresh(String token) {
    final cleanToken = token.trim();
    final profileUuid = _activeProfileUuid;
    if (cleanToken.isEmpty || profileUuid == null) {
      return;
    }

    unawaited(
      _enqueueRegistration(
        profileUuid: profileUuid,
        generation: _profileGeneration,
        requestPermission: false,
        pullBeforeRegistration: false,
        fcmTokenOverride: cleanToken,
      ),
    );
  }

  void _handleTokenStreamError(Object error, StackTrace stackTrace) {
    _lastError = error;
    debugPrint('NotificationDeviceRuntime token stream error: $error');
    debugPrintStack(stackTrace: stackTrace);
  }

  Future<void> dispose() async {
    clearProfile();
    await _tokenSubscription?.cancel();
    _tokenSubscription = null;
    await _registrationQueue;
  }
}

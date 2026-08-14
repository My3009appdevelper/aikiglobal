import 'dart:async';

import 'package:aikiglobal/core/data/local/app_database.dart';
import 'package:aikiglobal/core/data/local/daos/notification_devices_dao.dart';
import 'package:aikiglobal/core/data/providers/notification_devices_controller.dart';
import 'package:aikiglobal/core/notifications/notification_device_registration.dart';
import 'package:aikiglobal/core/notifications/notification_device_runtime.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase database;
  late NotificationDevicesDao dao;
  late NotificationDevicesController devicesController;
  late _FakeNotificationDeviceRegistrationClient client;
  late NotificationDeviceRuntime runtime;

  setUp(() {
    database = AppDatabase(executor: NativeDatabase.memory());
    dao = NotificationDevicesDao(database);
    devicesController = NotificationDevicesController(
      notificationDevicesDao: dao,
      notificationDevicesRemoteService: null,
      syncService: null,
    );
    client = _FakeNotificationDeviceRegistrationClient();
    runtime = NotificationDeviceRuntime(
      devicesController: devicesController,
      registrationClient: client,
    );
    devicesController.watchForProfile('profile-1', pullRemote: false);
  });

  tearDown(() async {
    await runtime.dispose();
    await client.dispose();
    devicesController.dispose();
    await database.close();
  });

  test('registers the active profile after requesting permission', () async {
    client.registration = _registration(token: 'token-1');

    await runtime.activateProfile('profile-1');

    expect(client.calls, [const _RegistrationCall(requestPermission: true)]);
    expect(devicesController.currentInstallation?.installationId, 'fid-1');
    expect(devicesController.currentInstallation?.fcmToken, 'token-1');
    expect(
      devicesController.currentInstallation?.permissionStatus,
      'authorized',
    );
    expect(devicesController.currentInstallation?.appVersion, '1.0.0+1');
    expect(devicesController.currentInstallation?.timeZone, 'America/Mexico_City');
    expect(devicesController.currentInstallation?.isActive, isTrue);
  });

  test('updates the same installation when the FCM token refreshes', () async {
    client.registration = _registration(token: 'token-1');
    await runtime.activateProfile('profile-1');
    final originalUuid =
        devicesController.currentInstallation?.uuidNotificationDevice;

    client.emitToken('token-2');
    await _waitUntil(
      () => devicesController.currentInstallation?.fcmToken == 'token-2',
    );

    expect(
      devicesController.currentInstallation?.uuidNotificationDevice,
      originalUuid,
    );
    expect(client.calls, [
      const _RegistrationCall(requestPermission: true),
      const _RegistrationCall(
        requestPermission: false,
        fcmTokenOverride: 'token-2',
      ),
    ]);
  });

  test(
    'refreshes permission without displaying the system prompt again',
    () async {
      client.registration = _registration(token: 'token-1');
      await runtime.activateProfile('profile-1');
      client.registration = _registration(
        token: 'token-1',
        permissionStatus: 'denied',
      );

      await runtime.refreshCurrentProfile();

      expect(
        client.calls.last,
        const _RegistrationCall(requestPermission: false),
      );
      expect(devicesController.currentInstallation?.permissionStatus, 'denied');
    },
  );

  test(
    'discards a registration completed after the profile was cleared',
    () async {
      final pending = client.delayNextRegistration();
      final activation = runtime.activateProfile('profile-1');
      await client.registrationStarted.future;

      runtime.clearProfile();
      pending.complete(_registration(token: 'token-1'));
      await activation;

      expect(devicesController.currentInstallation, isNull);
    },
  );
}

NotificationDeviceRegistration _registration({
  required String token,
  String permissionStatus = 'authorized',
}) {
  return NotificationDeviceRegistration(
    installationId: 'fid-1',
    fcmToken: token,
    platform: 'android',
    permissionStatus: permissionStatus,
    appVersion: '1.0.0+1',
    timeZone: 'America/Mexico_City',
    registrationRefreshedAt: DateTime.utc(2026, 7, 16, 18),
  );
}

Future<void> _waitUntil(bool Function() predicate) async {
  for (var attempt = 0; attempt < 100; attempt++) {
    if (predicate()) {
      return;
    }
    await Future<void>.delayed(const Duration(milliseconds: 10));
  }
  fail('La condición esperada no se cumplió a tiempo.');
}

class _FakeNotificationDeviceRegistrationClient
    implements NotificationDeviceRegistrationClient {
  final StreamController<String> _tokenController =
      StreamController<String>.broadcast();
  final List<_RegistrationCall> calls = [];

  NotificationDeviceRegistration registration = _registration(token: 'token-1');
  Completer<NotificationDeviceRegistration>? _pendingRegistration;
  Completer<void> registrationStarted = Completer<void>();

  @override
  Stream<String> get onTokenRefresh => _tokenController.stream;

  @override
  Future<NotificationDeviceRegistration> loadRegistration({
    required bool requestPermission,
    String? fcmTokenOverride,
  }) async {
    calls.add(
      _RegistrationCall(
        requestPermission: requestPermission,
        fcmTokenOverride: fcmTokenOverride,
      ),
    );
    if (!registrationStarted.isCompleted) {
      registrationStarted.complete();
    }

    final pending = _pendingRegistration;
    final loaded = pending == null ? registration : await pending.future;
    if (fcmTokenOverride == null) {
      return loaded;
    }
    return NotificationDeviceRegistration(
      installationId: loaded.installationId,
      fcmToken: fcmTokenOverride,
      platform: loaded.platform,
      permissionStatus: loaded.permissionStatus,
      appVersion: loaded.appVersion,
      timeZone: loaded.timeZone,
      registrationRefreshedAt: loaded.registrationRefreshedAt,
    );
  }

  Completer<NotificationDeviceRegistration> delayNextRegistration() {
    registrationStarted = Completer<void>();
    return _pendingRegistration = Completer<NotificationDeviceRegistration>();
  }

  void emitToken(String token) {
    _tokenController.add(token);
  }

  Future<void> dispose() => _tokenController.close();
}

class _RegistrationCall {
  const _RegistrationCall({
    required this.requestPermission,
    this.fcmTokenOverride,
  });

  final bool requestPermission;
  final String? fcmTokenOverride;

  @override
  bool operator ==(Object other) {
    return other is _RegistrationCall &&
        other.requestPermission == requestPermission &&
        other.fcmTokenOverride == fcmTokenOverride;
  }

  @override
  int get hashCode => Object.hash(requestPermission, fcmTokenOverride);
}

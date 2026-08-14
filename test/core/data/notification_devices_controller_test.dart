import 'package:aikiglobal/core/data/local/app_database.dart';
import 'package:aikiglobal/core/data/local/daos/notification_devices_dao.dart';
import 'package:aikiglobal/core/data/providers/notification_devices_controller.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase database;
  late NotificationDevicesDao dao;
  late NotificationDevicesController controller;

  setUp(() {
    database = AppDatabase(executor: NativeDatabase.memory());
    dao = NotificationDevicesDao(database);
    controller = NotificationDevicesController(
      notificationDevicesDao: dao,
      notificationDevicesRemoteService: null,
      syncService: null,
    );
    controller.watchForProfile('profile-1');
  });

  tearDown(() async {
    controller.dispose();
    await database.close();
  });

  test('reuses the same row when a Firebase installation refreshes', () async {
    await controller.registerCurrentInstallation(
      installationId: 'fid-1',
      fcmToken: null,
      platform: 'android',
      permissionStatus: 'not_determined',
      appVersion: '1.0.0+1',
      registrationRefreshedAt: null,
    );

    final originalUuid = controller.currentInstallation?.uuidNotificationDevice;
    expect(originalUuid, isNotNull);
    expect(controller.currentInstallation?.fcmToken, isNull);

    await controller.registerCurrentInstallation(
      installationId: 'fid-1',
      fcmToken: 'token-1',
      platform: 'android',
      permissionStatus: 'authorized',
      appVersion: '1.0.0+1',
      registrationRefreshedAt: DateTime.utc(2026, 7, 16),
    );

    expect(
      controller.currentInstallation?.uuidNotificationDevice,
      originalUuid,
    );
    expect(controller.currentInstallation?.fcmToken, 'token-1');
    expect(controller.currentInstallation?.canReceivePush, isTrue);
    expect(controller.devices, hasLength(1));
  });

  test('rejects unsupported platform and permission values', () async {
    expect(
      () => controller.registerCurrentInstallation(
        installationId: 'fid-1',
        fcmToken: null,
        platform: 'windows',
        permissionStatus: 'not_determined',
        appVersion: null,
        registrationRefreshedAt: null,
      ),
      throwsArgumentError,
    );

    expect(
      () => controller.registerCurrentInstallation(
        installationId: 'fid-1',
        fcmToken: null,
        platform: 'android',
        permissionStatus: 'granted',
        appVersion: null,
        registrationRefreshedAt: null,
      ),
      throwsArgumentError,
    );
  });

  test('deactivates the current installation without deleting it', () async {
    await controller.registerCurrentInstallation(
      installationId: 'fid-1',
      fcmToken: 'token-1',
      platform: 'android',
      permissionStatus: 'authorized',
      appVersion: null,
      registrationRefreshedAt: DateTime.utc(2026, 7, 16),
    );

    await controller.deactivateCurrentInstallation();

    final stored = await dao.getByProfileAndInstallation('profile-1', 'fid-1');
    expect(stored?.isActive, isFalse);
    expect(stored?.deletedAt, isNull);
    expect(controller.currentInstallation?.isActive, isFalse);
  });
}

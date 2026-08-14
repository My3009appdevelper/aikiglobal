import 'package:aikiglobal/core/data/local/app_database.dart';
import 'package:aikiglobal/core/data/local/daos/notification_devices_dao.dart';
import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase database;
  late NotificationDevicesDao dao;

  setUp(() {
    database = AppDatabase(executor: NativeDatabase.memory());
    dao = NotificationDevicesDao(database);
  });

  tearDown(() => database.close());

  test('stores a device registration with a nullable FCM token', () async {
    final now = DateTime.utc(2026, 7, 16);

    await dao.upsertNotificationDevice(
      NotificationDevicesTableCompanion.insert(
        uuidNotificationDevice: 'device-1',
        uuidProfile: 'profile-1',
        installationId: 'fid-1',
        platform: 'android',
        permissionStatus: const Value('not_determined'),
        createdAt: Value(now),
        updatedAt: Value(now),
      ),
    );

    final row = await dao.getByProfileAndInstallation('profile-1', 'fid-1');

    expect(row?.uuidNotificationDevice, 'device-1');
    expect(row?.fcmToken, isNull);
    expect(row?.isActive, isTrue);
  });

  test('updates a registration and marks it pending sync', () async {
    final now = DateTime.utc(2026, 7, 16);
    final refreshedAt = DateTime.utc(2026, 7, 17);

    await dao.upsertNotificationDevice(
      NotificationDevicesTableCompanion.insert(
        uuidNotificationDevice: 'device-1',
        uuidProfile: 'profile-1',
        installationId: 'fid-1',
        fcmToken: const Value('token-1'),
        platform: 'android',
        permissionStatus: const Value('authorized'),
        createdAt: Value(now),
        updatedAt: Value(now),
        syncedAt: Value(now),
      ),
    );

    await dao.updateRegistration(
      'device-1',
      fcmToken: 'token-2',
      platform: 'android',
      permissionStatus: 'authorized',
      appVersion: '1.0.0+1',
      isActive: true,
      registrationRefreshedAt: refreshedAt,
    );

    final updated = await dao.getByUuid('device-1');

    expect(updated?.fcmToken, 'token-2');
    expect(updated?.appVersion, '1.0.0+1');
    expect(updated?.registrationRefreshedAt?.toUtc(), refreshedAt);
    expect(updated?.syncedAt, isNull);
  });

  test('deactivates a profile installation without deleting it', () async {
    final now = DateTime.utc(2026, 7, 16);

    await dao.upsertNotificationDevice(
      NotificationDevicesTableCompanion.insert(
        uuidNotificationDevice: 'device-1',
        uuidProfile: 'profile-1',
        installationId: 'fid-1',
        fcmToken: const Value('token-1'),
        platform: 'android',
        permissionStatus: const Value('authorized'),
        createdAt: Value(now),
        updatedAt: Value(now),
        syncedAt: Value(now),
      ),
    );

    await dao.deactivateByProfileAndInstallation('profile-1', 'fid-1');

    final inactive = await dao.getByUuid('device-1');

    expect(inactive?.isActive, isFalse);
    expect(inactive?.deletedAt, isNull);
    expect(inactive?.syncedAt, isNull);
  });
}

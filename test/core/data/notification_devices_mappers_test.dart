import 'package:aikiglobal/core/data/local/app_database.dart';
import 'package:aikiglobal/core/data/sync/sync_mappers.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final remoteJson = <String, dynamic>{
    'uuid_notification_device': 'device-1',
    'uuid_profile': 'profile-1',
    'installation_id': 'fid-1',
    'fcm_token': null,
    'platform': 'android',
    'permission_status': 'not_determined',
    'app_version': null,
    'timezone': 'America/Mexico_City',
    'is_active': true,
    'registration_refreshed_at': null,
    'created_at': '2026-07-16T10:00:00.000Z',
    'updated_at': '2026-07-16T11:00:00.000Z',
    'deleted_at': null,
    'synced_at': null,
  };

  test('maps nullable remote registration fields to a Drift companion', () {
    final companion = notificationDeviceRemoteToCompanion(remoteJson);

    expect(companion.uuidNotificationDevice.value, 'device-1');
    expect(companion.fcmToken.value, isNull);
    expect(companion.appVersion.value, isNull);
    expect(companion.timeZone.value, 'America/Mexico_City');
    expect(companion.registrationRefreshedAt.value, isNull);
    expect(companion.syncedAt.value, isNotNull);
  });

  test('maps a remote registration to the app model', () {
    final device = notificationDeviceRemoteToApp(remoteJson);

    expect(device.uuidProfile, 'profile-1');
    expect(device.installationId, 'fid-1');
    expect(device.fcmToken, isNull);
    expect(device.timeZone, 'America/Mexico_City');
    expect(device.canReceivePush, isFalse);
  });

  test('does not send the local sync marker to Supabase', () {
    final now = DateTime.utc(2026, 7, 16);
    final device = LocalNotificationDevice(
      uuidNotificationDevice: 'device-1',
      uuidProfile: 'profile-1',
      installationId: 'fid-1',
      fcmToken: 'token-1',
      platform: 'android',
      permissionStatus: 'authorized',
      appVersion: '1.0.0+1',
      isActive: true,
      registrationRefreshedAt: now,
      createdAt: now,
      updatedAt: now,
      syncedAt: now,
    );

    final json = notificationDeviceToRemote(device);

    expect(json['fcm_token'], 'token-1');
    expect(json['registration_refreshed_at'], now.toIso8601String());
    expect(json.containsKey('synced_at'), isFalse);
  });
}

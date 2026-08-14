import '../local/app_database.dart';

class AppNotificationDevice {
  const AppNotificationDevice({
    required this.uuidNotificationDevice,
    required this.uuidProfile,
    required this.installationId,
    required this.platform,
    required this.permissionStatus,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    this.fcmToken,
    this.appVersion,
    this.timeZone,
    this.registrationRefreshedAt,
    this.deletedAt,
    this.syncedAt,
  });

  factory AppNotificationDevice.fromLocal(LocalNotificationDevice device) {
    return AppNotificationDevice(
      uuidNotificationDevice: device.uuidNotificationDevice,
      uuidProfile: device.uuidProfile,
      installationId: device.installationId,
      fcmToken: device.fcmToken,
      platform: device.platform,
      permissionStatus: device.permissionStatus,
      appVersion: device.appVersion,
      timeZone: device.timeZone,
      isActive: device.isActive,
      registrationRefreshedAt: device.registrationRefreshedAt,
      createdAt: device.createdAt,
      updatedAt: device.updatedAt,
      deletedAt: device.deletedAt,
      syncedAt: device.syncedAt,
    );
  }

  final String uuidNotificationDevice;
  final String uuidProfile;
  final String installationId;
  final String? fcmToken;
  final String platform;
  final String permissionStatus;
  final String? appVersion;
  final String? timeZone;
  final bool isActive;
  final DateTime? registrationRefreshedAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final DateTime? syncedAt;

  bool get canReceivePush {
    final token = fcmToken?.trim();
    final permissionAllowsPush =
        permissionStatus == 'authorized' || permissionStatus == 'provisional';
    return isActive &&
        deletedAt == null &&
        token != null &&
        token.isNotEmpty &&
        permissionAllowsPush;
  }

  bool get hasPendingSync => syncedAt == null || syncedAt!.isBefore(updatedAt);
}

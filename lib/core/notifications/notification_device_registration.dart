class NotificationDeviceRegistration {
  const NotificationDeviceRegistration({
    required this.installationId,
    required this.fcmToken,
    required this.platform,
    required this.permissionStatus,
    required this.appVersion,
    this.timeZone,
    required this.registrationRefreshedAt,
  });

  final String installationId;
  final String? fcmToken;
  final String platform;
  final String permissionStatus;
  final String? appVersion;
  final String? timeZone;
  final DateTime registrationRefreshedAt;
}

abstract interface class NotificationDeviceRegistrationClient {
  Stream<String> get onTokenRefresh;

  Future<NotificationDeviceRegistration> loadRegistration({
    required bool requestPermission,
    String? fcmTokenOverride,
  });
}

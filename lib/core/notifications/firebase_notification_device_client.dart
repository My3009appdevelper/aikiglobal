import 'package:firebase_app_installations/firebase_app_installations.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'notification_device_registration.dart';

class FirebaseNotificationDeviceClient
    implements NotificationDeviceRegistrationClient {
  FirebaseNotificationDeviceClient({DateTime Function()? now})
    : _now = now ?? DateTime.now;

  final DateTime Function() _now;

  @override
  Stream<String> get onTokenRefresh =>
      FirebaseMessaging.instance.onTokenRefresh;

  @override
  Future<NotificationDeviceRegistration> loadRegistration({
    required bool requestPermission,
    String? fcmTokenOverride,
  }) async {
    final messaging = FirebaseMessaging.instance;
    final settings = requestPermission
        ? await messaging.requestPermission(
            alert: true,
            announcement: false,
            badge: true,
            carPlay: false,
            criticalAlert: false,
            provisional: false,
            sound: true,
          )
        : await messaging.getNotificationSettings();

    final installationId = await FirebaseInstallations.instance.getId();
    final cleanOverride = _cleanNullableText(fcmTokenOverride);
    final fcmToken = cleanOverride ?? await messaging.getToken();
    final packageInfo = await PackageInfo.fromPlatform();
    String? timeZone;
    try {
      timeZone = (await FlutterTimezone.getLocalTimezone()).identifier;
    } catch (_) {
      timeZone = null;
    }

    return NotificationDeviceRegistration(
      installationId: installationId,
      fcmToken: _cleanNullableText(fcmToken),
      platform: 'android',
      permissionStatus: notificationPermissionStatus(
        settings.authorizationStatus,
      ),
      appVersion: formatNotificationAppVersion(
        packageInfo.version,
        packageInfo.buildNumber,
      ),
      timeZone: timeZone,
      registrationRefreshedAt: _now().toUtc(),
    );
  }
}

String notificationPermissionStatus(AuthorizationStatus status) {
  return switch (status) {
    AuthorizationStatus.authorized => 'authorized',
    AuthorizationStatus.denied => 'denied',
    AuthorizationStatus.notDetermined => 'not_determined',
    AuthorizationStatus.provisional => 'provisional',
  };
}

String? formatNotificationAppVersion(String version, String buildNumber) {
  final cleanVersion = version.trim();
  final cleanBuildNumber = buildNumber.trim();
  if (cleanVersion.isEmpty) {
    return null;
  }
  if (cleanBuildNumber.isEmpty) {
    return cleanVersion;
  }
  return '$cleanVersion+$cleanBuildNumber';
}

String? _cleanNullableText(String? value) {
  final clean = value?.trim();
  return clean == null || clean.isEmpty ? null : clean;
}

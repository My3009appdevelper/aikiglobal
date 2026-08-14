import 'package:aikiglobal/core/notifications/firebase_notification_device_client.dart';
import 'package:aikiglobal/core/notifications/firebase_notification_support.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('maps every Firebase notification authorization status', () {
    expect(
      notificationPermissionStatus(AuthorizationStatus.authorized),
      'authorized',
    );
    expect(notificationPermissionStatus(AuthorizationStatus.denied), 'denied');
    expect(
      notificationPermissionStatus(AuthorizationStatus.notDetermined),
      'not_determined',
    );
    expect(
      notificationPermissionStatus(AuthorizationStatus.provisional),
      'provisional',
    );
  });

  test('formats app version with its build number', () {
    expect(formatNotificationAppVersion('1.0.0', '1'), '1.0.0+1');
    expect(formatNotificationAppVersion('1.0.0', ''), '1.0.0');
  });

  test('enables the Firebase notification runtime only on Android', () {
    expect(
      supportsFirebaseNotificationRuntime(
        isWeb: false,
        platform: TargetPlatform.android,
      ),
      isTrue,
    );
    expect(
      supportsFirebaseNotificationRuntime(
        isWeb: true,
        platform: TargetPlatform.android,
      ),
      isFalse,
    );
    expect(
      supportsFirebaseNotificationRuntime(
        isWeb: false,
        platform: TargetPlatform.iOS,
      ),
      isFalse,
    );
  });
}

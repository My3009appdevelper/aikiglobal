import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'app/aiki_app.dart';
import 'core/data/providers/app_data_container.dart';
import 'core/notifications/firebase_notification_device_client.dart';
import 'core/notifications/firebase_notification_message_client.dart';
import 'core/notifications/firebase_notification_support.dart';
import 'core/notifications/notification_device_registration.dart';
import 'core/notifications/notification_message.dart';
import 'core/theme/app_theme_controller.dart';
import 'firebase_options.dart';

const resetLocalDatabaseOnStart = false;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  NotificationDeviceRegistrationClient? notificationRegistrationClient;
  NotificationMessageClient? notificationMessageClient;
  if (supportsFirebaseNotificationRuntime(
    isWeb: kIsWeb,
    platform: defaultTargetPlatform,
  )) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    notificationRegistrationClient = FirebaseNotificationDeviceClient();
    notificationMessageClient = FirebaseNotificationMessageClient();
  }

  final dataContainer = await AppDataContainer.create(
    resetLocalDatabaseOnStart: resetLocalDatabaseOnStart,
    notificationDeviceRegistrationClient: notificationRegistrationClient,
    notificationMessageClient: notificationMessageClient,
  );

  runApp(
    AikiApp(
      themeController: AppThemeController(),
      dataContainer: dataContainer,
    ),
  );
}

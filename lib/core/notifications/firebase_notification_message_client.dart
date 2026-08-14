import 'package:firebase_messaging/firebase_messaging.dart';

import 'notification_message.dart';

class FirebaseNotificationMessageClient implements NotificationMessageClient {
  FirebaseNotificationMessageClient({FirebaseMessaging? messaging})
    : _messaging = messaging ?? FirebaseMessaging.instance;

  final FirebaseMessaging _messaging;

  @override
  Stream<NotificationMessage> get onMessage =>
      FirebaseMessaging.onMessage.map(_toNotificationMessage);

  @override
  Stream<NotificationMessage> get onMessageOpenedApp =>
      FirebaseMessaging.onMessageOpenedApp.map(_toNotificationMessage);

  @override
  Future<NotificationMessage?> getInitialMessage() async {
    final message = await _messaging.getInitialMessage();
    return message == null ? null : _toNotificationMessage(message);
  }
}

NotificationMessage _toNotificationMessage(RemoteMessage message) {
  return notificationMessageFromFirebaseData(
    data: message.data,
    title: message.notification?.title,
    body: message.notification?.body,
  );
}

NotificationMessage notificationMessageFromFirebaseData({
  required Map<String, Object?> data,
  required String? title,
  required String? body,
}) {
  return NotificationMessage(
    data: Map.unmodifiable(data),
    title: title,
    body: body,
  );
}

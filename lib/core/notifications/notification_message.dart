abstract interface class NotificationMessageClient {
  Stream<NotificationMessage> get onMessage;

  Stream<NotificationMessage> get onMessageOpenedApp;

  Future<NotificationMessage?> getInitialMessage();
}

class NotificationMessage {
  const NotificationMessage({
    required this.data,
    required this.title,
    required this.body,
  });

  final Map<String, Object?> data;
  final String? title;
  final String? body;
}

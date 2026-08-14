import 'package:aikiglobal/core/notifications/firebase_notification_message_client.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'maps Firebase fields without exposing RemoteMessage past the adapter',
    () {
      final message = notificationMessageFromFirebaseData(
        data: {'schema_version': '1', 'category': 7},
        title: 'Título exacto',
        body: 'Mensaje con ñ',
      );

      expect(message.data, {'schema_version': '1', 'category': 7});
      expect(message.title, 'Título exacto');
      expect(message.body, 'Mensaje con ñ');
    },
  );
}

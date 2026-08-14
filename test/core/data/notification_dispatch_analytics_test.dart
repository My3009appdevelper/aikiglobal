import 'package:aikiglobal/core/data/models/notification_dispatch_analytics.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('maps aggregate counters and recipient tracking', () {
    final analytics = NotificationDispatchAnalytics.fromJson({
      'uuid_notification_dispatch': 'dispatch-1',
      'target_profile_count': 4,
      'target_device_count': 2,
      'success_device_count': 1,
      'failure_device_count': 1,
      'invalid_token_count': 1,
      'inbox_count': 4,
      'opened_count': 2,
      'read_count': 1,
      'recipients': [
        {
          'uuid_profile': 'profile-1',
          'display_name': 'Ana',
          'email': 'ana@example.com',
          'opened_at': '2026-08-04T12:00:00-06:00',
          'read_at': null,
        },
        {
          'uuid_profile': 'profile-2',
          'display_name': null,
          'email': 'luis@example.com',
          'opened_at': null,
          'read_at': null,
        },
      ],
    }, expectedDispatchUuid: 'dispatch-1');

    expect(analytics.targetProfileCount, 4);
    expect(analytics.successDeviceCount, 1);
    expect(analytics.notOpenedCount, 2);
    expect(analytics.notReadCount, 3);
    expect(analytics.openedRate, 0.5);
    expect(analytics.readRate, 0.25);
    expect(analytics.recipients.first.isOpened, isTrue);
    expect(analytics.recipients.first.isRead, isFalse);
  });

  test('uses zero rates for an empty inbox', () {
    final analytics = NotificationDispatchAnalytics.fromJson({
      'uuid_notification_dispatch': 'dispatch-1',
      'target_profile_count': 0,
      'target_device_count': 0,
      'success_device_count': 0,
      'failure_device_count': 0,
      'invalid_token_count': 0,
      'inbox_count': 0,
      'opened_count': 0,
      'read_count': 0,
      'recipients': [],
    }, expectedDispatchUuid: 'dispatch-1');

    expect(analytics.openedRate, 0);
    expect(analytics.readRate, 0);
    expect(analytics.recipients, isEmpty);
  });

  test('rejects a response for another dispatch', () {
    expect(
      () => NotificationDispatchAnalytics.fromJson({
        'uuid_notification_dispatch': 'dispatch-2',
        'target_profile_count': 0,
        'target_device_count': 0,
        'success_device_count': 0,
        'failure_device_count': 0,
        'invalid_token_count': 0,
        'inbox_count': 0,
        'opened_count': 0,
        'read_count': 0,
        'recipients': [],
      }, expectedDispatchUuid: 'dispatch-1'),
      throwsA(isA<FormatException>()),
    );
  });
}

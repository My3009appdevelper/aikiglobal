import 'package:aikiglobal/core/data/models/app_notification_inbox_item.dart';
import 'package:aikiglobal/core/theme/app_theme.dart';
import 'package:aikiglobal/core/theme/app_typography.dart';
import 'package:aikiglobal/features/notificaciones/notifications_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget themed(AppNotificationInboxItem item) {
    return MaterialApp(
      theme: AppTheme.light,
      home: Scaffold(
        body: NotificationInboxTile(item: item, onTap: () {}),
      ),
    );
  }

  testWidgets('notificación no leída resalta título y estado', (tester) async {
    await tester.pumpWidget(themed(_item()));

    final title = tester.widget<Text>(find.text('Un momento para ti'));
    expect(title.style?.fontFamily, AppTypography.displayFont);
    expect(title.style?.fontWeight, FontWeight.w700);
    expect(find.byIcon(Icons.notifications_none_rounded), findsOneWidget);
  });

  testWidgets('notificación leída reduce el peso del título', (tester) async {
    await tester.pumpWidget(
      themed(_item(readAt: DateTime.utc(2026, 7, 17, 12))),
    );

    final title = tester.widget<Text>(find.text('Un momento para ti'));
    expect(title.style?.fontWeight, FontWeight.w500);
  });
}

AppNotificationInboxItem _item({DateTime? readAt}) {
  final now = DateTime.utc(2026, 7, 17, 12);
  return AppNotificationInboxItem(
    uuidNotificationInbox: '22222222-2222-4222-8222-222222222222',
    uuidNotificationDispatch: '11111111-1111-4111-8111-111111111111',
    uuidProfile: '33333333-3333-4333-8333-333333333333',
    title: 'Un momento para ti',
    body: 'Respira y vuelve a tu centro.',
    category: 'general',
    actionType: 'none',
    actionPayload: const {},
    readAt: readAt,
    createdAt: now,
    updatedAt: now,
    syncedAt: now,
  );
}

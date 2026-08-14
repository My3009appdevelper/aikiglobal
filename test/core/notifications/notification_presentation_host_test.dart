import 'dart:async';

import 'package:aikiglobal/core/notifications/notification_payload_codec.dart';
import 'package:aikiglobal/core/notifications/notification_presentation_host.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('shows an AIKI banner and opens the foreground payload', (
    tester,
  ) async {
    final presentations = StreamController<NotificationPayload>.broadcast();
    addTearDown(presentations.close);
    final messengerKey = GlobalKey<ScaffoldMessengerState>();
    NotificationPayload? openedPayload;

    await tester.pumpWidget(
      NotificationPresentationHost(
        presentations: presentations.stream,
        scaffoldMessengerKey: messengerKey,
        onOpen: (payload) async => openedPayload = payload,
        child: MaterialApp(
          scaffoldMessengerKey: messengerKey,
          home: const Scaffold(body: SizedBox.expand()),
        ),
      ),
    );

    presentations.add(_payload());
    await tester.pumpAndSettle();

    expect(find.text('AIKI'), findsOneWidget);
    expect(find.text('  Título exacto  '), findsOneWidget);
    expect(find.text('Mensaje con acentos y ñ.'), findsOneWidget);
    expect(find.text('Abrir'), findsOneWidget);

    await tester.tap(find.text('Abrir'));
    await tester.pumpAndSettle();

    expect(openedPayload?.uuidNotificationInbox, 'inbox-1');
    expect(find.text('  Título exacto  '), findsNothing);
  });

  testWidgets('dismisses the foreground banner automatically', (tester) async {
    final presentations = StreamController<NotificationPayload>.broadcast();
    addTearDown(presentations.close);
    final messengerKey = GlobalKey<ScaffoldMessengerState>();

    await tester.pumpWidget(
      NotificationPresentationHost(
        presentations: presentations.stream,
        scaffoldMessengerKey: messengerKey,
        autoDismissDuration: const Duration(seconds: 2),
        onOpen: (_) async {},
        child: MaterialApp(
          scaffoldMessengerKey: messengerKey,
          home: const Scaffold(body: SizedBox.expand()),
        ),
      ),
    );

    presentations.add(_payload());
    await tester.pumpAndSettle();
    expect(find.text('  Título exacto  '), findsOneWidget);

    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();

    expect(find.text('  Título exacto  '), findsNothing);
  });
}

NotificationPayload _payload() {
  return const NotificationPayload(
    schemaVersion: '1',
    uuidNotificationDispatch: 'dispatch-1',
    uuidNotificationInbox: 'inbox-1',
    category: 'general',
    actionType: 'open_home',
    actionPayload: {},
    title: '  Título exacto  ',
    body: 'Mensaje con acentos y ñ.',
  );
}

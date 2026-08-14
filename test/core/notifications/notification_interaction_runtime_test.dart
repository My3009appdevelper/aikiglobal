import 'dart:async';

import 'package:aikiglobal/core/data/models/app_notification_inbox_item.dart';
import 'package:aikiglobal/core/data/providers/notifications_inbox_controller.dart';
import 'package:aikiglobal/core/notifications/notification_interaction_runtime.dart';
import 'package:aikiglobal/core/notifications/notification_message.dart';
import 'package:aikiglobal/core/notifications/notification_navigation_controller.dart';
import 'package:aikiglobal/core/notifications/notification_payload_codec.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late _FakeNotificationMessageClient messageClient;
  late _FakeNotificationsInboxController inboxController;
  late NotificationNavigationController navigationController;
  late NotificationNavigationCoordinator navigationCoordinator;
  late NotificationInteractionRuntime runtime;

  setUp(() {
    messageClient = _FakeNotificationMessageClient();
    inboxController = _FakeNotificationsInboxController();
    navigationController = NotificationNavigationController();
    navigationCoordinator = NotificationNavigationCoordinator(
      controller: navigationController,
      activateUserMode: () {},
    );
    runtime = NotificationInteractionRuntime(
      messageClient: messageClient,
      inboxController: inboxController,
      navigationCoordinator: navigationCoordinator,
      retryDelays: const [Duration(milliseconds: 100)],
    );
  });

  tearDown(() async {
    await runtime.dispose();
    navigationCoordinator.dispose();
    inboxController.dispose();
    await messageClient.dispose();
  });

  test('foreground pulls the active inbox and emits a presentation', () async {
    await runtime.activateProfile('profile-1');
    await runtime.start();
    final presentationFuture = runtime.presentations.first;

    messageClient.emitForeground(
      _message(title: 'Título foreground', body: 'Mensaje foreground'),
    );

    final presentation = await presentationFuture;
    expect(inboxController.pulledProfiles, ['profile-1']);
    expect(presentation.title, 'Título foreground');
    expect(presentation.body, 'Mensaje foreground');
    expect(inboxController.openedInboxUuids, isEmpty);
    expect(navigationController.pending, isNull);
  });

  test('opened message marks inbox and enqueues central navigation', () async {
    inboxController.itemToOpen = _inboxItem();
    await runtime.activateProfile('profile-1');
    await runtime.start();

    messageClient.emitOpened(_message(actionType: 'open_home'));
    await _waitUntil(() => navigationController.pending != null);

    expect(inboxController.openedInboxUuids, [_inboxUuid]);
    expect(navigationController.pending?.payload.actionType, 'open_home');
    expect(navigationController.pending?.uuidProfile, 'profile-1');
  });

  test(
    'initial message waits for a profile and start runs only once',
    () async {
      messageClient.initialMessage = _message(actionType: 'open_home');
      inboxController.itemToOpen = _inboxItem();

      await runtime.start();
      await runtime.start();

      expect(messageClient.initialMessageCalls, 1);
      expect(navigationController.pending, isNull);

      await runtime.activateProfile('profile-1');
      await _waitUntil(() => navigationController.pending != null);

      expect(inboxController.openedInboxUuids, [_inboxUuid]);
    },
  );

  test('malformed messages do not pull, open, present or navigate', () async {
    await runtime.activateProfile('profile-1');
    await runtime.start();
    final presentations = <NotificationPayload>[];
    final subscription = runtime.presentations.listen(presentations.add);
    addTearDown(subscription.cancel);

    messageClient.emitForeground(
      _message(dataOverrides: const {'action_payload': '["invalid"]'}),
    );
    messageClient.emitOpened(
      _message(dataOverrides: const {'schema_version': '2'}),
    );
    await _waitForQueue();

    expect(inboxController.pulledProfiles, isEmpty);
    expect(inboxController.openedInboxUuids, isEmpty);
    expect(presentations, isEmpty);
    expect(navigationController.pending, isNull);
  });

  test('retries when an inbox item becomes available locally', () async {
    await runtime.activateProfile('profile-1');
    await runtime.start();

    messageClient.emitOpened(_message(actionType: 'open_home'));
    await _waitUntil(() => inboxController.openedInboxUuids.isNotEmpty);
    expect(navigationController.pending, isNull);

    inboxController.itemToOpen = _inboxItem();
    inboxController.signalChanged();
    await _waitUntil(() => navigationController.pending != null);

    expect(inboxController.openedInboxUuids.length, greaterThanOrEqualTo(2));
    expect(navigationController.pending?.payload.actionType, 'open_home');
    expect(runtime.lastError, isNull);
  });

  test('discards an open completed after the profile changes', () async {
    final delayedOpen = inboxController.delayNextOpen();
    await runtime.activateProfile('profile-1');
    await runtime.start();

    messageClient.emitOpened(_message());
    await inboxController.openStarted.future;
    await runtime.activateProfile('profile-2');
    delayedOpen.complete(_inboxItem());
    await _waitForQueue();

    expect(navigationController.pending, isNull);
    expect(navigationCoordinator.activeProfileUuid, 'profile-2');
  });

  test('preserves two opened messages while their inbox rows arrive', () async {
    const secondInbox = '44444444-4444-4444-8444-444444444444';
    const secondDispatch = '55555555-5555-4555-8555-555555555555';
    await runtime.activateProfile('profile-1');
    await runtime.start();

    messageClient.emitOpened(_message(actionType: 'open_home'));
    messageClient.emitOpened(
      _message(
        actionType: 'open_home',
        inboxUuid: secondInbox,
        dispatchUuid: secondDispatch,
      ),
    );
    await _waitUntil(() => inboxController.openedInboxUuids.length >= 2);

    inboxController.itemsByUuid[_inboxUuid] = _inboxItem();
    inboxController.itemsByUuid[secondInbox] = _inboxItem(
      inboxUuid: secondInbox,
      dispatchUuid: secondDispatch,
    );
    inboxController.signalChanged();

    await _waitUntil(() => navigationController.pendingCount == 2);
    expect(
      navigationController.pending?.payload.uuidNotificationInbox,
      _inboxUuid,
    );
  });
}

NotificationMessage _message({
  String? title = 'Aviso',
  String? body = 'Mensaje',
  String actionType = 'none',
  String inboxUuid = _inboxUuid,
  String dispatchUuid = _dispatchUuid,
  Map<String, Object?> dataOverrides = const {},
}) {
  return NotificationMessage(
    data: {
      'schema_version': '1',
      'uuid_notification_dispatch': dispatchUuid,
      'uuid_notification_inbox': inboxUuid,
      'category': 'general',
      'action_type': actionType,
      'action_payload': '{}',
      ...dataOverrides,
    },
    title: title,
    body: body,
  );
}

AppNotificationInboxItem _inboxItem({
  String inboxUuid = _inboxUuid,
  String dispatchUuid = _dispatchUuid,
}) {
  final now = DateTime.utc(2026, 7, 17, 12);
  return AppNotificationInboxItem(
    uuidNotificationInbox: inboxUuid,
    uuidNotificationDispatch: dispatchUuid,
    uuidProfile: 'profile-1',
    title: 'Aviso persistido',
    body: 'Mensaje persistido',
    category: 'general',
    actionType: 'open_home',
    actionPayload: const {},
    readAt: now,
    openedAt: now,
    createdAt: now,
    updatedAt: now,
  );
}

const _dispatchUuid = '11111111-1111-4111-8111-111111111111';
const _inboxUuid = '22222222-2222-4222-8222-222222222222';

Future<void> _waitUntil(bool Function() predicate) async {
  for (var attempt = 0; attempt < 100; attempt++) {
    if (predicate()) {
      return;
    }
    await Future<void>.delayed(const Duration(milliseconds: 1));
  }
  fail('La condición esperada no se cumplió a tiempo.');
}

Future<void> _waitForQueue() async {
  await Future<void>.delayed(const Duration(milliseconds: 20));
}

class _FakeNotificationMessageClient implements NotificationMessageClient {
  final StreamController<NotificationMessage> _foregroundController =
      StreamController<NotificationMessage>.broadcast();
  final StreamController<NotificationMessage> _openedController =
      StreamController<NotificationMessage>.broadcast();

  NotificationMessage? initialMessage;
  int initialMessageCalls = 0;

  @override
  Stream<NotificationMessage> get onMessage => _foregroundController.stream;

  @override
  Stream<NotificationMessage> get onMessageOpenedApp =>
      _openedController.stream;

  @override
  Future<NotificationMessage?> getInitialMessage() async {
    initialMessageCalls++;
    return initialMessage;
  }

  void emitForeground(NotificationMessage message) {
    _foregroundController.add(message);
  }

  void emitOpened(NotificationMessage message) {
    _openedController.add(message);
  }

  Future<void> dispose() async {
    await _foregroundController.close();
    await _openedController.close();
  }
}

class _FakeNotificationsInboxController extends NotificationsInboxController {
  _FakeNotificationsInboxController() : super(notificationsInboxDao: null);

  final List<String> pulledProfiles = [];
  final List<String> openedInboxUuids = [];
  AppNotificationInboxItem? itemToOpen;
  final Map<String, AppNotificationInboxItem> itemsByUuid = {};
  Completer<AppNotificationInboxItem?>? _delayedOpen;
  Completer<void> openStarted = Completer<void>();

  @override
  Future<void> pullFromRemote({String? uuidProfile}) async {
    if (uuidProfile != null) {
      pulledProfiles.add(uuidProfile);
    }
  }

  @override
  Future<AppNotificationInboxItem?> openNotification(
    String uuidNotificationInbox,
  ) async {
    openedInboxUuids.add(uuidNotificationInbox);
    if (!openStarted.isCompleted) {
      openStarted.complete();
    }
    final delayed = _delayedOpen;
    return delayed == null
        ? itemsByUuid[uuidNotificationInbox] ?? itemToOpen
        : delayed.future;
  }

  Completer<AppNotificationInboxItem?> delayNextOpen() {
    openStarted = Completer<void>();
    return _delayedOpen = Completer<AppNotificationInboxItem?>();
  }

  void signalChanged() {
    notifyListeners();
  }
}

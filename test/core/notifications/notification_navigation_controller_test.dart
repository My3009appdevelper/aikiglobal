import 'package:aikiglobal/core/data/models/app_notification_inbox_item.dart';
import 'package:aikiglobal/core/notifications/notification_navigation_controller.dart';
import 'package:aikiglobal/core/notifications/notification_payload_codec.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('NotificationNavigationController', () {
    test('keeps pending intents in FIFO order until acknowledged', () {
      final controller = NotificationNavigationController();
      controller.activateProfile('profile-1');

      expect(controller.enqueue(_payload(inbox: 'inbox-1')), isTrue);
      expect(
        controller.enqueue(_payload(inbox: 'inbox-2', dispatch: 'dispatch-2')),
        isTrue,
      );

      final first = controller.peekPendingForProfile('profile-1');
      expect(first?.payload.uuidNotificationInbox, 'inbox-1');
      expect(controller.pendingCount, 2);

      expect(
        controller.acknowledgePendingForProfile('profile-1', first!),
        isTrue,
      );
      expect(controller.pending?.payload.uuidNotificationInbox, 'inbox-2');
    });

    test('deduplicates by inbox or dispatch UUID', () {
      final controller = NotificationNavigationController();
      controller.activateProfile('profile-1');

      expect(controller.enqueue(_payload()), isTrue);
      expect(controller.enqueue(_payload()), isFalse);
      expect(
        controller.enqueue(_payload(inbox: 'inbox-2', dispatch: 'dispatch-1')),
        isFalse,
      );
      expect(
        controller.enqueue(_payload(inbox: 'inbox-1', dispatch: 'dispatch-2')),
        isFalse,
      );
    });

    test('keeps pending navigation until HomeShell consumes it', () {
      final controller = NotificationNavigationController();
      var returnToHomeCalls = 0;
      final coordinator = NotificationNavigationCoordinator(
        controller: controller,
        activateUserMode: () {},
        returnToHomeShell: () => returnToHomeCalls++,
      );
      coordinator.activateProfile('profile-1');

      expect(coordinator.openPayload(_payload()), isTrue);
      expect(controller.pending, isNotNull);
      expect(returnToHomeCalls, 0);

      coordinator.attachHomeShell();
      final intent = coordinator.peekPendingForActiveProfile();

      expect(intent?.payload.uuidNotificationInbox, 'inbox-1');
      expect(controller.pending, isNotNull);
      expect(coordinator.acknowledgePendingForActiveProfile(intent!), isTrue);
      expect(controller.pending, isNull);
      coordinator.dispose();
    });

    test('reactiva la navegación pendiente al volver a primer plano', () {
      final controller = NotificationNavigationController();
      var returnToHomeCalls = 0;
      final coordinator = NotificationNavigationCoordinator(
        controller: controller,
        activateUserMode: () {},
        returnToHomeShell: () => returnToHomeCalls++,
      );
      coordinator.activateProfile('profile-1');
      coordinator.attachHomeShell();
      coordinator.openPayload(_payload());

      coordinator.refreshPendingNavigationOnResume();

      expect(returnToHomeCalls, 2);
      expect(coordinator.pending, isNotNull);
      coordinator.dispose();
    });

    test('clears an old pending intent when the profile changes', () {
      final controller = NotificationNavigationController();
      final coordinator = NotificationNavigationCoordinator(
        controller: controller,
        activateUserMode: () {},
      );
      coordinator.activateProfile('profile-1');
      coordinator.openPayload(_payload());

      coordinator.activateProfile('profile-2');

      expect(controller.pending, isNull);
      expect(coordinator.peekPendingForActiveProfile(), isNull);
      coordinator.dispose();
    });

    test('accepts a local inbox item only for the active profile', () {
      final controller = NotificationNavigationController();
      var userModeActivations = 0;
      final coordinator = NotificationNavigationCoordinator(
        controller: controller,
        activateUserMode: () => userModeActivations++,
      );
      coordinator.activateProfile('profile-1');

      expect(coordinator.openInboxItem(_inboxItem('profile-2')), isFalse);
      expect(coordinator.openInboxItem(_inboxItem('profile-1')), isTrue);
      expect(userModeActivations, 1);
      expect(controller.pending?.payload.actionType, 'open_home');
      coordinator.dispose();
    });

    test('allows reopening a handled item explicitly from the inbox', () {
      final controller = NotificationNavigationController();
      final coordinator = NotificationNavigationCoordinator(
        controller: controller,
        activateUserMode: () {},
      );
      coordinator.activateProfile('profile-1');

      expect(coordinator.openInboxItem(_inboxItem('profile-1')), isTrue);
      final first = coordinator.peekPendingForActiveProfile();
      expect(first, isNotNull);
      expect(coordinator.acknowledgePendingForActiveProfile(first!), isTrue);

      expect(coordinator.openInboxItem(_inboxItem('profile-1')), isTrue);
      expect(coordinator.peekPendingForActiveProfile(), isNotNull);
      coordinator.dispose();
    });
  });

  group('notification route mapping', () {
    test('maps all schema actions to central destinations', () {
      expect(
        notificationDestinationForAction('none'),
        NotificationDestination.dialog,
      );
      expect(
        notificationDestinationForAction('open_home'),
        NotificationDestination.home,
      );
      expect(
        notificationDestinationForAction('open_explore'),
        NotificationDestination.explore,
      );
      expect(
        notificationDestinationForAction('open_meditation'),
        NotificationDestination.meditation,
      );
      expect(
        notificationDestinationForAction('open_company_info'),
        NotificationDestination.companyInfo,
      );
      expect(
        notificationDestinationForAction('open_content_item'),
        NotificationDestination.contentItem,
      );
    });

    test('maps tab destinations to the existing user indices', () {
      expect(
        homeIndexForNotificationDestination(NotificationDestination.explore),
        0,
      );
      expect(
        homeIndexForNotificationDestination(NotificationDestination.home),
        1,
      );
      expect(
        homeIndexForNotificationDestination(NotificationDestination.meditation),
        1,
      );
      expect(
        homeIndexForNotificationDestination(
          NotificationDestination.companyInfo,
        ),
        isNull,
      );
    });
  });
}

NotificationPayload _payload({
  String inbox = 'inbox-1',
  String dispatch = 'dispatch-1',
  String actionType = 'open_home',
}) {
  return NotificationPayload(
    schemaVersion: '1',
    uuidNotificationDispatch: dispatch,
    uuidNotificationInbox: inbox,
    category: 'general',
    actionType: actionType,
    actionPayload: const {},
    title: 'Aviso',
    body: 'Mensaje',
  );
}

AppNotificationInboxItem _inboxItem(String profileUuid) {
  final now = DateTime.utc(2026, 7, 17);
  return AppNotificationInboxItem(
    uuidNotificationInbox: 'inbox-local',
    uuidNotificationDispatch: 'dispatch-local',
    uuidProfile: profileUuid,
    title: 'Aviso local',
    body: 'Mensaje local',
    category: 'general',
    actionType: 'open_home',
    actionPayload: const {},
    createdAt: now,
    updatedAt: now,
  );
}

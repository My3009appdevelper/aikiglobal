import 'package:aikiglobal/core/data/local/app_database.dart';
import 'package:aikiglobal/core/data/local/daos/notification_dispatches_dao.dart';
import 'package:aikiglobal/core/data/local/daos/notification_events_dao.dart';
import 'package:aikiglobal/core/data/local/daos/notifications_inbox_dao.dart';
import 'package:aikiglobal/core/data/providers/notification_dispatches_controller.dart';
import 'package:aikiglobal/core/data/providers/notification_events_controller.dart';
import 'package:aikiglobal/core/data/providers/notifications_inbox_controller.dart';
import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase database;

  setUp(() {
    database = AppDatabase(executor: NativeDatabase.memory());
  });

  tearDown(() => database.close());

  test(
    'events controller saves, validates and archives local events',
    () async {
      final dao = NotificationEventsDao(database);
      final controller = NotificationEventsController(
        notificationEventsDao: dao,
      );

      final uuid = await controller.saveNotificationEvent(
        name: 'Aviso manual',
        category: 'general',
        titleTemplate: 'Título',
        bodyTemplate: 'Mensaje',
        triggerType: 'manual',
        executionMode: 'once',
        audienceType: 'all_users',
        actionType: 'none',
        startsAt: DateTime.utc(2026, 7, 16, 10),
        status: 'draft',
        uuidCreatedByProfile: 'admin-1',
        uuidUpdatedByProfile: 'admin-1',
      );

      expect(uuid, isNotEmpty);
      expect(controller.events.single.name, 'Aviso manual');
      expect(controller.events.single.hasPendingSync, isTrue);

      expect(
        () => controller.saveNotificationEvent(
          name: 'Inválido',
          category: 'content',
          titleTemplate: 'Contenido',
          bodyTemplate: 'Mensaje',
          triggerType: 'manual',
          executionMode: 'once',
          audienceType: 'all',
          actionType: 'open_content_item',
          startsAt: DateTime.utc(2026, 7, 16, 10),
          status: 'draft',
        ),
        throwsArgumentError,
      );

      await controller.archive(uuid);
      expect(controller.events, isEmpty);
      expect((await dao.getByUuid(uuid))?.status, 'cancelled');

      controller.dispose();
    },
  );

  test(
    'events controller persists an interval trigger configuration',
    () async {
      final dao = NotificationEventsDao(database);
      final controller = NotificationEventsController(
        notificationEventsDao: dao,
      );

      final uuid = await controller.saveNotificationEvent(
        name: 'Recordatorio',
        category: 'schedule_changes',
        titleTemplate: 'Una pausa para ti',
        bodyTemplate: 'Regresa a tu práctica.',
        triggerType: 'schedule',
        triggerKey: 'schedule.interval',
        executionMode: 'per_occurrence',
        audienceType: 'all_users',
        actionType: 'open_meditation',
        triggerConfig: const {
          'interval_value': 12,
          'interval_unit': 'hours',
          'timezone_mode': 'user_local',
        },
        startsAt: DateTime.utc(2026, 7, 16, 10),
        status: 'draft',
      );

      expect(controller.events.single.uuidNotificationEvent, uuid);
      expect(controller.events.single.triggerConfig, {
        'interval_value': 12,
        'interval_unit': 'hours',
        'timezone_mode': 'user_local',
      });
      controller.dispose();
    },
  );

  test('dispatches controller exposes recent backend snapshots only', () async {
    final dao = NotificationDispatchesDao(database);
    final now = DateTime.utc(2026, 7, 16, 11);
    await dao.upsertNotificationDispatch(
      NotificationDispatchesTableCompanion.insert(
        uuidNotificationDispatch: 'dispatch-1',
        uuidNotificationEvent: 'event-1',
        triggerSource: 'manual',
        idempotencyKey: 'manual-1',
        titleSnapshot: 'Aviso',
        bodySnapshot: 'Mensaje',
        categorySnapshot: 'general',
        audienceTypeSnapshot: 'all',
        actionTypeSnapshot: 'none',
        status: const Value('completed'),
        createdAt: Value(now),
        updatedAt: Value(now),
        syncedAt: Value(now),
      ),
    );
    final controller = NotificationDispatchesController(
      notificationDispatchesDao: dao,
    );

    await controller.loadRecent();

    expect(controller.dispatches.single.uuidNotificationDispatch, 'dispatch-1');
    expect(await controller.hasDispatchForEvent('event-1'), isTrue);
    expect(await controller.hasDispatchForEvent('event-2'), isFalse);
    controller.clear();
    expect(controller.dispatches, isEmpty);
    controller.dispose();
  });

  test('inbox controller counts unread and opens idempotently', () async {
    final dao = NotificationsInboxDao(database);
    final now = DateTime.utc(2026, 7, 16, 12);
    await dao.upsertNotifications([
      _inboxCompanion(uuid: 'inbox-1', createdAt: now),
      _inboxCompanion(
        uuid: 'inbox-2',
        createdAt: now.add(const Duration(minutes: 1)),
      ),
      _inboxCompanion(
        uuid: 'inbox-read',
        createdAt: now.add(const Duration(minutes: 2)),
        readAt: now,
      ),
    ]);
    final controller = NotificationsInboxController(notificationsInboxDao: dao);

    await controller.loadForProfile('profile-1');
    expect(controller.unreadCount, 2);

    await controller.openNotification('inbox-1');
    final firstOpenedAt = (await dao.getByUuid('inbox-1'))?.openedAt;
    await controller.openNotification('inbox-1');
    expect((await dao.getByUuid('inbox-1'))?.openedAt, firstOpenedAt);
    expect(controller.unreadCount, 1);

    await controller.markAllRead();
    expect(controller.unreadCount, 0);
    expect((await dao.getByUuid('inbox-2'))?.openedAt, isNull);

    controller.clear();
    expect(controller.activeProfileUuid, isNull);
    expect(controller.notifications, isEmpty);
    controller.dispose();
  });
}

NotificationsInboxTableCompanion _inboxCompanion({
  required String uuid,
  required DateTime createdAt,
  DateTime? readAt,
}) {
  return NotificationsInboxTableCompanion.insert(
    uuidNotificationInbox: uuid,
    uuidNotificationDispatch: 'dispatch-$uuid',
    uuidProfile: 'profile-1',
    title: 'Aviso',
    body: 'Mensaje',
    category: 'general',
    actionType: 'none',
    readAt: Value(readAt),
    createdAt: Value(createdAt),
    updatedAt: Value(createdAt),
    syncedAt: Value(createdAt),
  );
}

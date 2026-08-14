import 'package:aikiglobal/core/data/common/json_object_codec.dart';
import 'package:aikiglobal/core/data/local/app_database.dart';
import 'package:aikiglobal/core/data/local/daos/notification_dispatches_dao.dart';
import 'package:aikiglobal/core/data/local/daos/notification_events_dao.dart';
import 'package:aikiglobal/core/data/local/daos/notifications_inbox_dao.dart';
import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase database;
  late NotificationEventsDao eventsDao;
  late NotificationDispatchesDao dispatchesDao;
  late NotificationsInboxDao inboxDao;

  setUp(() {
    database = AppDatabase(executor: NativeDatabase.memory());
    eventsDao = NotificationEventsDao(database);
    dispatchesDao = NotificationDispatchesDao(database);
    inboxDao = NotificationsInboxDao(database);
  });

  tearDown(() => database.close());

  test('archives an event and marks it pending sync', () async {
    final now = DateTime.utc(2026, 7, 16, 10);
    await eventsDao.upsertNotificationEvent(
      NotificationEventsTableCompanion.insert(
        uuidNotificationEvent: 'event-1',
        name: 'Aviso general',
        category: 'general',
        titleTemplate: 'Aviso',
        bodyTemplate: 'Mensaje',
        triggerType: 'manual',
        executionMode: 'once',
        audienceType: 'all',
        actionType: 'none',
        startsAt: Value(now),
        status: const Value('active'),
        createdAt: Value(now),
        updatedAt: Value(now),
        syncedAt: Value(now),
      ),
    );

    await eventsDao.softDeleteByUuid('event-1');

    final archived = await eventsDao.getByUuid('event-1');
    expect(archived?.status, 'cancelled');
    expect(archived?.deletedAt, isNotNull);
    expect(archived?.syncedAt, isNull);
    expect(await eventsDao.getPendingSync(), hasLength(1));
  });

  test('enforces a unique dispatch idempotency key', () async {
    final now = DateTime.utc(2026, 7, 16, 11);
    final first = _dispatchCompanion(
      uuid: 'dispatch-1',
      idempotencyKey: 'manual-request-1',
      createdAt: now,
    );
    final duplicate = _dispatchCompanion(
      uuid: 'dispatch-2',
      idempotencyKey: 'manual-request-1',
      createdAt: now.add(const Duration(minutes: 1)),
    );

    await dispatchesDao.upsertNotificationDispatch(first);

    expect(
      () => dispatchesDao.upsertNotificationDispatch(duplicate),
      throwsA(anything),
    );
  });

  test('lists dispatches by event from newest to oldest', () async {
    final now = DateTime.utc(2026, 7, 16, 11);
    await dispatchesDao.upsertNotificationDispatches([
      _dispatchCompanion(
        uuid: 'dispatch-old',
        idempotencyKey: 'old',
        createdAt: now,
      ),
      _dispatchCompanion(
        uuid: 'dispatch-new',
        idempotencyKey: 'new',
        createdAt: now.add(const Duration(minutes: 1)),
      ),
    ]);

    final rows = await dispatchesDao.getByEvent('event-1');

    expect(rows.map((row) => row.uuidNotificationDispatch), [
      'dispatch-new',
      'dispatch-old',
    ]);
  });

  test('isolates inbox rows by profile', () async {
    final now = DateTime.utc(2026, 7, 16, 12);
    await inboxDao.upsertNotifications([
      _inboxCompanion(
        uuid: 'inbox-1',
        dispatchUuid: 'dispatch-1',
        profileUuid: 'profile-1',
        createdAt: now,
      ),
      _inboxCompanion(
        uuid: 'inbox-2',
        dispatchUuid: 'dispatch-2',
        profileUuid: 'profile-2',
        createdAt: now,
      ),
    ]);

    final rows = await inboxDao.getForProfile('profile-1');

    expect(rows.map((row) => row.uuidNotificationInbox), ['inbox-1']);
  });

  test('enforces one inbox row per dispatch and profile', () async {
    final now = DateTime.utc(2026, 7, 16, 12);
    await inboxDao.upsertNotification(
      _inboxCompanion(
        uuid: 'inbox-1',
        dispatchUuid: 'dispatch-1',
        profileUuid: 'profile-1',
        createdAt: now,
      ),
    );

    expect(
      () => inboxDao.upsertNotification(
        _inboxCompanion(
          uuid: 'inbox-duplicate',
          dispatchUuid: 'dispatch-1',
          profileUuid: 'profile-1',
          createdAt: now.add(const Duration(minutes: 1)),
        ),
      ),
      throwsA(anything),
    );
    expect(
      (await inboxDao.getForProfile('profile-1')).single.uuidNotificationInbox,
      'inbox-1',
    );
  });

  test('markOpened sets read and opened timestamps only once', () async {
    final now = DateTime.utc(2026, 7, 16, 12);
    await inboxDao.upsertNotification(
      _inboxCompanion(
        uuid: 'inbox-1',
        dispatchUuid: 'dispatch-1',
        profileUuid: 'profile-1',
        createdAt: now,
      ),
    );

    await inboxDao.markOpened('inbox-1');
    final first = await inboxDao.getByUuid('inbox-1');
    await Future<void>.delayed(const Duration(milliseconds: 2));
    await inboxDao.markOpened('inbox-1');
    final second = await inboxDao.getByUuid('inbox-1');

    expect(first?.readAt, isNotNull);
    expect(first?.openedAt, isNotNull);
    expect(second?.readAt, first?.readAt);
    expect(second?.openedAt, first?.openedAt);
    expect(second?.syncedAt, isNull);
  });

  test('markAllRead leaves opened_at untouched', () async {
    final now = DateTime.utc(2026, 7, 16, 12);
    await inboxDao.upsertNotification(
      _inboxCompanion(
        uuid: 'inbox-1',
        dispatchUuid: 'dispatch-1',
        profileUuid: 'profile-1',
        createdAt: now,
      ),
    );

    await inboxDao.markAllRead('profile-1');
    final row = await inboxDao.getByUuid('inbox-1');

    expect(row?.readAt, isNotNull);
    expect(row?.openedAt, isNull);
    expect(await inboxDao.getPendingSyncForProfile('profile-1'), hasLength(1));
  });
}

NotificationDispatchesTableCompanion _dispatchCompanion({
  required String uuid,
  required String idempotencyKey,
  required DateTime createdAt,
}) {
  return NotificationDispatchesTableCompanion.insert(
    uuidNotificationDispatch: uuid,
    uuidNotificationEvent: 'event-1',
    triggerSource: 'manual',
    idempotencyKey: idempotencyKey,
    titleSnapshot: 'Aviso',
    bodySnapshot: 'Mensaje',
    categorySnapshot: 'general',
    audienceTypeSnapshot: 'all',
    actionTypeSnapshot: 'none',
    status: const Value('pending'),
    createdAt: Value(createdAt),
    updatedAt: Value(createdAt),
  );
}

NotificationsInboxTableCompanion _inboxCompanion({
  required String uuid,
  required String dispatchUuid,
  required String profileUuid,
  required DateTime createdAt,
}) {
  return NotificationsInboxTableCompanion.insert(
    uuidNotificationInbox: uuid,
    uuidNotificationDispatch: dispatchUuid,
    uuidProfile: profileUuid,
    title: 'Aviso',
    body: 'Mensaje',
    category: 'general',
    actionType: 'none',
    actionPayloadJson: Value(encodeJsonObject(const {})),
    createdAt: Value(createdAt),
    updatedAt: Value(createdAt),
    syncedAt: Value(createdAt),
  );
}

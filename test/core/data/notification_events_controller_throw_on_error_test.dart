import 'package:aikiglobal/core/data/local/app_database.dart';
import 'package:aikiglobal/core/data/local/daos/notification_events_dao.dart';
import 'package:aikiglobal/core/data/providers/notification_events_controller.dart';
import 'package:aikiglobal/core/data/remote/services/notification_events_remote_service.dart';
import 'package:aikiglobal/core/data/sync/notification_events_sync_service.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  late AppDatabase database;
  late _FailingNotificationEventsRemoteService remoteService;
  late NotificationEventsController controller;

  setUp(() {
    database = AppDatabase(executor: NativeDatabase.memory());
    final dao = NotificationEventsDao(database);
    remoteService = _FailingNotificationEventsRemoteService();
    controller = NotificationEventsController(
      notificationEventsDao: dao,
      syncService: NotificationEventsSyncService(
        dao: dao,
        service: remoteService,
      ),
    );
  });

  tearDown(() async {
    controller.dispose();
    await database.close();
  });

  test(
    'pull preserves the existing error-capturing behavior by default',
    () async {
      await controller.pullFromRemote();

      expect(controller.error, same(remoteService.failure));
      expect(controller.isSyncing, isFalse);
    },
  );

  test(
    'sync rethrows the captured error when throwOnError is requested',
    () async {
      await expectLater(
        controller.syncWithRemote(throwOnError: true),
        throwsA(same(remoteService.failure)),
      );

      expect(controller.error, same(remoteService.failure));
      expect(controller.isSyncing, isFalse);
    },
  );

  test(
    'pull rethrows the captured error when throwOnError is requested',
    () async {
      await expectLater(
        controller.pullFromRemote(throwOnError: true),
        throwsA(same(remoteService.failure)),
      );

      expect(controller.error, same(remoteService.failure));
      expect(controller.isSyncing, isFalse);
    },
  );

  test('remote-only pull rethrows when throwOnError is requested', () async {
    final remoteOnlyController = NotificationEventsController(
      notificationEventsDao: null,
      notificationEventsRemoteService: remoteService,
    );
    addTearDown(remoteOnlyController.dispose);

    await expectLater(
      remoteOnlyController.pullFromRemote(throwOnError: true),
      throwsA(same(remoteService.failure)),
    );

    expect(remoteOnlyController.error, same(remoteService.failure));
    expect(remoteOnlyController.isLoading, isFalse);
  });
}

class _FailingNotificationEventsRemoteService
    extends NotificationEventsRemoteService {
  _FailingNotificationEventsRemoteService()
    : super(supabase: SupabaseClient('http://localhost', 'test-anon-key'));

  final StateError failure = StateError('Fallo remoto');

  @override
  Future<List<Map<String, dynamic>>> getHeadsOnline() => Future.error(failure);

  @override
  Future<List<Map<String, dynamic>>> getAllOnline({
    String selectColumns = '*',
  }) => Future.error(failure);
}

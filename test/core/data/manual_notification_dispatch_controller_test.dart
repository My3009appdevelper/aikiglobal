import 'package:aikiglobal/core/data/local/app_database.dart';
import 'package:aikiglobal/core/data/local/daos/notification_dispatches_dao.dart';
import 'package:aikiglobal/core/data/models/app_notification_dispatch.dart';
import 'package:aikiglobal/core/data/models/manual_notification_dispatch_result.dart';
import 'package:aikiglobal/core/data/models/notification_dispatch_analytics.dart';
import 'package:aikiglobal/core/data/providers/notification_dispatches_controller.dart';
import 'package:aikiglobal/core/data/remote/services/manual_notification_dispatch_remote_service.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  late AppDatabase database;
  late NotificationDispatchesDao dao;
  late _FakeManualNotificationDispatchRemoteService service;
  late NotificationDispatchesController controller;

  setUp(() {
    database = AppDatabase(executor: NativeDatabase.memory());
    dao = NotificationDispatchesDao(database);
    service = _FakeManualNotificationDispatchRemoteService();
    controller = NotificationDispatchesController(
      notificationDispatchesDao: dao,
      manualNotificationDispatchRemoteService: service,
    );
  });

  tearDown(() async {
    controller.dispose();
    await database.close();
  });

  test(
    'keeps manual preview state separate from pull-only dispatch snapshots',
    () async {
      final preview = await controller.previewManualEvent(' event-1 ');

      expect(preview.targetProfileCount, 5);
      expect(controller.manualAudiencePreview, same(preview));
      expect(controller.isManualCommandInFlight, isFalse);
      expect(controller.manualCommandError, isNull);
      expect(service.previewedEventUuids, ['event-1']);
      expect(await dao.getAllNotDeleted(), isEmpty);
    },
  );

  test(
    'returns the backend dispatch acceptance without writing a dispatch locally',
    () async {
      final acceptance = await controller.requestManualDispatch('event-1');

      expect(acceptance.uuidNotificationDispatch, 'dispatch-1');
      expect(controller.manualDispatchAcceptance, same(acceptance));
      expect(service.dispatchedEventUuids, ['event-1']);
      expect(await dao.getAllNotDeleted(), isEmpty);
    },
  );

  test(
    'exposes a manual command failure and leaves pull state intact',
    () async {
      final failure = StateError('No autorizado');
      service.previewFailure = failure;

      await expectLater(
        controller.previewManualEvent('event-1'),
        throwsA(same(failure)),
      );

      expect(controller.manualCommandError, same(failure));
      expect(controller.error, isNull);
      expect(controller.isManualCommandInFlight, isFalse);
    },
  );

  test(
    'routes resend and failed retry to their explicit command targets',
    () async {
      await controller.requestManualResend(_dispatch(status: 'completed'));
      await controller.requestManualRetry(_dispatch(status: 'failed'));

      expect(service.resentDispatchUuids, ['dispatch-1']);
      expect(service.retriedDispatchUuids, ['dispatch-1']);
    },
  );

  test('loads typed analytics through the command service', () async {
    final analytics = await controller.loadAnalytics(
      _dispatch(status: 'completed'),
    );

    expect(analytics.uuidNotificationDispatch, 'dispatch-1');
    expect(service.analyticsDispatchUuids, ['dispatch-1']);
  });

  test('reuses cached analytics for the same dispatch snapshot', () async {
    final dispatch = _dispatch(status: 'completed');

    final first = await controller.loadAnalytics(dispatch);
    final second = await controller.loadAnalytics(dispatch);

    expect(second, same(first));
    expect(service.analyticsDispatchUuids, ['dispatch-1']);
  });
}

AppNotificationDispatch _dispatch({required String status}) {
  return AppNotificationDispatch(
    uuidNotificationDispatch: 'dispatch-1',
    uuidNotificationEvent: 'event-1',
    triggerSource: 'manual',
    idempotencyKey: 'manual:event-1',
    titleSnapshot: 'Aviso',
    bodySnapshot: 'Mensaje',
    categorySnapshot: 'general',
    audienceTypeSnapshot: 'all_users',
    actionTypeSnapshot: 'none',
    actionPayloadSnapshot: const {},
    status: status,
    targetProfileCount: 1,
    targetDeviceCount: 1,
    successDeviceCount: status == 'failed' ? 0 : 1,
    failureDeviceCount: status == 'failed' ? 1 : 0,
    invalidTokenCount: status == 'failed' ? 1 : 0,
    createdAt: DateTime.utc(2026, 8, 4),
    updatedAt: DateTime.utc(2026, 8, 4),
  );
}

class _FakeManualNotificationDispatchRemoteService
    extends ManualNotificationDispatchRemoteService {
  _FakeManualNotificationDispatchRemoteService()
    : super(supabase: SupabaseClient('http://localhost', 'test-anon-key'));

  final List<String> previewedEventUuids = [];
  final List<String> dispatchedEventUuids = [];
  final List<String> resentDispatchUuids = [];
  final List<String> retriedDispatchUuids = [];
  final List<String> analyticsDispatchUuids = [];
  Object? previewFailure;

  @override
  Future<ManualNotificationAudiencePreview> previewManualEvent(
    String uuidNotificationEvent,
  ) async {
    previewedEventUuids.add(uuidNotificationEvent);
    final failure = previewFailure;
    if (failure != null) {
      throw failure;
    }
    return const ManualNotificationAudiencePreview(
      uuidNotificationEvent: 'event-1',
      title: 'Aviso',
      body: 'Mensaje',
      category: 'general',
      audienceType: 'all_users',
      actionType: 'none',
      actionPayload: {},
      targetProfileCount: 5,
      targetDeviceCount: 7,
    );
  }

  @override
  Future<ManualNotificationDispatchAcceptance> requestManualDispatch(
    String uuidNotificationEvent, {
    String? requestId,
    String? retryDispatchUuid,
  }) async {
    dispatchedEventUuids.add(uuidNotificationEvent);
    if (retryDispatchUuid != null) {
      retriedDispatchUuids.add(retryDispatchUuid);
    }
    return const ManualNotificationDispatchAcceptance(
      uuidNotificationEvent: 'event-1',
      uuidNotificationDispatch: 'dispatch-1',
      status: 'pending',
      targetProfileCount: 5,
      targetDeviceCount: 7,
      reused: false,
    );
  }

  @override
  Future<ManualNotificationDispatchAcceptance> requestManualResend(
    String uuidNotificationEvent,
    String sourceDispatchUuid, {
    String? requestId,
  }) async {
    resentDispatchUuids.add(sourceDispatchUuid);
    return const ManualNotificationDispatchAcceptance(
      uuidNotificationEvent: 'event-1',
      uuidNotificationDispatch: 'dispatch-2',
      status: 'pending',
      targetProfileCount: 5,
      targetDeviceCount: 7,
      reused: false,
      sourceDispatchUuid: 'dispatch-1',
    );
  }

  @override
  Future<NotificationDispatchAnalytics> loadAnalytics(
    String uuidNotificationDispatch,
  ) async {
    analyticsDispatchUuids.add(uuidNotificationDispatch);
    return const NotificationDispatchAnalytics(
      uuidNotificationDispatch: 'dispatch-1',
      targetProfileCount: 1,
      targetDeviceCount: 1,
      successDeviceCount: 1,
      failureDeviceCount: 0,
      invalidTokenCount: 0,
      inboxCount: 1,
      openedCount: 0,
      readCount: 0,
      recipients: [],
    );
  }
}

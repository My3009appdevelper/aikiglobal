import 'dart:async';
import 'dart:math' as math;

import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';

import '../common/json_object_codec.dart';
import '../local/app_database.dart';
import '../local/daos/notification_events_dao.dart';
import '../models/app_notification_event.dart';
import '../models/notification_values.dart';
import '../remote/services/notification_events_remote_service.dart';
import '../sync/notification_events_sync_service.dart';
import '../sync/sync_mappers.dart';

class NotificationEventsController extends ChangeNotifier {
  NotificationEventsController({
    required NotificationEventsDao? notificationEventsDao,
    NotificationEventsRemoteService? notificationEventsRemoteService,
    NotificationEventsSyncService? syncService,
  }) : _dao = notificationEventsDao,
       _remoteService = notificationEventsRemoteService,
       _syncService = syncService;

  final NotificationEventsDao? _dao;
  final NotificationEventsRemoteService? _remoteService;
  final NotificationEventsSyncService? _syncService;

  StreamSubscription<List<LocalNotificationEvent>>? _subscription;
  List<AppNotificationEvent> _events = const [];
  bool _isLoading = false;
  bool _isSyncing = false;
  Object? _error;

  List<AppNotificationEvent> get events => _events;
  bool get isLoading => _isLoading;
  bool get isSyncing => _isSyncing;
  Object? get error => _error;

  void watchAll({bool pullRemote = false}) {
    _cancelSubscription();
    final dao = _dao;
    if (dao == null) {
      unawaited(loadAll());
      return;
    }

    _subscription = dao.watchAllNotDeleted().listen(
      (rows) {
        _events = _toAppEvents(rows);
        _error = null;
        notifyListeners();
      },
      onError: (Object error) {
        _error = error;
        notifyListeners();
      },
    );

    if (pullRemote) {
      unawaited(pullFromRemote());
    }
  }

  Future<void> loadAll() async {
    final dao = _dao;
    if (dao != null) {
      await _load(() async => _toAppEvents(await dao.getAllNotDeleted()));
      return;
    }
    await _loadRemote();
  }

  Future<void> pullFromRemote({bool throwOnError = false}) async {
    final syncService = _syncService;
    if (_dao == null || syncService == null) {
      await _loadRemote(throwOnError: throwOnError);
      return;
    }

    await _runSync(syncService.pull, throwOnError: throwOnError);
  }

  Future<void> syncWithRemote({bool throwOnError = false}) async {
    final syncService = _syncService;
    if (_dao == null || syncService == null) {
      await _loadRemote(throwOnError: throwOnError);
      return;
    }

    await _runSync(syncService.sync, throwOnError: throwOnError);
  }

  Future<String> saveNotificationEvent({
    String? uuidNotificationEvent,
    required String name,
    required String category,
    required String titleTemplate,
    required String bodyTemplate,
    required String triggerType,
    String? triggerKey,
    required String executionMode,
    required String audienceType,
    required String actionType,
    Map<String, dynamic> actionPayloadTemplate = const {},
    Map<String, dynamic> triggerConfig = const {},
    required DateTime startsAt,
    DateTime? endsAt,
    required String status,
    String? uuidCreatedByProfile,
    String? uuidUpdatedByProfile,
    bool syncAfterSave = false,
  }) async {
    final cleanUuid =
        _cleanNullableText(uuidNotificationEvent) ?? _generateUuidV4();
    final cleanName = name.trim();
    final cleanCategory = category.trim().toLowerCase();
    final cleanTitle = titleTemplate.trim();
    final cleanBody = bodyTemplate.trim();
    final cleanTriggerType = triggerType.trim().toLowerCase();
    final cleanTriggerKey = _cleanNullableText(triggerKey)?.toLowerCase();
    final cleanExecutionMode = executionMode.trim().toLowerCase();
    final cleanAudienceType = audienceType.trim().toLowerCase();
    final cleanActionType = actionType.trim().toLowerCase();
    final cleanStatus = status.trim().toLowerCase();
    final utcStartsAt = startsAt.toUtc();
    final utcEndsAt = endsAt?.toUtc();
    final canonicalPayload = decodeJsonObject(
      encodeJsonObject(actionPayloadTemplate),
    );
    final canonicalTriggerConfig = decodeJsonObject(
      encodeJsonObject(triggerConfig),
    );

    validateNotificationEventDefinition(
      name: cleanName,
      category: cleanCategory,
      titleTemplate: cleanTitle,
      bodyTemplate: cleanBody,
      triggerType: cleanTriggerType,
      triggerKey: cleanTriggerKey,
      executionMode: cleanExecutionMode,
      audienceType: cleanAudienceType,
      actionType: cleanActionType,
      actionPayloadTemplate: canonicalPayload,
      triggerConfig: canonicalTriggerConfig,
      startsAt: utcStartsAt,
      endsAt: utcEndsAt,
      status: cleanStatus,
    );

    final existing = await _findByUuid(cleanUuid);
    final now = DateTime.now().toUtc();
    final local = LocalNotificationEvent(
      uuidNotificationEvent: cleanUuid,
      name: cleanName,
      category: cleanCategory,
      titleTemplate: cleanTitle,
      bodyTemplate: cleanBody,
      triggerType: cleanTriggerType,
      triggerKey: cleanTriggerKey,
      executionMode: cleanExecutionMode,
      audienceType: cleanAudienceType,
      actionType: cleanActionType,
      actionPayloadTemplateJson: encodeJsonObject(canonicalPayload),
      triggerConfigJson: encodeJsonObject(canonicalTriggerConfig),
      startsAt: utcStartsAt,
      endsAt: utcEndsAt,
      status: cleanStatus,
      uuidCreatedByProfile:
          _cleanNullableText(uuidCreatedByProfile) ??
          existing?.uuidCreatedByProfile,
      uuidUpdatedByProfile:
          _cleanNullableText(uuidUpdatedByProfile) ??
          existing?.uuidUpdatedByProfile,
      createdAt: existing?.createdAt ?? now,
      updatedAt: now,
      deletedAt: null,
      syncedAt: null,
    );

    final dao = _dao;
    if (dao != null) {
      await dao.upsertNotificationEvent(
        NotificationEventsTableCompanion.insert(
          uuidNotificationEvent: local.uuidNotificationEvent,
          name: local.name,
          category: local.category,
          titleTemplate: local.titleTemplate,
          bodyTemplate: local.bodyTemplate,
          triggerType: local.triggerType,
          triggerKey: Value(local.triggerKey),
          executionMode: local.executionMode,
          audienceType: local.audienceType,
          actionType: local.actionType,
          actionPayloadTemplateJson: Value(local.actionPayloadTemplateJson),
          triggerConfigJson: Value(local.triggerConfigJson),
          startsAt: Value(local.startsAt),
          endsAt: Value(local.endsAt),
          status: Value(local.status),
          uuidCreatedByProfile: Value(local.uuidCreatedByProfile),
          uuidUpdatedByProfile: Value(local.uuidUpdatedByProfile),
          createdAt: Value(local.createdAt),
          updatedAt: Value(local.updatedAt),
          deletedAt: const Value(null),
          syncedAt: const Value(null),
        ),
      );
      await _reloadLocal();
    } else if (_remoteService != null) {
      await _remoteService.upsertOnline(notificationEventToRemote(local));
      await _loadRemote();
    } else {
      throw StateError('No hay persistencia configurada para notificaciones.');
    }

    if (syncAfterSave) {
      await syncWithRemote(throwOnError: true);
    }
    return cleanUuid;
  }

  Future<void> archive(
    String uuidNotificationEvent, {
    bool syncAfterUpdate = false,
  }) async {
    final cleanUuid = uuidNotificationEvent.trim();
    if (cleanUuid.isEmpty) {
      return;
    }

    final dao = _dao;
    if (dao != null) {
      await dao.softDeleteByUuid(cleanUuid);
      await _reloadLocal();
    } else if (_remoteService != null) {
      final now = DateTime.now().toUtc();
      await _remoteService.updateOnlineById(cleanUuid, {
        'status': 'cancelled',
        'deleted_at': _remoteService.isoUtc(now),
      });
      await _loadRemote();
    }

    if (syncAfterUpdate) {
      await syncWithRemote();
    }
  }

  void clear() {
    _cancelSubscription();
    _events = const [];
    _isLoading = false;
    _isSyncing = false;
    _error = null;
    notifyListeners();
  }

  Future<AppNotificationEvent?> _findByUuid(String uuid) async {
    final dao = _dao;
    if (dao != null) {
      final local = await dao.getByUuid(uuid);
      return local == null ? null : AppNotificationEvent.fromLocal(local);
    }
    for (final event in _events) {
      if (event.uuidNotificationEvent == uuid) {
        return event;
      }
    }
    return null;
  }

  Future<void> _reloadLocal() async {
    final dao = _dao;
    if (dao == null) {
      return;
    }
    _events = _toAppEvents(await dao.getAllNotDeleted());
    _error = null;
    notifyListeners();
  }

  Future<void> _loadRemote({bool throwOnError = false}) async {
    final service = _remoteService;
    if (service == null) {
      return;
    }
    await _load(() async {
      final rows = await service.getAllOnline();
      return List.unmodifiable(
        rows
            .where((row) => row['deleted_at'] == null)
            .map(notificationEventRemoteToApp),
      );
    }, throwOnError: throwOnError);
  }

  Future<void> _load(
    Future<List<AppNotificationEvent>> Function() operation, {
    bool throwOnError = false,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _events = await operation();
    } catch (error) {
      _error = error;
      if (throwOnError) {
        rethrow;
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _runSync(
    Future<void> Function() operation, {
    bool throwOnError = false,
  }) async {
    _isSyncing = true;
    _error = null;
    notifyListeners();
    try {
      await operation();
      await _reloadLocal();
    } catch (error) {
      _error = error;
      if (throwOnError) {
        rethrow;
      }
    } finally {
      _isSyncing = false;
      notifyListeners();
    }
  }

  List<AppNotificationEvent> _toAppEvents(List<LocalNotificationEvent> rows) {
    return List.unmodifiable(rows.map(AppNotificationEvent.fromLocal));
  }

  String? _cleanNullableText(String? value) {
    final clean = value?.trim();
    return clean == null || clean.isEmpty ? null : clean;
  }

  String _generateUuidV4() {
    final random = math.Random.secure();
    final bytes = List<int>.generate(16, (_) => random.nextInt(256));
    bytes[6] = (bytes[6] & 0x0f) | 0x40;
    bytes[8] = (bytes[8] & 0x3f) | 0x80;
    String hexByte(int value) => value.toRadixString(16).padLeft(2, '0');
    final hex = bytes.map(hexByte).join();
    return '${hex.substring(0, 8)}-${hex.substring(8, 12)}-'
        '${hex.substring(12, 16)}-${hex.substring(16, 20)}-'
        '${hex.substring(20)}';
  }

  void _cancelSubscription() {
    _subscription?.cancel();
    _subscription = null;
  }

  @override
  void dispose() {
    _cancelSubscription();
    super.dispose();
  }
}

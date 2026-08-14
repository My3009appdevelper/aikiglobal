import 'dart:async';

import '../../notifications/notification_device_runtime.dart';
import 'admin_profiles_controller.dart';
import 'company_info_controller.dart';
import 'content_media_controller.dart';
import 'content_items_controller.dart';
import 'current_profile_controller.dart';
import 'notification_devices_controller.dart';
import 'notification_dispatches_controller.dart';
import 'notification_events_controller.dart';
import 'notifications_inbox_controller.dart';
import 'subscription_controller.dart';
import 'user_content_states_controller.dart';
import 'wellness_daily_logs_controller.dart';
import 'wellness_profile_stats_controller.dart';

enum AppLoadScope {
  authenticatedEntry,
  explore,
  safeSpace,
  profile,
  appResume,
  adminContent,
  adminContentForm,
  adminUsers,
  adminCompany,
  adminNotifications,
  adminNotificationDispatch,
}

/// Coordina sincronizaciones de datos sin exponer sus detalles a la UI.
///
/// Cada controller mantiene la estrategia push-then-pull de su propio sync
/// service. Esta clase decide qué módulos deben sincronizarse según el lugar
/// desde donde se solicita la carga y evita ejecuciones simultáneas.
class AppLoadCoordinator {
  AppLoadCoordinator({
    required CurrentProfileController currentProfileController,
    required AdminProfilesController adminProfilesController,
    required CompanyInfoController companyInfoController,
    required ContentItemsController contentItemsController,
    required ContentMediaController contentMediaController,
    required NotificationDevicesController notificationDevicesController,
    required NotificationDispatchesController notificationDispatchesController,
    required NotificationEventsController notificationEventsController,
    required NotificationsInboxController notificationsInboxController,
    required SubscriptionController subscriptionController,
    required UserContentStatesController userContentStatesController,
    required WellnessDailyLogsController wellnessDailyLogsController,
    required WellnessProfileStatsController wellnessProfileStatsController,
    NotificationDeviceRuntime? notificationDeviceRuntime,
  }) : _currentProfileController = currentProfileController,
       _adminProfilesController = adminProfilesController,
       _companyInfoController = companyInfoController,
       _contentItemsController = contentItemsController,
       _contentMediaController = contentMediaController,
       _notificationDevicesController = notificationDevicesController,
       _notificationDispatchesController = notificationDispatchesController,
       _notificationEventsController = notificationEventsController,
       _notificationsInboxController = notificationsInboxController,
       _subscriptionController = subscriptionController,
       _userContentStatesController = userContentStatesController,
       _wellnessDailyLogsController = wellnessDailyLogsController,
       _wellnessProfileStatsController = wellnessProfileStatsController,
       _notificationDeviceRuntime = notificationDeviceRuntime;

  final CurrentProfileController _currentProfileController;
  final AdminProfilesController _adminProfilesController;
  final CompanyInfoController _companyInfoController;
  final ContentItemsController _contentItemsController;
  final ContentMediaController _contentMediaController;
  final NotificationDevicesController _notificationDevicesController;
  final NotificationDispatchesController _notificationDispatchesController;
  final NotificationEventsController _notificationEventsController;
  final NotificationsInboxController _notificationsInboxController;
  final SubscriptionController _subscriptionController;
  final UserContentStatesController _userContentStatesController;
  final WellnessDailyLogsController _wellnessDailyLogsController;
  final WellnessProfileStatsController _wellnessProfileStatsController;
  final NotificationDeviceRuntime? _notificationDeviceRuntime;

  static const _resumeInterval = Duration(minutes: 5);
  Future<void> _syncQueue = Future<void>.value();
  final Map<String, Future<void>> _scheduledSyncs = {};
  DateTime? _lastResumeSync;
  String? _lastResumeProfileUuid;
  bool _disposed = false;

  Future<void> syncWithRemote({required AppLoadScope scope}) {
    if (_disposed || !_currentProfileController.isAuthenticated) {
      return Future<void>.value();
    }

    final profileUuid = _currentProfileController.profile?.uuidProfile;
    if (profileUuid == null || profileUuid.trim().isEmpty) {
      return Future<void>.value();
    }

    final scheduleKey = _scheduleKey(scope, profileUuid);
    final scheduledSync = _scheduledSyncs[scheduleKey];
    if (scheduledSync != null) {
      return scheduledSync;
    }

    if (scope == AppLoadScope.appResume) {
      final now = DateTime.now();
      final lastSync = _lastResumeSync;
      if (lastSync != null &&
          _lastResumeProfileUuid == profileUuid &&
          now.difference(lastSync) < _resumeInterval) {
        return Future<void>.value();
      }
      _lastResumeSync = now;
      _lastResumeProfileUuid = profileUuid;
    }

    final completer = Completer<void>();
    final scheduledFuture = completer.future;
    _scheduledSyncs[scheduleKey] = scheduledFuture;

    _syncQueue = _syncQueue.then<void>(
      (_) => _runScheduledSync(
        scope: scope,
        profileUuid: profileUuid,
        scheduleKey: scheduleKey,
        completer: completer,
      ),
    );
    return scheduledFuture;
  }

  Future<void> _runScheduledSync({
    required AppLoadScope scope,
    required String profileUuid,
    required String scheduleKey,
    required Completer<void> completer,
  }) async {
    try {
      if (_isCurrentProfile(profileUuid)) {
        await _execute(scope: scope, profileUuid: profileUuid);
      }
    } catch (_) {
      // El controller conserva sus datos locales y su propio error.
    } finally {
      final scheduled = _scheduledSyncs[scheduleKey];
      if (identical(scheduled, completer.future)) {
        _scheduledSyncs.remove(scheduleKey);
      }
      if (!completer.isCompleted) {
        completer.complete();
      }
    }
  }

  bool _isCurrentProfile(String profileUuid) {
    return !_disposed &&
        _currentProfileController.isAuthenticated &&
        _currentProfileController.profile?.uuidProfile == profileUuid;
  }

  String _scheduleKey(AppLoadScope scope, String profileUuid) {
    return '${scope.name}:$profileUuid';
  }

  Future<void> _execute({
    required AppLoadScope scope,
    required String profileUuid,
  }) async {
    try {
      switch (scope) {
        case AppLoadScope.authenticatedEntry:
        case AppLoadScope.appResume:
          await Future.wait([
            _currentProfileController.syncWithRemote(),
            _companyInfoController.syncWithRemote(),
            _contentItemsController.syncWithRemote(),
            _notificationsInboxController.syncWithRemote(
              uuidProfile: profileUuid,
            ),
            _syncNotificationDevices(
              profileUuid,
              isInitialEntry: scope == AppLoadScope.authenticatedEntry,
            ),
            _userContentStatesController.syncWithRemote(
              uuidProfile: profileUuid,
            ),
            _wellnessDailyLogsController.syncWithRemote(
              uuidProfile: profileUuid,
            ),
            _wellnessProfileStatsController.syncWithRemote(
              uuidProfile: profileUuid,
            ),
            _subscriptionController.syncWithRemote(),
          ]);
        case AppLoadScope.explore:
          await Future.wait([
            _contentItemsController.syncWithRemote(),
            _companyInfoController.syncWithRemote(),
            _userContentStatesController.syncWithRemote(
              uuidProfile: profileUuid,
            ),
            _subscriptionController.syncWithRemote(),
          ]);
        case AppLoadScope.safeSpace:
          await Future.wait([
            _wellnessDailyLogsController.syncWithRemote(
              uuidProfile: profileUuid,
            ),
            _wellnessProfileStatsController.syncWithRemote(
              uuidProfile: profileUuid,
            ),
            _notificationsInboxController.syncWithRemote(
              uuidProfile: profileUuid,
            ),
            _contentItemsController.syncWithRemote(),
            _userContentStatesController.syncWithRemote(
              uuidProfile: profileUuid,
            ),
            _subscriptionController.syncWithRemote(),
          ]);
        case AppLoadScope.profile:
          await Future.wait([
            _currentProfileController.syncWithRemote(),
            _subscriptionController.syncWithRemote(),
          ]);
        case AppLoadScope.adminContent:
          await _contentItemsController.syncWithRemote();
        case AppLoadScope.adminContentForm:
          await Future.wait([
            _contentItemsController.syncWithRemote(),
            _contentMediaController.syncWithRemote(),
          ]);
        case AppLoadScope.adminUsers:
          await _adminProfilesController.syncWithRemote();
        case AppLoadScope.adminCompany:
          await _companyInfoController.syncWithRemote();
        case AppLoadScope.adminNotifications:
          await Future.wait([
            _notificationEventsController.syncWithRemote(),
            _notificationDispatchesController.syncWithRemote(),
            _contentItemsController.syncWithRemote(),
            _wellnessProfileStatsController.syncWithRemote(
              uuidProfile: profileUuid,
            ),
          ]);
          unawaited(_notificationDispatchesController.prefetchAnalytics());
        case AppLoadScope.adminNotificationDispatch:
          await Future.wait([
            _notificationEventsController.syncWithRemote(),
            _notificationDispatchesController.syncWithRemote(),
            _wellnessProfileStatsController.syncWithRemote(
              uuidProfile: profileUuid,
            ),
          ]);
      }
    } catch (_) {
      // La UI conserva el cache local. Cada controller mantiene su propio error.
    }
  }

  Future<void> _syncNotificationDevices(
    String profileUuid, {
    required bool isInitialEntry,
  }) {
    final runtime = _notificationDeviceRuntime;
    if (runtime != null) {
      // activateProfile() ya hace el pull inicial y registra la instalacion.
      if (isInitialEntry) {
        return Future<void>.value();
      }
      return runtime.refreshCurrentProfile();
    }

    return _notificationDevicesController.syncWithRemote(
      uuidProfile: profileUuid,
    );
  }

  Future<void> syncForUserTab(int index) {
    switch (index) {
      case 0:
        return syncWithRemote(scope: AppLoadScope.explore);
      case 1:
        return syncWithRemote(scope: AppLoadScope.safeSpace);
      case 2:
        return syncWithRemote(scope: AppLoadScope.profile);
      default:
        return Future<void>.value();
    }
  }

  Future<void> syncForAdminTab(int index) {
    switch (index) {
      case 0:
        return syncWithRemote(scope: AppLoadScope.adminContent);
      case 1:
        return syncWithRemote(scope: AppLoadScope.adminCompany);
      case 2:
        return syncWithRemote(scope: AppLoadScope.adminUsers);
      case 3:
        return syncWithRemote(scope: AppLoadScope.adminNotifications);
      case 4:
        return syncWithRemote(scope: AppLoadScope.profile);
      default:
        return Future<void>.value();
    }
  }

  void dispose() {
    _disposed = true;
  }
}

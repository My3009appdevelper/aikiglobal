import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../notifications/notification_device_registration.dart';
import '../../notifications/notification_device_runtime.dart';
import '../../notifications/notification_interaction_runtime.dart';
import '../../notifications/notification_message.dart';
import '../../notifications/notification_navigation_controller.dart';
import '../local/app_database.dart';
import '../local/cache/local_media_cache.dart';
import '../local/daos/company_info_dao.dart';
import '../local/daos/content_downloads_dao.dart';
import '../local/daos/content_media_dao.dart';
import '../local/daos/content_items_dao.dart';
import '../local/daos/notification_devices_dao.dart';
import '../local/daos/notification_dispatches_dao.dart';
import '../local/daos/notification_events_dao.dart';
import '../local/daos/notifications_inbox_dao.dart';
import '../local/daos/profiles_dao.dart';
import '../local/daos/user_content_states_dao.dart';
import '../local/daos/wellness_daily_logs_dao.dart';
import '../local/daos/wellness_profile_stats_dao.dart';
import '../remote/services/auth_remote_service.dart';
import '../remote/services/company_info_remote_service.dart';
import '../remote/services/company_info_storage_service.dart';
import '../remote/services/content_media_remote_service.dart';
import '../remote/services/content_media_storage_service.dart';
import '../remote/services/content_items_remote_service.dart';
import '../remote/services/manual_notification_dispatch_remote_service.dart';
import '../remote/services/notification_devices_remote_service.dart';
import '../remote/services/notification_dispatches_remote_service.dart';
import '../remote/services/notification_events_remote_service.dart';
import '../remote/services/notifications_inbox_remote_service.dart';
import '../remote/services/profile_photo_storage_service.dart';
import '../remote/services/profiles_remote_service.dart';
import '../remote/services/subscription_remote_service.dart';
import '../remote/services/user_content_states_remote_service.dart';
import '../remote/services/wellness_daily_logs_remote_service.dart';
import '../remote/services/wellness_profile_stats_remote_service.dart';
import '../remote/supabase_config.dart';
import '../sync/company_info_sync_service.dart';
import '../sync/content_media_sync_service.dart';
import '../sync/content_items_sync_service.dart';
import '../sync/notification_devices_sync_service.dart';
import '../sync/notification_dispatches_sync_service.dart';
import '../sync/notification_events_sync_service.dart';
import '../sync/notifications_inbox_sync_service.dart';
import '../sync/profiles_sync_service.dart';
import '../sync/user_content_states_sync_service.dart';
import '../sync/wellness_daily_logs_sync_service.dart';
import '../sync/wellness_profile_stats_sync_service.dart';
import 'admin_profiles_controller.dart';
import 'app_load_coordinator.dart';
import 'company_info_controller.dart';
import 'content_downloads_controller.dart';
import 'content_media_controller.dart';
import 'content_items_controller.dart';
import 'current_profile_controller.dart';
import 'notification_devices_controller.dart';
import 'notification_dispatches_controller.dart';
import 'notification_events_controller.dart';
import 'notifications_inbox_controller.dart';
import 'user_content_states_controller.dart';
import 'wellness_daily_logs_controller.dart';
import 'wellness_profile_stats_controller.dart';
import 'subscription_controller.dart';

class AppDataContainer {
  AppDataContainer._({
    required this.database,
    required this.profilesDao,
    required this.companyInfoDao,
    required this.contentDownloadsDao,
    required this.contentItemsDao,
    required this.contentMediaDao,
    required this.notificationDevicesDao,
    required this.notificationEventsDao,
    required this.notificationDispatchesDao,
    required this.notificationsInboxDao,
    required this.userContentStatesDao,
    required this.wellnessDailyLogsDao,
    required this.wellnessProfileStatsDao,
    required this.adminProfilesController,
    required this.appLoadCoordinator,
    required this.companyInfoController,
    required this.subscriptionController,
    required this.contentDownloadsController,
    required this.currentProfileController,
    required this.contentItemsController,
    required this.contentMediaController,
    required this.notificationDevicesController,
    required this.notificationEventsController,
    required this.notificationDispatchesController,
    required this.notificationsInboxController,
    this.notificationDeviceRuntime,
    this.notificationInteractionRuntime,
    required this.notificationNavigationController,
    required this.notificationNavigationCoordinator,
    required this.userContentStatesController,
    required this.wellnessDailyLogsController,
    required this.wellnessProfileStatsController,
    this.profilesRemoteService,
    this.companyInfoRemoteService,
    this.companyInfoStorageService,
    this.profilePhotoStorageService,
    this.contentMediaStorageService,
    this.contentItemsRemoteService,
    this.contentMediaRemoteService,
    this.notificationDevicesRemoteService,
    this.notificationEventsRemoteService,
    this.notificationDispatchesRemoteService,
    this.notificationsInboxRemoteService,
    this.userContentStatesRemoteService,
    this.wellnessDailyLogsRemoteService,
    this.wellnessProfileStatsRemoteService,
    this.subscriptionRemoteService,
    this.profilesSyncService,
    this.companyInfoSyncService,
    this.contentItemsSyncService,
    this.contentMediaSyncService,
    this.notificationDevicesSyncService,
    this.notificationEventsSyncService,
    this.notificationDispatchesSyncService,
    this.notificationsInboxSyncService,
    this.userContentStatesSyncService,
    this.wellnessDailyLogsSyncService,
    this.wellnessProfileStatsSyncService,
    this.currentProfileListener,
  });

  final AppDatabase? database;
  final ProfilesDao? profilesDao;
  final CompanyInfoDao? companyInfoDao;
  final ContentDownloadsDao? contentDownloadsDao;
  final ContentItemsDao? contentItemsDao;
  final ContentMediaDao? contentMediaDao;
  final NotificationDevicesDao? notificationDevicesDao;
  final NotificationEventsDao? notificationEventsDao;
  final NotificationDispatchesDao? notificationDispatchesDao;
  final NotificationsInboxDao? notificationsInboxDao;
  final UserContentStatesDao? userContentStatesDao;
  final WellnessDailyLogsDao? wellnessDailyLogsDao;
  final WellnessProfileStatsDao? wellnessProfileStatsDao;
  final ProfilesRemoteService? profilesRemoteService;
  final CompanyInfoRemoteService? companyInfoRemoteService;
  final CompanyInfoStorageService? companyInfoStorageService;
  final ProfilePhotoStorageService? profilePhotoStorageService;
  final ContentMediaStorageService? contentMediaStorageService;
  final ContentItemsRemoteService? contentItemsRemoteService;
  final ContentMediaRemoteService? contentMediaRemoteService;
  final NotificationDevicesRemoteService? notificationDevicesRemoteService;
  final NotificationEventsRemoteService? notificationEventsRemoteService;
  final NotificationDispatchesRemoteService?
  notificationDispatchesRemoteService;
  final NotificationsInboxRemoteService? notificationsInboxRemoteService;
  final UserContentStatesRemoteService? userContentStatesRemoteService;
  final WellnessDailyLogsRemoteService? wellnessDailyLogsRemoteService;
  final WellnessProfileStatsRemoteService? wellnessProfileStatsRemoteService;
  final SubscriptionRemoteService? subscriptionRemoteService;
  final ProfilesSyncService? profilesSyncService;
  final CompanyInfoSyncService? companyInfoSyncService;
  final ContentItemsSyncService? contentItemsSyncService;
  final ContentMediaSyncService? contentMediaSyncService;
  final NotificationDevicesSyncService? notificationDevicesSyncService;
  final NotificationEventsSyncService? notificationEventsSyncService;
  final NotificationDispatchesSyncService? notificationDispatchesSyncService;
  final NotificationsInboxSyncService? notificationsInboxSyncService;
  final UserContentStatesSyncService? userContentStatesSyncService;
  final WellnessDailyLogsSyncService? wellnessDailyLogsSyncService;
  final WellnessProfileStatsSyncService? wellnessProfileStatsSyncService;
  final AdminProfilesController adminProfilesController;
  final AppLoadCoordinator appLoadCoordinator;
  final CompanyInfoController companyInfoController;
  final SubscriptionController subscriptionController;
  final ContentDownloadsController contentDownloadsController;
  final CurrentProfileController currentProfileController;
  final ContentItemsController contentItemsController;
  final ContentMediaController contentMediaController;
  final NotificationDevicesController notificationDevicesController;
  final NotificationEventsController notificationEventsController;
  final NotificationDispatchesController notificationDispatchesController;
  final NotificationsInboxController notificationsInboxController;
  final NotificationDeviceRuntime? notificationDeviceRuntime;
  final NotificationInteractionRuntime? notificationInteractionRuntime;
  final NotificationNavigationController notificationNavigationController;
  final NotificationNavigationCoordinator notificationNavigationCoordinator;
  final UserContentStatesController userContentStatesController;
  final WellnessDailyLogsController wellnessDailyLogsController;
  final WellnessProfileStatsController wellnessProfileStatsController;
  final VoidCallback? currentProfileListener;

  bool get hasRemote =>
      profilesRemoteService != null &&
      contentItemsRemoteService != null &&
      contentMediaRemoteService != null &&
      userContentStatesRemoteService != null &&
      wellnessDailyLogsRemoteService != null &&
      wellnessProfileStatsRemoteService != null;

  static Future<AppDataContainer> create({
    bool resetLocalDatabaseOnStart = false,
    NotificationDeviceRegistrationClient? notificationDeviceRegistrationClient,
    NotificationMessageClient? notificationMessageClient,
  }) async {
    await SupabaseConfig.initializeIfConfigured();

    AppDatabase? database;
    ProfilesDao? profilesDao;
    CompanyInfoDao? companyInfoDao;
    ContentDownloadsDao? contentDownloadsDao;
    ContentItemsDao? contentItemsDao;
    ContentMediaDao? contentMediaDao;
    NotificationDevicesDao? notificationDevicesDao;
    NotificationEventsDao? notificationEventsDao;
    NotificationDispatchesDao? notificationDispatchesDao;
    NotificationsInboxDao? notificationsInboxDao;
    UserContentStatesDao? userContentStatesDao;
    WellnessDailyLogsDao? wellnessDailyLogsDao;
    WellnessProfileStatsDao? wellnessProfileStatsDao;

    if (!kIsWeb) {
      database = AppDatabase(
        resetLocalDatabaseOnOpen: resetLocalDatabaseOnStart,
      );
      profilesDao = ProfilesDao(database);
      companyInfoDao = CompanyInfoDao(database);
      contentDownloadsDao = ContentDownloadsDao(database);
      contentItemsDao = ContentItemsDao(database);
      contentMediaDao = ContentMediaDao(database);
      notificationDevicesDao = NotificationDevicesDao(database);
      notificationEventsDao = NotificationEventsDao(database);
      notificationDispatchesDao = NotificationDispatchesDao(database);
      notificationsInboxDao = NotificationsInboxDao(database);
      userContentStatesDao = UserContentStatesDao(database);
      wellnessDailyLogsDao = WellnessDailyLogsDao(database);
      wellnessProfileStatsDao = WellnessProfileStatsDao(database);
    }

    ProfilesRemoteService? profilesRemoteService;
    CompanyInfoRemoteService? companyInfoRemoteService;
    CompanyInfoStorageService? companyInfoStorageService;
    ProfilePhotoStorageService? profilePhotoStorageService;
    ContentMediaStorageService? contentMediaStorageService;
    ContentItemsRemoteService? contentItemsRemoteService;
    ContentMediaRemoteService? contentMediaRemoteService;
    NotificationDevicesRemoteService? notificationDevicesRemoteService;
    NotificationEventsRemoteService? notificationEventsRemoteService;
    NotificationDispatchesRemoteService? notificationDispatchesRemoteService;
    ManualNotificationDispatchRemoteService?
    manualNotificationDispatchRemoteService;
    NotificationsInboxRemoteService? notificationsInboxRemoteService;
    UserContentStatesRemoteService? userContentStatesRemoteService;
    WellnessDailyLogsRemoteService? wellnessDailyLogsRemoteService;
    WellnessProfileStatsRemoteService? wellnessProfileStatsRemoteService;
    SubscriptionRemoteService? subscriptionRemoteService;
    ProfilesSyncService? profilesSyncService;
    CompanyInfoSyncService? companyInfoSyncService;
    ContentItemsSyncService? contentItemsSyncService;
    ContentMediaSyncService? contentMediaSyncService;
    NotificationDevicesSyncService? notificationDevicesSyncService;
    NotificationEventsSyncService? notificationEventsSyncService;
    NotificationDispatchesSyncService? notificationDispatchesSyncService;
    NotificationsInboxSyncService? notificationsInboxSyncService;
    UserContentStatesSyncService? userContentStatesSyncService;
    WellnessDailyLogsSyncService? wellnessDailyLogsSyncService;
    WellnessProfileStatsSyncService? wellnessProfileStatsSyncService;
    AuthRemoteService? authRemoteService;
    final localMediaCache = kIsWeb ? null : const LocalMediaCache();

    final supabase = SupabaseConfig.clientOrNull;
    if (supabase != null) {
      authRemoteService = AuthRemoteService(supabase: supabase);
      profilesRemoteService = ProfilesRemoteService(supabase: supabase);
      companyInfoRemoteService = CompanyInfoRemoteService(supabase: supabase);
      companyInfoStorageService = CompanyInfoStorageService(supabase: supabase);
      profilePhotoStorageService = ProfilePhotoStorageService(
        supabase: supabase,
      );
      contentMediaStorageService = ContentMediaStorageService(
        supabase: supabase,
      );
      contentItemsRemoteService = ContentItemsRemoteService(supabase: supabase);
      contentMediaRemoteService = ContentMediaRemoteService(supabase: supabase);
      notificationDevicesRemoteService = NotificationDevicesRemoteService(
        supabase: supabase,
      );
      notificationEventsRemoteService = NotificationEventsRemoteService(
        supabase: supabase,
      );
      notificationDispatchesRemoteService = NotificationDispatchesRemoteService(
        supabase: supabase,
      );
      manualNotificationDispatchRemoteService =
          ManualNotificationDispatchRemoteService(supabase: supabase);
      notificationsInboxRemoteService = NotificationsInboxRemoteService(
        supabase: supabase,
      );
      userContentStatesRemoteService = UserContentStatesRemoteService(
        supabase: supabase,
      );
      wellnessDailyLogsRemoteService = WellnessDailyLogsRemoteService(
        supabase: supabase,
      );
      wellnessProfileStatsRemoteService = WellnessProfileStatsRemoteService(
        supabase: supabase,
      );
      subscriptionRemoteService = SubscriptionRemoteService(supabase: supabase);

      if (profilesDao != null) {
        profilesSyncService = ProfilesSyncService(
          dao: profilesDao,
          service: profilesRemoteService,
        );
      }

      if (companyInfoDao != null) {
        companyInfoSyncService = CompanyInfoSyncService(
          dao: companyInfoDao,
          service: companyInfoRemoteService,
        );
      }

      if (contentItemsDao != null) {
        contentItemsSyncService = ContentItemsSyncService(
          dao: contentItemsDao,
          service: contentItemsRemoteService,
        );
      }

      if (contentMediaDao != null) {
        contentMediaSyncService = ContentMediaSyncService(
          dao: contentMediaDao,
          service: contentMediaRemoteService,
        );
      }

      if (notificationDevicesDao != null) {
        notificationDevicesSyncService = NotificationDevicesSyncService(
          dao: notificationDevicesDao,
          service: notificationDevicesRemoteService,
        );
      }

      if (notificationEventsDao != null) {
        notificationEventsSyncService = NotificationEventsSyncService(
          dao: notificationEventsDao,
          service: notificationEventsRemoteService,
        );
      }

      if (notificationDispatchesDao != null) {
        notificationDispatchesSyncService = NotificationDispatchesSyncService(
          dao: notificationDispatchesDao,
          service: notificationDispatchesRemoteService,
        );
      }

      if (notificationsInboxDao != null) {
        notificationsInboxSyncService = NotificationsInboxSyncService(
          dao: notificationsInboxDao,
          service: notificationsInboxRemoteService,
        );
      }

      if (userContentStatesDao != null) {
        userContentStatesSyncService = UserContentStatesSyncService(
          dao: userContentStatesDao,
          service: userContentStatesRemoteService,
        );
      }

      if (wellnessDailyLogsDao != null) {
        wellnessDailyLogsSyncService = WellnessDailyLogsSyncService(
          dao: wellnessDailyLogsDao,
          service: wellnessDailyLogsRemoteService,
        );
      }

      if (wellnessProfileStatsDao != null) {
        wellnessProfileStatsSyncService = WellnessProfileStatsSyncService(
          dao: wellnessProfileStatsDao,
          service: wellnessProfileStatsRemoteService,
        );
      }
    }

    final adminProfilesController = AdminProfilesController(
      profilesDao: profilesDao,
      profilesRemoteService: profilesRemoteService,
      wellnessProfileStatsDao: wellnessProfileStatsDao,
      wellnessProfileStatsRemoteService: wellnessProfileStatsRemoteService,
      profilesSyncService: profilesSyncService,
      subscriptionRemoteService: subscriptionRemoteService,
    );

    final companyInfoController = CompanyInfoController(
      companyInfoDao: companyInfoDao,
      companyInfoRemoteService: companyInfoRemoteService,
      companyInfoStorageService: companyInfoStorageService,
      syncService: companyInfoSyncService,
    );

    final notificationDevicesController = NotificationDevicesController(
      notificationDevicesDao: notificationDevicesDao,
      notificationDevicesRemoteService: notificationDevicesRemoteService,
      syncService: notificationDevicesSyncService,
    );
    final notificationEventsController = NotificationEventsController(
      notificationEventsDao: notificationEventsDao,
      notificationEventsRemoteService: notificationEventsRemoteService,
      syncService: notificationEventsSyncService,
    );
    final notificationDispatchesController = NotificationDispatchesController(
      notificationDispatchesDao: notificationDispatchesDao,
      notificationDispatchesRemoteService: notificationDispatchesRemoteService,
      manualNotificationDispatchRemoteService:
          manualNotificationDispatchRemoteService,
      syncService: notificationDispatchesSyncService,
    );
    final notificationsInboxController = NotificationsInboxController(
      notificationsInboxDao: notificationsInboxDao,
      notificationsInboxRemoteService: notificationsInboxRemoteService,
      syncService: notificationsInboxSyncService,
    );
    final notificationDeviceRuntime =
        notificationDeviceRegistrationClient == null
        ? null
        : NotificationDeviceRuntime(
            devicesController: notificationDevicesController,
            registrationClient: notificationDeviceRegistrationClient,
          );

    final currentProfileController = CurrentProfileController(
      profilesDao: profilesDao,
      remoteService: profilesRemoteService,
      syncService: profilesSyncService,
      authService: authRemoteService,
      profilePhotoStorageService: profilePhotoStorageService,
      localMediaCache: localMediaCache,
      beforeSignOut: () => notificationDevicesController
          .deactivateCurrentInstallation(requireRemoteConfirmation: true),
    );

    final notificationNavigationController = NotificationNavigationController();
    final notificationNavigationCoordinator = NotificationNavigationCoordinator(
      controller: notificationNavigationController,
      activateUserMode: () {
        currentProfileController.setViewMode(AppViewMode.user);
      },
    );
    final notificationInteractionRuntime = notificationMessageClient == null
        ? null
        : NotificationInteractionRuntime(
            messageClient: notificationMessageClient,
            inboxController: notificationsInboxController,
            navigationCoordinator: notificationNavigationCoordinator,
          );

    final contentItemsController = ContentItemsController(
      contentItemsDao: contentItemsDao,
      contentItemsRemoteService: contentItemsRemoteService,
      syncService: contentItemsSyncService,
      contentMediaStorageService: contentMediaStorageService,
      localMediaCache: localMediaCache,
    );

    final contentMediaController = ContentMediaController(
      contentMediaDao: contentMediaDao,
      contentMediaRemoteService: contentMediaRemoteService,
      contentMediaStorageService: contentMediaStorageService,
      syncService: contentMediaSyncService,
      localMediaCache: localMediaCache,
    );

    final subscriptionController = SubscriptionController(
      remoteService: subscriptionRemoteService,
    );

    final contentDownloadsController = ContentDownloadsController(
      contentDownloadsDao: contentDownloadsDao,
      contentMediaController: contentMediaController,
      storageService: contentMediaStorageService,
      localMediaCache: localMediaCache,
      subscriptionController: subscriptionController,
    );

    final userContentStatesController = UserContentStatesController(
      userContentStatesDao: userContentStatesDao,
      userContentStatesRemoteService: userContentStatesRemoteService,
      syncService: userContentStatesSyncService,
    );

    final wellnessProfileStatsController = WellnessProfileStatsController(
      wellnessProfileStatsDao: wellnessProfileStatsDao,
      wellnessProfileStatsRemoteService: wellnessProfileStatsRemoteService,
      syncService: wellnessProfileStatsSyncService,
    );

    final wellnessDailyLogsController = WellnessDailyLogsController(
      wellnessDailyLogsDao: wellnessDailyLogsDao,
      wellnessDailyLogsRemoteService: wellnessDailyLogsRemoteService,
      syncService: wellnessDailyLogsSyncService,
      wellnessProfileStatsController: wellnessProfileStatsController,
    );

    final appLoadCoordinator = AppLoadCoordinator(
      currentProfileController: currentProfileController,
      adminProfilesController: adminProfilesController,
      companyInfoController: companyInfoController,
      contentItemsController: contentItemsController,
      contentMediaController: contentMediaController,
      notificationDevicesController: notificationDevicesController,
      notificationDispatchesController: notificationDispatchesController,
      notificationEventsController: notificationEventsController,
      notificationsInboxController: notificationsInboxController,
      subscriptionController: subscriptionController,
      userContentStatesController: userContentStatesController,
      wellnessDailyLogsController: wellnessDailyLogsController,
      wellnessProfileStatsController: wellnessProfileStatsController,
      notificationDeviceRuntime: notificationDeviceRuntime,
    );

    String? activeStatesProfileUuid;
    void currentProfileListener() {
      final profile = currentProfileController.profile;
      final nextProfileUuid = profile?.uuidProfile;

      if (nextProfileUuid == activeStatesProfileUuid) {
        return;
      }

      activeStatesProfileUuid = nextProfileUuid;

      notificationEventsController.clear();
      notificationDispatchesController.clear();
      notificationsInboxController.clear();

      if (nextProfileUuid == null) {
        notificationDeviceRuntime?.clearProfile();
        notificationInteractionRuntime?.clearProfile();
        notificationNavigationCoordinator.activateProfile(null);
        notificationDevicesController.clear();
        subscriptionController.clear();
        contentDownloadsController.clear();
        userContentStatesController.clear();
        wellnessDailyLogsController.clear();
        wellnessProfileStatsController.clear();
        return;
      }

      notificationDevicesController.watchForProfile(
        nextProfileUuid,
        pullRemote: false,
      );
      unawaited(notificationDeviceRuntime?.activateProfile(nextProfileUuid));
      notificationsInboxController.watchForProfile(
        nextProfileUuid,
        pullRemote: false,
      );
      notificationNavigationCoordinator.activateProfile(nextProfileUuid);
      unawaited(
        notificationInteractionRuntime?.activateProfile(nextProfileUuid),
      );
      userContentStatesController.watchForProfile(
        nextProfileUuid,
        pullRemote: false,
      );
      wellnessDailyLogsController.watchForProfile(
        nextProfileUuid,
        pullRemote: false,
      );
      wellnessProfileStatsController.watchForProfile(
        nextProfileUuid,
        pullRemote: false,
      );
      subscriptionController.watchForProfile(
        nextProfileUuid,
        loadRemote: false,
      );
      contentDownloadsController.watchForProfile(nextProfileUuid);
      unawaited(
        appLoadCoordinator.syncWithRemote(
          scope: AppLoadScope.authenticatedEntry,
        ),
      );
    }

    currentProfileController.addListener(currentProfileListener);
    unawaited(notificationInteractionRuntime?.start());

    await currentProfileController.enforceRememberPreferenceOnStartup();
    await currentProfileController.loadCurrentSession();
    if (currentProfileController.isAuthenticated) {
      await appLoadCoordinator.syncWithRemote(
        scope: AppLoadScope.authenticatedEntry,
      );
      await contentItemsController.loadPublished();
    }
    currentProfileListener();
    currentProfileController.startAuthListener();

    return AppDataContainer._(
      database: database,
      profilesDao: profilesDao,
      companyInfoDao: companyInfoDao,
      contentDownloadsDao: contentDownloadsDao,
      contentItemsDao: contentItemsDao,
      contentMediaDao: contentMediaDao,
      notificationDevicesDao: notificationDevicesDao,
      notificationEventsDao: notificationEventsDao,
      notificationDispatchesDao: notificationDispatchesDao,
      notificationsInboxDao: notificationsInboxDao,
      userContentStatesDao: userContentStatesDao,
      wellnessDailyLogsDao: wellnessDailyLogsDao,
      wellnessProfileStatsDao: wellnessProfileStatsDao,
      adminProfilesController: adminProfilesController,
      companyInfoController: companyInfoController,
      subscriptionController: subscriptionController,
      contentDownloadsController: contentDownloadsController,
      currentProfileController: currentProfileController,
      contentItemsController: contentItemsController,
      contentMediaController: contentMediaController,
      notificationDevicesController: notificationDevicesController,
      notificationEventsController: notificationEventsController,
      notificationDispatchesController: notificationDispatchesController,
      notificationsInboxController: notificationsInboxController,
      notificationDeviceRuntime: notificationDeviceRuntime,
      notificationInteractionRuntime: notificationInteractionRuntime,
      notificationNavigationController: notificationNavigationController,
      notificationNavigationCoordinator: notificationNavigationCoordinator,
      userContentStatesController: userContentStatesController,
      wellnessDailyLogsController: wellnessDailyLogsController,
      wellnessProfileStatsController: wellnessProfileStatsController,
      appLoadCoordinator: appLoadCoordinator,
      profilesRemoteService: profilesRemoteService,
      companyInfoRemoteService: companyInfoRemoteService,
      companyInfoStorageService: companyInfoStorageService,
      profilePhotoStorageService: profilePhotoStorageService,
      contentMediaStorageService: contentMediaStorageService,
      contentItemsRemoteService: contentItemsRemoteService,
      contentMediaRemoteService: contentMediaRemoteService,
      notificationDevicesRemoteService: notificationDevicesRemoteService,
      notificationEventsRemoteService: notificationEventsRemoteService,
      notificationDispatchesRemoteService: notificationDispatchesRemoteService,
      notificationsInboxRemoteService: notificationsInboxRemoteService,
      userContentStatesRemoteService: userContentStatesRemoteService,
      wellnessDailyLogsRemoteService: wellnessDailyLogsRemoteService,
      wellnessProfileStatsRemoteService: wellnessProfileStatsRemoteService,
      subscriptionRemoteService: subscriptionRemoteService,
      profilesSyncService: profilesSyncService,
      companyInfoSyncService: companyInfoSyncService,
      contentItemsSyncService: contentItemsSyncService,
      contentMediaSyncService: contentMediaSyncService,
      notificationDevicesSyncService: notificationDevicesSyncService,
      notificationEventsSyncService: notificationEventsSyncService,
      notificationDispatchesSyncService: notificationDispatchesSyncService,
      notificationsInboxSyncService: notificationsInboxSyncService,
      userContentStatesSyncService: userContentStatesSyncService,
      wellnessDailyLogsSyncService: wellnessDailyLogsSyncService,
      wellnessProfileStatsSyncService: wellnessProfileStatsSyncService,
      currentProfileListener: currentProfileListener,
    );
  }

  Future<void> syncForUserTab(int index) {
    if (currentProfileController.isAdminView) {
      return Future<void>.value();
    }
    return appLoadCoordinator.syncForUserTab(index);
  }

  Future<void> syncForAppResume() {
    return appLoadCoordinator.syncWithRemote(scope: AppLoadScope.appResume);
  }

  Future<void> dispose() async {
    final listener = currentProfileListener;
    if (listener != null) {
      currentProfileController.removeListener(listener);
    }
    appLoadCoordinator.dispose();
    currentProfileController.stopAuthListener();
    await notificationInteractionRuntime?.dispose();
    await notificationDeviceRuntime?.dispose();
    currentProfileController.dispose();
    contentItemsController.dispose();
    contentMediaController.dispose();
    contentDownloadsController.dispose();
    subscriptionController.dispose();
    notificationDevicesController.dispose();
    notificationEventsController.dispose();
    notificationDispatchesController.dispose();
    notificationsInboxController.dispose();
    notificationNavigationCoordinator.dispose();
    notificationNavigationController.dispose();
    userContentStatesController.dispose();
    wellnessDailyLogsController.dispose();
    wellnessProfileStatsController.dispose();
    companyInfoController.dispose();
    adminProfilesController.dispose();
    await database?.close();
  }
}

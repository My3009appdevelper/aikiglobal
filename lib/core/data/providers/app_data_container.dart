import 'package:flutter/foundation.dart';

import '../local/app_database.dart';
import '../local/daos/content_items_dao.dart';
import '../local/daos/profiles_dao.dart';
import '../local/daos/user_content_states_dao.dart';
import '../local/daos/wellness_daily_logs_dao.dart';
import '../local/daos/wellness_profile_stats_dao.dart';
import '../remote/services/auth_remote_service.dart';
import '../remote/services/content_items_remote_service.dart';
import '../remote/services/profile_photo_storage_service.dart';
import '../remote/services/profiles_remote_service.dart';
import '../remote/services/user_content_states_remote_service.dart';
import '../remote/services/wellness_daily_logs_remote_service.dart';
import '../remote/services/wellness_profile_stats_remote_service.dart';
import '../remote/supabase_config.dart';
import '../sync/content_items_sync_service.dart';
import '../sync/profiles_sync_service.dart';
import '../sync/user_content_states_sync_service.dart';
import '../sync/wellness_daily_logs_sync_service.dart';
import '../sync/wellness_profile_stats_sync_service.dart';
import 'content_items_controller.dart';
import 'current_profile_controller.dart';
import 'user_content_states_controller.dart';
import 'wellness_daily_logs_controller.dart';
import 'wellness_profile_stats_controller.dart';

class AppDataContainer {
  AppDataContainer._({
    required this.database,
    required this.profilesDao,
    required this.contentItemsDao,
    required this.userContentStatesDao,
    required this.wellnessDailyLogsDao,
    required this.wellnessProfileStatsDao,
    required this.currentProfileController,
    required this.contentItemsController,
    required this.userContentStatesController,
    required this.wellnessDailyLogsController,
    required this.wellnessProfileStatsController,
    this.profilesRemoteService,
    this.profilePhotoStorageService,
    this.contentItemsRemoteService,
    this.userContentStatesRemoteService,
    this.wellnessDailyLogsRemoteService,
    this.wellnessProfileStatsRemoteService,
    this.profilesSyncService,
    this.contentItemsSyncService,
    this.userContentStatesSyncService,
    this.wellnessDailyLogsSyncService,
    this.wellnessProfileStatsSyncService,
    this.currentProfileListener,
  });

  final AppDatabase? database;
  final ProfilesDao? profilesDao;
  final ContentItemsDao? contentItemsDao;
  final UserContentStatesDao? userContentStatesDao;
  final WellnessDailyLogsDao? wellnessDailyLogsDao;
  final WellnessProfileStatsDao? wellnessProfileStatsDao;
  final ProfilesRemoteService? profilesRemoteService;
  final ProfilePhotoStorageService? profilePhotoStorageService;
  final ContentItemsRemoteService? contentItemsRemoteService;
  final UserContentStatesRemoteService? userContentStatesRemoteService;
  final WellnessDailyLogsRemoteService? wellnessDailyLogsRemoteService;
  final WellnessProfileStatsRemoteService? wellnessProfileStatsRemoteService;
  final ProfilesSyncService? profilesSyncService;
  final ContentItemsSyncService? contentItemsSyncService;
  final UserContentStatesSyncService? userContentStatesSyncService;
  final WellnessDailyLogsSyncService? wellnessDailyLogsSyncService;
  final WellnessProfileStatsSyncService? wellnessProfileStatsSyncService;
  final CurrentProfileController currentProfileController;
  final ContentItemsController contentItemsController;
  final UserContentStatesController userContentStatesController;
  final WellnessDailyLogsController wellnessDailyLogsController;
  final WellnessProfileStatsController wellnessProfileStatsController;
  final VoidCallback? currentProfileListener;

  bool get hasRemote =>
      profilesRemoteService != null &&
      contentItemsRemoteService != null &&
      userContentStatesRemoteService != null &&
      wellnessDailyLogsRemoteService != null &&
      wellnessProfileStatsRemoteService != null;

  static Future<AppDataContainer> create({
    bool resetLocalDatabaseOnStart = false,
  }) async {
    await SupabaseConfig.initializeIfConfigured();

    AppDatabase? database;
    ProfilesDao? profilesDao;
    ContentItemsDao? contentItemsDao;
    UserContentStatesDao? userContentStatesDao;
    WellnessDailyLogsDao? wellnessDailyLogsDao;
    WellnessProfileStatsDao? wellnessProfileStatsDao;

    if (!kIsWeb) {
      database = AppDatabase(
        resetLocalDatabaseOnOpen: resetLocalDatabaseOnStart,
      );
      profilesDao = ProfilesDao(database);
      contentItemsDao = ContentItemsDao(database);
      userContentStatesDao = UserContentStatesDao(database);
      wellnessDailyLogsDao = WellnessDailyLogsDao(database);
      wellnessProfileStatsDao = WellnessProfileStatsDao(database);
    }

    ProfilesRemoteService? profilesRemoteService;
    ProfilePhotoStorageService? profilePhotoStorageService;
    ContentItemsRemoteService? contentItemsRemoteService;
    UserContentStatesRemoteService? userContentStatesRemoteService;
    WellnessDailyLogsRemoteService? wellnessDailyLogsRemoteService;
    WellnessProfileStatsRemoteService? wellnessProfileStatsRemoteService;
    ProfilesSyncService? profilesSyncService;
    ContentItemsSyncService? contentItemsSyncService;
    UserContentStatesSyncService? userContentStatesSyncService;
    WellnessDailyLogsSyncService? wellnessDailyLogsSyncService;
    WellnessProfileStatsSyncService? wellnessProfileStatsSyncService;
    AuthRemoteService? authRemoteService;

    final supabase = SupabaseConfig.clientOrNull;
    if (supabase != null) {
      authRemoteService = AuthRemoteService(supabase: supabase);
      profilesRemoteService = ProfilesRemoteService(supabase: supabase);
      profilePhotoStorageService = ProfilePhotoStorageService(
        supabase: supabase,
      );
      contentItemsRemoteService = ContentItemsRemoteService(supabase: supabase);
      userContentStatesRemoteService = UserContentStatesRemoteService(
        supabase: supabase,
      );
      wellnessDailyLogsRemoteService = WellnessDailyLogsRemoteService(
        supabase: supabase,
      );
      wellnessProfileStatsRemoteService = WellnessProfileStatsRemoteService(
        supabase: supabase,
      );

      if (profilesDao != null) {
        profilesSyncService = ProfilesSyncService(
          dao: profilesDao,
          service: profilesRemoteService,
        );
      }

      if (contentItemsDao != null) {
        contentItemsSyncService = ContentItemsSyncService(
          dao: contentItemsDao,
          service: contentItemsRemoteService,
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

    final currentProfileController = CurrentProfileController(
      profilesDao: profilesDao,
      remoteService: profilesRemoteService,
      syncService: profilesSyncService,
      authService: authRemoteService,
      profilePhotoStorageService: profilePhotoStorageService,
    );

    final contentItemsController = ContentItemsController(
      contentItemsDao: contentItemsDao,
      contentItemsRemoteService: contentItemsRemoteService,
      syncService: contentItemsSyncService,
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

    String? activeStatesProfileUuid;
    void currentProfileListener() {
      final profile = currentProfileController.profile;
      final nextProfileUuid = profile?.uuidProfile;

      if (nextProfileUuid == activeStatesProfileUuid) {
        return;
      }

      activeStatesProfileUuid = nextProfileUuid;

      if (nextProfileUuid == null) {
        userContentStatesController.clear();
        wellnessDailyLogsController.clear();
        wellnessProfileStatsController.clear();
        return;
      }

      userContentStatesController.watchForProfile(nextProfileUuid);
      wellnessDailyLogsController.watchForProfile(nextProfileUuid);
      wellnessProfileStatsController.watchForProfile(nextProfileUuid);
    }

    currentProfileController.addListener(currentProfileListener);

    await currentProfileController.enforceRememberPreferenceOnStartup();
    await currentProfileController.loadCurrentSession();
    if (currentProfileController.isAuthenticated) {
      await contentItemsController.pullFromRemote();
      await contentItemsController.loadPublished();
    }
    currentProfileListener();
    currentProfileController.startAuthListener();

    return AppDataContainer._(
      database: database,
      profilesDao: profilesDao,
      contentItemsDao: contentItemsDao,
      userContentStatesDao: userContentStatesDao,
      wellnessDailyLogsDao: wellnessDailyLogsDao,
      wellnessProfileStatsDao: wellnessProfileStatsDao,
      currentProfileController: currentProfileController,
      contentItemsController: contentItemsController,
      userContentStatesController: userContentStatesController,
      wellnessDailyLogsController: wellnessDailyLogsController,
      wellnessProfileStatsController: wellnessProfileStatsController,
      profilesRemoteService: profilesRemoteService,
      profilePhotoStorageService: profilePhotoStorageService,
      contentItemsRemoteService: contentItemsRemoteService,
      userContentStatesRemoteService: userContentStatesRemoteService,
      wellnessDailyLogsRemoteService: wellnessDailyLogsRemoteService,
      wellnessProfileStatsRemoteService: wellnessProfileStatsRemoteService,
      profilesSyncService: profilesSyncService,
      contentItemsSyncService: contentItemsSyncService,
      userContentStatesSyncService: userContentStatesSyncService,
      wellnessDailyLogsSyncService: wellnessDailyLogsSyncService,
      wellnessProfileStatsSyncService: wellnessProfileStatsSyncService,
      currentProfileListener: currentProfileListener,
    );
  }

  Future<void> dispose() async {
    final listener = currentProfileListener;
    if (listener != null) {
      currentProfileController.removeListener(listener);
    }
    currentProfileController.stopAuthListener();
    currentProfileController.dispose();
    contentItemsController.dispose();
    userContentStatesController.dispose();
    wellnessDailyLogsController.dispose();
    wellnessProfileStatsController.dispose();
    await database?.close();
  }
}

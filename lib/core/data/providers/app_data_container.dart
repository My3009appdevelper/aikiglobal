import 'package:flutter/foundation.dart';

import '../local/app_database.dart';
import '../local/cache/local_media_cache.dart';
import '../local/daos/company_info_dao.dart';
import '../local/daos/content_media_dao.dart';
import '../local/daos/content_items_dao.dart';
import '../local/daos/profiles_dao.dart';
import '../local/daos/user_content_states_dao.dart';
import '../local/daos/wellness_daily_logs_dao.dart';
import '../local/daos/wellness_profile_stats_dao.dart';
import '../remote/services/auth_remote_service.dart';
import '../remote/services/company_info_remote_service.dart';
import '../remote/services/content_media_remote_service.dart';
import '../remote/services/content_media_storage_service.dart';
import '../remote/services/content_items_remote_service.dart';
import '../remote/services/profile_photo_storage_service.dart';
import '../remote/services/profiles_remote_service.dart';
import '../remote/services/user_content_states_remote_service.dart';
import '../remote/services/wellness_daily_logs_remote_service.dart';
import '../remote/services/wellness_profile_stats_remote_service.dart';
import '../remote/supabase_config.dart';
import '../sync/company_info_sync_service.dart';
import '../sync/content_media_sync_service.dart';
import '../sync/content_items_sync_service.dart';
import '../sync/profiles_sync_service.dart';
import '../sync/user_content_states_sync_service.dart';
import '../sync/wellness_daily_logs_sync_service.dart';
import '../sync/wellness_profile_stats_sync_service.dart';
import 'admin_profiles_controller.dart';
import 'company_info_controller.dart';
import 'content_media_controller.dart';
import 'content_items_controller.dart';
import 'current_profile_controller.dart';
import 'user_content_states_controller.dart';
import 'wellness_daily_logs_controller.dart';
import 'wellness_profile_stats_controller.dart';

class AppDataContainer {
  AppDataContainer._({
    required this.database,
    required this.profilesDao,
    required this.companyInfoDao,
    required this.contentItemsDao,
    required this.contentMediaDao,
    required this.userContentStatesDao,
    required this.wellnessDailyLogsDao,
    required this.wellnessProfileStatsDao,
    required this.adminProfilesController,
    required this.companyInfoController,
    required this.currentProfileController,
    required this.contentItemsController,
    required this.contentMediaController,
    required this.userContentStatesController,
    required this.wellnessDailyLogsController,
    required this.wellnessProfileStatsController,
    this.profilesRemoteService,
    this.companyInfoRemoteService,
    this.profilePhotoStorageService,
    this.contentMediaStorageService,
    this.contentItemsRemoteService,
    this.contentMediaRemoteService,
    this.userContentStatesRemoteService,
    this.wellnessDailyLogsRemoteService,
    this.wellnessProfileStatsRemoteService,
    this.profilesSyncService,
    this.companyInfoSyncService,
    this.contentItemsSyncService,
    this.contentMediaSyncService,
    this.userContentStatesSyncService,
    this.wellnessDailyLogsSyncService,
    this.wellnessProfileStatsSyncService,
    this.currentProfileListener,
  });

  final AppDatabase? database;
  final ProfilesDao? profilesDao;
  final CompanyInfoDao? companyInfoDao;
  final ContentItemsDao? contentItemsDao;
  final ContentMediaDao? contentMediaDao;
  final UserContentStatesDao? userContentStatesDao;
  final WellnessDailyLogsDao? wellnessDailyLogsDao;
  final WellnessProfileStatsDao? wellnessProfileStatsDao;
  final ProfilesRemoteService? profilesRemoteService;
  final CompanyInfoRemoteService? companyInfoRemoteService;
  final ProfilePhotoStorageService? profilePhotoStorageService;
  final ContentMediaStorageService? contentMediaStorageService;
  final ContentItemsRemoteService? contentItemsRemoteService;
  final ContentMediaRemoteService? contentMediaRemoteService;
  final UserContentStatesRemoteService? userContentStatesRemoteService;
  final WellnessDailyLogsRemoteService? wellnessDailyLogsRemoteService;
  final WellnessProfileStatsRemoteService? wellnessProfileStatsRemoteService;
  final ProfilesSyncService? profilesSyncService;
  final CompanyInfoSyncService? companyInfoSyncService;
  final ContentItemsSyncService? contentItemsSyncService;
  final ContentMediaSyncService? contentMediaSyncService;
  final UserContentStatesSyncService? userContentStatesSyncService;
  final WellnessDailyLogsSyncService? wellnessDailyLogsSyncService;
  final WellnessProfileStatsSyncService? wellnessProfileStatsSyncService;
  final AdminProfilesController adminProfilesController;
  final CompanyInfoController companyInfoController;
  final CurrentProfileController currentProfileController;
  final ContentItemsController contentItemsController;
  final ContentMediaController contentMediaController;
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
  }) async {
    await SupabaseConfig.initializeIfConfigured();

    AppDatabase? database;
    ProfilesDao? profilesDao;
    CompanyInfoDao? companyInfoDao;
    ContentItemsDao? contentItemsDao;
    ContentMediaDao? contentMediaDao;
    UserContentStatesDao? userContentStatesDao;
    WellnessDailyLogsDao? wellnessDailyLogsDao;
    WellnessProfileStatsDao? wellnessProfileStatsDao;

    if (!kIsWeb) {
      database = AppDatabase(
        resetLocalDatabaseOnOpen: resetLocalDatabaseOnStart,
      );
      profilesDao = ProfilesDao(database);
      companyInfoDao = CompanyInfoDao(database);
      contentItemsDao = ContentItemsDao(database);
      contentMediaDao = ContentMediaDao(database);
      userContentStatesDao = UserContentStatesDao(database);
      wellnessDailyLogsDao = WellnessDailyLogsDao(database);
      wellnessProfileStatsDao = WellnessProfileStatsDao(database);
    }

    ProfilesRemoteService? profilesRemoteService;
    CompanyInfoRemoteService? companyInfoRemoteService;
    ProfilePhotoStorageService? profilePhotoStorageService;
    ContentMediaStorageService? contentMediaStorageService;
    ContentItemsRemoteService? contentItemsRemoteService;
    ContentMediaRemoteService? contentMediaRemoteService;
    UserContentStatesRemoteService? userContentStatesRemoteService;
    WellnessDailyLogsRemoteService? wellnessDailyLogsRemoteService;
    WellnessProfileStatsRemoteService? wellnessProfileStatsRemoteService;
    ProfilesSyncService? profilesSyncService;
    CompanyInfoSyncService? companyInfoSyncService;
    ContentItemsSyncService? contentItemsSyncService;
    ContentMediaSyncService? contentMediaSyncService;
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
      profilePhotoStorageService = ProfilePhotoStorageService(
        supabase: supabase,
      );
      contentMediaStorageService = ContentMediaStorageService(
        supabase: supabase,
      );
      contentItemsRemoteService = ContentItemsRemoteService(supabase: supabase);
      contentMediaRemoteService = ContentMediaRemoteService(supabase: supabase);
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
    );

    final companyInfoController = CompanyInfoController(
      companyInfoDao: companyInfoDao,
      companyInfoRemoteService: companyInfoRemoteService,
      syncService: companyInfoSyncService,
    );

    final currentProfileController = CurrentProfileController(
      profilesDao: profilesDao,
      remoteService: profilesRemoteService,
      syncService: profilesSyncService,
      authService: authRemoteService,
      profilePhotoStorageService: profilePhotoStorageService,
      localMediaCache: localMediaCache,
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
      companyInfoDao: companyInfoDao,
      contentItemsDao: contentItemsDao,
      contentMediaDao: contentMediaDao,
      userContentStatesDao: userContentStatesDao,
      wellnessDailyLogsDao: wellnessDailyLogsDao,
      wellnessProfileStatsDao: wellnessProfileStatsDao,
      adminProfilesController: adminProfilesController,
      companyInfoController: companyInfoController,
      currentProfileController: currentProfileController,
      contentItemsController: contentItemsController,
      contentMediaController: contentMediaController,
      userContentStatesController: userContentStatesController,
      wellnessDailyLogsController: wellnessDailyLogsController,
      wellnessProfileStatsController: wellnessProfileStatsController,
      profilesRemoteService: profilesRemoteService,
      companyInfoRemoteService: companyInfoRemoteService,
      profilePhotoStorageService: profilePhotoStorageService,
      contentMediaStorageService: contentMediaStorageService,
      contentItemsRemoteService: contentItemsRemoteService,
      contentMediaRemoteService: contentMediaRemoteService,
      userContentStatesRemoteService: userContentStatesRemoteService,
      wellnessDailyLogsRemoteService: wellnessDailyLogsRemoteService,
      wellnessProfileStatsRemoteService: wellnessProfileStatsRemoteService,
      profilesSyncService: profilesSyncService,
      companyInfoSyncService: companyInfoSyncService,
      contentItemsSyncService: contentItemsSyncService,
      contentMediaSyncService: contentMediaSyncService,
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
    contentMediaController.dispose();
    userContentStatesController.dispose();
    wellnessDailyLogsController.dispose();
    wellnessProfileStatsController.dispose();
    companyInfoController.dispose();
    adminProfilesController.dispose();
    await database?.close();
  }
}

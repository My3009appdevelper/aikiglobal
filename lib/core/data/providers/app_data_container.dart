import 'package:flutter/foundation.dart';

import '../local/app_database.dart';
import '../local/daos/content_items_dao.dart';
import '../local/daos/profiles_dao.dart';
import '../remote/services/auth_remote_service.dart';
import '../remote/services/content_items_remote_service.dart';
import '../remote/services/profiles_remote_service.dart';
import '../remote/supabase_config.dart';
import '../sync/content_items_sync_service.dart';
import '../sync/profiles_sync_service.dart';
import 'content_items_controller.dart';
import 'current_profile_controller.dart';

class AppDataContainer {
  AppDataContainer._({
    required this.database,
    required this.profilesDao,
    required this.contentItemsDao,
    required this.currentProfileController,
    required this.contentItemsController,
    this.profilesRemoteService,
    this.contentItemsRemoteService,
    this.profilesSyncService,
    this.contentItemsSyncService,
  });

  final AppDatabase? database;
  final ProfilesDao? profilesDao;
  final ContentItemsDao? contentItemsDao;
  final ProfilesRemoteService? profilesRemoteService;
  final ContentItemsRemoteService? contentItemsRemoteService;
  final ProfilesSyncService? profilesSyncService;
  final ContentItemsSyncService? contentItemsSyncService;
  final CurrentProfileController currentProfileController;
  final ContentItemsController contentItemsController;

  bool get hasRemote =>
      profilesRemoteService != null && contentItemsRemoteService != null;

  static Future<AppDataContainer> create() async {
    await SupabaseConfig.initializeIfConfigured();

    AppDatabase? database;
    ProfilesDao? profilesDao;
    ContentItemsDao? contentItemsDao;

    if (!kIsWeb) {
      database = AppDatabase();
      profilesDao = ProfilesDao(database);
      contentItemsDao = ContentItemsDao(database);
    }

    ProfilesRemoteService? profilesRemoteService;
    ContentItemsRemoteService? contentItemsRemoteService;
    ProfilesSyncService? profilesSyncService;
    ContentItemsSyncService? contentItemsSyncService;
    AuthRemoteService? authRemoteService;

    final supabase = SupabaseConfig.clientOrNull;
    if (supabase != null) {
      authRemoteService = AuthRemoteService(supabase: supabase);
      profilesRemoteService = ProfilesRemoteService(supabase: supabase);
      contentItemsRemoteService = ContentItemsRemoteService(supabase: supabase);

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
    }

    final currentProfileController = CurrentProfileController(
      profilesDao: profilesDao,
      remoteService: profilesRemoteService,
      syncService: profilesSyncService,
      authService: authRemoteService,
    );

    final contentItemsController = ContentItemsController(
      contentItemsDao: contentItemsDao,
      contentItemsRemoteService: contentItemsRemoteService,
      syncService: contentItemsSyncService,
    );

    await currentProfileController.enforceRememberPreferenceOnStartup();
    await currentProfileController.loadCurrentSession();
    if (currentProfileController.isAuthenticated) {
      await contentItemsController.pullFromRemote();
      await contentItemsController.loadPublished();
    }
    currentProfileController.startAuthListener();

    return AppDataContainer._(
      database: database,
      profilesDao: profilesDao,
      contentItemsDao: contentItemsDao,
      currentProfileController: currentProfileController,
      contentItemsController: contentItemsController,
      profilesRemoteService: profilesRemoteService,
      contentItemsRemoteService: contentItemsRemoteService,
      profilesSyncService: profilesSyncService,
      contentItemsSyncService: contentItemsSyncService,
    );
  }

  Future<void> dispose() async {
    currentProfileController.stopAuthListener();
    currentProfileController.dispose();
    contentItemsController.dispose();
    await database?.close();
  }
}

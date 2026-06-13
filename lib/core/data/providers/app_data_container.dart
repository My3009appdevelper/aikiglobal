import 'package:flutter/foundation.dart';

import '../local/app_database.dart';
import '../local/daos/content_items_dao.dart';
import '../local/daos/profiles_dao.dart';
import '../local/daos/user_content_states_dao.dart';
import '../remote/services/auth_remote_service.dart';
import '../remote/services/content_items_remote_service.dart';
import '../remote/services/profiles_remote_service.dart';
import '../remote/services/user_content_states_remote_service.dart';
import '../remote/supabase_config.dart';
import '../sync/content_items_sync_service.dart';
import '../sync/profiles_sync_service.dart';
import '../sync/user_content_states_sync_service.dart';
import 'content_items_controller.dart';
import 'current_profile_controller.dart';
import 'user_content_states_controller.dart';

class AppDataContainer {
  AppDataContainer._({
    required this.database,
    required this.profilesDao,
    required this.contentItemsDao,
    required this.userContentStatesDao,
    required this.currentProfileController,
    required this.contentItemsController,
    required this.userContentStatesController,
    this.profilesRemoteService,
    this.contentItemsRemoteService,
    this.userContentStatesRemoteService,
    this.profilesSyncService,
    this.contentItemsSyncService,
    this.userContentStatesSyncService,
    this.currentProfileListener,
  });

  final AppDatabase? database;
  final ProfilesDao? profilesDao;
  final ContentItemsDao? contentItemsDao;
  final UserContentStatesDao? userContentStatesDao;
  final ProfilesRemoteService? profilesRemoteService;
  final ContentItemsRemoteService? contentItemsRemoteService;
  final UserContentStatesRemoteService? userContentStatesRemoteService;
  final ProfilesSyncService? profilesSyncService;
  final ContentItemsSyncService? contentItemsSyncService;
  final UserContentStatesSyncService? userContentStatesSyncService;
  final CurrentProfileController currentProfileController;
  final ContentItemsController contentItemsController;
  final UserContentStatesController userContentStatesController;
  final VoidCallback? currentProfileListener;

  bool get hasRemote =>
      profilesRemoteService != null &&
      contentItemsRemoteService != null &&
      userContentStatesRemoteService != null;

  static Future<AppDataContainer> create({
    bool resetLocalDatabaseOnStart = false,
  }) async {
    await SupabaseConfig.initializeIfConfigured();

    AppDatabase? database;
    ProfilesDao? profilesDao;
    ContentItemsDao? contentItemsDao;
    UserContentStatesDao? userContentStatesDao;

    if (!kIsWeb) {
      database = AppDatabase(
        resetLocalDatabaseOnOpen: resetLocalDatabaseOnStart,
      );
      profilesDao = ProfilesDao(database);
      contentItemsDao = ContentItemsDao(database);
      userContentStatesDao = UserContentStatesDao(database);
    }

    ProfilesRemoteService? profilesRemoteService;
    ContentItemsRemoteService? contentItemsRemoteService;
    UserContentStatesRemoteService? userContentStatesRemoteService;
    ProfilesSyncService? profilesSyncService;
    ContentItemsSyncService? contentItemsSyncService;
    UserContentStatesSyncService? userContentStatesSyncService;
    AuthRemoteService? authRemoteService;

    final supabase = SupabaseConfig.clientOrNull;
    if (supabase != null) {
      authRemoteService = AuthRemoteService(supabase: supabase);
      profilesRemoteService = ProfilesRemoteService(supabase: supabase);
      contentItemsRemoteService = ContentItemsRemoteService(supabase: supabase);
      userContentStatesRemoteService = UserContentStatesRemoteService(
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

    final userContentStatesController = UserContentStatesController(
      userContentStatesDao: userContentStatesDao,
      userContentStatesRemoteService: userContentStatesRemoteService,
      syncService: userContentStatesSyncService,
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
        return;
      }

      userContentStatesController.watchForProfile(nextProfileUuid);
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
      currentProfileController: currentProfileController,
      contentItemsController: contentItemsController,
      userContentStatesController: userContentStatesController,
      profilesRemoteService: profilesRemoteService,
      contentItemsRemoteService: contentItemsRemoteService,
      userContentStatesRemoteService: userContentStatesRemoteService,
      profilesSyncService: profilesSyncService,
      contentItemsSyncService: contentItemsSyncService,
      userContentStatesSyncService: userContentStatesSyncService,
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
    await database?.close();
  }
}

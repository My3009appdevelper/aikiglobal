import 'package:aikiglobal/core/data/local/app_database.dart';
import 'package:aikiglobal/core/data/local/cache/local_media_cache.dart';
import 'package:aikiglobal/core/data/local/daos/content_downloads_dao.dart';
import 'package:aikiglobal/core/data/models/app_subscription.dart';
import 'package:aikiglobal/core/data/providers/content_downloads_controller.dart';
import 'package:aikiglobal/core/data/providers/content_media_controller.dart';
import 'package:aikiglobal/core/data/providers/subscription_controller.dart';
import 'package:aikiglobal/core/data/remote/services/subscription_remote_service.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  test('canDownload requiere un producto que incluya descargas', () async {
    final subscriptionController = SubscriptionController(
      remoteService: _FakeSubscriptionRemoteService(),
    );
    addTearDown(subscriptionController.dispose);
    final downloadsController = _downloadsController(subscriptionController);
    addTearDown(downloadsController.dispose);

    subscriptionController.watchForProfile('profile-1');
    downloadsController.watchForProfile('profile-1');
    await pumpEventQueue();

    expect(downloadsController.canDownload(descargable: true), isTrue);
    expect(downloadsController.canDownload(descargable: false), isFalse);
  });

  test('recupera una descarga que quedó en downloading', () async {
    final database = AppDatabase(executor: NativeDatabase.memory());
    addTearDown(database.close);
    final dao = ContentDownloadsDao(database);
    final now = DateTime.now().toUtc();
    await dao.upsertDownload(
      ContentDownloadsTableCompanion.insert(
        uuidContentDownload: 'download-1',
        uuidProfile: 'profile-1',
        uuidContentItem: 'content-1',
        uuidContentMedia: 'media-1',
        storagePathSupabase: 'content-1/media/media-1/file.mp3',
        status: const Value(ContentDownloadsController.statusDownloading),
        createdAt: Value(now),
        updatedAt: Value(now),
      ),
    );

    final subscriptionController = SubscriptionController();
    final downloadsController = ContentDownloadsController(
      contentDownloadsDao: dao,
      contentMediaController: ContentMediaController(
        contentMediaDao: null,
        contentMediaRemoteService: null,
        contentMediaStorageService: null,
        syncService: null,
      ),
      storageService: null,
      localMediaCache: const LocalMediaCache(),
      subscriptionController: subscriptionController,
    );
    addTearDown(downloadsController.dispose);
    addTearDown(subscriptionController.dispose);

    downloadsController.watchForProfile('profile-1');
    await downloadsController.recoverInterruptedDownloads();

    final recovered = await dao.getByProfileAndMedia('profile-1', 'media-1');
    expect(recovered?.status, ContentDownloadsController.statusFailed);
  });
}

ContentDownloadsController _downloadsController(
  SubscriptionController subscriptionController,
) {
  return ContentDownloadsController(
    contentDownloadsDao: null,
    contentMediaController: ContentMediaController(
      contentMediaDao: null,
      contentMediaRemoteService: null,
      contentMediaStorageService: null,
      syncService: null,
    ),
    storageService: null,
    localMediaCache: const LocalMediaCache(),
    subscriptionController: subscriptionController,
  );
}

class _FakeSubscriptionRemoteService extends SubscriptionRemoteService {
  _FakeSubscriptionRemoteService()
    : super(supabase: SupabaseClient('http://localhost', 'test-anon-key'));

  @override
  Future<List<AppSubscriptionProduct>> getAvailableProductsOnline() async {
    final now = DateTime.now().toUtc();
    return [
      AppSubscriptionProduct(
        uuidSubscriptionProduct: 'product-premium',
        codigo: 'premium',
        nombre: 'Premium',
        descripcion: null,
        incluyeDescargas: true,
        activo: true,
        orden: 1,
        createdAt: now,
        updatedAt: now,
      ),
    ];
  }

  @override
  Future<AppUserSubscription?> getCurrentForProfileOnline(
    String uuidProfile,
  ) async {
    final now = DateTime.now().toUtc();
    return AppUserSubscription(
      uuidUserSubscription: 'subscription-$uuidProfile',
      uuidProfile: uuidProfile,
      uuidSubscriptionProduct: 'product-premium',
      source: 'manual',
      status: 'active',
      startedAt: now,
      currentPeriodStart: now,
      currentPeriodEnd: now.add(const Duration(days: 30)),
      autoRenew: false,
      createdAt: now,
      updatedAt: now,
    );
  }
}

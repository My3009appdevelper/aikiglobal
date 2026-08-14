import 'dart:async';

import 'package:aikiglobal/core/data/models/app_subscription.dart';
import 'package:aikiglobal/core/data/providers/subscription_controller.dart';
import 'package:aikiglobal/core/data/remote/services/subscription_remote_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  test('ignora una respuesta que pertenece a un perfil anterior', () async {
    final oldProfileResult = Completer<AppUserSubscription?>();
    final newProfileResult = Completer<AppUserSubscription?>();
    final service = _FakeSubscriptionRemoteService(
      results: {
        'profile-old': oldProfileResult.future,
        'profile-new': newProfileResult.future,
      },
    );
    final controller = SubscriptionController(remoteService: service);
    addTearDown(controller.dispose);

    controller.watchForProfile('profile-old');
    await Future<void>.delayed(Duration.zero);
    controller.watchForProfile('profile-new');

    newProfileResult.complete(_subscription('profile-new'));
    await pumpEventQueue();
    expect(controller.currentSubscription?.uuidProfile, 'profile-new');

    oldProfileResult.complete(_subscription('profile-old'));
    await pumpEventQueue();
    expect(controller.currentSubscription?.uuidProfile, 'profile-new');
  });

  test('el acceso a descargas depende del producto activo', () async {
    final service = _FakeSubscriptionRemoteService(
      results: {'profile-1': Future.value(_subscription('profile-1'))},
      productIncludesDownloads: false,
    );
    final controller = SubscriptionController(remoteService: service);
    addTearDown(controller.dispose);

    controller.watchForProfile('profile-1');
    await pumpEventQueue();

    expect(controller.hasPremiumAccess, isTrue);
    expect(controller.hasDownloadAccess, isFalse);
  });
}

class _FakeSubscriptionRemoteService extends SubscriptionRemoteService {
  _FakeSubscriptionRemoteService({
    required this.results,
    this.productIncludesDownloads = true,
  }) : super(supabase: SupabaseClient('http://localhost', 'test-anon-key'));

  final Map<String, Future<AppUserSubscription?>> results;
  final bool productIncludesDownloads;

  @override
  Future<List<AppSubscriptionProduct>> getAvailableProductsOnline() {
    return Future.value([_product(productIncludesDownloads)]);
  }

  @override
  Future<AppUserSubscription?> getCurrentForProfileOnline(
    String uuidProfile,
  ) {
    return results[uuidProfile]!;
  }
}

AppSubscriptionProduct _product(bool incluyeDescargas) {
  final now = DateTime.utc(2026, 8, 4);
  return AppSubscriptionProduct(
    uuidSubscriptionProduct: 'product-premium',
    codigo: 'premium',
    nombre: 'Premium',
    descripcion: null,
    incluyeDescargas: incluyeDescargas,
    activo: true,
    orden: 1,
    createdAt: now,
    updatedAt: now,
  );
}

AppUserSubscription _subscription(String uuidProfile) {
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

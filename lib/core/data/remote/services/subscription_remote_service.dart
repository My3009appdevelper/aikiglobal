import 'package:supabase_flutter/supabase_flutter.dart';

import '../supabase_tables.dart';
import '../../models/app_subscription.dart';

class SubscriptionRemoteService {
  SubscriptionRemoteService({required SupabaseClient supabase})
    : _supabase = supabase;

  final SupabaseClient _supabase;

  Future<List<AppSubscriptionProduct>> getAvailableProductsOnline() async {
    final rows = await _supabase
        .from(SupabaseTables.subscriptionProducts)
        .select()
        .eq('activo', true)
        .isFilter('deleted_at', null)
        .order('orden');

    return rows
        .map(
          (row) =>
              AppSubscriptionProduct.fromJson(Map<String, dynamic>.from(row)),
        )
        .toList(growable: false);
  }

  Future<List<AppUserSubscription>> getForProfileOnline(
    String uuidProfile,
  ) async {
    final cleanProfile = uuidProfile.trim();
    if (cleanProfile.isEmpty) {
      return const [];
    }

    final rows = await _supabase
        .from(SupabaseTables.userSubscriptions)
        .select()
        .eq('uuid_profile', cleanProfile)
        .isFilter('deleted_at', null);

    return rows
        .map(
          (row) => AppUserSubscription.fromJson(Map<String, dynamic>.from(row)),
        )
        .toList(growable: false);
  }

  Future<AppUserSubscription?> getCurrentForProfileOnline(
    String uuidProfile,
  ) async {
    final subscriptions = await getForProfileOnline(uuidProfile);
    if (subscriptions.isEmpty) {
      return null;
    }

    final sorted = [...subscriptions]
      ..sort((a, b) {
        if (a.hasPremiumAccess != b.hasPremiumAccess) {
          return a.hasPremiumAccess ? -1 : 1;
        }

        final aDate = a.currentPeriodEnd;
        final bDate = b.currentPeriodEnd;
        if (aDate == null && bDate != null) {
          return -1;
        }
        if (aDate != null && bDate == null) {
          return 1;
        }
        if (aDate != null && bDate != null) {
          final byEnd = bDate.compareTo(aDate);
          if (byEnd != 0) {
            return byEnd;
          }
        }
        return b.updatedAt.compareTo(a.updatedAt);
      });

    return sorted.first;
  }

  Future<List<AppUserSubscription>> getAllSubscriptionsOnline() async {
    final rows = await _supabase
        .from(SupabaseTables.userSubscriptions)
        .select()
        .isFilter('deleted_at', null);

    return rows
        .map(
          (row) => AppUserSubscription.fromJson(Map<String, dynamic>.from(row)),
        )
        .toList(growable: false);
  }

  Future<void> grantManualSubscription({
    required String uuidProfile,
    required String uuidSubscriptionProduct,
    DateTime? currentPeriodEnd,
  }) async {
    final cleanProfile = uuidProfile.trim();
    final cleanProduct = uuidSubscriptionProduct.trim();
    final activeRows = await _supabase
        .from(SupabaseTables.userSubscriptions)
        .select('uuid_user_subscription')
        .eq('uuid_profile', cleanProfile)
        .eq('status', 'active')
        .isFilter('deleted_at', null)
        .limit(1);

    if (activeRows.isNotEmpty) {
      throw StateError('Este usuario ya tiene una suscripción activa.');
    }

    final now = DateTime.now().toUtc();
    await _supabase.from(SupabaseTables.userSubscriptions).insert({
      'uuid_profile': cleanProfile,
      'uuid_subscription_product': cleanProduct,
      'source': 'manual',
      'status': 'active',
      'started_at': now.toIso8601String(),
      'current_period_start': now.toIso8601String(),
      'current_period_end': currentPeriodEnd?.toIso8601String(),
      'auto_renew': false,
    });
  }

  Future<void> revokeSubscription(String uuidUserSubscription) async {
    await _supabase
        .from(SupabaseTables.userSubscriptions)
        .update({
          'status': 'revoked',
          'cancelled_at': DateTime.now().toUtc().toIso8601String(),
          'auto_renew': false,
        })
        .eq('uuid_user_subscription', uuidUserSubscription.trim());
  }
}

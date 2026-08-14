import 'package:flutter/material.dart';

import '../../../core/constants/app_assets.dart';
import '../../../core/data/models/app_subscription.dart';
import '../../../core/data/providers/app_data_scope.dart';
import '../../../core/data/providers/subscription_controller.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/app_hero_image_overlay.dart';
import '../../../shared/widgets/app_primary_button.dart';

class SubscriptionCard extends StatelessWidget {
  const SubscriptionCard({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = AppDataScope.subscription(context);

    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) => _SubscriptionCardContent(controller: controller),
    );
  }
}

class _SubscriptionCardContent extends StatelessWidget {
  const _SubscriptionCardContent({required this.controller});

  final SubscriptionController controller;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final scheme = Theme.of(context).colorScheme;
    final surface = scheme.surface;
    final gold31 = scheme.primary.withValues(alpha: 0.31);
    final subscription = controller.currentSubscription;
    final hasPremium = controller.hasPremiumAccess;
    final product = subscription == null
        ? null
        : _productForSubscription(
            controller,
            subscription.uuidSubscriptionProduct,
          );
    final planName = product?.nombre ?? 'Plan Premium';
    final periodEnd = subscription?.currentPeriodEnd;

    return Container(
      height: 220,
      decoration: BoxDecoration(
        borderRadius: AppRadius.large,
        boxShadow: AppShadows.soft(brightness),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            AppAssets.backgroundArchitecture,
            fit: BoxFit.cover,
            alignment: Alignment.centerRight,
            errorBuilder: (context, error, stackTrace) {
              return DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [surface, gold31]),
                ),
              );
            },
          ),
          const AppHeroImageOverlay(),
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: scheme.primary,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.workspace_premium_outlined,
                        color: scheme.onPrimary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            hasPremium
                                ? 'Suscripción activa'
                                : 'Sin suscripción activa',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(
                                  color: scheme.onSurface,
                                  fontFamily: AppTypography.displayFont,
                                  fontFamilyFallback:
                                      AppTypography.fallbackFonts,
                                ),
                          ),
                          Text(
                            planName,
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(
                                  color: scheme.primary,
                                  fontFamily: AppTypography.displayFont,
                                  fontFamilyFallback:
                                      AppTypography.fallbackFonts,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  hasPremium && periodEnd != null
                      ? 'Vigente hasta ${_formatDate(periodEnd)}'
                      : controller.isLoading
                      ? 'Consultando tu suscripción...'
                      : controller.error != null
                      ? 'No se pudo consultar tu suscripción.'
                      : 'Las descargas offline requieren Premium.',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: scheme.onSurface),
                ),
                const SizedBox(height: 12),
                AppPrimaryButton(
                  label: hasPremium
                      ? 'Premium activo'
                      : 'Disponible próximamente',
                  onPressed: null,
                  expand: false,
                  height: 42,
                  backgroundColor: scheme.primary,
                  foregroundColor: scheme.onPrimary,
                  icon: null,
                  disabledOpacity: hasPremium ? 1 : 0.55,
                  labelStyle: const TextStyle(
                    fontFamily: AppTypography.displayFont,
                    fontFamilyFallback: AppTypography.fallbackFonts,
                    fontWeight: FontWeight.w300,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

AppSubscriptionProduct? _productForSubscription(
  SubscriptionController controller,
  String uuidSubscriptionProduct,
) {
  for (final product in controller.availableProducts) {
    if (product.uuidSubscriptionProduct == uuidSubscriptionProduct) {
      return product;
    }
  }
  return null;
}

String _formatDate(DateTime value) {
  final local = value.toLocal();
  final day = local.day.toString().padLeft(2, '0');
  final month = local.month.toString().padLeft(2, '0');
  return '$day/$month/${local.year}';
}

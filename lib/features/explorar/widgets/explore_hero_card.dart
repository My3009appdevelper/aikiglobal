import 'package:flutter/material.dart';

import '../../../core/constants/app_assets.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/app_cover_image.dart';
import '../../../shared/widgets/app_hero_image_overlay.dart';
import '../../../shared/widgets/app_interactive.dart';
import '../../../shared/widgets/app_primary_button.dart';

class ExploreHeroCard extends StatelessWidget {
  const ExploreHeroCard({
    super.key,
    this.onTap,
    this.title = 'Bienvenido a tu espacio de paz interior',
    this.subtitle = 'Explora, aprende y conecta contigo.',
    this.imagePath,
    this.resolveImageUrl,
  });

  final VoidCallback? onTap;
  final String title;
  final String subtitle;
  final String? imagePath;
  final Future<String?> Function(String imagePath)? resolveImageUrl;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final scheme = Theme.of(context).colorScheme;
    final gold31 = scheme.primary.withValues(alpha: 0.31);

    return AppInteractive(
      tooltip: 'Conocer Aiki',
      borderRadius: AppRadius.extraLarge,
      hoverScale: 1.012,
      onTap: onTap,
      child: Container(
        height: 280,
        decoration: BoxDecoration(
          borderRadius: AppRadius.extraLarge,
          boxShadow: AppShadows.elevated(brightness),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            AppCoverImage(
              imagePath: imagePath,
              fallbackAsset: AppAssets.backgroundArchitecture,
              resolveImageUrl: resolveImageUrl,
              fallback: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [scheme.surface, gold31]),
                ),
              ),
            ),
            const AppHeroImageOverlay(),
            Padding(
              padding: const EdgeInsets.all(22),
              child: Align(
                alignment: Alignment.centerLeft,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 246),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _cleanText(
                          title,
                          'Bienvenido a tu espacio de paz interior',
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.headlineLarge
                            ?.copyWith(
                              color: scheme.onSurface,
                              fontSize: 28,
                              height: 1.08,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _cleanText(
                          subtitle,
                          'Explora, aprende y conecta contigo.',
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: scheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 16),
                      AppPrimaryButton(
                        label: 'Conocer Aiki',
                        onPressed: onTap,
                        expand: false,
                        height: 46,
                        backgroundColor: scheme.primary,
                        foregroundColor: scheme.onPrimary,
                        labelStyle: const TextStyle(
                          fontFamily: AppTypography.displayFont,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _cleanText(String value, String fallback) {
  final clean = value.trim();
  return clean.isEmpty ? fallback : clean;
}

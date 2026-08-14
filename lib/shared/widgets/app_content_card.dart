import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_shadows.dart';
import '../../core/theme/app_typography.dart';
import 'app_cover_image.dart';
import 'app_interactive.dart';
import 'app_logo.dart';

class AppContentCard extends StatelessWidget {
  const AppContentCard({
    super.key,
    required this.imageAsset,
    required this.title,
    required this.subtitle,
    this.imagePath,
    this.resolveImageUrl,
    this.badge,
    this.isNew = false,
    this.favoriteIcon = Icons.bookmark_border_rounded,
    this.progressPercentage,
    this.width = 172,
    this.onTap,
    this.onFavoriteTap,
  });

  final String imageAsset;
  final String? imagePath;
  final Future<String?> Function(String imagePath)? resolveImageUrl;
  final String title;
  final String subtitle;
  final String? badge;
  final bool isNew;
  final IconData favoriteIcon;
  final int? progressPercentage;
  final double width;
  final VoidCallback? onTap;
  final VoidCallback? onFavoriteTap;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final scheme = Theme.of(context).colorScheme;
    final cardColor = scheme.surface;

    return SizedBox(
      width: width,
      child: AppInteractive(
        tooltip: 'Abrir $title',
        borderRadius: AppRadius.medium,
        hoverScale: 1,
        pressedScale: 1,
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: cardColor.withValues(alpha: 0.88),
            borderRadius: AppRadius.medium,
            boxShadow: AppShadows.soft(brightness),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 104,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    AppCoverImage(
                      fallbackAsset: null,
                      imagePath: imagePath,
                      resolveImageUrl: resolveImageUrl,
                      fallback: Container(
                        color: scheme.surface,
                        alignment: Alignment.center,
                        child: AppLogo(
                          width: 96,
                          light: brightness == Brightness.dark,
                        ),
                      ),
                    ),
                    DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            AppColors.black.withValues(alpha: 0.02),
                            AppColors.black.withValues(alpha: 0.16),
                          ],
                        ),
                      ),
                    ),
                    if (badge != null || isNew)
                      Positioned(
                        top: 10,
                        left: 10,
                        child: _Badge(label: isNew ? 'NUEVO' : badge!),
                      ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontFamily: AppTypography.displayFont,
                        fontFamilyFallback: AppTypography.fallbackFonts,
                        color: scheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontFamily: AppTypography.displayFont,
                        color: scheme.onSurface,
                      ),
                    ),
                    if (progressPercentage case final progress?) ...[
                      const SizedBox(height: 10),
                      _ProgressIndicator(progressPercentage: progress),
                    ],
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time_rounded,
                          size: 16,
                          color: scheme.primary,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            subtitle.split(' · ').last,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  fontFamily: AppTypography.displayFont,
                                  color: scheme.onSurface,
                                ),
                          ),
                        ),
                        _FavoriteActionIcon(
                          icon: favoriteIcon,
                          onTap: onFavoriteTap,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProgressIndicator extends StatelessWidget {
  const _ProgressIndicator({required this.progressPercentage});

  final int progressPercentage;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final progress = progressPercentage.clamp(0, 100).toInt();

    return Row(
      children: [
        Expanded(
          child: ClipRRect(
            borderRadius: AppRadius.full,
            child: LinearProgressIndicator(
              value: progress / 100,
              minHeight: 5,
              backgroundColor: scheme.onSurface.withValues(alpha: 0.12),
              valueColor: AlwaysStoppedAnimation<Color>(scheme.primary),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '$progress%',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            fontFamily: AppTypography.displayFont,
            color: scheme.onSurface,
          ),
        ),
      ],
    );
  }
}

class _FavoriteActionIcon extends StatelessWidget {
  const _FavoriteActionIcon({required this.icon, this.onTap});

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final selected = icon == Icons.bookmark_rounded;
    final scheme = Theme.of(context).colorScheme;

    return AppInteractive(
      tooltip: selected ? 'Quitar de favoritos' : 'Guardar en favoritos',
      borderRadius: AppRadius.full,
      hoverScale: 1,
      pressedScale: 1,
      onTap: onTap,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 180),
        transitionBuilder: (child, animation) {
          return FadeTransition(opacity: animation, child: child);
        },
        child: Icon(
          selected ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
          key: ValueKey(selected),
          size: 20,
          color: scheme.primary,
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.88),
        borderRadius: AppRadius.full,
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          fontFamily: AppTypography.displayFont,
          fontFamilyFallback: AppTypography.fallbackFonts,
          color: Theme.of(context).colorScheme.onSurface,
          fontSize: 11,
        ),
      ),
    );
  }
}

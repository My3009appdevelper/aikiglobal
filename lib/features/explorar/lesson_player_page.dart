import 'package:flutter/material.dart';

import '../../core/constants/app_assets.dart';
import '../../core/data/providers/app_data_scope.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../shared/widgets/app_cover_image.dart';
import '../../shared/widgets/app_interactive.dart';
import '../../shared/widgets/app_logo.dart';
import 'models/content_item.dart';

class LessonPlayerPage extends StatelessWidget {
  const LessonPlayerPage({super.key, required this.item});

  final ContentItem item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final titleColor = theme.colorScheme.onSurface;
    final bodyColor = isDark
        ? AppColors.darkTextMuted
        : AppColors.textSecondary;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    _CircleIcon(
                      icon: Icons.arrow_back_rounded,
                      tooltip: 'Regresar',
                      onTap: () => Navigator.of(context).pop(),
                    ),
                    const Spacer(),
                    const AppLogo(width: 132),
                    const Spacer(),
                    const _CircleIcon(
                      icon: Icons.more_horiz_rounded,
                      tooltip: 'Más opciones',
                    ),
                  ],
                ),
              ),
              AspectRatio(
                aspectRatio: 1.05,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    AppCoverImage(
                      fallbackAsset: null,
                      imagePath: item.imagePath,
                      resolveImageUrl: AppDataScope.contentItems(
                        context,
                      ).resolveCoverImageUrl,
                      fallback: Container(
                        color: isDark ? AppColors.darkSurface : AppColors.sandLight,
                        alignment: Alignment.center,
                        child: AppLogo(
                          width: 146,
                          light: isDark,
                        ),
                      ),
                    ),
                    DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            AppColors.transparent,
                            AppColors.black.withValues(
                              alpha: isDark ? 0.65 : 0.35,
                            ),
                          ],
                        ),
                      ),
                    ),
                    Center(
                      child: Container(
                        width: 84,
                        height: 84,
                        decoration: BoxDecoration(
                          color: AppColors.black.withValues(alpha: 0.28),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.play_arrow_rounded,
                          color: AppColors.white,
                          size: 56,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'LECCIÓN 1 DE ${item.lessons ?? 8}',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      item.title,
                      style: Theme.of(
                        context,
                      ).textTheme.displayMedium?.copyWith(color: titleColor),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      item.description ??
                          'Una práctica para revitalizar tu cuerpo y mente. Conecta contigo y eleva tu vitalidad.',
                      style: Theme.of(
                        context,
                      ).textTheme.bodyLarge?.copyWith(color: bodyColor),
                    ),
                    const SizedBox(height: 34),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _PlayerIconButton(
                          Icons.skip_previous_rounded,
                          tooltip: 'Lección anterior',
                        ),
                        _PlayerIconButton(
                          Icons.replay_10_rounded,
                          tooltip: 'Retroceder 10 segundos',
                        ),
                        _LargePlayButton(),
                        _PlayerIconButton(
                          Icons.forward_10_rounded,
                          tooltip: 'Adelantar 10 segundos',
                        ),
                        _PlayerIconButton(
                          Icons.skip_next_rounded,
                          tooltip: 'Siguiente lección',
                        ),
                      ],
                    ),
                    const SizedBox(height: 34),
                    _NextLessonCard(item: item),
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

class _CircleIcon extends StatelessWidget {
  const _CircleIcon({required this.icon, required this.tooltip, this.onTap});

  final IconData icon;
  final String tooltip;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final background = isDark
        ? AppColors.black.withValues(alpha: 0.25)
        : AppColors.sandLight.withValues(alpha: 0.95);
    final iconColor = isDark ? AppColors.white : AppColors.primaryDeep;

    return AppInteractive(
      tooltip: tooltip,
      borderRadius: AppRadius.full,
      hoverScale: 1,
      pressedScale: 1,
      onTap: onTap ?? () {},
      child: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(color: background, shape: BoxShape.circle),
        child: Icon(icon, color: iconColor),
      ),
    );
  }
}

class _PlayerIconButton extends StatelessWidget {
  const _PlayerIconButton(this.icon, {required this.tooltip});

  final IconData icon;
  final String tooltip;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).brightness == Brightness.dark
        ? AppColors.white
        : AppColors.primaryDeep;

    return AppInteractive(
      tooltip: tooltip,
      borderRadius: AppRadius.full,
      hoverScale: 1,
      pressedScale: 1,
      onTap: () {},
      child: SizedBox.square(
        dimension: 46,
        child: Icon(icon, color: color, size: 34),
      ),
    );
  }
}

class _LargePlayButton extends StatelessWidget {
  const _LargePlayButton();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return AppInteractive(
      tooltip: 'Reproducir lección',
      borderRadius: AppRadius.full,
      hoverScale: 1,
      pressedScale: 1,
      onTap: () {},
      child: Container(
        width: 82,
        height: 82,
        decoration: BoxDecoration(
          color: scheme.primary,
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.play_arrow_rounded,
          color: scheme.onPrimary,
          size: 48,
        ),
      ),
    );
  }
}

class _NextLessonCard extends StatelessWidget {
  const _NextLessonCard({required this.item});

  final ContentItem item;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface = isDark
        ? AppColors.darkSurfaceSoft
        : AppColors.white.withValues(alpha: 0.94);
    final stroke = isDark ? AppColors.darkStroke : AppColors.stroke;
    final titleColor = Theme.of(context).colorScheme.onSurface;
    final mutedColor = isDark
        ? AppColors.darkTextMuted
        : AppColors.textSecondary;

    return AppInteractive(
      tooltip: 'Abrir siguiente lección',
      borderRadius: AppRadius.large,
      hoverScale: 1.015,
      onTap: () {},
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: surface,
          borderRadius: AppRadius.large,
          border: Border.all(color: stroke),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: AppRadius.small,
              child: Image.asset(
                AppAssets.backgroundGarden,
                width: 88,
                height: 72,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'SIGUIENTE LECCIÓN',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  Text(
                    'Conecta con la tierra',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(
                      context,
                    ).textTheme.titleLarge?.copyWith(color: titleColor),
                  ),
                  Text(
                    '16 min',
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: mutedColor),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: titleColor),
          ],
        ),
      ),
    );
  }
}


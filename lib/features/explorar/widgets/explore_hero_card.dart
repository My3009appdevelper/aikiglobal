import 'package:flutter/material.dart';

import '../../../core/constants/app_assets.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../shared/widgets/app_interactive.dart';
import '../../../shared/widgets/app_primary_button.dart';

class ExploreHeroCard extends StatelessWidget {
  const ExploreHeroCard({super.key, this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final isDark = brightness == Brightness.dark;
    final titleColor = isDark ? AppColors.white : AppColors.primaryDeep;
    final bodyColor = isDark
        ? AppColors.warmIvory.withValues(alpha: 0.9)
        : AppColors.primary.withValues(alpha: 0.82);

    return AppInteractive(
      tooltip: 'Abrir destacado',
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
            Image.asset(
              AppAssets.backgroundArchitecture,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.sandLight, AppColors.sand],
                    ),
                  ),
                );
              },
            ),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: isDark
                      ? [
                          AppColors.primaryDeep.withValues(alpha: 0.96),
                          AppColors.primaryDeep.withValues(alpha: 0.76),
                          AppColors.primaryDeep.withValues(alpha: 0.2),
                        ]
                      : [
                          AppColors.ivory.withValues(alpha: 0.98),
                          AppColors.ivory.withValues(alpha: 0.72),
                          AppColors.transparent,
                        ],
                ),
              ),
            ),
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
                        'Bienvenido a tu espacio de paz interior',
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.headlineLarge
                            ?.copyWith(
                              color: titleColor,
                              fontSize: 28,
                              height: 1.08,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Explora, aprende y conecta contigo.',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(
                          context,
                        ).textTheme.bodyMedium?.copyWith(color: bodyColor),
                      ),
                      const SizedBox(height: 16),
                      AppPrimaryButton(
                        label: 'Explorar ahora',
                        onPressed: onTap,
                        expand: false,
                        height: 46,
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

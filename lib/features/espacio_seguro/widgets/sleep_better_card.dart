import 'package:flutter/material.dart';

import '../../../core/constants/app_assets.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../shared/widgets/app_secondary_button.dart';

class SleepBetterCard extends StatelessWidget {
  const SleepBetterCard({super.key});

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    return Container(
      height: 210,
      decoration: BoxDecoration(
        borderRadius: AppRadius.large,
        boxShadow: AppShadows.soft(brightness),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            AppAssets.backgroundSafeSpace,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primaryDeep, AppColors.primary],
                  ),
                ),
              );
            },
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.black.withValues(alpha: 0.64),
                  AppColors.black.withValues(alpha: 0.28),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  'Duerme mejor',
                  style: Theme.of(
                    context,
                  ).textTheme.headlineMedium?.copyWith(color: AppColors.white),
                ),
                const SizedBox(height: 8),
                Text(
                  'Rutinas y sonidos para un descanso profundo.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.white.withValues(alpha: 0.86),
                  ),
                ),
                const SizedBox(height: 16),
                AppSecondaryButton(
                  label: 'Explorar',
                  onPressed: () {},
                  icon: Icons.arrow_forward_rounded,
                  expand: false,
                  height: 44,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

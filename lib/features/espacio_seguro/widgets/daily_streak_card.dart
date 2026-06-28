import 'package:flutter/material.dart';

import '../../../core/constants/app_assets.dart';
import '../../../core/data/providers/app_data_scope.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_shadows.dart';

class DailyStreakCard extends StatelessWidget {
  const DailyStreakCard({super.key});

  @override
  Widget build(BuildContext context) {
    final statsController = AppDataScope.wellnessProfileStats(context);
    final brightness = Theme.of(context).brightness;
    final isDark = brightness == Brightness.dark;
    final foreground = AppColors.white;

    return AnimatedBuilder(
      animation: statsController,
      builder: (context, _) {
        return Container(
          constraints: const BoxConstraints(minHeight: 190),
          decoration: BoxDecoration(
            borderRadius: AppRadius.large,
            boxShadow: AppShadows.elevated(brightness),
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(
                AppAssets.evento8,
                fit: BoxFit.cover,
                alignment: Alignment.centerRight,
                errorBuilder: (context, error, stackTrace) {
                  return const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF4F5F35), Color(0xFF25311F)],
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
                    colors: [
                      const Color(
                        0xFF40502B,
                      ).withValues(alpha: isDark ? 0.96 : 0.9),
                      const Color(0xFF40502B).withValues(alpha: 0.78),
                      const Color(0xFF1D2718).withValues(alpha: 0.28),
                    ],
                  ),
                ),
              ),
              _DailyStreakContent(
                foreground: foreground,
                streak: statsController.currentStreak,
              ),
            ],
          ),
        );
      },
    );
  }
}

class _DailyStreakContent extends StatelessWidget {
  const _DailyStreakContent({required this.foreground, required this.streak});

  final Color foreground;
  final int streak;

  @override
  Widget build(BuildContext context) {
    final hasStreak = streak > 0;

    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 20, 26, 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'TU CAMINO, DÍA A DÍA',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: foreground.withValues(alpha: 0.76),
              letterSpacing: 1.6,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            hasStreak ? 'Estás cuidando de ti' : 'No has empezado tu racha',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: foreground,
              fontSize: hasStreak ? 23 : 24,
              height: 1.05,
            ),
          ),
          if (hasStreak) ...[
            const SizedBox(height: 4),
            SizedBox(
              width: double.infinity,
              child: FittedBox(
                alignment: Alignment.centerLeft,
                fit: BoxFit.scaleDown,
                child: Text(
                  _streakLabel(streak),
                  maxLines: 1,
                  style: Theme.of(context).textTheme.displayMedium?.copyWith(
                    color: foreground,
                    height: 1.03,
                  ),
                ),
              ),
            ),
          ],
          const SizedBox(height: 8),
          Text(
            'Pequeños pasos, grandes transformaciones.',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: foreground.withValues(alpha: 0.9),
            ),
          ),
        ],
      ),
    );
  }
}

String _streakLabel(int streak) {
  if (streak == 1) {
    return '1 día seguido';
  }

  return '$streak días seguidos';
}

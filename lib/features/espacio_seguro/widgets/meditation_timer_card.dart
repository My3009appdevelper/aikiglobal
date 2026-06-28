import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../shared/widgets/app_interactive.dart';
import '../../../shared/widgets/app_tertiary_button.dart';
import '../meditation_timer_page.dart';

class MeditationTimerCard extends StatelessWidget {
  const MeditationTimerCard({super.key});

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final surface = brightness == Brightness.dark
        ? AppColors.darkSurface
        : AppColors.white;
    final stroke = brightness == Brightness.dark
        ? AppColors.darkStroke
        : AppColors.stroke;
    return AppInteractive(
      borderRadius: AppRadius.large,
      hoverScale: 1.01,
      pressedScale: 0.98,
      onTap: () => _openTimer(context),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: surface.withValues(alpha: 0.92),
          borderRadius: AppRadius.large,
          border: Border.all(color: stroke),
          boxShadow: AppShadows.soft(brightness),
        ),
        child: Row(
          children: [
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).colorScheme.primary.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.timer_rounded,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Timer de meditación',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            AppTertiaryButton(
              icon: Icons.arrow_forward_rounded,
              onPressed: () => _openTimer(context),
            ),
          ],
        ),
      ),
    );
  }

  void _openTimer(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const MeditationTimerPage()),
    );
  }
}

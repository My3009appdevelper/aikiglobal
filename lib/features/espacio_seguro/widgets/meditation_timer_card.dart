import 'package:flutter/material.dart';

import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/app_interactive.dart';
import '../meditation_timer_page.dart';

class MeditationTimerCard extends StatelessWidget {
  const MeditationTimerCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: FractionallySizedBox(
        widthFactor: 0.75,
        child: _MeditationTimerCardBody(onTap: () => _openTimer(context)),
      ),
    );
  }

  void _openTimer(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const MeditationTimerPage()),
    );
  }
}

class _MeditationTimerCardBody extends StatelessWidget {
  const _MeditationTimerCardBody({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final scheme = Theme.of(context).colorScheme;

    return AppInteractive(
      borderRadius: AppRadius.large,
      hoverScale: 1.01,
      pressedScale: 0.98,
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: scheme.surface,
          borderRadius: AppRadius.large,
          border: Border.all(color: scheme.onSurface.withValues(alpha: 0.14)),
          boxShadow: AppShadows.soft(brightness),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                'Timer de meditación',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: scheme.onSurface,
                  fontFamily: AppTypography.displayFont,
                  fontWeight: FontWeight.w300,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: scheme.primary,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.timer_rounded, color: scheme.onPrimary),
            ),
          ],
        ),
      ),
    );
  }
}

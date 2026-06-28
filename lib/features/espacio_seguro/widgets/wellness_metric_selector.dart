import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../shared/widgets/app_interactive.dart';

class WellnessMetricSelector extends StatelessWidget {
  const WellnessMetricSelector({
    super.key,
    required this.label,
    required this.icon,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final IconData icon;
  final int value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final textColor = Theme.of(context).colorScheme.onSurface;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: textColor,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            for (var level = 1; level <= 5; level++) ...[
              Expanded(
                child: _MetricSegment(
                  level: level,
                  selected: value >= level,
                  onTap: () => onChanged(level),
                ),
              ),
              if (level < 5) const SizedBox(width: 7),
            ],
          ],
        ),
      ],
    );
  }
}

class _MetricSegment extends StatelessWidget {
  const _MetricSegment({
    required this.level,
    required this.selected,
    required this.onTap,
  });

  final int level;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final fill = selected
        ? Theme.of(context).colorScheme.primary
        : brightness == Brightness.dark
        ? AppColors.darkSurface
        : AppColors.sandLight;
    final border = selected
        ? Theme.of(context).colorScheme.primary
        : brightness == Brightness.dark
        ? AppColors.darkStroke
        : AppColors.stroke;
    final foreground = selected
        ? Theme.of(context).colorScheme.onPrimary
        : Theme.of(context).colorScheme.onSurface;

    return AppInteractive(
      borderRadius: AppRadius.full,
      onTap: onTap,
      hoverScale: 1.02,
      pressedScale: 0.94,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        height: 34,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: fill,
          borderRadius: AppRadius.full,
          border: Border.all(color: border),
        ),
        child: Text(
          level.toString(),
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: foreground,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}

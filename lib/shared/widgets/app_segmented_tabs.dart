import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_shadows.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import 'app_interactive.dart';

class AppSegmentedTabs extends StatelessWidget {
  const AppSegmentedTabs({
    super.key,
    required this.labels,
    required this.selectedIndex,
    required this.onChanged,
  });

  final List<String> labels;
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    if (labels.isEmpty) {
      return const SizedBox.shrink();
    }

    final safeIndex = selectedIndex.clamp(0, labels.length - 1);
    final isScrollable = labels.length > 3;
    final tabs = List<Widget>.generate(labels.length, (index) {
      final tab = _AppSegmentedTab(
        label: labels[index],
        selected: index == safeIndex,
        onTap: () => onChanged(index),
      );
      if (isScrollable) {
        return SizedBox(width: 132, child: tab);
      }
      return Expanded(child: tab);
    });

    final tabRow = isScrollable
        ? SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(children: tabs),
          )
        : Row(children: tabs);

    final brightness = Theme.of(context).brightness;
    final scheme = Theme.of(context).colorScheme;
    final stroke = brightness == Brightness.dark
        ? AppColors.darkStroke
        : AppColors.stroke;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: AppRadius.full,
        border: Border.all(color: stroke),
        boxShadow: AppShadows.soft(brightness),
      ),
      child: tabRow,
    );
  }
}

class _AppSegmentedTab extends StatelessWidget {
  const _AppSegmentedTab({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: AppInteractive(
        borderRadius: AppRadius.full,
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            color: selected ? scheme.primary : AppColors.transparent,
            borderRadius: AppRadius.full,
            border: Border.all(
              color: selected
                  ? scheme.primary
                  : scheme.primary.withValues(alpha: 0.08),
            ),
          ),
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: selected ? scheme.onPrimary : scheme.primary,
              fontFamily: AppTypography.displayFont,
              fontFamilyFallback: AppTypography.fallbackFonts,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}

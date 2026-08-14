import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_typography.dart';
import 'app_interactive.dart';

class AppSettingTile extends StatelessWidget {
  const AppSettingTile({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.trailing,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final scheme = Theme.of(context).colorScheme;
    final iconColor = scheme.onPrimary;
    final tileColor = scheme.primary;

    return AppInteractive(
      tooltip: title,
      borderRadius: AppRadius.medium,
      hoverScale: 1.01,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: tileColor,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: scheme.onSurface,
                      fontFamily: AppTypography.displayFont,
                      fontFamilyFallback: AppTypography.fallbackFonts,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: scheme.onSurface,
                      fontFamily: AppTypography.primaryFont,
                      fontFamilyFallback: AppTypography.fallbackFonts,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 18),
            trailing ??
                Icon(
                  Icons.chevron_right_rounded,
                  color: brightness == Brightness.dark
                      ? AppColors.darkTextMuted
                      : AppColors.textSecondary,
                ),
          ],
        ),
      ),
    );
  }
}

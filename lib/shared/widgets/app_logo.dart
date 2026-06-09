import 'package:flutter/material.dart';

import '../../core/constants/app_assets.dart';
import '../../core/theme/app_colors.dart';

class AppLogo extends StatelessWidget {
  const AppLogo({
    super.key,
    this.width = 172,
    this.height,
    this.compact = false,
    this.light = false,
  });

  final double width;
  final double? height;
  final bool compact;
  final bool light;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final asset = compact
        ? AppAssets.logoMark
        : light || isDark
        ? AppAssets.logoCompleteColorWhiteLetters
        : AppAssets.logoCompleteColor;

    return Image.asset(
      asset,
      width: width,
      height: height,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.spa_outlined,
              size: compact ? width : 32,
              color: light || isDark ? AppColors.white : AppColors.primary,
            ),
            if (!compact) ...[
              const SizedBox(width: 8),
              Text(
                'Aiki',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: light || isDark ? AppColors.white : AppColors.primary,
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}

import 'package:flutter/material.dart';

import 'app_colors.dart';

class AppShadows {
  const AppShadows._();

  static List<BoxShadow> soft(Brightness brightness) {
    final color = brightness == Brightness.dark
        ? AppColors.black.withValues(alpha: 0.28)
        : AppColors.primaryDeep.withValues(alpha: 0.08);
    return [
      BoxShadow(color: color, blurRadius: 24, offset: const Offset(0, 12)),
    ];
  }

  static List<BoxShadow> elevated(Brightness brightness) {
    final color = brightness == Brightness.dark
        ? AppColors.black.withValues(alpha: 0.38)
        : AppColors.primaryDeep.withValues(alpha: 0.12);
    return [
      BoxShadow(color: color, blurRadius: 34, offset: const Offset(0, 18)),
    ];
  }
}

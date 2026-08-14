import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import '../core/theme/app_theme_controller.dart';
import 'app_theme_transition.dart';

class AikiThemeHost extends StatelessWidget {
  const AikiThemeHost({
    super.key,
    required this.controller,
    required this.child,
  });

  final AppThemeController controller;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      child: child,
      builder: (context, child) {
        final theme = controller.isDark ? AppTheme.dark : AppTheme.light;

        return AnimatedTheme(
          data: theme,
          duration: appThemeAnimationDuration,
          curve: appThemeAnimationCurve,
          child: child!,
        );
      },
    );
  }
}

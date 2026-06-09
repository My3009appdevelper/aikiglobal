import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_radius.dart';
import 'app_typography.dart';

class AppTheme {
  const AppTheme._();

  static ThemeData get light => _build(
    brightness: Brightness.light,
    scheme: AppColors.lightScheme,
    scaffold: AppColors.ivory,
    card: AppColors.white,
  );

  static ThemeData get dark => _build(
    brightness: Brightness.dark,
    scheme: AppColors.darkScheme,
    scaffold: AppColors.darkBackground,
    card: AppColors.darkSurface,
  );

  static ThemeData _build({
    required Brightness brightness,
    required ColorScheme scheme,
    required Color scaffold,
    required Color card,
  }) {
    final textTheme = AppTypography.textTheme(brightness);

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: scaffold,
      cardColor: card,
      fontFamily: AppTypography.primaryFont,
      fontFamilyFallback: AppTypography.fallbackFonts,
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.transparent,
        elevation: 0,
        centerTitle: false,
        foregroundColor: scheme.onSurface,
        titleTextStyle: textTheme.titleLarge,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: brightness == Brightness.dark
            ? AppColors.darkSurfaceSoft
            : AppColors.white.withValues(alpha: 0.78),
        hintStyle: textTheme.bodyMedium?.copyWith(
          color: brightness == Brightness.dark
              ? AppColors.darkTextMuted.withValues(alpha: 0.72)
              : AppColors.textMuted,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 18,
        ),
        border: OutlineInputBorder(
          borderRadius: AppRadius.full,
          borderSide: BorderSide(
            color: brightness == Brightness.dark
                ? AppColors.darkStroke
                : AppColors.stroke,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.full,
          borderSide: BorderSide(
            color: brightness == Brightness.dark
                ? AppColors.darkStroke
                : AppColors.stroke,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.full,
          borderSide: BorderSide(color: scheme.secondary, width: 1.4),
        ),
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: FadeForwardsPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.windows: FadeForwardsPageTransitionsBuilder(),
          TargetPlatform.linux: FadeForwardsPageTransitionsBuilder(),
        },
      ),
    );
  }
}

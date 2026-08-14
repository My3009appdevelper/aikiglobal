import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_typography.dart';

class AppTheme {
  const AppTheme._();

  static ThemeData get light => _build(
    brightness: Brightness.light,
    scheme: AppColors.lightScheme,
    scaffold: AppColors.ivory,
    card: AppColors.background,
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
    final inputBorderRadius = BorderRadius.circular(20);
    final inputLabelStyle = textTheme.bodyMedium?.copyWith(
      color: scheme.onSurface,
    );

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
        fillColor: scheme.surface,
        labelStyle: inputLabelStyle,
        floatingLabelStyle: inputLabelStyle,
        hintStyle: textTheme.bodyMedium?.copyWith(color: scheme.onSurface),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 18,
        ),
        border: OutlineInputBorder(
          borderRadius: inputBorderRadius,
          borderSide: BorderSide(color: scheme.tertiary),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: inputBorderRadius,
          borderSide: BorderSide(color: scheme.tertiary),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: inputBorderRadius,
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

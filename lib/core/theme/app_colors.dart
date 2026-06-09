import 'package:flutter/material.dart';

class AppColors {
  const AppColors._();

  static const transparent = Color(0x00000000);
  static const white = Color(0xFFFFFFFF);
  static const black = Color(0xFF000000);

  static const primary = Color(0xFF5C332A);
  static const primaryDeep = Color(0xFF532624);
  static const ivory = Color(0xFFFFFAF1);
  static const warmIvory = Color(0xFFF8F0E4);
  static const sand = Color(0xFFEADCC9);
  static const sandLight = Color(0xFFF5ECDF);
  static const textPrimary = primaryDeep;
  static const textSecondary = primary;
  static const textMuted = Color(0xFF9A897D);
  static const stroke = Color(0xFFE3D6C8);
  static const danger = Color(0xFFB64839);

  static const darkBackground = Color(0xFF1F1714);
  static const darkSurface = Color(0xFF2A1D19);
  static const darkSurfaceSoft = Color(0xFF33241F);
  static const darkStroke = Color(0xFF4A332B);
  static const darkText = Color(0xFFF6E9DA);
  static const darkTextMuted = Color(0xFFCDBBAC);

  static const lightScheme = ColorScheme(
    brightness: Brightness.light,
    primary: primary,
    onPrimary: white,
    secondary: primaryDeep,
    onSecondary: white,
    tertiary: primary,
    onTertiary: white,
    error: danger,
    onError: white,
    surface: ivory,
    onSurface: textPrimary,
  );

  static const darkScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: sand,
    onPrimary: primaryDeep,
    secondary: sandLight,
    onSecondary: darkBackground,
    tertiary: sand,
    onTertiary: darkBackground,
    error: danger,
    onError: white,
    surface: darkBackground,
    onSurface: darkText,
  );
}

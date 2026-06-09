import 'package:flutter/material.dart';

import 'app_colors.dart';

class AppTypography {
  const AppTypography._();

  static const primaryFont = 'Poppins';
  static const secondaryFont = 'Poppins';
  static const displayFont = 'BegumSans';
  static const fallbackFonts = <String>['Poppins', 'Arial', 'sans-serif'];

  static TextTheme textTheme(Brightness brightness) {
    final textColor = brightness == Brightness.dark
        ? AppColors.darkText
        : AppColors.textPrimary;
    final mutedColor = brightness == Brightness.dark
        ? AppColors.darkTextMuted
        : AppColors.textSecondary;

    return TextTheme(
      displayLarge: TextStyle(
        fontFamily: displayFont,
        fontFamilyFallback: fallbackFonts,
        fontSize: 48,
        height: 1.08,
        fontWeight: FontWeight.w400,
        color: textColor,
      ),
      displayMedium: TextStyle(
        fontFamily: displayFont,
        fontFamilyFallback: fallbackFonts,
        fontSize: 38,
        height: 1.12,
        fontWeight: FontWeight.w400,
        color: textColor,
      ),
      headlineLarge: TextStyle(
        fontFamily: displayFont,
        fontFamilyFallback: fallbackFonts,
        fontSize: 32,
        height: 1.15,
        fontWeight: FontWeight.w500,
        color: textColor,
      ),
      headlineMedium: TextStyle(
        fontFamily: displayFont,
        fontFamilyFallback: fallbackFonts,
        fontSize: 26,
        height: 1.18,
        fontWeight: FontWeight.w500,
        color: textColor,
      ),
      titleLarge: TextStyle(
        fontFamily: secondaryFont,
        fontFamilyFallback: fallbackFonts,
        fontSize: 22,
        height: 1.25,
        fontWeight: FontWeight.w600,
        color: textColor,
      ),
      titleMedium: TextStyle(
        fontFamily: secondaryFont,
        fontFamilyFallback: fallbackFonts,
        fontSize: 17,
        height: 1.3,
        fontWeight: FontWeight.w600,
        color: textColor,
      ),
      bodyLarge: TextStyle(
        fontFamily: primaryFont,
        fontFamilyFallback: fallbackFonts,
        fontSize: 16,
        height: 1.55,
        fontWeight: FontWeight.w400,
        color: mutedColor,
      ),
      bodyMedium: TextStyle(
        fontFamily: primaryFont,
        fontFamilyFallback: fallbackFonts,
        fontSize: 14,
        height: 1.45,
        fontWeight: FontWeight.w400,
        color: mutedColor,
      ),
      bodySmall: TextStyle(
        fontFamily: primaryFont,
        fontFamilyFallback: fallbackFonts,
        fontSize: 12,
        height: 1.35,
        fontWeight: FontWeight.w400,
        color: mutedColor,
      ),
      labelLarge: TextStyle(
        fontFamily: primaryFont,
        fontFamilyFallback: fallbackFonts,
        fontSize: 16,
        height: 1.2,
        fontWeight: FontWeight.w600,
        color: textColor,
      ),
      labelMedium: TextStyle(
        fontFamily: primaryFont,
        fontFamilyFallback: fallbackFonts,
        fontSize: 13,
        height: 1.2,
        fontWeight: FontWeight.w600,
        color: textColor,
      ),
    );
  }
}

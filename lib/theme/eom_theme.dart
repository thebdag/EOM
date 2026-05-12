import 'package:flutter/material.dart';
import 'eom_colors.dart';

/// EOM Material 3 theme — dark mode default, zero shadows, soft corners.
class EomTheme {
  EomTheme._();

  static ThemeData get dark {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: EomColors.background,
      colorScheme: const ColorScheme.dark(
        surface: EomColors.surface,
        primary: EomColors.accent,
        secondary: EomColors.sage,
        error: EomColors.error,
        onSurface: EomColors.textPrimary,
        onPrimary: EomColors.background,
        onSecondary: EomColors.background,
      ),
      cardTheme: CardThemeData(
        color: EomColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: EomColors.surfaceBorder, width: 0.5),
        ),
        margin: EdgeInsets.zero,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: EomColors.background,
        foregroundColor: EomColors.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: EomColors.textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w500,
          letterSpacing: -0.3,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: false,
        border: InputBorder.none,
        enabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
        hintStyle: TextStyle(
          color: EomColors.textTertiary,
          fontSize: 16,
          fontWeight: FontWeight.w400,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          color: EomColors.textPrimary,
          fontSize: 28,
          fontWeight: FontWeight.w500,
          letterSpacing: -0.5,
        ),
        headlineMedium: TextStyle(
          color: EomColors.textPrimary,
          fontSize: 22,
          fontWeight: FontWeight.w500,
          letterSpacing: -0.3,
        ),
        titleMedium: TextStyle(
          color: EomColors.textPrimary,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        bodyLarge: TextStyle(
          color: EomColors.textPrimary,
          fontSize: 16,
          fontWeight: FontWeight.w400,
          height: 1.6,
        ),
        bodyMedium: TextStyle(
          color: EomColors.textSecondary,
          fontSize: 14,
          fontWeight: FontWeight.w400,
          height: 1.5,
        ),
        labelMedium: TextStyle(
          color: EomColors.textSecondary,
          fontSize: 13,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.3,
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: EomColors.divider,
        thickness: 0.5,
        space: 0,
      ),
      splashFactory: InkSparkle.splashFactory,
    );
  }
}

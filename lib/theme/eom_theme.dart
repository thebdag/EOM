import 'package:flutter/material.dart';
import 'eom_colors.dart';
import 'eom_shapes.dart';

/// Bundled orientation display face (Cormorant Garamond). Body stays system sans.
const String eomDisplaySerif = 'CormorantGaramond';

/// Vault-room spacing — ceremonial empty vs mid-session breath.
class EomSpacing {
  EomSpacing._();

  static const double xs = 8;
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;

  /// Top-bar / field horizontal inset (between [sm] and [lg]).
  static const double bar = 20;
}

/// EOM Material 3 theme — dark vault, zero shadows, orientation serif.
class EomTheme {
  EomTheme._();

  static TextStyle _orientation({
    required double fontSize,
    FontWeight fontWeight = FontWeight.w500,
    double letterSpacing = -0.3,
    Color color = EomColors.textPrimary,
  }) {
    return TextStyle(
      fontFamily: eomDisplaySerif,
      color: color,
      fontSize: fontSize,
      fontWeight: fontWeight,
      letterSpacing: letterSpacing,
    );
  }

  /// Section orientation labels — "Your map", "Connections", "Guide".
  static TextStyle orientationLabel({double fontSize = 13}) {
    return _orientation(
      fontSize: fontSize,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.2,
      color: EomColors.textTertiary,
    );
  }

  /// Brand / sheet titles (serif). Not for CTAs or dense chrome.
  static TextStyle displayTitle({
    double fontSize = 22,
    double letterSpacing = 0.8,
  }) {
    return _orientation(fontSize: fontSize, letterSpacing: letterSpacing);
  }

  /// Orientation actions — gold CTAs stay sans (spec: never serif chrome).
  static TextStyle orientationCta({double fontSize = 16}) {
    return TextStyle(
      fontSize: fontSize,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.2,
    );
  }

  static ThemeData get dark {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      fontFamily: null, // body/labels: platform sans
      scaffoldBackgroundColor: EomColors.background,
      colorScheme: const ColorScheme.dark(
        surface: EomColors.surface,
        primary: EomColors.accent,
        secondary: EomColors.sage,
        tertiary: EomColors.gold,
        error: EomColors.error,
        onSurface: EomColors.textPrimary,
        onPrimary: EomColors.background,
        onSecondary: EomColors.background,
        onTertiary: EomColors.background,
      ),
      cardTheme: CardThemeData(
        color: EomColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(EomShapes.radiusMd),
          side: const BorderSide(color: EomColors.surfaceBorder, width: 0.5),
        ),
        margin: EdgeInsets.zero,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: EomColors.background,
        foregroundColor: EomColors.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: _orientation(fontSize: 20, letterSpacing: -0.2),
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
          horizontal: EomSpacing.bar,
          vertical: EomSpacing.md,
        ),
      ),
      textTheme: TextTheme(
        headlineLarge: _orientation(fontSize: 28, letterSpacing: -0.5),
        headlineMedium: _orientation(fontSize: 22),
        headlineSmall: _orientation(fontSize: 18, letterSpacing: -0.2),
        titleLarge: const TextStyle(
          color: EomColors.textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w500,
          letterSpacing: -0.2,
        ),
        titleMedium: const TextStyle(
          color: EomColors.textPrimary,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        bodyLarge: const TextStyle(
          color: EomColors.textPrimary,
          fontSize: 16,
          fontWeight: FontWeight.w400,
          height: 1.6,
        ),
        bodyMedium: const TextStyle(
          color: EomColors.textSecondary,
          fontSize: 14,
          fontWeight: FontWeight.w400,
          height: 1.5,
        ),
        labelMedium: const TextStyle(
          color: EomColors.textSecondary,
          fontSize: 13,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.3,
        ),
        labelSmall: const TextStyle(
          color: EomColors.textSecondary,
          fontSize: 13,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.2,
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

import 'package:flutter/material.dart';

/// EOM color palette — "Epistemic Calm" dark mode vault aesthetic.
class EomColors {
  EomColors._();

  // Backgrounds
  static const Color background = Color(0xFF1A1C23);
  static const Color surface = Color(0xFF242731);
  static const Color surfaceBorder = Color(0xFF3A3E4A);

  // Primary accent — muted indigo
  static const Color accent = Color(0xFF6366F1);
  static const Color accentMuted = Color(0xFF4F46E5);
  static const Color accentSubtle = Color(0x336366F1); // 20% opacity

  // Secondary accent — sage green (for "Act" intent)
  static const Color sage = Color(0xFF6EE7B7);
  static const Color sageMuted = Color(0xFF34D399);
  static const Color sageSubtle = Color(0x336EE7B7);

  // Text
  static const Color textPrimary = Color(0xFFE2E8F0);
  static const Color textSecondary = Color(0xFF94A3B8);
  static const Color textTertiary = Color(0xFF64748B);

  // Intent button backgrounds (idle)
  static const Color intentIdle = Color(0xFF2A2D38);
  static const Color intentHover = Color(0xFF323642);

  // Utility
  static const Color divider = Color(0xFF2E3240);
  static const Color error = Color(0xFFF87171);
  static const Color transparent = Colors.transparent;
}

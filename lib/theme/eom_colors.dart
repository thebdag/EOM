import 'package:flutter/material.dart';

/// EOM color palette — "Epistemic Calm" dark vault (Family kinship).
///
/// Roles: [gold] = brand/orientation only; [accent] = calm selection;
/// [sage] = Act / high-confidence cues. Near-black [background]; surfaces lift.
class EomColors {
  EomColors._();

  // Backgrounds — deeper void; surfaces lift for readable cards
  static const Color background = Color(0xFF0E0F12);
  static const Color surface = Color(0xFF1A1D26);
  static const Color surfaceBorder = Color(0xFF3A3E4A);

  // Primary accent — muted indigo (calm selection)
  static const Color accent = Color(0xFF6366F1);
  static const Color accentMuted = Color(0xFF4F46E5);
  static const Color accentSubtle = Color(0x336366F1); // 20% opacity

  // Secondary accent — sage green (for "Act" intent)
  static const Color sage = Color(0xFF6EE7B7);
  static const Color sageMuted = Color(0xFF34D399);
  static const Color sageSubtle = Color(0x336EE7B7);

  // Orientation accent — muted bronze/gold (rare; never jewelry on every tap)
  static const Color gold = Color(0xFFC4A574);
  static const Color goldMuted = Color(0xFFA68B4B);
  static const Color goldSubtle = Color(0x33C4A574); // 20% opacity

  // Text — tertiary ≥ ~4.5:1 on background (F12)
  static const Color textPrimary = Color(0xFFE2E8F0);
  static const Color textSecondary = Color(0xFF94A3B8);
  static const Color textTertiary = Color(0xFF8B95A8);

  // Intent button backgrounds (idle)
  static const Color intentIdle = Color(0xFF22252F);
  static const Color intentHover = Color(0xFF2A2E3A);

  // Utility
  static const Color divider = Color(0xFF262A35);
  static const Color error = Color(0xFFF87171);
  static const Color transparent = Colors.transparent;
}

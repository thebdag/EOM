import 'package:flutter/widgets.dart';

/// Signature shape helpers — leaf radius only at ceremonial moments
/// (empty panel / optional response card), not a global card system.
/// Cubic leaf clips stay off the input field (saveLayer cost).
class EomShapes {
  EomShapes._();

  /// Tight chrome radius (disclosure rows).
  static const double radiusSm = 8;

  /// Soft ordinary radius (matches theme cards and shared fields).
  static const double radiusMd = 12;

  /// Asymmetric leaf-ish corner radii for a quiet organic frame.
  /// Top-leading and bottom-trailing are tighter; the other pair opens.
  static BorderRadius get leafRadius => const BorderRadius.only(
    topLeft: Radius.circular(28),
    topRight: Radius.circular(10),
    bottomLeft: Radius.circular(10),
    bottomRight: Radius.circular(28),
  );
}

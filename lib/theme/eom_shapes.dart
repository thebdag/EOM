import 'package:flutter/widgets.dart';

/// Signature shape helpers — leaf only at ceremonial moments (empty panel /
/// optional response card), not a global card system.
class EomShapes {
  EomShapes._();

  /// Soft ordinary radius (matches theme cards).
  static const double radiusMd = 12;

  /// Asymmetric leaf-ish corner radii for a quiet organic frame.
  /// Top-leading and bottom-trailing are tighter; the other pair opens.
  static BorderRadius get leafRadius => const BorderRadius.only(
    topLeft: Radius.circular(28),
    topRight: Radius.circular(10),
    bottomLeft: Radius.circular(10),
    bottomRight: Radius.circular(28),
  );

  /// Organic leaf silhouette in [rect] (tip toward bottom-right).
  /// Use with [ClipPath] / [CustomClipper] for signature empty-state panels.
  static Path leaf(Rect rect) {
    final path = Path();
    final w = rect.width;
    final h = rect.height;
    final o = rect.topLeft;

    // Stem notch at top-left → swell to tip at bottom-right.
    path.moveTo(o.dx + w * 0.08, o.dy + h * 0.12);
    path.cubicTo(
      o.dx + w * 0.35,
      o.dy - h * 0.02,
      o.dx + w * 0.78,
      o.dy + h * 0.18,
      o.dx + w * 0.92,
      o.dy + h * 0.48,
    );
    path.cubicTo(
      o.dx + w * 1.02,
      o.dy + h * 0.72,
      o.dx + w * 0.72,
      o.dy + h * 1.02,
      o.dx + w * 0.42,
      o.dy + h * 0.92,
    );
    path.cubicTo(
      o.dx + w * 0.12,
      o.dy + h * 0.82,
      o.dx - w * 0.02,
      o.dy + h * 0.42,
      o.dx + w * 0.08,
      o.dy + h * 0.12,
    );
    path.close();
    return path;
  }
}

/// Clips a child to [EomShapes.leaf].
class EomLeafClipper extends CustomClipper<Path> {
  const EomLeafClipper();

  @override
  Path getClip(Size size) => EomShapes.leaf(Offset.zero & size);

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

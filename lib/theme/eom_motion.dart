import 'package:flutter/material.dart';

/// Material 3 standard/utility motion — Epistemic Calm cap.
///
/// Durations stay ≤300ms. [curve] is `Curves.easeOut` (M3 emphasized
/// `cubic-bezier(0.2, 0, 0, 1)` analogue). No springs, no bounce.
class EomMotion {
  EomMotion._();

  /// Intent select / small chrome.
  static const Duration short = Duration(milliseconds: 200);

  /// Enter, layout, page push.
  static const Duration medium = Duration(milliseconds: 300);

  /// Hide / reverse.
  static const Duration exit = Duration(milliseconds: 200);

  static const Curve curve = Curves.easeOut;

  /// Quiet upward enter, matching [ResponseCard].
  static const Offset slide = Offset(0, 0.05);

  static bool disableAnimationsOf(BuildContext context) =>
      MediaQuery.disableAnimationsOf(context);

  static Duration of(BuildContext context, Duration duration) =>
      disableAnimationsOf(context) ? Duration.zero : duration;

  /// Soft-gate / modal sheet enter–exit (M3 [AnimationStyle]).
  static AnimationStyle get sheetStyle => const AnimationStyle(
    duration: medium,
    curve: curve,
    reverseDuration: exit,
    reverseCurve: curve,
  );
}

/// Fade + tiny upward slide. Used on Android/desktop; iOS keeps Cupertino
/// so interactive pop stays.
class EomFadePageTransitionsBuilder extends PageTransitionsBuilder {
  const EomFadePageTransitionsBuilder();

  @override
  Duration get transitionDuration => EomMotion.medium;

  @override
  Duration get reverseTransitionDuration => EomMotion.exit;

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    if (EomMotion.disableAnimationsOf(context)) return child;
    final curved = CurvedAnimation(
      parent: animation,
      curve: EomMotion.curve,
      reverseCurve: EomMotion.curve,
    );
    return FadeTransition(
      opacity: curved,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: EomMotion.slide,
          end: Offset.zero,
        ).animate(curved),
        child: child,
      ),
    );
  }
}

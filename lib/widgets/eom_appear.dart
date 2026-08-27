import 'package:flutter/material.dart';
import '../theme/eom_motion.dart';

/// Fade appear. Mounts [child] only while [visible] is true.
///
/// Hide is a snap-unmount (zero-height placeholder, child gone) so
/// `find.byType` stays honest. Enter fades. Never [AnimatedCrossFade].
/// Layout is immediate so the first frame is hittable (no [AnimatedSize]
/// clip). [FadeTransition] still hit-tests at opacity 0.
class EomAppear extends StatefulWidget {
  const EomAppear({
    super.key,
    required this.visible,
    required this.child,
    this.expandWidth = true,
    this.alignment = Alignment.topCenter,
  });

  final bool visible;
  final Widget child;

  /// When true, the collapsed placeholder is full-width (column items).
  final bool expandWidth;

  /// Kept for call-site stability; layout is not size-animated.
  final Alignment alignment;

  @override
  State<EomAppear> createState() => _EomAppearState();
}

class _EomAppearState extends State<EomAppear>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  bool _started = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: EomMotion.medium);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncDuration();
    if (!_started) {
      _started = true;
      if (widget.visible) {
        if (EomMotion.disableAnimationsOf(context)) {
          _controller.value = 1;
        } else {
          _controller.forward();
        }
      }
    }
  }

  @override
  void didUpdateWidget(EomAppear oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncDuration();
    if (widget.visible && !oldWidget.visible) {
      if (EomMotion.disableAnimationsOf(context)) {
        _controller.value = 1;
      } else {
        _controller.forward(from: 0);
      }
    } else if (!widget.visible) {
      // Snap-unmount this frame. Do not reverse() — hide is not an ease.
      _controller.value = 0;
    }
  }

  void _syncDuration() {
    _controller.duration = EomMotion.of(context, EomMotion.medium);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.visible) {
      return SizedBox(
        width: widget.expandWidth ? double.infinity : 0,
        height: 0,
      );
    }
    final reduced = EomMotion.disableAnimationsOf(context);
    final fade = reduced
        ? const AlwaysStoppedAnimation<double>(1)
        : Tween<double>(begin: 0, end: 1).animate(
            CurvedAnimation(parent: _controller, curve: EomMotion.curve),
          );
    return FadeTransition(opacity: fade, child: widget.child);
  }
}

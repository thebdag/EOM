import 'package:flutter/material.dart';
import '../theme/eom_motion.dart';

/// Size+fade appear. Mounts [child] only while [visible] is true.
///
/// Never uses [AnimatedCrossFade] — both children would stay in the tree
/// and break `find.byType` (EOM-S24 learning).
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
    final reduced = EomMotion.disableAnimationsOf(context);
    return AnimatedSize(
      duration: reduced ? Duration.zero : EomMotion.medium,
      curve: EomMotion.curve,
      alignment: widget.alignment,
      child: widget.visible
          ? FadeTransition(
              opacity: reduced
                  ? const AlwaysStoppedAnimation<double>(1)
                  : CurvedAnimation(
                      parent: _controller,
                      curve: EomMotion.curve,
                    ),
              child: widget.child,
            )
          : SizedBox(
              width: widget.expandWidth ? double.infinity : 0,
              height: 0,
            ),
    );
  }
}

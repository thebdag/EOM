import 'package:flutter/material.dart';
import '../theme/eom_colors.dart';
import '../theme/eom_motion.dart';
import '../theme/eom_shapes.dart';
import '../theme/eom_theme.dart';

/// Animated text response — fades in with 300ms easing per design spec.
class ResponseCard extends StatefulWidget {
  const ResponseCard({
    super.key,
    required this.text,
    required this.accentColor,
    this.isError = false,
    this.onOpenSettings,
  });

  final String text;
  final Color accentColor;

  /// Soft error styling + optional recovery action (EOM-S18).
  final bool isError;

  /// When non-null, shows a calm "Open Settings" text button under the copy.
  final VoidCallback? onOpenSettings;

  @override
  State<ResponseCard> createState() => _ResponseCardState();
}

class _ResponseCardState extends State<ResponseCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeIn;
  late final Animation<Offset> _slideUp;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: EomMotion.medium, vsync: this);
    _fadeIn = CurvedAnimation(parent: _controller, curve: EomMotion.curve);
    _slideUp = Tween<Offset>(
      begin: EomMotion.slide,
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: EomMotion.curve));
    _controller.forward();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reduced = EomMotion.disableAnimationsOf(context);
    _controller.duration = reduced ? Duration.zero : EomMotion.medium;
    if (reduced) _controller.value = 1;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accent = widget.isError ? EomColors.error : widget.accentColor;

    return FadeTransition(
      opacity: _fadeIn,
      child: SlideTransition(
        position: _slideUp,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(EomSpacing.lg),
          decoration: BoxDecoration(
            color: EomColors.surface,
            borderRadius: widget.isError
                ? BorderRadius.circular(EomShapes.radiusMd)
                : EomShapes.leafRadius,
            border: Border.all(color: EomColors.surfaceBorder, width: 0.5),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 24,
                height: 3,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: EomSpacing.md),
              _buildRichText(widget.text),
              if (widget.onOpenSettings != null) ...[
                const SizedBox(height: EomSpacing.md),
                TextButton(
                  onPressed: widget.onOpenSettings,
                  style: TextButton.styleFrom(
                    foregroundColor: EomColors.accent,
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text(
                    'Open Settings',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRichText(String text) {
    final spans = <TextSpan>[];
    final regex = RegExp(r'\*\*(.+?)\*\*');
    int lastEnd = 0;

    for (final match in regex.allMatches(text)) {
      if (match.start > lastEnd) {
        spans.add(TextSpan(text: text.substring(lastEnd, match.start)));
      }
      spans.add(
        TextSpan(
          text: match.group(1),
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
      );
      lastEnd = match.end;
    }
    if (lastEnd < text.length) {
      spans.add(TextSpan(text: text.substring(lastEnd)));
    }

    return RichText(
      text: TextSpan(
        style: TextStyle(
          color: widget.isError
              ? EomColors.textSecondary
              : EomColors.textPrimary,
          fontSize: 15,
          fontWeight: FontWeight.w400,
          height: 1.65,
        ),
        children: spans,
      ),
    );
  }
}

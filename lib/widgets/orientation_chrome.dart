import 'package:flutter/material.dart';
import '../theme/eom_colors.dart';
import '../theme/eom_motion.dart';
import '../theme/eom_shapes.dart';
import '../theme/eom_theme.dart';

/// Gold, sans orientation action (Connect / Capture). Never serif chrome.
class OrientationCta extends StatelessWidget {
  const OrientationCta({
    super.key,
    this.buttonKey,
    required this.label,
    required this.onPressed,
    this.enabled = true,
    this.loading = false,
  });

  final Key? buttonKey;
  final String label;
  final VoidCallback? onPressed;
  final bool enabled;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final active = enabled && !loading && onPressed != null;
    return TextButton(
      key: buttonKey,
      onPressed: active ? onPressed : null,
      style: TextButton.styleFrom(
        foregroundColor: active ? EomColors.gold : EomColors.goldMuted,
        disabledForegroundColor: EomColors.goldMuted,
        padding: const EdgeInsets.symmetric(vertical: EomSpacing.sm),
        minimumSize: const Size(0, 44),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        alignment: Alignment.centerLeft,
      ),
      child: loading
          ? const SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(
                strokeWidth: 1.5,
                color: EomColors.gold,
              ),
            )
          : Text(label, style: EomTheme.orientationCta()),
    );
  }
}

/// Collapsed/expanded orientation row (Advanced, Connections).
class OrientationDisclosure extends StatelessWidget {
  const OrientationDisclosure({
    super.key,
    required this.label,
    required this.expanded,
    required this.onToggle,
    required this.child,
  });

  final String label;
  final bool expanded;
  final VoidCallback onToggle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: onToggle,
          borderRadius: BorderRadius.circular(EomShapes.radiusSm),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: EomSpacing.xs),
            child: Row(
              children: [
                Text(label, style: EomTheme.orientationLabel()),
                const Spacer(),
                Icon(
                  expanded ? Icons.expand_less : Icons.expand_more,
                  size: 18,
                  color: EomColors.textTertiary,
                ),
              ],
            ),
          ),
        ),
        AnimatedSize(
          duration: EomMotion.of(context, EomMotion.medium),
          curve: EomMotion.curve,
          alignment: Alignment.topCenter,
          child: expanded ? child : const SizedBox(width: double.infinity),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import '../models/intent.dart';
import '../theme/eom_colors.dart';

/// Pill-shaped intent button — muted idle state, subtle glow on tap.
/// Shows [CognitiveIntent.description] as a subtitle + tooltip (EOM-S20).
class IntentButton extends StatelessWidget {
  const IntentButton({
    super.key,
    required this.intent,
    required this.onPressed,
    this.isLoading = false,
    this.isSelected = false,
  });

  final CognitiveIntent intent;
  final VoidCallback onPressed;
  final bool isLoading;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    final labelColor = isSelected ? intent.color : EomColors.textSecondary;
    final descColor = isSelected
        ? intent.color.withValues(alpha: 0.75)
        : EomColors.textTertiary;

    return Tooltip(
      message: intent.description,
      waitDuration: const Duration(milliseconds: 400),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          color: isSelected
              ? intent.color.withValues(alpha: 0.15)
              : EomColors.intentIdle,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected
                ? intent.color.withValues(alpha: 0.4)
                : EomColors.surfaceBorder,
            width: 0.5,
          ),
        ),
        child: Material(
          color: EomColors.transparent,
          borderRadius: BorderRadius.circular(24),
          child: InkWell(
            onTap: isLoading ? null : onPressed,
            borderRadius: BorderRadius.circular(24),
            splashColor: intent.color.withValues(alpha: 0.1),
            highlightColor: intent.color.withValues(alpha: 0.05),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isLoading && isSelected)
                    SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 1.5,
                        color: intent.color,
                      ),
                    )
                  else
                    Icon(intent.icon, size: 18, color: labelColor),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        intent.label,
                        style: TextStyle(
                          color: labelColor,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.3,
                        ),
                      ),
                      Text(
                        intent.description,
                        style: TextStyle(
                          color: descColor,
                          fontSize: 11,
                          fontWeight: FontWeight.w400,
                          height: 1.2,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

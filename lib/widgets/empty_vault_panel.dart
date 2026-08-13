import 'package:flutter/material.dart';
import '../theme/eom_colors.dart';
import '../theme/eom_shapes.dart';
import '../theme/eom_theme.dart';

/// Ceremonial empty canvas — leaf-framed room around the blank input.
///
/// Gold stays on the optional Connect CTA (orientation), never on intent
/// pills. [onConnect] opens the soft-gate sheet (EOM-S27).
class EmptyVaultPanel extends StatelessWidget {
  const EmptyVaultPanel({
    super.key,
    required this.child,
    this.showConnectCta = false,
    this.onConnect,
  });

  final Widget child;
  final bool showConnectCta;
  final VoidCallback? onConnect;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('empty-vault-frame'),
      decoration: BoxDecoration(
        color: EomColors.surface.withValues(alpha: 0.35),
        borderRadius: EomShapes.leafRadius,
        border: Border.all(color: EomColors.surfaceBorder, width: 0.5),
      ),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          EomSpacing.lg,
          EomSpacing.xl,
          EomSpacing.lg,
          EomSpacing.lg,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            child,
            if (showConnectCta) ...[
              const SizedBox(height: EomSpacing.md),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton(
                  onPressed: onConnect,
                  style: TextButton.styleFrom(
                    foregroundColor: EomColors.gold,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    minimumSize: const Size(0, 44),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    alignment: Alignment.centerLeft,
                  ),
                  child: const Text(
                    'Connect a guide',
                    style: TextStyle(
                      fontFamily: eomDisplaySerif,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.2,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

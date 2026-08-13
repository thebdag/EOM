import 'package:flutter/material.dart';
import '../models/llm_provider_kind.dart';
import '../theme/eom_colors.dart';
import '../theme/eom_shapes.dart';
import '../theme/eom_theme.dart';

BoxDecoration eomSurfaceDecoration({BorderRadius? radius}) {
  return BoxDecoration(
    color: EomColors.surface,
    borderRadius: radius ?? BorderRadius.circular(EomShapes.radiusMd),
    border: Border.all(color: EomColors.surfaceBorder, width: 0.5),
  );
}

/// Lifted 0.5px field used by the soft gate and Settings (EOM-S27, S28).
class EomSurfaceField extends StatelessWidget {
  const EomSurfaceField({
    super.key,
    required this.controller,
    required this.hint,
    this.obscure = false,
  });

  final TextEditingController controller;
  final String hint;
  final bool obscure;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: eomSurfaceDecoration(),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        autocorrect: !obscure,
        enableSuggestions: !obscure,
        enableIMEPersonalizedLearning: !obscure,
        style: const TextStyle(color: EomColors.textPrimary, fontSize: 15),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: EomColors.textTertiary),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: EomSpacing.md,
            vertical: EomSpacing.md,
          ),
        ),
      ),
    );
  }
}

/// Active-provider picker — shared by the soft gate and Settings.
class ProviderPicker extends StatelessWidget {
  const ProviderPicker({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final LlmProviderKind value;
  final ValueChanged<LlmProviderKind> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: EomSpacing.md),
      decoration: eomSurfaceDecoration(),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<LlmProviderKind>(
          value: value,
          isExpanded: true,
          dropdownColor: EomColors.surface,
          items: LlmProviderKind.values
              .map(
                (kind) =>
                    DropdownMenuItem(value: kind, child: Text(kind.label)),
              )
              .toList(),
          onChanged: (val) {
            if (val != null) onChanged(val);
          },
        ),
      ),
    );
  }
}

/// Essential credential field for [provider] (key / master key only).
class GuideKeyField extends StatelessWidget {
  const GuideKeyField({
    super.key,
    required this.provider,
    required this.controller,
  });

  final LlmProviderKind provider;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return EomSurfaceField(
      controller: controller,
      hint: provider.keyHint,
      obscure: true,
    );
  }
}

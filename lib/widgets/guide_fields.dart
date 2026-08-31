import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../models/llm_provider_kind.dart';
import '../services/on_device_llm.dart';
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

  bool get _includeOnDevice {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
      case TargetPlatform.iOS:
        return true;
      default:
        return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final kinds = LlmProviderKind.pickerKinds(
      includeOnDevice: _includeOnDevice,
      selected: value,
    );
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: EomSpacing.md),
      decoration: eomSurfaceDecoration(),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<LlmProviderKind>(
          value: value,
          isExpanded: true,
          dropdownColor: EomColors.surface,
          items: kinds
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

/// Quiet availability line for the on-device Guide (Settings).
class OnDeviceGuideStatus extends StatefulWidget {
  const OnDeviceGuideStatus({super.key, this.client});

  final OnDeviceLlmClient? client;

  @override
  State<OnDeviceGuideStatus> createState() => _OnDeviceGuideStatusState();
}

class _OnDeviceGuideStatusState extends State<OnDeviceGuideStatus> {
  late Future<OnDeviceAvailability> _future;

  @override
  void initState() {
    super.initState();
    _future = (widget.client ?? OnDeviceLlm.instance).availability();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<OnDeviceAvailability>(
      future: _future,
      builder: (context, snapshot) {
        final copy = snapshot.hasError
            ? 'Not available here — choose another Guide'
            : (snapshot.data?.statusCopy ?? 'Preparing…');
        return Text(
          copy,
          style: const TextStyle(
            color: EomColors.textTertiary,
            fontSize: 13,
            height: 1.4,
          ),
        );
      },
    );
  }
}

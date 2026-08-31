import 'package:flutter/material.dart';

import '../models/llm_provider_kind.dart';
import '../services/settings_service.dart';
import '../theme/eom_colors.dart';
import '../theme/eom_motion.dart';
import '../theme/eom_shapes.dart';
import '../theme/eom_theme.dart';
import 'guide_fields.dart';
import 'orientation_chrome.dart';

/// Persists the active provider + essential key. Tests inject a throwing
/// implementation to cover the error path.
typedef SoftGatePersist =
    Future<void> Function(LlmProviderKind provider, String key);

/// Quiet first-run / no-key sheet (EOM-S27 / F1 / F5).
///
/// Provider pick + essential key only. Dismiss without Connect is cancel
/// (not a hard wall). Pops `true` after a successful persist.
class SoftGateSheet extends StatefulWidget {
  const SoftGateSheet({super.key, this.persist});

  final SoftGatePersist? persist;

  static Future<bool> show(BuildContext context) async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: EomColors.surface,
      elevation: 0,
      isScrollControlled: true,
      sheetAnimationStyle: EomMotion.sheetStyleOf(context),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(EomShapes.radiusMd),
        ),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(ctx).bottom),
          child: const SoftGateSheet(),
        );
      },
    );
    return result == true;
  }

  @override
  State<SoftGateSheet> createState() => _SoftGateSheetState();
}

class _SoftGateSheetState extends State<SoftGateSheet> {
  late LlmProviderKind _provider;
  final _keyController = TextEditingController();
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _provider = SettingsService.activeProvider;
    _keyController.text = SettingsService.keyFor(_provider);
  }

  @override
  void dispose() {
    _keyController.dispose();
    super.dispose();
  }

  Future<void> _defaultPersist(LlmProviderKind provider, String key) async {
    await SettingsService.setActiveProvider(provider);
    if (provider.requiresCredential) {
      await SettingsService.setKey(provider, key);
    }
  }

  Future<void> _connect() async {
    final key = _keyController.text.trim();
    if (_provider.requiresCredential && key.isEmpty) {
      setState(() => _error = 'Add a key to connect.');
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final persist = widget.persist ?? _defaultPersist;
      await persist(_provider, key);
      if (mounted) Navigator.pop(context, true);
    } catch (e, st) {
      debugPrint('EOM: soft-gate persist failed: $e\n$st');
      if (mounted) {
        setState(() {
          _saving = false;
          _error = 'Could not save the key. Try again.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          EomSpacing.lg,
          EomSpacing.md,
          EomSpacing.lg,
          EomSpacing.lg,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Connect a guide', style: EomTheme.displayTitle()),
            const SizedBox(height: EomSpacing.xs),
            Text(
              _provider.requiresCredential
                  ? 'Choose a provider and add its key. You can change this later.'
                  : 'This guide runs on your device. You can change this later.',
              style: const TextStyle(
                color: EomColors.textTertiary,
                fontSize: 14,
                height: 1.4,
              ),
            ),
            const SizedBox(height: EomSpacing.lg),
            ProviderPicker(
              value: _provider,
              onChanged: (kind) {
                setState(() {
                  _provider = kind;
                  _keyController.text = SettingsService.keyFor(kind);
                  _error = null;
                });
              },
            ),
            if (_provider.requiresCredential) ...[
              const SizedBox(height: EomSpacing.md),
              GuideKeyField(provider: _provider, controller: _keyController),
            ],
            const SizedBox(height: EomSpacing.md),
            Align(
              alignment: Alignment.centerLeft,
              child: ValueListenableBuilder<TextEditingValue>(
                valueListenable: _keyController,
                builder: (context, value, _) {
                  final canConnect =
                      !_provider.requiresCredential ||
                      value.text.trim().isNotEmpty;
                  return OrientationCta(
                    buttonKey: const Key('soft-gate-connect'),
                    label: 'Connect',
                    enabled: canConnect,
                    loading: _saving,
                    onPressed: _connect,
                  );
                },
              ),
            ),
            if (_error != null) ...[
              const SizedBox(height: EomSpacing.xs),
              Text(
                _error!,
                style: const TextStyle(
                  color: EomColors.textTertiary,
                  fontSize: 13,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

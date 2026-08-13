import 'package:flutter/material.dart';
import '../models/llm_provider_kind.dart';
import '../services/settings_service.dart';
import '../theme/eom_colors.dart';
import '../theme/eom_theme.dart';
import 'guide_fields.dart';

/// Quiet first-run / no-key sheet (EOM-S27 / F1 / F5).
///
/// Provider pick + essential key only. Dismiss without Connect is cancel
/// (not a hard wall). Pops `true` after a successful persist.
class SoftGateSheet extends StatefulWidget {
  const SoftGateSheet({super.key});

  static Future<bool> show(BuildContext context) async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: EomColors.surface,
      elevation: 0,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
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

  @override
  void initState() {
    super.initState();
    _provider = SettingsService.activeProvider;
    _keyController.text = _keyFor(_provider);
    _keyController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _keyController.dispose();
    super.dispose();
  }

  String _keyFor(LlmProviderKind kind) {
    switch (kind) {
      case LlmProviderKind.openai:
        return SettingsService.openAiKey;
      case LlmProviderKind.anthropic:
        return SettingsService.anthropicKey;
      case LlmProviderKind.gemini:
        return SettingsService.geminiKey;
      case LlmProviderKind.local:
        return SettingsService.localApiKey;
    }
  }

  Future<void> _connect() async {
    final key = _keyController.text.trim();
    if (key.isEmpty) return;
    try {
      await SettingsService.setActiveProvider(_provider);
      switch (_provider) {
        case LlmProviderKind.openai:
          await SettingsService.setOpenAiKey(key);
        case LlmProviderKind.anthropic:
          await SettingsService.setAnthropicKey(key);
        case LlmProviderKind.gemini:
          await SettingsService.setGeminiKey(key);
        case LlmProviderKind.local:
          await SettingsService.setLocalApiKey(key);
      }
      if (mounted) Navigator.pop(context, true);
    } catch (e, st) {
      debugPrint('EOM: soft-gate persist failed: $e\n$st');
    }
  }

  bool get _canConnect => _keyController.text.trim().isNotEmpty;

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
            Text(
              'Connect a guide',
              style: TextStyle(
                fontFamily: eomDisplaySerif,
                color: EomColors.textPrimary,
                fontSize: 22,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: EomSpacing.xs),
            const Text(
              'Choose a provider and add its key. You can change this later.',
              style: TextStyle(
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
                  _keyController.text = _keyFor(kind);
                });
              },
            ),
            const SizedBox(height: EomSpacing.md),
            GuideKeyField(provider: _provider, controller: _keyController),
            const SizedBox(height: EomSpacing.md),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                key: const Key('soft-gate-connect'),
                onPressed: _connect,
                style: TextButton.styleFrom(
                  foregroundColor: _canConnect
                      ? EomColors.gold
                      : EomColors.goldMuted,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  minimumSize: const Size(0, 44),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  alignment: Alignment.centerLeft,
                ),
                child: const Text(
                  'Connect',
                  style: TextStyle(
                    fontFamily: eomDisplaySerif,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

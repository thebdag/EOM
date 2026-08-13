import 'package:flutter/material.dart';
import '../models/llm_provider_kind.dart';
import '../services/settings_service.dart';
import '../theme/eom_colors.dart';
import '../theme/eom_theme.dart';
import '../widgets/guide_fields.dart';

/// Calm Settings (EOM-S28 / F4) — active-provider essential fields;
/// Advanced (gateway / model alias) collapsed; quiet Epiture lineage.
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  LlmProviderKind _activeProvider = LlmProviderKind.fallback;
  bool _advancedExpanded = false;
  final _openAiController = TextEditingController();
  final _anthropicController = TextEditingController();
  final _geminiController = TextEditingController();
  final _localHostController = TextEditingController();
  final _localModelController = TextEditingController();
  final _localApiKeyController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _activeProvider = SettingsService.activeProvider;
    _openAiController.text = SettingsService.openAiKey;
    _anthropicController.text = SettingsService.anthropicKey;
    _geminiController.text = SettingsService.geminiKey;
    _localHostController.text = SettingsService.localHost;
    _localModelController.text = SettingsService.localModel;
    _localApiKeyController.text = SettingsService.localApiKey;
  }

  @override
  void dispose() {
    _openAiController.dispose();
    _anthropicController.dispose();
    _geminiController.dispose();
    _localHostController.dispose();
    _localModelController.dispose();
    _localApiKeyController.dispose();
    super.dispose();
  }

  /// Settings persist on *any* route pop (EOM-S6) — AppBar back, Android
  /// system back, and iOS swipe-back all route through the [PopScope].
  bool _allowPop = false;

  TextEditingController _keyControllerFor(LlmProviderKind kind) {
    switch (kind) {
      case LlmProviderKind.openai:
        return _openAiController;
      case LlmProviderKind.anthropic:
        return _anthropicController;
      case LlmProviderKind.gemini:
        return _geminiController;
      case LlmProviderKind.local:
        return _localApiKeyController;
    }
  }

  Future<void> _persistSettings() async {
    await SettingsService.setActiveProvider(_activeProvider);
    await SettingsService.setOpenAiKey(_openAiController.text);
    await SettingsService.setAnthropicKey(_anthropicController.text);
    await SettingsService.setGeminiKey(_geminiController.text);
    await SettingsService.setLocalHost(_localHostController.text);
    await SettingsService.setLocalModel(_localModelController.text);
    await SettingsService.setLocalApiKey(_localApiKeyController.text);
  }

  Future<void> _onPopInvoked(bool didPop) async {
    if (didPop) return;
    await _persistSettings();
    if (!mounted) return;
    setState(() => _allowPop = true);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _allowPop,
      onPopInvokedWithResult: (didPop, _) => _onPopInvoked(didPop),
      child: Scaffold(
        appBar: AppBar(title: const Text('Settings')),
        body: ListView(
          padding: const EdgeInsets.all(EomSpacing.lg),
          children: [
            _orientationLabel('Guide'),
            ProviderPicker(
              value: _activeProvider,
              onChanged: (val) => setState(() => _activeProvider = val),
            ),
            const SizedBox(height: EomSpacing.lg),
            GuideKeyField(
              provider: _activeProvider,
              controller: _keyControllerFor(_activeProvider),
            ),
            const SizedBox(height: EomSpacing.xl),
            _buildAdvanced(),
            const Padding(
              padding: EdgeInsets.only(top: EomSpacing.xxl),
              child: Text(
                'Kin to Epiture.',
                style: TextStyle(
                  fontFamily: eomDisplaySerif,
                  color: EomColors.textTertiary,
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _orientationLabel(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: EomSpacing.sm),
      child: Text(title, style: EomTheme.orientationLabel()),
    );
  }

  Widget _buildAdvanced() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () => setState(() => _advancedExpanded = !_advancedExpanded),
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                Text('Advanced', style: EomTheme.orientationLabel()),
                const Spacer(),
                Icon(
                  _advancedExpanded ? Icons.expand_less : Icons.expand_more,
                  size: 18,
                  color: EomColors.textTertiary,
                ),
              ],
            ),
          ),
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
          alignment: Alignment.topCenter,
          child: _advancedExpanded
              ? Column(
                  children: [
                    EomSurfaceField(
                      controller: _localHostController,
                      hint: 'Gateway Origin (e.g., http://127.0.0.1:4000)',
                    ),
                    const SizedBox(height: EomSpacing.sm),
                    EomSurfaceField(
                      controller: _localModelController,
                      hint: 'Model Alias (e.g., qwen-smart)',
                    ),
                  ],
                )
              : const SizedBox(width: double.infinity),
        ),
      ],
    );
  }
}

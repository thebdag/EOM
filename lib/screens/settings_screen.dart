import 'package:flutter/material.dart';
import '../models/llm_provider_kind.dart';
import '../services/settings_service.dart';
import '../theme/eom_colors.dart';
import '../theme/eom_theme.dart';
import '../widgets/guide_fields.dart';
import '../widgets/orientation_chrome.dart';

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
  String? _hostError;
  final _openAiController = TextEditingController();
  final _anthropicController = TextEditingController();
  final _geminiController = TextEditingController();
  final _localHostController = TextEditingController();
  final _localModelController = TextEditingController();
  final _localApiKeyController = TextEditingController();

  late final LlmProviderKind _initialProvider;
  late final String _initialOpenAi;
  late final String _initialAnthropic;
  late final String _initialGemini;
  late final String _initialLocalHost;
  late final String _initialLocalModel;
  late final String _initialLocalApiKey;

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
    _initialProvider = _activeProvider;
    _initialOpenAi = _openAiController.text;
    _initialAnthropic = _anthropicController.text;
    _initialGemini = _geminiController.text;
    _initialLocalHost = _localHostController.text;
    _initialLocalModel = _localModelController.text;
    _initialLocalApiKey = _localApiKeyController.text;
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
    if (_activeProvider != _initialProvider) {
      await SettingsService.setActiveProvider(_activeProvider);
    }
    if (_openAiController.text.trim() != _initialOpenAi) {
      await SettingsService.setOpenAiKey(_openAiController.text);
    }
    if (_anthropicController.text.trim() != _initialAnthropic) {
      await SettingsService.setAnthropicKey(_anthropicController.text);
    }
    if (_geminiController.text.trim() != _initialGemini) {
      await SettingsService.setGeminiKey(_geminiController.text);
    }
    if (_localApiKeyController.text.trim() != _initialLocalApiKey) {
      await SettingsService.setLocalApiKey(_localApiKeyController.text);
    }
    if (_localModelController.text.trim() != _initialLocalModel) {
      await SettingsService.setLocalModel(_localModelController.text);
    }
    if (_localHostController.text.trim() != _initialLocalHost) {
      await SettingsService.setLocalHost(_localHostController.text);
    }
  }

  Future<void> _onPopInvoked(bool didPop) async {
    if (didPop) return;
    try {
      await _persistSettings();
    } on FormatException catch (e) {
      if (!mounted) return;
      setState(() {
        _hostError = e.message;
        _advancedExpanded = true;
      });
      return;
    }
    if (!mounted) return;
    setState(() {
      _allowPop = true;
      _hostError = null;
    });
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
            OrientationDisclosure(
              label: 'Advanced',
              expanded: _advancedExpanded,
              onToggle: () =>
                  setState(() => _advancedExpanded = !_advancedExpanded),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  EomSurfaceField(
                    controller: _localHostController,
                    hint: 'Gateway Origin (e.g., http://127.0.0.1:4000)',
                  ),
                  if (_hostError != null) ...[
                    const SizedBox(height: EomSpacing.xs),
                    Text(
                      _hostError!,
                      style: const TextStyle(
                        color: EomColors.textTertiary,
                        fontSize: 13,
                      ),
                    ),
                  ],
                  const SizedBox(height: EomSpacing.sm),
                  EomSurfaceField(
                    controller: _localModelController,
                    hint: 'Model Alias (e.g., qwen-smart)',
                  ),
                ],
              ),
            ),
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
}

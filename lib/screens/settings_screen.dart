import 'package:flutter/material.dart';
import '../models/llm_provider_kind.dart';
import '../services/settings_service.dart';
import '../theme/eom_colors.dart';
import '../theme/eom_motion.dart';
import '../theme/eom_theme.dart';
import '../widgets/guide_fields.dart';
import '../widgets/orientation_chrome.dart';

/// Calm Settings (EOM-S28 / F4) — active-provider essential fields;
/// Advanced (gateway / model alias) collapsed; quiet Epiture lineage.
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key, this.persist});

  /// Optional persistence seam used to verify graceful failure handling.
  final Future<void> Function()? persist;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  LlmProviderKind _activeProvider = LlmProviderKind.fallback;
  bool _advancedExpanded = false;
  String? _hostError;
  String? _saveError;
  late final Map<LlmProviderKind, TextEditingController> _keyControllers;
  final _localHostController = TextEditingController();
  final _localModelController = TextEditingController();

  late final LlmProviderKind _initialProvider;
  late final Map<LlmProviderKind, String> _initialKeys;
  late final String _initialLocalHost;
  late final String _initialLocalModel;

  @override
  void initState() {
    super.initState();
    _activeProvider = SettingsService.activeProvider;
    _keyControllers = {
      for (final kind in LlmProviderKind.values)
        kind: TextEditingController(text: SettingsService.keyFor(kind)),
    };
    _localHostController.text = SettingsService.localHost;
    _localModelController.text = SettingsService.localModel;
    _initialProvider = _activeProvider;
    _initialKeys = {
      for (final entry in _keyControllers.entries) entry.key: entry.value.text,
    };
    _initialLocalHost = _localHostController.text;
    _initialLocalModel = _localModelController.text;
  }

  @override
  void dispose() {
    for (final controller in _keyControllers.values) {
      controller.dispose();
    }
    _localHostController.dispose();
    _localModelController.dispose();
    super.dispose();
  }

  /// Settings persist on *any* route pop (EOM-S6) — AppBar back, Android
  /// system back, and iOS swipe-back all route through the [PopScope].
  bool _allowPop = false;

  TextEditingController _keyControllerFor(LlmProviderKind kind) =>
      _keyControllers[kind]!;

  Future<void> _persistSettings() async {
    if (_activeProvider != _initialProvider) {
      await SettingsService.setActiveProvider(_activeProvider);
    }
    for (final entry in _keyControllers.entries) {
      if (entry.value.text.trim() != _initialKeys[entry.key]) {
        await SettingsService.setKey(entry.key, entry.value.text);
      }
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
      await (widget.persist?.call() ?? _persistSettings());
    } on FormatException catch (e) {
      if (!mounted) return;
      setState(() {
        _hostError = e.message;
        _saveError = null;
        _advancedExpanded = true;
      });
      return;
    } catch (e, st) {
      debugPrint('EOM: settings save failed: $e\n$st');
      if (!mounted) return;
      setState(() {
        _saveError = 'Settings could not be saved. Try again.';
      });
      return;
    }
    if (!mounted) return;
    setState(() {
      _allowPop = true;
      _hostError = null;
      _saveError = null;
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
            AnimatedSwitcher(
              duration: EomMotion.of(context, EomMotion.medium),
              switchInCurve: EomMotion.curve,
              switchOutCurve: EomMotion.curve,
              child: GuideKeyField(
                key: ValueKey(_activeProvider),
                provider: _activeProvider,
                controller: _keyControllerFor(_activeProvider),
              ),
            ),
            if (_saveError != null) ...[
              const SizedBox(height: EomSpacing.sm),
              Text(
                _saveError!,
                style: const TextStyle(
                  color: EomColors.textTertiary,
                  fontSize: 13,
                ),
              ),
            ],
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

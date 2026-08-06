import 'package:flutter/material.dart';
import '../services/settings_service.dart';
import '../theme/eom_colors.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _activeProvider = 'GEMINI';
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
        appBar: AppBar(title: const Text('AI Configuration')),
        body: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _buildSectionTitle('Active Provider'),
            _buildDropdown(),
            const SizedBox(height: 32),

            _buildSectionTitle('OpenAI'),
            _buildTextField(
              'API Key (sk-...)',
              _openAiController,
              obscure: true,
            ),
            const SizedBox(height: 24),

            _buildSectionTitle('Anthropic'),
            _buildTextField(
              'API Key (sk-ant-...)',
              _anthropicController,
              obscure: true,
            ),
            const SizedBox(height: 24),

            _buildSectionTitle('Google Gemini'),
            _buildTextField('API Key', _geminiController, obscure: true),
            const SizedBox(height: 24),

            _buildSectionTitle('LiteLLM'),
            _buildTextField(
              'Master Key (required)',
              _localApiKeyController,
              obscure: true,
            ),
            const SizedBox(height: 12),
            _buildTextField(
              'Gateway Origin (e.g., http://127.0.0.1:4000)',
              _localHostController,
            ),
            const SizedBox(height: 12),
            _buildTextField(
              'Model Alias (e.g., qwen-smart)',
              _localModelController,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          color: EomColors.textSecondary,
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: EomColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: EomColors.surfaceBorder, width: 0.5),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _activeProvider,
          isExpanded: true,
          dropdownColor: EomColors.surface,
          items: const [
            DropdownMenuItem(value: 'OPENAI', child: Text('OpenAI')),
            DropdownMenuItem(
              value: 'ANTHROPIC',
              child: Text('Anthropic Claude'),
            ),
            DropdownMenuItem(value: 'GEMINI', child: Text('Google Gemini')),
            DropdownMenuItem(value: 'LOCAL', child: Text('LiteLLM')),
          ],
          onChanged: (val) {
            if (val != null) setState(() => _activeProvider = val);
          },
        ),
      ),
    );
  }

  Widget _buildTextField(
    String hint,
    TextEditingController controller, {
    bool obscure = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: EomColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: EomColors.surfaceBorder, width: 0.5),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        style: const TextStyle(color: EomColors.textPrimary, fontSize: 15),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: EomColors.textTertiary),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
      ),
    );
  }
}

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
  final _ollamaHostController = TextEditingController();
  final _ollamaModelController = TextEditingController();
  final _ollamaApiKeyController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _activeProvider = SettingsService.activeProvider;
    _openAiController.text = SettingsService.openAiKey;
    _anthropicController.text = SettingsService.anthropicKey;
    _geminiController.text = SettingsService.geminiKey;
    _ollamaHostController.text = SettingsService.ollamaHost;
    _ollamaModelController.text = SettingsService.ollamaModel;
    _ollamaApiKeyController.text = SettingsService.ollamaApiKey;
  }

  @override
  void dispose() {
    _openAiController.dispose();
    _anthropicController.dispose();
    _geminiController.dispose();
    _ollamaHostController.dispose();
    _ollamaModelController.dispose();
    _ollamaApiKeyController.dispose();
    super.dispose();
  }

  Future<void> _saveSettings() async {
    await SettingsService.setActiveProvider(_activeProvider);
    await SettingsService.setOpenAiKey(_openAiController.text);
    await SettingsService.setAnthropicKey(_anthropicController.text);
    await SettingsService.setGeminiKey(_geminiController.text);
    await SettingsService.setOllamaHost(_ollamaHostController.text);
    await SettingsService.setOllamaModel(_ollamaModelController.text);
    await SettingsService.setOllamaApiKey(_ollamaApiKeyController.text);
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Configuration'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _saveSettings,
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildSectionTitle('Active Provider'),
          _buildDropdown(),
          const SizedBox(height: 32),
          
          _buildSectionTitle('OpenAI'),
          _buildTextField('API Key (sk-...)', _openAiController, obscure: true),
          const SizedBox(height: 24),
          
          _buildSectionTitle('Anthropic'),
          _buildTextField('API Key (sk-ant-...)', _anthropicController, obscure: true),
          const SizedBox(height: 24),
          
          _buildSectionTitle('Google Gemini'),
          _buildTextField('API Key', _geminiController, obscure: true),
          const SizedBox(height: 24),
          
          _buildSectionTitle('Ollama (Local)'),
          _buildTextField('API Key', _ollamaApiKeyController, obscure: true),
          const SizedBox(height: 12),
          _buildTextField('Host URL', _ollamaHostController),
          const SizedBox(height: 12),
          _buildTextField('Model Name (e.g., llama3.1)', _ollamaModelController),
        ],
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
            DropdownMenuItem(value: 'ANTHROPIC', child: Text('Anthropic Claude')),
            DropdownMenuItem(value: 'GEMINI', child: Text('Google Gemini')),
            DropdownMenuItem(value: 'OLLAMA', child: Text('Ollama (Local)')),
          ],
          onChanged: (val) {
            if (val != null) setState(() => _activeProvider = val);
          },
        ),
      ),
    );
  }

  Widget _buildTextField(String hint, TextEditingController controller, {bool obscure = false}) {
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
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }
}

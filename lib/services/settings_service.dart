import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  static const String _kProvider = 'active_provider';
  static const String _kOpenAiKey = 'openai_api_key';
  static const String _kAnthropicKey = 'anthropic_api_key';
  static const String _kGeminiKey = 'gemini_api_key';
  static const String _kOllamaHost = 'ollama_host';
  static const String _kOllamaModel = 'ollama_model';
  static const String _kOllamaApiKey = 'ollama_api_key';

  static late SharedPreferences _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Active Provider
  static String get activeProvider => _prefs.getString(_kProvider) ?? 'GEMINI';
  static Future<void> setActiveProvider(String provider) async =>
      await _prefs.setString(_kProvider, provider);

  // OpenAI Key
  static String get openAiKey => _prefs.getString(_kOpenAiKey) ?? '';
  static Future<void> setOpenAiKey(String key) async =>
      await _prefs.setString(_kOpenAiKey, key.trim());

  // Anthropic Key
  static String get anthropicKey => _prefs.getString(_kAnthropicKey) ?? '';
  static Future<void> setAnthropicKey(String key) async =>
      await _prefs.setString(_kAnthropicKey, key.trim());

  // Gemini Key
  static String get geminiKey => _prefs.getString(_kGeminiKey) ?? '';
  static Future<void> setGeminiKey(String key) async =>
      await _prefs.setString(_kGeminiKey, key.trim());

  // Ollama Host
  static String get ollamaHost =>
      _prefs.getString(_kOllamaHost) ?? 'http://127.0.0.1:11434';
  static Future<void> setOllamaHost(String host) async =>
      await _prefs.setString(_kOllamaHost, host.trim());

  // Ollama Model
  static String get ollamaModel => _prefs.getString(_kOllamaModel) ?? 'llama3.1';
  static Future<void> setOllamaModel(String model) async =>
      await _prefs.setString(_kOllamaModel, model.trim());

  // Ollama API Key
  static String get ollamaApiKey => _prefs.getString(_kOllamaApiKey) ?? '';
  static Future<void> setOllamaApiKey(String key) async =>
      await _prefs.setString(_kOllamaApiKey, key.trim());
}

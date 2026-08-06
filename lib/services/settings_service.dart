import 'package:shared_preferences/shared_preferences.dart';
import '../models/llm_provider_kind.dart';

class SettingsService {
  static const String _kProvider = 'active_provider';
  static const String _kOpenAiKey = 'openai_api_key';
  static const String _kAnthropicKey = 'anthropic_api_key';
  static const String _kGeminiKey = 'gemini_api_key';
  // Preference keys keep `ollama_*` names for backward compatibility.
  static const String _kLocalHost = 'ollama_host';
  static const String _kLocalModel = 'ollama_model';
  static const String _kLocalApiKey = 'ollama_api_key';

  static const String defaultGatewayOrigin = 'http://127.0.0.1:4000';
  static const String defaultModelAlias = 'qwen-smart';

  static late SharedPreferences _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  /// Strip trailing slashes and an optional `/v1` so pasted LITELLM_BASE
  /// values do not become `/v1/v1/...` when clients append the OpenAI path.
  static String normalizeGatewayOrigin(String host) {
    var origin = host.trim();
    origin = origin.replaceAll(RegExp(r'/+$'), '');
    if (origin.toLowerCase().endsWith('/v1')) {
      origin = origin.substring(0, origin.length - 3);
      origin = origin.replaceAll(RegExp(r'/+$'), '');
    }
    return origin;
  }

  // Active Provider — legacy OLLAMA → LOCAL mapping lives in
  // LlmProviderKind.fromString (EOM-S10).
  static LlmProviderKind get activeProvider {
    final raw = _prefs.getString(_kProvider);
    return raw == null
        ? LlmProviderKind.fallback
        : LlmProviderKind.fromString(raw);
  }

  static Future<void> setActiveProvider(LlmProviderKind provider) async {
    await _prefs.setString(_kProvider, provider.id);
  }

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

  // LiteLLM Gateway Origin (no /v1 suffix)
  static String get localHost {
    final raw = _prefs.getString(_kLocalHost);
    if (raw == null || raw.trim().isEmpty) return defaultGatewayOrigin;
    return normalizeGatewayOrigin(raw);
  }

  static Future<void> setLocalHost(String host) async =>
      await _prefs.setString(_kLocalHost, normalizeGatewayOrigin(host));

  // LiteLLM Model Alias (e.g. qwen-smart, auto, claude-haiku)
  static String get localModel {
    final raw = _prefs.getString(_kLocalModel);
    if (raw == null || raw.trim().isEmpty) return defaultModelAlias;
    return raw.trim();
  }

  static Future<void> setLocalModel(String model) async =>
      await _prefs.setString(_kLocalModel, model.trim());

  // LiteLLM Master Key (required for the LAN-facing gateway)
  static String get localApiKey => _prefs.getString(_kLocalApiKey) ?? '';
  static Future<void> setLocalApiKey(String key) async =>
      await _prefs.setString(_kLocalApiKey, key.trim());
}

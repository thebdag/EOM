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
  static const Map<LlmProviderKind, String> _providerKeyPreferences = {
    LlmProviderKind.openai: _kOpenAiKey,
    LlmProviderKind.anthropic: _kAnthropicKey,
    LlmProviderKind.gemini: _kGeminiKey,
    LlmProviderKind.local: _kLocalApiKey,
  };

  static const String defaultGatewayOrigin = 'http://127.0.0.1:4000';
  static const String defaultModelAlias = 'qwen-smart';

  static late SharedPreferences _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  /// Strip trailing slashes and an optional `/v1` so pasted LITELLM_BASE
  /// values do not become `/v1/v1/...` when clients append the OpenAI path.
  ///
  /// Rejects missing scheme/host, non-http(s) schemes, and userinfo
  /// (`http://127.0.0.1:4000@evil.com`). LAN `http://` origins stay valid
  /// (LiteLLM on the local network). Throws [FormatException] on invalid
  /// input.
  static String normalizeGatewayOrigin(String host) {
    var origin = host.trim();
    origin = origin.replaceAll(RegExp(r'/+$'), '');
    if (origin.toLowerCase().endsWith('/v1')) {
      origin = origin.substring(0, origin.length - 3);
      origin = origin.replaceAll(RegExp(r'/+$'), '');
    }
    final uri = Uri.tryParse(origin);
    if (uri == null ||
        !uri.hasScheme ||
        uri.host.isEmpty ||
        (uri.scheme != 'http' && uri.scheme != 'https')) {
      throw const FormatException(
        'Gateway origin must be an http(s) URL with a host.',
      );
    }
    if (uri.userInfo.isNotEmpty) {
      throw const FormatException(
        'Gateway origin must not include credentials.',
      );
    }
    return uri.origin;
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
    await _setString(_kProvider, provider.id);
  }

  /// Essential credential for [kind] (cloud API key or LiteLLM master key).
  static String keyFor(LlmProviderKind kind) =>
      _prefs.getString(_providerKeyPreferences[kind]!) ?? '';

  static Future<void> setKey(LlmProviderKind kind, String key) async =>
      await _setString(_providerKeyPreferences[kind]!, key.trim());

  // OpenAI Key
  static String get openAiKey => keyFor(LlmProviderKind.openai);
  static Future<void> setOpenAiKey(String key) async =>
      await setKey(LlmProviderKind.openai, key);

  // Anthropic Key
  static String get anthropicKey => keyFor(LlmProviderKind.anthropic);
  static Future<void> setAnthropicKey(String key) async =>
      await setKey(LlmProviderKind.anthropic, key);

  // Gemini Key
  static String get geminiKey => keyFor(LlmProviderKind.gemini);
  static Future<void> setGeminiKey(String key) async =>
      await setKey(LlmProviderKind.gemini, key);

  // LiteLLM Gateway Origin (no /v1 suffix)
  static String get localHost {
    final raw = _prefs.getString(_kLocalHost);
    if (raw == null || raw.trim().isEmpty) return defaultGatewayOrigin;
    try {
      return normalizeGatewayOrigin(raw);
    } on FormatException {
      return defaultGatewayOrigin;
    }
  }

  static Future<void> setLocalHost(String host) async {
    if (host.trim().isEmpty) {
      await _setString(_kLocalHost, defaultGatewayOrigin);
      return;
    }
    await _setString(_kLocalHost, normalizeGatewayOrigin(host));
  }

  // LiteLLM Model Alias (e.g. qwen-smart, auto, claude-haiku)
  static String get localModel {
    final raw = _prefs.getString(_kLocalModel);
    if (raw == null || raw.trim().isEmpty) return defaultModelAlias;
    return raw.trim();
  }

  static Future<void> setLocalModel(String model) async =>
      await _setString(_kLocalModel, model.trim());

  // LiteLLM Master Key (required for the LAN-facing gateway)
  static String get localApiKey => keyFor(LlmProviderKind.local);
  static Future<void> setLocalApiKey(String key) async =>
      await setKey(LlmProviderKind.local, key);

  /// Whether the *active* provider has the credential needed to run an intent.
  ///
  /// Used by the empty-state Connect CTA (EOM-S26). A key on a different
  /// provider does not count.
  static bool get hasUsableGuide => keyFor(activeProvider).isNotEmpty;

  static Future<void> _setString(String preference, String value) async {
    final saved = await _prefs.setString(preference, value);
    if (!saved) {
      throw StateError('Settings storage rejected the write.');
    }
  }
}

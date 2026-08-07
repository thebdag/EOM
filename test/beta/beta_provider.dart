/// CLI LLM client for the beta runner (EOM-T67).
///
/// Builds the system prompt using the REAL `CognitiveIntent.buildPrompt`
/// (imported from `package:eom`) so the pressure test exercises the exact
/// prompts the app sends. The HTTP transport mirrors
/// `lib/services/llm_provider.dart` but reads config from environment
/// variables instead of `shared_preferences` (which needs Flutter bindings
/// unavailable under `flutter test` for a CLI-style call).
///
/// Drift risk: the HTTP shapes here must stay aligned with
/// `lib/services/llm_provider.dart`. The `defaultContext` string is copied
/// from `AiService` for the same reason — see `learnings.md`.
library;

import 'dart:convert';

import 'package:eom/models/intent.dart';
import 'package:eom/services/ai_service.dart' show AiService;
import 'package:eom/services/intent_config.dart';
import 'package:http/http.dart' as http;

/// The delimiter between prose and the JSON epilogue. Aliased to
/// `AiService.epistemicMarker` so the beta runner and the app can never
/// drift; `test/beta_drift_test.dart` asserts the alias stays exact.
const betaEpistemicMarker = AiService.epistemicMarker;

/// Which provider HTTP shape to use.
enum BetaProviderKind { openai, anthropic, gemini, local }

BetaProviderKind _kindFromString(String raw) {
  switch (raw) {
    case 'openai':
      return BetaProviderKind.openai;
    case 'anthropic':
      return BetaProviderKind.anthropic;
    case 'gemini':
      return BetaProviderKind.gemini;
    case 'local':
      return BetaProviderKind.local;
    default:
      throw ArgumentError('Unknown EOM_BETA_PROVIDER "$raw"');
  }
}

/// Resolved configuration for a beta run, from environment variables.
class BetaConfig {
  const BetaConfig({
    required this.provider,
    required this.apiKey,
    required this.model,
    required this.host,
  });

  final BetaProviderKind provider;
  final String apiKey;
  final String model;
  final String host;

  /// Reads `EOM_BETA_PROVIDER` (default `local`), `EOM_BETA_API_KEY`,
  /// `EOM_BETA_MODEL`, and `EOM_BETA_HOST` (local only, default
  /// `http://127.0.0.1:4000`).
  factory BetaConfig.fromEnv(Map<String, String> env) {
    final kind = _kindFromString(env['EOM_BETA_PROVIDER'] ?? 'local');
    final apiKey = env['EOM_BETA_API_KEY'] ?? '';
    final host = env['EOM_BETA_HOST'] ?? 'http://127.0.0.1:4000';
    final model =
        env['EOM_BETA_MODEL'] ??
        switch (kind) {
          BetaProviderKind.openai => 'gpt-4o',
          BetaProviderKind.anthropic => 'claude-3-5-sonnet-20241022',
          BetaProviderKind.gemini => 'gemini-1.5-pro',
          BetaProviderKind.local => 'qwen-smart',
        };
    if (apiKey.isEmpty) {
      throw StateError(
        'EOM_BETA_API_KEY is required (set it to the provider API key or the '
        'LiteLLM master key for local runs).',
      );
    }
    return BetaConfig(provider: kind, apiKey: apiKey, model: model, host: host);
  }

  /// Short label for response metadata, e.g. `local/qwen-smart`.
  String get label => '${provider.name}/$model';
}

/// Builds the full system prompt for [intent] exactly as `AiService` does.
String buildSystemPrompt(CognitiveIntent intent) {
  return '${AiService.defaultContext}\n\n${intent.buildPrompt(betaEpistemicMarker)}';
}

/// Sends [systemPrompt] + [userInput] to the configured provider and returns
/// the raw assistant text. Throws on non-200 or unexpected shape, mirroring
/// the app providers.
Future<String> callProvider({
  required BetaConfig config,
  required String systemPrompt,
  required String userInput,
}) async {
  switch (config.provider) {
    case BetaProviderKind.openai:
    case BetaProviderKind.local:
      // Both use the OpenAI-compatible /v1/chat/completions shape; local hits
      // the LiteLLM gateway at $host/v1/...
      final base = config.provider == BetaProviderKind.local
          ? config.host
          : 'https://api.openai.com';
      final resp = await http.post(
        Uri.parse('$base/v1/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${config.apiKey}',
        },
        body: jsonEncode({
          'model': config.model,
          'messages': [
            {'role': 'system', 'content': systemPrompt},
            {'role': 'user', 'content': userInput},
          ],
          if (config.provider == BetaProviderKind.local) 'stream': false,
        }),
      );
      if (resp.statusCode != 200) {
        throw Exception('${config.provider.name} error: ${resp.body}');
      }
      return _extractOpenAi(jsonDecode(resp.body));
    case BetaProviderKind.anthropic:
      final resp = await http.post(
        Uri.parse('https://api.anthropic.com/v1/messages'),
        headers: {
          'Content-Type': 'application/json',
          'x-api-key': config.apiKey,
          'anthropic-version': '2023-06-01',
        },
        body: jsonEncode({
          'model': config.model,
          'system': systemPrompt,
          'max_tokens': 1024,
          'messages': [
            {'role': 'user', 'content': userInput},
          ],
        }),
      );
      if (resp.statusCode != 200) {
        throw Exception('anthropic error: ${resp.body}');
      }
      return _extractAnthropic(jsonDecode(resp.body));
    case BetaProviderKind.gemini:
      final resp = await http.post(
        Uri.parse(
          'https://generativelanguage.googleapis.com/v1beta/models/'
          '${config.model}:generateContent?key=${config.apiKey}',
        ),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'systemInstruction': {
            'parts': [
              {'text': systemPrompt},
            ],
          },
          'contents': [
            {
              'role': 'user',
              'parts': [
                {'text': userInput},
              ],
            },
          ],
        }),
      );
      if (resp.statusCode != 200) {
        throw Exception('gemini error: ${resp.body}');
      }
      return _extractGemini(jsonDecode(resp.body));
  }
}

String _extractOpenAi(dynamic data) {
  if (data is Map) {
    final choices = data['choices'];
    if (choices is List && choices.isNotEmpty) {
      final message = choices[0] is Map ? choices[0]['message'] : null;
      final content = message is Map ? message['content'] : null;
      if (content is String && content.isNotEmpty) return content;
    }
  }
  throw Exception('openai/local: unexpected response shape');
}

String _extractAnthropic(dynamic data) {
  if (data is Map) {
    final content = data['content'];
    if (content is List && content.isNotEmpty) {
      final text = content[0] is Map ? content[0]['text'] : null;
      if (text is String && text.isNotEmpty) return text;
    }
  }
  throw Exception('anthropic: unexpected response shape');
}

String _extractGemini(dynamic data) {
  if (data is Map) {
    final candidates = data['candidates'];
    if (candidates is List && candidates.isNotEmpty) {
      final first = candidates[0];
      final content = first is Map ? first['content'] : null;
      final parts = content is Map ? content['parts'] : null;
      if (parts is List && parts.isNotEmpty) {
        final text = parts[0] is Map ? parts[0]['text'] : null;
        if (text is String && text.isNotEmpty) return text;
      }
    }
  }
  throw Exception('gemini: unexpected response shape');
}

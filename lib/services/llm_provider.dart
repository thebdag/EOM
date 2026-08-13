import 'dart:convert';
import '../models/llm_provider_kind.dart';
import 'settings_service.dart';
import 'package:http/http.dart' as http;

/// Builds the concrete [LlmProvider] for a [LlmProviderKind]. Lives in the
/// service layer so `lib/models/` stays free of provider dependencies.
extension LlmProviderKindFactory on LlmProviderKind {
  LlmProvider createProvider() {
    switch (this) {
      case LlmProviderKind.openai:
        return OpenAiProvider();
      case LlmProviderKind.anthropic:
        return AnthropicProvider();
      case LlmProviderKind.local:
        return LocalProvider();
      case LlmProviderKind.gemini:
        return GeminiProvider();
    }
  }
}

/// One turn in a conversation, owned by the provider layer (EOM-S11).
///
/// Replaces the `Map<String, String>` role/content maps that used to flow
/// through the history plumbing untyped.
class ChatMessage {
  const ChatMessage({required this.role, required this.content});

  factory ChatMessage.user(String content) =>
      ChatMessage(role: 'user', content: content);

  factory ChatMessage.assistant(String content) =>
      ChatMessage(role: 'assistant', content: content);

  /// `user`, `assistant`, or `system`.
  final String role;
  final String content;

  /// OpenAI-compatible chat-completions shape, also used by the LiteLLM
  /// gateway.
  Map<String, String> toJson() => {'role': role, 'content': content};
}

abstract class LlmProvider {
  Future<String> generate(
    String systemPrompt,
    String userMessage, {
    List<ChatMessage> history = const [],
  });
}

/// Shared OpenAI-compatible chat-completions client (EOM-S13). Both
/// [OpenAiProvider] and [LocalProvider] repeat the same request shape —
/// POST → status-check → decode → extract — so it lives here once.
Future<String> _postChatCompletion({
  required Uri url,
  required String apiKey,
  required String model,
  required String systemPrompt,
  required String userMessage,
  required List<ChatMessage> history,
  required String errorPrefix,
  Map<String, dynamic> extraBody = const {},
}) async {
  final response = await http.post(
    url,
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $apiKey',
    },
    body: jsonEncode({
      'model': model,
      'messages': [
        {'role': 'system', 'content': systemPrompt},
        ...history.map((m) => m.toJson()),
        {'role': 'user', 'content': userMessage},
      ],
      ...extraBody,
    }),
  );

  if (response.statusCode != 200) {
    throw Exception('$errorPrefix: ${response.body}');
  }
  return _extractChatContent(jsonDecode(response.body), errorPrefix);
}

/// Extracts the assistant message from a chat-completions payload, throwing
/// a descriptive [Exception] for unexpected shapes (EOM-S4).
String _extractChatContent(dynamic data, String errorPrefix) {
  if (data is Map) {
    final choices = data['choices'];
    if (choices is List && choices.isNotEmpty) {
      final message = choices[0] is Map ? choices[0]['message'] : null;
      final content = message is Map ? message['content'] : null;
      if (content is String && content.isNotEmpty) return content;
    }
  }
  throw Exception('$errorPrefix: unexpected response shape');
}

class OpenAiProvider implements LlmProvider {
  @override
  Future<String> generate(
    String systemPrompt,
    String userMessage, {
    List<ChatMessage> history = const [],
  }) async {
    final apiKey = SettingsService.openAiKey;
    if (apiKey.isEmpty) {
      throw Exception('OPENAI_API_KEY is missing');
    }

    return _postChatCompletion(
      url: Uri.parse('https://api.openai.com/v1/chat/completions'),
      apiKey: apiKey,
      model: 'gpt-4o', // or gpt-4o-mini
      systemPrompt: systemPrompt,
      userMessage: userMessage,
      history: history,
      errorPrefix: 'OpenAI Error',
    );
  }

  /// Extracts the assistant message from a chat-completions payload.
  ///
  /// Throws a descriptive [Exception] for unexpected shapes — e.g. an
  /// empty `choices` list under rate limiting — instead of leaking a raw
  /// RangeError/TypeError (EOM-S4).
  static String extractContent(dynamic data) =>
      _extractChatContent(data, 'OpenAI Error');
}

class AnthropicProvider implements LlmProvider {
  @override
  Future<String> generate(
    String systemPrompt,
    String userMessage, {
    List<ChatMessage> history = const [],
  }) async {
    final apiKey = SettingsService.anthropicKey;
    if (apiKey.isEmpty) {
      throw Exception('ANTHROPIC_API_KEY is missing');
    }

    final response = await http.post(
      Uri.parse('https://api.anthropic.com/v1/messages'),
      headers: {
        'Content-Type': 'application/json',
        'x-api-key': apiKey,
        'anthropic-version': '2023-06-01',
      },
      body: jsonEncode({
        'model': 'claude-3-5-sonnet-20241022',
        'system': systemPrompt,
        'max_tokens': 1024,
        'messages': [
          ...history.map((m) => m.toJson()),
          {'role': 'user', 'content': userMessage},
        ],
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Anthropic Error: ${response.body}');
    }
    return extractContent(jsonDecode(response.body));
  }

  /// Extracts the text block from a messages payload. Throws a descriptive
  /// [Exception] when the content list is missing or holds no text block
  /// (EOM-S4).
  static String extractContent(dynamic data) {
    if (data is Map) {
      final content = data['content'];
      if (content is List && content.isNotEmpty) {
        final text = content[0] is Map ? content[0]['text'] : null;
        if (text is String && text.isNotEmpty) return text;
      }
    }
    throw Exception('Anthropic Error: unexpected response shape');
  }
}

class GeminiProvider implements LlmProvider {
  @override
  Future<String> generate(
    String systemPrompt,
    String userMessage, {
    List<ChatMessage> history = const [],
  }) async {
    final apiKey = SettingsService.geminiKey;
    if (apiKey.isEmpty) {
      throw Exception('GEMINI_API_KEY is missing');
    }

    final response = await http.post(
      generateContentUri(),
      headers: generateContentHeaders(apiKey),
      body: jsonEncode({
        'systemInstruction': {
          'parts': [
            {'text': systemPrompt},
          ],
        },
        'contents': [
          ...history.map(
            (m) => {
              'role': m.role == 'assistant' ? 'model' : 'user',
              'parts': [
                {'text': m.content},
              ],
            },
          ),
          {
            'role': 'user',
            'parts': [
              {'text': userMessage},
            ],
          },
        ],
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Gemini Error: ${response.body}');
    }
    return extractContent(jsonDecode(response.body));
  }

  /// Extracts the first candidate's text from a generateContent payload.
  /// Safety-blocked responses arrive with no `content` on the candidate —
  /// throws a descriptive [Exception] instead of a RangeError (EOM-S4).
  static String extractContent(dynamic data) {
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
    throw Exception(
      'Gemini Error: unexpected response shape (possibly safety-blocked)',
    );
  }

  /// Endpoint without the API key in the query string.
  static Uri generateContentUri() => Uri.parse(
    'https://generativelanguage.googleapis.com/v1beta/models/'
    'gemini-1.5-pro:generateContent',
  );

  static Map<String, String> generateContentHeaders(String apiKey) => {
    'Content-Type': 'application/json',
    'x-goog-api-key': apiKey,
  };
}

/// LiteLLM Gateway client (provider id `LOCAL`) — OpenAI-compatible
/// `/v1/chat/completions` against the scratchpad-shaped LiteLLM proxy.
class LocalProvider implements LlmProvider {
  @override
  Future<String> generate(
    String systemPrompt,
    String userMessage, {
    List<ChatMessage> history = const [],
  }) async {
    final host = SettingsService.localHost;
    final model = SettingsService.localModel;
    final apiKey = SettingsService.localApiKey;

    if (apiKey.isEmpty) {
      throw Exception('LiteLLM Master Key is required');
    }
    if (model.isEmpty) {
      throw Exception('LiteLLM Model Alias is missing');
    }

    return _postChatCompletion(
      url: Uri.parse('$host/v1/chat/completions'),
      apiKey: apiKey,
      model: model,
      systemPrompt: systemPrompt,
      userMessage: userMessage,
      history: history,
      errorPrefix: 'LiteLLM Error',
      extraBody: const {'stream': false},
    );
  }
}

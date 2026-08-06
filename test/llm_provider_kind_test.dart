import 'package:eom/models/llm_provider_kind.dart';
import 'package:eom/services/llm_provider.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('LlmProviderKind.fromString (EOM-S10)', () {
    test('parses every persisted id', () {
      for (final kind in LlmProviderKind.values) {
        expect(LlmProviderKind.fromString(kind.id), kind);
      }
    });

    test('maps the legacy OLLAMA preference to local', () {
      expect(LlmProviderKind.fromString('OLLAMA'), LlmProviderKind.local);
    });

    test('is case- and whitespace-tolerant', () {
      expect(LlmProviderKind.fromString(' openai '), LlmProviderKind.openai);
      expect(
        LlmProviderKind.fromString('anthropic'),
        LlmProviderKind.anthropic,
      );
    });

    test('falls back to gemini for unknown or empty values', () {
      expect(LlmProviderKind.fromString('NOPE'), LlmProviderKind.fallback);
      expect(LlmProviderKind.fromString(''), LlmProviderKind.fallback);
      expect(LlmProviderKind.fallback, LlmProviderKind.gemini);
    });
  });

  group('createProvider (EOM-S10)', () {
    test('builds the matching concrete provider', () {
      expect(LlmProviderKind.openai.createProvider(), isA<OpenAiProvider>());
      expect(
        LlmProviderKind.anthropic.createProvider(),
        isA<AnthropicProvider>(),
      );
      expect(LlmProviderKind.gemini.createProvider(), isA<GeminiProvider>());
      expect(LlmProviderKind.local.createProvider(), isA<LocalProvider>());
    });
  });

  group('ChatMessage (EOM-S11)', () {
    test('serialises to the OpenAI-compatible shape', () {
      expect(ChatMessage.user('hi').toJson(), {
        'role': 'user',
        'content': 'hi',
      });
      expect(ChatMessage.assistant('hello').toJson(), {
        'role': 'assistant',
        'content': 'hello',
      });
    });
  });
}

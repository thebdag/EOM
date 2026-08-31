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

    test('parses ON_DEVICE', () {
      expect(LlmProviderKind.fromString('ON_DEVICE'), LlmProviderKind.onDevice);
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

    test('keyHint matches Settings / soft-gate field copy', () {
      expect(LlmProviderKind.openai.keyHint, 'API Key (sk-...)');
      expect(LlmProviderKind.anthropic.keyHint, 'API Key (sk-ant-...)');
      expect(LlmProviderKind.gemini.keyHint, 'API Key');
      expect(LlmProviderKind.local.keyHint, 'Master Key (required)');
      expect(LlmProviderKind.onDevice.requiresCredential, isFalse);
      expect(LlmProviderKind.gemini.requiresCredential, isTrue);
    });
  });

  group('pickerKinds', () {
    test('omits on-device unless included or already selected', () {
      expect(
        LlmProviderKind.pickerKinds(includeOnDevice: false),
        isNot(contains(LlmProviderKind.onDevice)),
      );
      expect(
        LlmProviderKind.pickerKinds(includeOnDevice: true),
        contains(LlmProviderKind.onDevice),
      );
      expect(
        LlmProviderKind.pickerKinds(
          includeOnDevice: false,
          selected: LlmProviderKind.onDevice,
        ),
        contains(LlmProviderKind.onDevice),
      );
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
      expect(
        LlmProviderKind.onDevice.createProvider(),
        isA<OnDeviceProvider>(),
      );
    });
  });

  group('GeminiProvider headers', () {
    test('keeps the API key out of the URL', () {
      expect(GeminiProvider.generateContentUri().query, isEmpty);
      expect(
        GeminiProvider.generateContentUri().toString(),
        isNot(contains('key=')),
      );
    });

    test('sends the key as x-goog-api-key', () {
      expect(
        GeminiProvider.generateContentHeaders('secret'),
        containsPair('x-goog-api-key', 'secret'),
      );
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

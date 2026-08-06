import 'package:eom/models/intent.dart';
import 'package:eom/services/ai_service.dart';
import 'package:eom/services/llm_provider.dart';
import 'package:eom/services/settings_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakeProvider implements LlmProvider {
  _FakeProvider(this.payload);

  final String payload;

  @override
  Future<String> generate(
    String systemPrompt,
    String userMessage, {
    List<Map<String, String>> history = const [],
  }) async => payload;
}

class _ThrowingProvider implements LlmProvider {
  @override
  Future<String> generate(
    String systemPrompt,
    String userMessage, {
    List<Map<String, String>> history = const [],
  }) async => throw Exception('provider exploded');
}

void main() {
  group('AiService Map parsing (EOM-S4)', () {
    test('parses a well-formed map response into tree and operation', () async {
      final service = AiService(
        provider: _FakeProvider(
          'Some prose.\n${AiService.epistemicMarker}\n'
          '{"label": "You", "children": [{"label": "Focus"}], '
          '"relationships": [{"source": "Focus", "target": "Rest", '
          '"type": "supports"}]}',
        ),
      );

      final response = await service.process('input', CognitiveIntent.map);

      expect(response.text, 'Some prose.');
      expect(response.tree, isNotNull);
      expect(response.tree!.label, 'You');
      expect(response.operation, isNotNull);
    });

    test('degrades to prose-only when the tree has the wrong shape', () async {
      final service = AiService(
        provider: _FakeProvider(
          'Keep the prose.\n${AiService.epistemicMarker}\n'
          '{"label": "You", "children": "not-a-list"}',
        ),
      );

      final response = await service.process('input', CognitiveIntent.map);

      expect(response.text, 'Keep the prose.');
      expect(response.tree, isNull);
      expect(response.operation, isNull);
    });

    test('degrades to prose-only when a child node is not an object', () async {
      final service = AiService(
        provider: _FakeProvider(
          'Prose survives.\n${AiService.epistemicMarker}\n'
          '{"label": "You", "children": ["just a string"]}',
        ),
      );

      final response = await service.process('input', CognitiveIntent.map);

      expect(response.text, 'Prose survives.');
      expect(response.tree, isNull);
    });
  });

  group('error responses (EOM-S5)', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      await SettingsService.init();
    });

    test(
      'provider failures are flagged isError with a readable message',
      () async {
        final service = AiService(provider: _ThrowingProvider());

        final response = await service.process('input', CognitiveIntent.act);

        expect(response.isError, isTrue);
        expect(response.text, contains('provider exploded'));
        expect(response.operation, isNull);
        expect(response.tree, isNull);
      },
    );

    test('successful responses are not flagged isError', () async {
      final service = AiService(provider: _FakeProvider('plain prose'));

      final response = await service.process('input', CognitiveIntent.act);

      expect(response.isError, isFalse);
      expect(response.text, 'plain prose');
    });
  });

  group('provider content extraction (EOM-S4)', () {
    test('OpenAI returns content from a well-formed payload', () {
      final text = OpenAiProvider.extractContent({
        'choices': [
          {
            'message': {'content': 'hello'},
          },
        ],
      });
      expect(text, 'hello');
    });

    test('OpenAI throws a descriptive error for empty choices', () {
      expect(
        () => OpenAiProvider.extractContent({'choices': []}),
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('OpenAI Error'),
          ),
        ),
      );
    });

    test('OpenAI throws a descriptive error for null content', () {
      expect(
        () => OpenAiProvider.extractContent({
          'choices': [
            {'message': null},
          ],
        }),
        throwsA(isA<Exception>()),
      );
    });

    test('Anthropic returns text from a well-formed payload', () {
      final text = AnthropicProvider.extractContent({
        'content': [
          {'type': 'text', 'text': 'hi'},
        ],
      });
      expect(text, 'hi');
    });

    test('Anthropic throws a descriptive error for empty content', () {
      expect(
        () => AnthropicProvider.extractContent({'content': []}),
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('Anthropic Error'),
          ),
        ),
      );
    });

    test('Gemini returns text from a well-formed payload', () {
      final text = GeminiProvider.extractContent({
        'candidates': [
          {
            'content': {
              'parts': [
                {'text': 'hey'},
              ],
            },
          },
        ],
      });
      expect(text, 'hey');
    });

    test('Gemini throws a descriptive error for safety-blocked candidates', () {
      expect(
        () => GeminiProvider.extractContent({
          'candidates': [
            {'finishReason': 'SAFETY'},
          ],
        }),
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('Gemini Error'),
          ),
        ),
      );
    });

    test('Gemini throws a descriptive error for missing candidates', () {
      expect(
        () => GeminiProvider.extractContent({'promptFeedback': {}}),
        throwsA(isA<Exception>()),
      );
    });
  });
}

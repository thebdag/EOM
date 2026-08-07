import 'package:eom/services/intent_error.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('IntentError (EOM-S18)', () {
    test('maps missing API key to Settings recovery', () {
      final err = IntentError.from(Exception('OPENAI_API_KEY is missing'));
      expect(err.offerSettings, isTrue);
      expect(err.message, contains('API key'));
      expect(err.message, isNot(contains('Exception')));
      expect(err.message, isNot(contains('OPENAI')));
    });

    test('maps LiteLLM config gaps to Settings recovery', () {
      final err = IntentError.from(Exception('LiteLLM Model Alias is missing'));
      expect(err.offerSettings, isTrue);
      expect(err.message.toLowerCase(), contains('settings'));
    });

    test('maps provider HTTP failures to Settings recovery', () {
      final err = IntentError.from(Exception('OpenAI Error: {"error":"x"}'));
      expect(err.offerSettings, isTrue);
      expect(err.message, isNot(contains('{"error"')));
    });

    test('maps unknown failures to calm copy without Settings', () {
      final err = IntentError.from(Exception('provider exploded'));
      expect(err.offerSettings, isFalse);
      expect(err.message, contains('quiet'));
      expect(err.message, isNot(contains('provider exploded')));
    });
  });
}

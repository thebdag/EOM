import 'package:eom/models/conversation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Conversation (EOM-S11)', () {
    test('round-trips through toMap/fromMap', () {
      final conversation = Conversation(
        timestamp: DateTime(2026, 8, 6, 9, 30),
        initialInput: 'a tangled thought',
        intent: 'clarify',
        response: 'a clearer thought',
      );

      final restored = Conversation.fromMap(conversation.toMap());
      expect(restored.timestamp, conversation.timestamp);
      expect(restored.initialInput, 'a tangled thought');
      expect(restored.intent, 'clarify');
      expect(restored.response, 'a clearer thought');
    });

    test('malformed timestamps arrive null instead of throwing (EOM-S9)', () {
      final conversation = Conversation.fromMap({
        'timestamp': 'not-a-date',
        'initialInput': 'x',
        'intent': 'map',
        'response': 'y',
      });
      expect(conversation.timestamp, isNull);
    });

    test('missing fields degrade to empty strings', () {
      final conversation = Conversation.fromMap(<dynamic, dynamic>{});
      expect(conversation.timestamp, isNull);
      expect(conversation.initialInput, '');
      expect(conversation.intent, '');
      expect(conversation.response, '');
    });

    test('null timestamp serialises to an empty string', () {
      const conversation = Conversation(
        timestamp: null,
        initialInput: 'x',
        intent: 'act',
        response: 'y',
      );
      expect(conversation.toMap()['timestamp'], '');
    });
  });
}

import 'package:eom/models/epistemic_operation.dart';
import 'package:eom/models/intent.dart';
import 'package:eom/services/ai_service.dart';
import 'package:eom/services/intent_config.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CognitiveIntentOps.buildPrompt (EOM-S14)', () {
    test('every intent prompt embeds the epilogue marker', () {
      for (final intent in CognitiveIntent.values) {
        expect(
          intent.buildPrompt(AiService.epistemicMarker),
          contains(AiService.epistemicMarker),
        );
      }
    });

    test('each intent prompt carries its epilogue contract', () {
      expect(CognitiveIntent.clarify.buildPrompt('M'), contains('"clarified"'));
      expect(
        CognitiveIntent.compress.buildPrompt('M'),
        contains('"principle"'),
      );
      expect(CognitiveIntent.map.buildPrompt('M'), contains('"relationships"'));
      expect(
        CognitiveIntent.reflect.buildPrompt('M'),
        contains('"contradictions"'),
      );
      expect(CognitiveIntent.act.buildPrompt('M'), contains('"actionable"'));
    });

    test('only map produces a tree', () {
      for (final intent in CognitiveIntent.values) {
        expect(intent.producesTree, intent == CognitiveIntent.map);
      }
    });
  });

  group('CognitiveIntentOps.parseOperation (EOM-S14)', () {
    test('routes each intent to its operation type', () {
      expect(
        CognitiveIntent.clarify.parseOperation({'clarified': 'x'}),
        isA<ClarifyOperation>(),
      );
      expect(
        CognitiveIntent.compress.parseOperation({'principle': 'x'}),
        isA<CompressOperation>(),
      );
      expect(
        CognitiveIntent.map.parseOperation({'label': 'You'}),
        isA<MapOperation>(),
      );
      expect(
        CognitiveIntent.reflect.parseOperation(const {}),
        isA<ReflectOperation>(),
      );
      expect(
        CognitiveIntent.act.parseOperation({'actionable': 'x'}),
        isA<ActOperation>(),
      );
    });

    test('throws FormatException when core content is absent', () {
      expect(
        () => CognitiveIntent.clarify.parseOperation(const {}),
        throwsFormatException,
      );
    });
  });
}

import 'package:eom/models/epistemic_gap.dart';
import 'package:eom/models/epistemic_node.dart';
import 'package:eom/services/epistemic_gap_service.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/in_memory_epistemic_store.dart';

EpistemicNode node(
  String content, {
  EpistemicNodeType type = EpistemicNodeType.belief,
}) => EpistemicNode(content: content, type: type);

void main() {
  late InMemoryStore store;
  late EpistemicGapService service;

  setUp(() {
    store = InMemoryStore();
    service = EpistemicGapService(store);
  });

  group('explicitGaps', () {
    test('returns question and unknown nodes with their IDs', () async {
      final q = node(
        'What do I actually value?',
        type: EpistemicNodeType.question,
      );
      final u = node('How markets clear', type: EpistemicNodeType.unknown);
      store.nodes.addAll([
        q,
        u,
        node('Kindness is fundamental.'),
        node('A hunch about luck', type: EpistemicNodeType.intuition),
      ]);

      final gaps = await service.explicitGaps();
      expect(gaps, hasLength(2));
      expect(
        gaps[0],
        EpistemicGap(
          concept: q.content,
          kind: EpistemicGapKind.question,
          nodeId: q.id,
        ),
      );
      expect(gaps[1].kind, EpistemicGapKind.unknown);
      expect(gaps[1].nodeId, u.id);
    });

    test('is empty when no question or unknown nodes exist', () async {
      store.nodes.add(node('Everything is mapped.'));
      expect(await service.explicitGaps(), isEmpty);
    });
  });

  group('detectGaps', () {
    test('flags concepts with no covering node', () async {
      store.nodes.add(node('Kindness is fundamental.'));
      final gaps = await service.detectGaps(['stoic detachment']);
      expect(gaps.single.kind, EpistemicGapKind.unmappedConcept);
      expect(gaps.single.concept, 'stoic detachment');
      expect(gaps.single.nodeId, isNull);
    });

    test('treats exact content match as covered, case-insensitively', () async {
      store.nodes.add(node('Stoic detachment'));
      expect(await service.detectGaps(['stoic detachment']), isEmpty);
    });

    test('treats a concept contained in an existing node as covered', () async {
      store.nodes.add(node('Stoic detachment from outcomes brings calm.'));
      expect(await service.detectGaps(['stoic detachment']), isEmpty);
    });

    test(
      'does not re-report an articulated question as an unmapped concept',
      () async {
        store.nodes.add(
          node('What is enough?', type: EpistemicNodeType.question),
        );
        expect(await service.detectGaps(['what is enough?']), isEmpty);
      },
    );

    test(
      'dedupes repeats and skips blanks, preserving first-seen order',
      () async {
        final gaps = await service.detectGaps([
          '  ',
          'fate',
          'Fate',
          'luck',
          'luck ',
        ]);
        expect(gaps.map((g) => g.concept), ['fate', 'luck']);
      },
    );
  });
}

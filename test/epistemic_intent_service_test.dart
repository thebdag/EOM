import 'package:eom/models/epistemic_node.dart';
import 'package:eom/models/epistemic_operation.dart';
import 'package:eom/models/epistemic_relationship.dart';
import 'package:eom/services/epistemic_gap_service.dart';
import 'package:eom/services/epistemic_intent_service.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/in_memory_epistemic_store.dart';

void main() {
  late InMemoryStore store;
  late EpistemicIntentService service;

  setUp(() {
    store = InMemoryStore();
    service = EpistemicIntentService(store);
  });

  EpistemicNode seedNode(String content, {ProvenanceSource? source}) {
    final node = EpistemicNode(
      content: content,
      type: EpistemicNodeType.belief,
      provenance: source != null
          ? ProvenanceRecord(source: source, timestamp: DateTime.now())
          : null,
    );
    store.nodes.add(node);
    return node;
  }

  group('processCompress', () {
    test(
      'creates a node with the parsed type, confidence, and category',
      () async {
        final node = await service.processCompress(
          const CompressOperation(
            principle: 'Clarity comes from subtraction.',
            nodeType: 'belief',
            category: 'rational',
            confidence: 0.7,
          ),
        );

        expect(store.nodes, [node]);
        expect(node.content, 'Clarity comes from subtraction.');
        expect(node.type, EpistemicNodeType.belief);
        expect(node.category, EpistemicCategory.rational);
        expect(node.confidence, 0.7);
        expect(node.provenance?.source, ProvenanceSource.reasoning);
      },
    );

    test('falls back to knowledge / null category for unknown names', () async {
      final node = await service.processCompress(
        const CompressOperation(
          principle: 'p',
          nodeType: 'gibberish',
          category: 'nonsense',
        ),
      );

      expect(node.type, EpistemicNodeType.knowledge);
      expect(node.category, isNull);
    });

    test('links keyword-matching nodes as examples of the principle', () async {
      final related = seedNode('My focus drifts when I skip morning walks.');
      seedNode('Unrelated grocery list.');

      final principle = await service.processCompress(
        const CompressOperation(
          principle: 'Attention needs rhythm.',
          keywords: ['focus'],
        ),
      );

      expect(store.edges, hasLength(1));
      final edge = store.edges.single;
      expect(edge.sourceId, related.id);
      expect(edge.targetId, principle.id);
      expect(edge.type, EpistemicRelationshipType.isExampleOf);
    });

    test('matches keywords case-insensitively', () async {
      seedNode('FOCUS is fragile.');

      await service.processCompress(
        const CompressOperation(principle: 'p', keywords: ['focus']),
      );

      expect(store.edges, hasLength(1));
    });

    test(
      'refines prior compress abstractions instead of exemplifying',
      () async {
        final prior = seedNode(
          'Attention needs rhythm.',
          source: ProvenanceSource.reasoning,
        );

        final principle = await service.processCompress(
          const CompressOperation(
            principle: 'All stability is rhythmic.',
            keywords: ['attention'],
          ),
        );

        expect(store.edges, hasLength(1));
        final edge = store.edges.single;
        expect(edge.sourceId, principle.id);
        expect(edge.targetId, prior.id);
        expect(edge.type, EpistemicRelationshipType.refines);
      },
    );

    test('creates no edges when nothing matches', () async {
      seedNode('Completely different topic.');

      await service.processCompress(
        const CompressOperation(principle: 'p', keywords: ['zzz-absent']),
      );

      expect(store.edges, isEmpty);
    });

    test('creates no edges when keywords are empty', () async {
      seedNode('Anything at all.');

      await service.processCompress(const CompressOperation(principle: 'p'));

      expect(store.edges, isEmpty);
    });

    test('never links the principle to itself', () async {
      final node = await service.processCompress(
        const CompressOperation(principle: 'focus', keywords: ['focus']),
      );

      expect(store.nodes, [node]);
      expect(store.edges, isEmpty);
    });

    test('repeat sessions link edges to the persisted node id', () async {
      final related = seedNode('My focus drifts when I skip morning walks.');

      final first = await service.processCompress(
        const CompressOperation(
          principle: 'Attention needs rhythm.',
          keywords: ['focus'],
        ),
      );
      // Repeat session: case-insensitive match merges into the stored row.
      final repeated = await service.processCompress(
        const CompressOperation(
          principle: 'attention NEEDS rhythm.',
          keywords: ['focus'],
        ),
      );

      expect(repeated.id, first.id);
      expect(store.nodes, hasLength(2));
      expect(store.edges, hasLength(2));
      for (final edge in store.edges) {
        expect(await store.get(edge.sourceId), isNotNull);
        expect(await store.get(edge.targetId), isNotNull);
        expect(
          {edge.sourceId, edge.targetId}.contains(related.id),
          isTrue,
          reason: 'every edge should connect the related node',
        );
      }
    });
  });
  group('processClarify', () {
    test('creates a belief node and links keywords', () async {
      seedNode('fuzzy focus');
      final node = await service.processClarify(
        const ClarifyOperation(
          clarified: 'Focus requires clear boundaries.',
          nodeType: 'belief',
          confidence: 0.8,
          keywords: ['focus'],
        ),
      );

      expect(store.nodes.length, 2);
      expect(node.content, 'Focus requires clear boundaries.');
      expect(node.type, EpistemicNodeType.belief);
      expect(node.confidence, 0.8);
      expect(node.provenance?.source, ProvenanceSource.reasoning);

      expect(store.edges, hasLength(1));
      expect(store.edges.single.type, EpistemicRelationshipType.isExampleOf);
    });
  });

  group('processAct', () {
    test('creates a knowledge node and links keywords', () async {
      seedNode('acting on boundaries');
      final node = await service.processAct(
        const ActOperation(
          actionable: 'Set boundaries early.',
          confidence: 0.9,
          keywords: ['boundaries'],
        ),
      );

      expect(node.content, 'Set boundaries early.');
      expect(node.type, EpistemicNodeType.knowledge);
      expect(node.confidence, 0.9);
      expect(store.edges, hasLength(1));
    });
  });

  group('processMap', () {
    test('creates nodes and known edges, skips unknown', () async {
      await service.processMap(
        const MapOperation(
          rootLabel: 'You',
          relationships: [
            MappedRelationship(source: 'A', target: 'B', type: 'supports'),
            MappedRelationship(source: 'B', target: 'C', type: 'unknown_type'),
          ],
        ),
      );

      expect(store.nodes.length, 2);
      for (final n in store.nodes) {
        expect(n.type, EpistemicNodeType.belief);
        expect(n.confidence, 0.3);
      }

      expect(store.edges, hasLength(1));
      expect(store.edges.single.type, EpistemicRelationshipType.supports);
    });

    test(
      'labels differing only by case resolve to one node, no self-loop',
      () async {
        await service.processMap(
          const MapOperation(
            rootLabel: 'You',
            relationships: [
              MappedRelationship(
                source: 'Focus',
                target: 'focus',
                type: 'supports',
              ),
            ],
          ),
        );

        expect(store.nodes, hasLength(1));
        expect(store.edges, isEmpty);
      },
    );
  });

  group('processReflect', () {
    test('upserts statements and links contradictions', () async {
      final existing = seedNode('I always sleep late.');

      await service.processReflect(
        const ReflectOperation(
          contradictions: [
            Contradiction(
              statement: 'I want to wake up early.',
              conflictsWith: 'I always sleep late.',
            ),
          ],
        ),
      );

      expect(store.nodes.length, 2);
      final newStmt = store.nodes.last;
      expect(newStmt.content, 'I want to wake up early.');

      expect(store.edges, hasLength(1));
      expect(store.edges.single.type, EpistemicRelationshipType.contradicts);
      expect(store.edges.single.sourceId, newStmt.id);
      expect(store.edges.single.targetId, existing.id);
    });

    test('skips a statement that contradicts itself', () async {
      await service.processReflect(
        const ReflectOperation(
          contradictions: [
            Contradiction(
              statement: 'I never rest.',
              conflictsWith: 'i NEVER rest.',
            ),
          ],
        ),
      );

      expect(store.nodes, hasLength(1));
      expect(store.edges, isEmpty);
    });
  });

  group('gap detection wiring (EOM-T14)', () {
    late EpistemicIntentService wired;

    setUp(() {
      wired = EpistemicIntentService(
        store,
        gapDetector: EpistemicGapService(store),
      );
    });

    test('is inert when no detector is injected', () async {
      await service.processClarify(
        const ClarifyOperation(
          clarified: 'Clarity needs space.',
          keywords: ['solitude'],
        ),
      );
      expect(service.lastDetectedGaps, isEmpty);
    });

    test('surfaces keywords with no covering node after Clarify', () async {
      seedNode('Stillness restores me.'); // covers "stillness"
      await wired.processClarify(
        const ClarifyOperation(
          clarified: 'Clarity needs space.',
          keywords: ['stillness', 'monastic silence'],
        ),
      );
      expect(wired.lastDetectedGaps.map((g) => g.concept), [
        'monastic silence',
      ]);
    });

    test('surfaces low-confidence statements after Reflect', () async {
      await wired.processReflect(
        const ReflectOperation(lowConfidenceNodes: ['I might be a fraud']),
      );
      expect(wired.lastDetectedGaps.single.concept, 'I might be a fraud');
    });

    test('does not create nodes for detected gaps', () async {
      final before = store.nodes.length;
      await wired.processAct(
        const ActOperation(
          actionable: 'Ship the small thing.',
          keywords: ['unmapped concept'],
        ),
      );
      // Only the actionable node itself was persisted.
      expect(store.nodes.length, before + 1);
      expect(wired.lastDetectedGaps.single.concept, 'unmapped concept');
    });
  });
}

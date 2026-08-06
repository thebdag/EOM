import 'package:eom/models/epistemic_node.dart';
import 'package:eom/models/epistemic_operation.dart';
import 'package:eom/models/epistemic_relationship.dart';
import 'package:eom/services/epistemic_intent_service.dart';
import 'package:eom/services/epistemic_service.dart';
import 'package:flutter_test/flutter_test.dart';

/// In-memory [EpistemicGraphStore] so tests need no SQLite.
class InMemoryStore implements EpistemicGraphStore {
  final List<EpistemicNode> nodes = [];
  final List<EpistemicRelationship> edges = [];

  @override
  Future<EpistemicNode> create(EpistemicNode node) async {
    nodes.add(node);
    return node;
  }

  @override
  Future<List<EpistemicNode>> all() async => List.unmodifiable(nodes);

  @override
  Future<EpistemicRelationship> addRelationship(
    EpistemicRelationship relationship,
  ) async {
    edges.add(relationship);
    return relationship;
  }
}

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
  });
}

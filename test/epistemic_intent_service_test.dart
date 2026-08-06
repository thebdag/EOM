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
  Future<EpistemicNode> upsert(EpistemicNode node) async {
    final lowerContent = node.content.toLowerCase();
    final index = nodes.indexWhere(
      (n) => n.content.toLowerCase() == lowerContent,
    );
    if (index != -1) {
      final existing = nodes[index];
      final merged = existing.copyWith(
        type: node.type,
        confidence: node.confidence,
        category: node.category,
        provenance: node.provenance,
      );
      nodes[index] = merged;
      return merged;
    } else {
      nodes.add(node);
      return node;
    }
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
  });
}

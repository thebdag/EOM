import 'dart:convert';

import 'package:eom/models/epistemic_node.dart';
import 'package:eom/models/epistemic_relationship.dart';
import 'package:eom/services/epistemic_export_service.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/in_memory_epistemic_store.dart';

EpistemicNode node(
  String content, {
  double confidence = 0.5,
  EpistemicNodeType type = EpistemicNodeType.belief,
  EpistemicCategory? category,
}) => EpistemicNode(
  content: content,
  type: type,
  confidence: confidence,
  category: category,
);

void main() {
  late InMemoryStore store;
  late EpistemicExportService exporter;

  setUp(() {
    store = InMemoryStore();
    exporter = EpistemicExportService(store);
  });

  group('toJsonGraph', () {
    test('contains metadata plus every node and edge', () async {
      final a = await store.create(node('A', confidence: 0.9));
      final b = await store.create(node('B'));
      await store.addRelationship(
        EpistemicRelationship(
          sourceId: a.id,
          targetId: b.id,
          type: EpistemicRelationshipType.supports,
        ),
      );

      final graph = await exporter.toJsonGraph();
      expect(graph['version'], 1);
      expect(graph['node_count'], 2);
      expect(graph['edge_count'], 1);
      expect(graph['nodes'], hasLength(2));
      expect(graph['edges'], hasLength(1));
      expect(graph['exported_at'], isA<String>());
    });

    test('round-trips through the model fromJson', () async {
      await store.create(
        node('Kindness matters', category: EpistemicCategory.revelatory),
      );
      final graph = await exporter.toJsonGraph();
      final restored = EpistemicNode.fromJson(
        (graph['nodes'] as List).single as Map<String, dynamic>,
      );
      expect(restored.content, 'Kindness matters');
      expect(restored.category, EpistemicCategory.revelatory);
    });

    test('toJson emits parseable pretty JSON', () async {
      await store.create(node('A'));
      final decoded = jsonDecode(await exporter.toJson());
      expect(decoded['node_count'], 1);
    });
  });

  group('toMarkdown', () {
    test('groups nodes by type, highest confidence first', () async {
      await store.create(node('Weak belief', confidence: 0.2));
      await store.create(node('Strong belief', confidence: 0.9));
      await store.create(
        node('Open question', type: EpistemicNodeType.question),
      );

      final md = await exporter.toMarkdown();
      expect(md, contains('## Beliefs (2)'));
      expect(md, contains('## Questions (1)'));
      expect(md.indexOf('Strong belief'), lessThan(md.indexOf('Weak belief')));
      expect(md, contains('**0.90** — Strong belief'));
    });

    test('omits empty type sections', () async {
      await store.create(node('Only a belief'));
      final md = await exporter.toMarkdown();
      expect(md, isNot(contains('## Hypotheses')));
      expect(md, isNot(contains('## Relationships')));
    });

    test('lists relationships with resolved content snippets', () async {
      final a = await store.create(node('Courage is learnable'));
      final b = await store.create(node('Fear can be faced'));
      await store.addRelationship(
        EpistemicRelationship(
          sourceId: a.id,
          targetId: b.id,
          type: EpistemicRelationshipType.supports,
        ),
      );

      final md = await exporter.toMarkdown();
      expect(
        md,
        contains('- Courage is learnable —supports→ Fear can be faced'),
      );
    });

    test('marks edges pointing at missing nodes', () async {
      final a = await store.create(node('Lone node'));
      store.edges.add(
        EpistemicRelationship(
          sourceId: a.id,
          targetId: 'ghost',
          type: EpistemicRelationshipType.entails,
        ),
      );
      final md = await exporter.toMarkdown();
      expect(md, contains('_(missing node)_'));
    });

    test('annotates category when present', () async {
      await store.create(
        node('Sudden insight', category: EpistemicCategory.revelatory),
      );
      final md = await exporter.toMarkdown();
      expect(md, contains('Sudden insight _(revelatory)_'));
    });
  });
}

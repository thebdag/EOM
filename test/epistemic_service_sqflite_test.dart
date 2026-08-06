import 'package:eom/models/epistemic_node.dart';
import 'package:eom/models/epistemic_relationship.dart';
import 'package:eom/services/epistemic_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

/// Regression tests for EOM-S2: every node write used to throw a
/// DatabaseException because [EpistemicNode.toJson] carries a `relationships`
/// key with no matching column. These tests run against the real
/// sqflite-backed store (via the ffi factory) rather than the in-memory
/// fake, so column drift between the model and the schema cannot hide.
void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  late EpistemicService service;

  setUp(() async {
    final path = '${await getDatabasesPath()}/epistemic.db';
    await databaseFactory.deleteDatabase(path);
    service = EpistemicService();
    await service.init();
  });

  tearDown(() => service.close());

  EpistemicNode sampleNode({
    String content = 'I believe attention is the scarcest resource.',
  }) => EpistemicNode(
    content: content,
    type: EpistemicNodeType.belief,
    confidence: 0.7,
    provenance: ProvenanceRecord(
      source: ProvenanceSource.experience,
      timestamp: DateTime.utc(2026, 8, 6),
    ),
    category: EpistemicCategory.empirical,
  );

  test('create persists a node and round-trips every column', () async {
    final node = sampleNode();
    await service.create(node);

    final loaded = await service.get(node.id);
    expect(loaded, isNotNull);
    expect(loaded!.content, node.content);
    expect(loaded.type, node.type);
    expect(loaded.confidence, closeTo(node.confidence, 1e-9));
    expect(loaded.category, EpistemicCategory.empirical);
    expect(loaded.provenance?.source, ProvenanceSource.experience);
  });

  test('create tolerates a node carrying lazy-loaded relationships', () async {
    final node = EpistemicNode(
      content: 'Relationships attached must not reach sqflite.',
      type: EpistemicNodeType.knowledge,
      relationships: [
        EpistemicRelationship(
          sourceId: 'a',
          targetId: 'b',
          type: EpistemicRelationshipType.refines,
        ),
      ],
    );
    await service.create(node);
    expect((await service.get(node.id))!.content, node.content);
  });

  test('update persists new field values', () async {
    final node = sampleNode();
    await service.create(node);
    await service.update(node.copyWith(confidence: 0.9));

    final loaded = await service.get(node.id);
    expect(loaded!.confidence, closeTo(0.9, 1e-9));
    final history = await service.confidenceHistory(node.id);
    expect(history.map((e) => e.confidence), [0.7, 0.9]);
  });

  test(
    'upsert merges on case-insensitive content and keeps the stored id',
    () async {
      final first = await service.upsert(
        sampleNode(content: 'Deep Work matters'),
      );
      final second = await service.upsert(
        sampleNode(content: 'deep work MATTERS'),
      );
      expect(second.id, first.id);
      expect(await service.all(), hasLength(1));
    },
  );
}

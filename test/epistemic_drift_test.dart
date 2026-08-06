import 'package:eom/models/epistemic_node.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/in_memory_epistemic_store.dart';

EpistemicNode node(String content, {double confidence = 0.5}) => EpistemicNode(
  content: content,
  type: EpistemicNodeType.belief,
  confidence: confidence,
);

void main() {
  late InMemoryStore store;

  setUp(() => store = InMemoryStore());

  group('confidence events', () {
    test('create records a baseline event', () async {
      final n = node('Baseline belief', confidence: 0.6);
      await store.create(n);

      final history = await store.confidenceHistory(n.id);
      expect(history.single.confidence, 0.6);
      expect(history.single.nodeId, n.id);
    });

    test('upsert records an event only when confidence changes', () async {
      await store.upsert(node('Shifting belief', confidence: 0.5));
      await store.upsert(node('Shifting belief', confidence: 0.5)); // no-op
      await store.upsert(node('Shifting belief', confidence: 0.8));

      final history = await store.confidenceHistory(store.nodes.single.id);
      expect(history.map((e) => e.confidence), [0.5, 0.8]);
    });

    test('histories are isolated per node', () async {
      final a = await store.create(node('A', confidence: 0.4));
      final b = await store.create(node('B', confidence: 0.9));

      expect((await store.confidenceHistory(a.id)).single.confidence, 0.4);
      expect((await store.confidenceHistory(b.id)).single.confidence, 0.9);
    });
  });

  group('confidenceDrifts', () {
    test('computes signed movement from baseline to latest', () async {
      await store.upsert(node('Growing conviction', confidence: 0.4));
      await store.upsert(node('Growing conviction', confidence: 0.9));

      final drifts = await store.confidenceDrifts();
      expect(drifts.single.from, 0.4);
      expect(drifts.single.to, 0.9);
      expect(drifts.single.delta, closeTo(0.5, 1e-9));
      expect(drifts.single.eventCount, 2);
    });

    test('excludes nodes with no drift yet', () async {
      await store.create(node('Fresh node', confidence: 0.5));
      expect(await store.confidenceDrifts(), isEmpty);
    });

    test('sorts biggest movers first and honours minAbsDelta', () async {
      await store.upsert(node('Small shift', confidence: 0.5));
      await store.upsert(node('Small shift', confidence: 0.6));
      await store.upsert(node('Big shift', confidence: 0.2));
      await store.upsert(node('Big shift', confidence: 0.9));

      final drifts = await store.confidenceDrifts();
      expect(drifts.first.absDelta, closeTo(0.7, 1e-9));

      final filtered = await store.confidenceDrifts(minAbsDelta: 0.5);
      expect(filtered, hasLength(1));
    });

    test('negative drift reports confidence loss', () async {
      await store.upsert(node('Fading belief', confidence: 0.9));
      await store.upsert(node('Fading belief', confidence: 0.3));

      final drift = (await store.confidenceDrifts()).single;
      expect(drift.delta, closeTo(-0.6, 1e-9));
    });
  });
}

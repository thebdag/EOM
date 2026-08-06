import 'package:eom/models/epistemic_maturity.dart';
import 'package:eom/models/epistemic_node.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/in_memory_epistemic_store.dart';

EpistemicNode node(
  String content, {
  double confidence = 0.5,
  EpistemicCategory? category,
}) => EpistemicNode(
  content: content,
  type: EpistemicNodeType.belief,
  confidence: confidence,
  category: category,
);

void main() {
  group('computeMaturityByDomain', () {
    test('groups nodes by category with uncategorised last', () {
      final result = computeMaturityByDomain([
        node('a', category: EpistemicCategory.empirical),
        node('b', category: EpistemicCategory.rational),
        node('c'), // uncategorised
      ]);
      expect(result.keys.toList(), [
        EpistemicCategory.empirical,
        EpistemicCategory.rational,
        null,
      ]);
    });

    test('omits domains with no nodes', () {
      final result = computeMaturityByDomain([
        node('a', category: EpistemicCategory.intuitive),
      ]);
      expect(result.keys, [EpistemicCategory.intuitive]);
    });

    test('counts high and uncertain nodes at the thresholds', () {
      final result = computeMaturityByDomain([
        node('certain', confidence: 0.7, category: EpistemicCategory.rational),
        node(
          'confident',
          confidence: 0.9,
          category: EpistemicCategory.rational,
        ),
        node(
          'doubtful',
          confidence: 0.39,
          category: EpistemicCategory.rational,
        ),
        node('neutral', confidence: 0.5, category: EpistemicCategory.rational),
      ]);
      final m = result[EpistemicCategory.rational]!;
      expect(m.total, 4);
      expect(m.highConfidence, 2);
      expect(m.uncertain, 1);
    });
  });

  group('EpistemicMaturity.score', () {
    test('is high / (high + uncertain)', () {
      const m = EpistemicMaturity(
        domain: EpistemicCategory.empirical,
        total: 5,
        highConfidence: 3,
        uncertain: 1,
      );
      expect(m.score, 0.75);
    });

    test('excludes the neutral band from the ratio', () {
      const m = EpistemicMaturity(
        domain: EpistemicCategory.empirical,
        total: 10,
        highConfidence: 1,
        uncertain: 1,
      );
      expect(m.score, 0.5);
    });

    test('is null when there are no decided nodes', () {
      const m = EpistemicMaturity(
        domain: EpistemicCategory.empirical,
        total: 3,
        highConfidence: 0,
        uncertain: 0,
      );
      expect(m.score, isNull);
    });
  });

  group('store.maturityByDomain', () {
    test('aggregates the in-memory graph', () async {
      final store = InMemoryStore();
      store.nodes.addAll([
        node(
          'seen truth',
          confidence: 0.9,
          category: EpistemicCategory.empirical,
        ),
        node(
          'felt doubt',
          confidence: 0.2,
          category: EpistemicCategory.intuitive,
        ),
        node('unfiled', confidence: 0.8),
      ]);

      final result = await store.maturityByDomain();
      expect(result[EpistemicCategory.empirical]!.score, 1.0);
      expect(result[EpistemicCategory.intuitive]!.score, 0.0);
      expect(result[null]!.highConfidence, 1);
    });
  });
}

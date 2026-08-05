import 'package:flutter_test/flutter_test.dart';
import 'package:eom/models/epistemic_node.dart';

void main() {
  // ── epistemicCategoryFromString ─────────────────────────────────────────────

  group('epistemicCategoryFromString', () {
    test('round-trips every valid category name', () {
      for (final cat in EpistemicCategory.values) {
        expect(epistemicCategoryFromString(cat.name), cat);
      }
    });

    test('throws ArgumentError for unknown category string', () {
      expect(
        () => epistemicCategoryFromString('nonsense'),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('is case-sensitive — "Empirical" is not valid', () {
      expect(
        () => epistemicCategoryFromString('Empirical'),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('parses each category to its correct enum value', () {
      expect(
        epistemicCategoryFromString('empirical'),
        EpistemicCategory.empirical,
      );
      expect(
        epistemicCategoryFromString('rational'),
        EpistemicCategory.rational,
      );
      expect(
        epistemicCategoryFromString('intuitive'),
        EpistemicCategory.intuitive,
      );
      expect(
        epistemicCategoryFromString('abductive'),
        EpistemicCategory.abductive,
      );
      expect(
        epistemicCategoryFromString('revelatory'),
        EpistemicCategory.revelatory,
      );
    });
  });

  // ── EpistemicNode.category field ────────────────────────────────────────────

  group('EpistemicNode category field', () {
    test('defaults to null when not supplied', () {
      final node = EpistemicNode(
        content: 'unclassified belief',
        type: EpistemicNodeType.belief,
      );
      expect(node.category, isNull);
    });

    test('accepts an explicit EpistemicCategory', () {
      for (final cat in EpistemicCategory.values) {
        final node = EpistemicNode(
          content: 'categorised node',
          type: EpistemicNodeType.knowledge,
          category: cat,
        );
        expect(node.category, cat);
      }
    });
  });

  // ── toJson / fromJson ───────────────────────────────────────────────────────

  group('toJson / fromJson with category', () {
    test('serialises category as its name string', () {
      final node = EpistemicNode(
        content: 'x',
        type: EpistemicNodeType.belief,
        category: EpistemicCategory.rational,
      );
      expect(node.toJson()['category'], 'rational');
    });

    test('serialises null category as null', () {
      final node = EpistemicNode(content: 'x', type: EpistemicNodeType.belief);
      expect(node.toJson()['category'], isNull);
    });

    test('round-trips all five categories', () {
      for (final cat in EpistemicCategory.values) {
        final original = EpistemicNode(
          id: 'cat-${cat.name}',
          content: 'content for ${cat.name}',
          type: EpistemicNodeType.hypothesis,
          confidence: 0.6,
          createdAt: DateTime(2026, 1, 1),
          updatedAt: DateTime(2026, 1, 2),
          category: cat,
        );
        final roundTripped = EpistemicNode.fromJson(original.toJson());

        expect(roundTripped.id, original.id);
        expect(roundTripped.category, original.category);
      }
    });

    test('round-trips null category', () {
      final original = EpistemicNode(
        id: 'no-cat',
        content: 'no category set',
        type: EpistemicNodeType.question,
        createdAt: DateTime(2026, 3, 1),
        updatedAt: DateTime(2026, 3, 2),
      );
      final roundTripped = EpistemicNode.fromJson(original.toJson());
      expect(roundTripped.category, isNull);
    });

    test('fromJson throws ArgumentError for invalid category string', () {
      final bad = {
        'id': 'x',
        'content': 'c',
        'type': 'belief',
        'confidence': 0.5,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
        'source_type': null,
        'source_timestamp': null,
        'category': 'INVALID_CATEGORY',
      };
      expect(() => EpistemicNode.fromJson(bad), throwsA(isA<ArgumentError>()));
    });
  });

  // ── copyWith ────────────────────────────────────────────────────────────────

  group('copyWith with category', () {
    final base = EpistemicNode(
      id: 'base',
      content: 'original',
      type: EpistemicNodeType.belief,
      category: EpistemicCategory.empirical,
      createdAt: DateTime(2026),
    );

    test('preserves category when not specified', () {
      final copy = base.copyWith(content: 'changed');
      expect(copy.category, EpistemicCategory.empirical);
    });

    test('replaces category when specified', () {
      final copy = base.copyWith(category: EpistemicCategory.abductive);
      expect(copy.category, EpistemicCategory.abductive);
      expect(copy.content, base.content); // other fields unchanged
    });

    test('copyWith on a null-category node preserves null', () {
      final uncategorised = EpistemicNode(
        id: 'no-cat',
        content: 'test',
        type: EpistemicNodeType.unknown,
      );
      final copy = uncategorised.copyWith(content: 'updated');
      expect(copy.category, isNull);
    });
  });

  // ── toString ────────────────────────────────────────────────────────────────

  group('toString includes category', () {
    test('includes category name when set', () {
      final node = EpistemicNode(
        content: 'c',
        type: EpistemicNodeType.belief,
        category: EpistemicCategory.revelatory,
      );
      expect(node.toString(), contains('revelatory'));
    });

    test('includes "null" when category is not set', () {
      final node = EpistemicNode(content: 'c', type: EpistemicNodeType.belief);
      expect(node.toString(), contains('null'));
    });
  });
}

import 'package:eom/models/epistemic_node.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('EpistemicCategory', () {
    test('fromString parses valid categories', () {
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

    test('fromString throws on invalid category', () {
      expect(() => epistemicCategoryFromString('magic'), throwsArgumentError);
    });
  });

  group('EpistemicNode category integration', () {
    test('category defaults to null', () {
      final node = EpistemicNode(
        content: 'Test content',
        type: EpistemicNodeType.belief,
      );

      expect(node.category, isNull);
    });

    test('category is preserved through copyWith', () {
      final node = EpistemicNode(
        content: 'Test content',
        type: EpistemicNodeType.belief,
        category: EpistemicCategory.empirical,
      );

      final copy = node.copyWith(content: 'New content');
      expect(copy.category, EpistemicCategory.empirical);

      final copy2 = node.copyWith(category: EpistemicCategory.rational);
      expect(copy2.category, EpistemicCategory.rational);
    });

    test('category is preserved through JSON round-trip', () {
      final node = EpistemicNode(
        content: 'Test content',
        type: EpistemicNodeType.knowledge,
        category: EpistemicCategory.revelatory,
      );

      final json = node.toJson();
      final restored = EpistemicNode.fromJson(json);

      expect(restored.category, EpistemicCategory.revelatory);
    });
  });
}

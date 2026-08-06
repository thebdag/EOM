import 'package:flutter_test/flutter_test.dart';
import 'package:eom/models/thought_node.dart';

void main() {
  group('ThoughtNode', () {
    test('initialization', () {
      final node = ThoughtNode(label: 'Root');
      expect(node.label, 'Root');
      expect(node.children, isEmpty);
      expect(node.isExpanded, isTrue);
    });

    test('descendantCount', () {
      final child = ThoughtNode(label: 'Child');
      final root = ThoughtNode(label: 'Root', children: [child]);
      expect(root.descendantCount, 1);

      final grandchild = ThoughtNode(label: 'Grandchild');
      child.children.add(grandchild);
      expect(root.descendantCount, 2);
    });

    test('toJson and fromJson', () {
      final node = ThoughtNode(label: 'Test');
      final json = node.toJson();
      final decoded = ThoughtNode.fromJson(json);
      expect(decoded.label, 'Test');
    });

    group('fromJson tolerance (EOM-S14)', () {
      test('defaults a missing label and missing children', () {
        final node = ThoughtNode.fromJson(const {});
        expect(node.label, 'Node');
        expect(node.children, isEmpty);
      });

      test('decodes children recursively', () {
        final node = ThoughtNode.fromJson({
          'label': 'Root',
          'children': [
            {
              'label': 'Child',
              'children': [
                {'label': 'Grandchild'},
              ],
            },
          ],
        });
        expect(node.descendantCount, 2);
        expect(node.children.single.children.single.label, 'Grandchild');
      });

      test('throws on structurally wrong children so callers can degrade', () {
        expect(
          () => ThoughtNode.fromJson({'children': 'not-a-list'}),
          throwsA(isA<TypeError>()),
        );
        expect(
          () => ThoughtNode.fromJson({
            'children': ['just a string'],
          }),
          throwsA(isA<TypeError>()),
        );
      });
    });

    group('tryParseRaw (EOM-S14)', () {
      test('parses a bare JSON tree', () {
        final tree = ThoughtNode.tryParseRaw('{"label": "You"}');
        expect(tree, isNotNull);
        expect(tree!.label, 'You');
      });

      test('strips markdown fences', () {
        final tree = ThoughtNode.tryParseRaw('```json\n{"label": "You"}\n```');
        expect(tree, isNotNull);
        expect(tree!.label, 'You');
      });

      test('returns null for non-JSON and non-object JSON', () {
        expect(ThoughtNode.tryParseRaw('total garbage'), isNull);
        expect(ThoughtNode.tryParseRaw('[1, 2, 3]'), isNull);
      });
    });
  });
}

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
      final root = ThoughtNode(
        label: 'Root',
        children: [child],
      );
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
  });
}

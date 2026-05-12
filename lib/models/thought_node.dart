/// A node in the thought-map tree.
class ThoughtNode {
  ThoughtNode({
    required this.label,
    this.children = const [],
    this.isExpanded = true,
  });

  final String label;
  final List<ThoughtNode> children;
  bool isExpanded;

  bool get isLeaf => children.isEmpty;

  /// Total descendant count (recursive).
  int get descendantCount {
    int count = children.length;
    for (final child in children) {
      count += child.descendantCount;
    }
    return count;
  }
}

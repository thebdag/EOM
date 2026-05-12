/// A node in the thought-map tree.
class ThoughtNode {
  ThoughtNode({
    required this.label,
    List<ThoughtNode>? children,
    this.isExpanded = true,
  }) : children = children ?? [];

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

  Map<String, dynamic> toJson() => {
        'label': label,
        'children': children.map((c) => c.toJson()).toList(),
        'isExpanded': isExpanded,
      };

  factory ThoughtNode.fromJson(Map<String, dynamic> json) => ThoughtNode(
        label: json['label'] as String,
        children: (json['children'] as List<dynamic>?)
            ?.map((e) => ThoughtNode.fromJson(e as Map<String, dynamic>))
            .toList(),
        isExpanded: json['isExpanded'] as bool? ?? true,
      );
}

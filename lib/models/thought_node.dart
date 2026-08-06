import 'dart:convert';

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

  /// Recursive decoder shared by the tree view and the Map intent's
  /// response parsing (EOM-S14). Tolerant of a missing `label`; throws on
  /// structurally wrong children so callers can degrade to prose.
  factory ThoughtNode.fromJson(Map<String, dynamic> json) => ThoughtNode(
    label: json['label'] as String? ?? 'Node',
    children: (json['children'] as List<dynamic>? ?? [])
        .map((e) => ThoughtNode.fromJson(e as Map<String, dynamic>))
        .toList(),
    isExpanded: json['isExpanded'] as bool? ?? true,
  );

  /// Parses a raw LLM body — possibly wrapped in markdown fences — into a
  /// tree. Returns null when the body is not a JSON object (the pre-T8
  /// pure-JSON fallback in `AiService`).
  static ThoughtNode? tryParseRaw(String raw) {
    try {
      final cleaned = raw
          .replaceAll('```json', '')
          .replaceAll('```', '')
          .trim();
      return ThoughtNode.fromJson(jsonDecode(cleaned) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }
}

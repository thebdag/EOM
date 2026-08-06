import 'dart:convert';

import '../models/epistemic_node.dart';
import 'epistemic_service.dart';

/// Read surface for epistemic-map export (EOM-T19).
abstract class EpistemicExporter {
  /// The full graph as a JSON-encodable structure.
  Future<Map<String, dynamic>> toJsonGraph();

  /// The full graph as pretty-printed JSON.
  Future<String> toJson();

  /// The full graph as a human-readable Markdown document.
  Future<String> toMarkdown();
}

/// Exports the entire epistemic map for external use (EOM-T19).
///
/// Two formats:
/// - **JSON** — full fidelity: every node and edge with all fields, plus
///   export metadata. Suitable for backup or re-import.
/// - **Markdown** — readable summary: nodes grouped by type (confidence
///   shown, highest first), then a relationship listing with endpoints
///   resolved to content snippets.
class EpistemicExportService implements EpistemicExporter {
  EpistemicExportService(this._store);

  final EpistemicGraphStore _store;

  /// Bump when the JSON structure changes incompatibly.
  static const exportVersion = 1;

  @override
  Future<Map<String, dynamic>> toJsonGraph() async {
    final nodes = await _store.all();
    final edges = await _store.allRelationships();
    return {
      'version': exportVersion,
      'exported_at': DateTime.now().toIso8601String(),
      'node_count': nodes.length,
      'edge_count': edges.length,
      'nodes': nodes.map((n) => n.toJson()).toList(),
      'edges': edges.map((e) => e.toJson()).toList(),
    };
  }

  @override
  Future<String> toJson() async =>
      const JsonEncoder.withIndent('  ').convert(await toJsonGraph());

  @override
  Future<String> toMarkdown() async {
    final nodes = await _store.all();
    final edges = await _store.allRelationships();
    final contentById = {for (final n in nodes) n.id: n.content};

    final buffer = StringBuffer()
      ..writeln('# Epistemic Map')
      ..writeln()
      ..writeln(
        'Exported ${DateTime.now().toIso8601String()} — '
        '${nodes.length} nodes, ${edges.length} relationships.',
      )
      ..writeln();

    for (final type in EpistemicNodeType.values) {
      final ofType = nodes.where((n) => n.type == type).toList()
        ..sort((a, b) => b.confidence.compareTo(a.confidence));
      if (ofType.isEmpty) continue;
      buffer
        ..writeln('## ${_typeHeading(type)} (${ofType.length})')
        ..writeln();
      for (final n in ofType) {
        final category = n.category != null ? ' _(${n.category!.name})_' : '';
        buffer.writeln(
          '- **${n.confidence.toStringAsFixed(2)}** — ${n.content}$category',
        );
      }
      buffer.writeln();
    }

    if (edges.isNotEmpty) {
      buffer
        ..writeln('## Relationships (${edges.length})')
        ..writeln();
      for (final e in edges) {
        buffer.writeln(
          '- ${_snippet(contentById[e.sourceId])} '
          '—${e.type.name}→ '
          '${_snippet(contentById[e.targetId])}',
        );
      }
    }

    return buffer.toString().trimRight();
  }

  /// Explicit per-type headings — naive pluralisation produced
  /// "Hypothesiss" and "Knowledges" (EOM-S9).
  static const _typeHeadings = {
    EpistemicNodeType.belief: 'Beliefs',
    EpistemicNodeType.knowledge: 'Knowledge',
    EpistemicNodeType.hypothesis: 'Hypotheses',
    EpistemicNodeType.intuition: 'Intuitions',
    EpistemicNodeType.question: 'Questions',
    EpistemicNodeType.unknown: 'Unknowns',
  };

  static String _typeHeading(EpistemicNodeType type) => _typeHeadings[type]!;

  static String _snippet(String? content, {int max = 60}) {
    if (content == null) return '_(missing node)_';
    if (content.length <= max) return content;
    return '${content.substring(0, max - 1)}…';
  }
}

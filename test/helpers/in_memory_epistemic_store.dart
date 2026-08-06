import 'package:eom/models/epistemic_node.dart';
import 'package:eom/models/epistemic_relationship.dart';
import 'package:eom/services/epistemic_service.dart';

/// In-memory [EpistemicGraphStore] so tests need no SQLite.
///
/// `search` approximates FTS with case-insensitive substring matching —
/// sufficient for traversal/query-semantics tests that run without a real
/// database. FTS ranking itself is covered by the sanitiser unit tests.
class InMemoryStore extends EpistemicGraphStore {
  final List<EpistemicNode> nodes = [];
  final List<EpistemicRelationship> edges = [];

  @override
  Future<EpistemicNode> create(EpistemicNode node) async {
    nodes.add(node);
    return node;
  }

  @override
  Future<EpistemicNode> upsert(EpistemicNode node) async {
    final lowerContent = node.content.toLowerCase();
    final index = nodes.indexWhere(
      (n) => n.content.toLowerCase() == lowerContent,
    );
    if (index != -1) {
      final existing = nodes[index];
      final merged = existing.copyWith(
        type: node.type,
        confidence: node.confidence,
        category: node.category,
        provenance: node.provenance,
      );
      nodes[index] = merged;
      return merged;
    } else {
      nodes.add(node);
      return node;
    }
  }

  @override
  Future<EpistemicNode?> get(String id) async {
    for (final node in nodes) {
      if (node.id == id) return node;
    }
    return null;
  }

  @override
  Future<List<EpistemicNode>> all() async => List.unmodifiable(nodes);

  @override
  Future<List<EpistemicNode>> byType(EpistemicNodeType type) async =>
      nodes.where((n) => n.type == type).toList();

  @override
  Future<EpistemicRelationship> addRelationship(
    EpistemicRelationship relationship,
  ) async {
    edges.add(relationship);
    return relationship;
  }

  @override
  Future<List<EpistemicRelationship>> getRelationshipsForNode(
    String nodeId,
  ) async {
    return edges
        .where((e) => e.sourceId == nodeId || e.targetId == nodeId)
        .toList();
  }

  @override
  Future<List<EpistemicNode>> search(String query) async {
    final lower = query.toLowerCase();
    return nodes.where((n) => n.content.toLowerCase().contains(lower)).toList();
  }
}

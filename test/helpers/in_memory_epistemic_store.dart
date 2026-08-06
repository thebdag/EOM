import 'package:eom/models/confidence_event.dart';
import 'package:eom/models/epistemic_node.dart';
import 'package:eom/models/epistemic_relationship.dart';
import 'package:eom/services/sqlite_epistemic_graph_store.dart';

/// In-memory [EpistemicGraphStore] so tests need no SQLite.
///
/// `search` approximates FTS with case-insensitive substring matching —
/// sufficient for traversal/query-semantics tests that run without a real
/// database. FTS ranking itself is covered by the sanitiser unit tests.
class InMemoryStore extends EpistemicGraphStore {
  final List<EpistemicNode> nodes = [];
  final List<EpistemicRelationship> edges = [];
  final List<ConfidenceEvent> confidenceEvents = [];

  @override
  Future<EpistemicNode> create(EpistemicNode node) async {
    nodes.add(node);
    confidenceEvents.add(
      ConfidenceEvent(nodeId: node.id, confidence: node.confidence),
    );
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
      if (merged.confidence != existing.confidence) {
        confidenceEvents.add(
          ConfidenceEvent(nodeId: merged.id, confidence: merged.confidence),
        );
      }
      return merged;
    } else {
      nodes.add(node);
      confidenceEvents.add(
        ConfidenceEvent(nodeId: node.id, confidence: node.confidence),
      );
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
  Future<List<EpistemicRelationship>> allRelationships() async =>
      List.unmodifiable(edges);

  @override
  Future<List<EpistemicRelationship>> getRelationshipsForNode(
    String nodeId,
  ) async {
    return edges
        .where((e) => e.sourceId == nodeId || e.targetId == nodeId)
        .toList();
  }

  @override
  Future<List<ConfidenceEvent>> confidenceHistory(String nodeId) async =>
      confidenceEvents.where((e) => e.nodeId == nodeId).toList();

  @override
  Future<List<EpistemicNode>> search(String query) async {
    final lower = query.toLowerCase();
    return nodes.where((n) => n.content.toLowerCase().contains(lower)).toList();
  }
}

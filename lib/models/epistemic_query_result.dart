import 'epistemic_node.dart';
import 'epistemic_relationship.dart';

/// The outcome of a graph traversal rooted at a single node (EOM-T17).
///
/// Returned by `EpistemicGraphStore.traverse`. [nodes] are in breadth-first
/// order with the root first; [edges] are the unique relationships
/// encountered while expanding the frontier.
class EpistemicQueryResult {
  const EpistemicQueryResult({
    required this.rootId,
    required this.nodes,
    required this.edges,
  });

  /// The node ID the traversal started from.
  final String rootId;

  /// Nodes reached, in BFS order (root first, if it exists).
  final List<EpistemicNode> nodes;

  /// Unique relationships encountered during traversal.
  final List<EpistemicRelationship> edges;

  bool get isEmpty => nodes.isEmpty;

  @override
  String toString() =>
      'EpistemicQueryResult(rootId: $rootId, nodes: ${nodes.length}, edges: ${edges.length})';
}

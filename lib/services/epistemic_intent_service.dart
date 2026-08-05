import '../models/compress_result.dart';
import '../models/epistemic_node.dart';
import '../models/epistemic_relationship.dart';
import 'epistemic_service.dart';

/// Bridges intent responses to the epistemic graph (EOM-T7).
///
/// Keeps [AiService] focused on LLM interaction and [EpistemicService]
/// focused on storage. Future intents (EOM-T8 through T10) add their own
/// `process*` methods here.
class EpistemicIntentService {
  EpistemicIntentService(this._store);

  final EpistemicGraphStore _store;

  /// Persists the abstracted principle from a Compress operation and links
  /// it to related existing nodes.
  ///
  /// Creates one [EpistemicNode] for the principle, then scans existing
  /// nodes for keyword overlap:
  ///
  /// - Related nodes produced by an earlier Compress (provenance
  ///   [ProvenanceSource.reasoning]) are *refined by* the new principle
  ///   (`refines` edge: principle → related).
  /// - All other related nodes are *examples of* the new principle
  ///   (`isExampleOf` edge: related → principle).
  ///
  /// Returns the created principle node. Storage errors propagate to the
  /// caller, which is expected to treat persistence as non-blocking.
  Future<EpistemicNode> processCompressResult(CompressResult result) async {
    final principle = EpistemicNode(
      content: result.principle,
      type: _parseNodeType(result.nodeType),
      confidence: result.confidence,
      category: _parseCategory(result.category),
      provenance: ProvenanceRecord(
        source: ProvenanceSource.reasoning,
        timestamp: DateTime.now(),
      ),
    );
    await _store.create(principle);

    final keywords = result.keywords.map((k) => k.toLowerCase()).toSet();
    if (keywords.isEmpty) return principle;

    final existing = await _store.all();
    for (final other in existing) {
      if (other.id == principle.id) continue;
      if (!_hasOverlap(other.content, keywords)) continue;

      final isPriorAbstraction =
          other.provenance?.source == ProvenanceSource.reasoning;
      await _store.addRelationship(
        EpistemicRelationship(
          sourceId: isPriorAbstraction ? principle.id : other.id,
          targetId: isPriorAbstraction ? other.id : principle.id,
          type: isPriorAbstraction
              ? EpistemicRelationshipType.refines
              : EpistemicRelationshipType.isExampleOf,
        ),
      );
    }

    return principle;
  }

  /// Whole-word, case-insensitive keyword match against node content.
  bool _hasOverlap(String content, Set<String> keywords) {
    final lower = content.toLowerCase();
    return keywords.any((k) => lower.contains(k));
  }

  EpistemicNodeType _parseNodeType(String value) {
    try {
      return epistemicNodeTypeFromString(value);
    } on ArgumentError {
      return EpistemicNodeType.knowledge;
    }
  }

  EpistemicCategory? _parseCategory(String? value) {
    if (value == null) return null;
    try {
      return epistemicCategoryFromString(value);
    } on ArgumentError {
      return null;
    }
  }
}

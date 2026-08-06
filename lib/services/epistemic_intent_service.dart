import '../models/epistemic_gap.dart';
import '../models/epistemic_node.dart';
import '../models/epistemic_operation.dart';
import '../models/epistemic_relationship.dart';
import 'epistemic_gap_service.dart';
import 'sqlite_epistemic_graph_store.dart';

/// Bridges intent responses to the epistemic graph (EOM-T7, EOM-T11).
///
/// Keeps [AiService] focused on LLM interaction and [SqliteEpistemicGraphStore]
/// focused on storage. Every thought session upserts the nodes derived
/// from its operation; repeat sessions merge into existing nodes rather
/// than duplicating them.
///
/// When an [EpistemicGapDetector] is supplied (EOM-T14), each session also
/// scans its surfaced concepts (keywords, low-confidence statements) for
/// gaps and exposes them via [lastDetectedGaps] — read-only surfacing; no
/// nodes are created for gaps.
class EpistemicIntentService {
  EpistemicIntentService(this._store, {EpistemicGapDetector? gapDetector})
    : _gapDetector = gapDetector;

  final EpistemicGraphStore _store;
  final EpistemicGapDetector? _gapDetector;

  List<EpistemicGap> _lastGaps = const [];

  /// Gaps detected while persisting the most recent session (EOM-T14).
  ///
  /// Empty when no detector is injected or the last session surfaced no
  /// unmapped concepts.
  List<EpistemicGap> get lastDetectedGaps => _lastGaps;

  Future<void> _detectGaps(Iterable<String> concepts) async {
    final detector = _gapDetector;
    if (detector == null) return;
    _lastGaps = await detector.detectGaps(concepts);
  }

  /// Shared skeleton of processCompress/processClarify/processAct
  /// (EOM-S13): build the derived node, upsert it, link keyword-overlapping
  /// nodes, then scan the surfaced concepts for gaps.
  Future<EpistemicNode> _persistDerivedNode({
    required String content,
    required EpistemicNodeType type,
    required double confidence,
    EpistemicCategory? category,
    required List<String> keywords,
  }) async {
    final node = EpistemicNode(
      content: content,
      type: type,
      confidence: confidence,
      category: category,
      provenance: ProvenanceRecord(
        source: ProvenanceSource.reasoning,
        timestamp: DateTime.now(),
      ),
    );
    final saved = await _store.upsert(node);
    await _linkKeywords(saved, keywords);
    await _detectGaps(keywords);
    return saved;
  }

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
  /// Returns the upserted principle node. Storage errors propagate to the
  /// caller, which is expected to treat persistence as non-blocking.
  Future<EpistemicNode> processCompress(CompressOperation operation) {
    return _persistDerivedNode(
      content: operation.principle,
      type: _parseNodeType(operation.nodeType),
      confidence: operation.confidence,
      category: _parseCategory(operation.category),
      keywords: operation.keywords,
    );
  }

  Future<void> _linkKeywords(
    EpistemicNode node,
    List<String> keywordsRaw,
  ) async {
    final keywords = keywordsRaw.map((k) => k.toLowerCase()).toSet();
    if (keywords.isEmpty) return;

    final existing = await _store.all();
    for (final other in existing) {
      if (other.id == node.id) continue;
      if (!_hasOverlap(other.content, keywords)) continue;

      final isPriorAbstraction =
          other.provenance?.source == ProvenanceSource.reasoning;
      await _store.addRelationship(
        EpistemicRelationship(
          sourceId: isPriorAbstraction ? node.id : other.id,
          targetId: isPriorAbstraction ? other.id : node.id,
          type: isPriorAbstraction
              ? EpistemicRelationshipType.refines
              : EpistemicRelationshipType.isExampleOf,
        ),
      );
    }
  }

  Future<EpistemicNode> processClarify(ClarifyOperation operation) {
    return _persistDerivedNode(
      content: operation.clarified,
      type: _parseNodeType(operation.nodeType),
      confidence: operation.confidence,
      category: _parseCategory(operation.category),
      keywords: operation.keywords,
    );
  }

  Future<EpistemicNode> processAct(ActOperation operation) {
    return _persistDerivedNode(
      content: operation.actionable,
      type: EpistemicNodeType.knowledge,
      confidence: operation.confidence,
      keywords: operation.keywords,
    );
  }

  Future<void> processMap(MapOperation operation) async {
    final nodesByLabel = <String, EpistemicNode>{};

    Future<EpistemicNode> getOrCreateNode(String label) async {
      // upsert matches content case-insensitively, so the identity map must
      // too — otherwise "Focus"/"focus" resolve to one stored row and
      // produce self-loop edges (EOM-S7).
      final key = label.toLowerCase();
      if (nodesByLabel.containsKey(key)) return nodesByLabel[key]!;
      final node = EpistemicNode(
        content: label,
        type: EpistemicNodeType.belief,
        confidence: 0.3,
        provenance: ProvenanceRecord(
          source: ProvenanceSource.reasoning,
          timestamp: DateTime.now(),
        ),
      );
      final saved = await _store.upsert(node);
      nodesByLabel[key] = saved;
      return saved;
    }

    for (final rel in operation.relationships) {
      final type = epistemicRelationshipTypeTryParse(rel.type);
      if (type == null) continue;

      final sourceNode = await getOrCreateNode(rel.source);
      final targetNode = await getOrCreateNode(rel.target);
      if (sourceNode.id == targetNode.id) continue;

      await _store.addRelationship(
        EpistemicRelationship(
          sourceId: sourceNode.id,
          targetId: targetNode.id,
          type: type,
        ),
      );
    }
  }

  Future<void> processReflect(ReflectOperation operation) async {
    for (final contradiction in operation.contradictions) {
      final statementNode = EpistemicNode(
        content: contradiction.statement,
        type: EpistemicNodeType.belief,
        confidence: 0.5,
        provenance: ProvenanceRecord(
          source: ProvenanceSource.reasoning,
          timestamp: DateTime.now(),
        ),
      );
      final savedStatement = await _store.upsert(statementNode);

      if (contradiction.conflictsWith.isNotEmpty) {
        final lowerConflictsWith = contradiction.conflictsWith.toLowerCase();
        final existing = await _store.all();
        for (final other in existing) {
          if (other.id == savedStatement.id) continue;
          if (other.content.toLowerCase() == lowerConflictsWith) {
            await _store.addRelationship(
              EpistemicRelationship(
                sourceId: savedStatement.id,
                targetId: other.id,
                type: EpistemicRelationshipType.contradicts,
              ),
            );
            break;
          }
        }
      }
    }
    await _detectGaps(operation.lowConfidenceNodes);
  }

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

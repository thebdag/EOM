import '../models/epistemic_gap.dart';
import '../models/epistemic_node.dart';
import 'sqlite_epistemic_graph_store.dart';

/// Read surface for epistemic gap detection (EOM-T14). Implemented by
/// [EpistemicGapService]; fakeable via [EpistemicGraphStore] test doubles.
abstract class EpistemicGapDetector {
  /// Gaps the user has already articulated: `question` and `unknown` nodes.
  Future<List<EpistemicGap>> explicitGaps();

  /// Concepts from [concepts] that have no covering node in the graph.
  Future<List<EpistemicGap>> detectGaps(Iterable<String> concepts);
}

/// Detects what the user does not yet have a node for (EOM-T14).
///
/// Two gap sources:
/// 1. **Explicit** — nodes typed `question` or `unknown`; the user said the
///    gap out loud.
/// 2. **Inferred** — concept labels surfaced by intent sessions (keywords,
///    `lowConfidenceNodes`, relationship endpoints) that match nothing in
///    the graph. Coverage is decided by exact content match first, then by
///    `EpistemicGraphStore.search` (FTS-backed in production, substring in
///    test fakes).
class EpistemicGapService implements EpistemicGapDetector {
  EpistemicGapService(this._store);

  final EpistemicGraphStore _store;

  @override
  Future<List<EpistemicGap>> explicitGaps() async {
    final questions = await _store.byType(EpistemicNodeType.question);
    final unknowns = await _store.byType(EpistemicNodeType.unknown);
    return [
      for (final n in questions)
        EpistemicGap(
          concept: n.content,
          kind: EpistemicGapKind.question,
          nodeId: n.id,
        ),
      for (final n in unknowns)
        EpistemicGap(
          concept: n.content,
          kind: EpistemicGapKind.unknown,
          nodeId: n.id,
        ),
    ];
  }

  /// Returns the subset of [concepts] with no covering node.
  ///
  /// A concept is *covered* when an existing node's content equals it or
  /// contains it (case-insensitive), or when the concept contains an
  /// existing node's content. Blank and duplicate concepts are skipped;
  /// gaps are returned in first-seen order.
  @override
  Future<List<EpistemicGap>> detectGaps(Iterable<String> concepts) async {
    final gaps = <EpistemicGap>[];
    final seen = <String>{};

    for (final raw in concepts) {
      final concept = raw.trim();
      if (concept.isEmpty) continue;
      final key = concept.toLowerCase();
      if (!seen.add(key)) continue;

      if (await _isCovered(concept)) continue;

      gaps.add(
        EpistemicGap(concept: concept, kind: EpistemicGapKind.unmappedConcept),
      );
    }
    return gaps;
  }

  Future<bool> _isCovered(String concept) async {
    final lower = concept.toLowerCase();
    for (final hit in await _store.search(concept)) {
      final content = hit.content.toLowerCase();
      if (content == lower ||
          content.contains(lower) ||
          lower.contains(content)) {
        return true;
      }
    }
    // FTS can miss short or punctuation-only labels — fall back to an exact
    // content scan so an articulated question/unknown never double-reports.
    for (final node in await _store.all()) {
      if (node.content.toLowerCase() == lower) return true;
    }
    return false;
  }
}

/// The kind of epistemic gap (EOM-T14).
///
/// - [question] — an open inquiry the user has already articulated.
/// - [unknown] — an acknowledged blind spot.
/// - [unmappedConcept] — a concept referenced in a session that has no
///   corresponding node in the graph at all.
enum EpistemicGapKind { question, unknown, unmappedConcept }

/// A detected gap in the user's epistemic graph (EOM-T14).
///
/// Gaps of kind [EpistemicGapKind.question] / [EpistemicGapKind.unknown]
/// already exist as nodes, so [nodeId] is set. [EpistemicGapKind.unmappedConcept]
/// gaps have no node yet — [nodeId] is null and [concept] is the raw label
/// extracted from a session.
class EpistemicGap {
  const EpistemicGap({required this.concept, required this.kind, this.nodeId});

  /// What is missing — node content or a raw concept label.
  final String concept;

  /// The category of this gap.
  final EpistemicGapKind kind;

  /// The backing node ID, when the gap is already articulated as a node.
  final String? nodeId;

  @override
  String toString() =>
      'EpistemicGap(kind: ${kind.name}, concept: "$concept", nodeId: $nodeId)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EpistemicGap &&
          runtimeType == other.runtimeType &&
          concept == other.concept &&
          kind == other.kind &&
          nodeId == other.nodeId;

  @override
  int get hashCode => concept.hashCode ^ kind.hashCode ^ nodeId.hashCode;
}

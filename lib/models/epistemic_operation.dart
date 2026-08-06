/// Structured epistemic operations appended to intent responses.
///
/// Every cognitive intent can append a JSON block after its prose response
/// (delimited by `---EPISTEMIC---`, see `AiService`). Each subclass here is
/// the parsed contents of that block for one intent:
///
/// - [ClarifyOperation] — a fuzzy belief, disambiguated, with raised
///   confidence (EOM-T6).
/// - [CompressOperation] — a higher-order principle abstracted from a
///   cluster (EOM-T7). Supersedes the old `CompressResult` model.
/// - [MapOperation] — relationships surfaced between concepts in a cluster
///   (EOM-T8).
/// - [ReflectOperation] — contradictions detected and low-confidence nodes
///   flagged (EOM-T9).
/// - [ActOperation] — the highest-confidence belief worth acting on
///   (EOM-T10).
///
/// All `fromJson` factories follow the same contract: tolerant of missing
/// optional fields, and they throw [FormatException] only when the payload's
/// core content is absent — a missing/malformed epilogue must never break
/// the prose UX.
sealed class EpistemicOperation {
  const EpistemicOperation();

  Map<String, dynamic> toJson();
}

/// Shared tolerant parsers for the operation payloads below.
String _requiredText(Map<String, dynamic> json, String key, String owner) {
  final value = (json[key] as String? ?? '').trim();
  if (value.isEmpty) {
    throw FormatException('$owner requires a "$key".');
  }
  return value;
}

String? _optionalText(Map<String, dynamic> json, String key) {
  final value = (json[key] as String?)?.trim();
  return value == null || value.isEmpty ? null : value;
}

double _confidence(Map<String, dynamic> json, double fallback) {
  final raw = json['confidence'];
  return raw is num ? raw.toDouble().clamp(0.0, 1.0) : fallback;
}

List<String> _stringList(Map<String, dynamic> json, String key) {
  final raw = json[key];
  return raw is List
      ? raw
            .whereType<String>()
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList()
      : const <String>[];
}

List<T> _objectList<T>(
  Map<String, dynamic> json,
  String key,
  T? Function(Map<String, dynamic>) parse,
) {
  final raw = json[key];
  if (raw is! List) return <T>[];
  return raw
      .whereType<Map<String, dynamic>>()
      .map(parse)
      .whereType<T>()
      .toList();
}

/// Clarify: disambiguates a fuzzy belief and raises its confidence (EOM-T6).
class ClarifyOperation extends EpistemicOperation {
  const ClarifyOperation({
    required this.clarified,
    this.nodeType = 'belief',
    this.category,
    this.confidence = defaultConfidence,
    this.keywords = const [],
  });

  /// Default confidence for a clarified belief. The belief is the user's own
  /// assertion sharpened by dialogue, so it starts above neutral.
  static const double defaultConfidence = 0.7;

  /// The disambiguated belief, stated in one sentence.
  final String clarified;

  /// Epistemic node type name: `belief`, `knowledge`, or `hypothesis`.
  final String nodeType;

  /// Epistemic category name, or null if the LLM did not assign one.
  final String? category;

  /// Confidence in the range [0.0, 1.0] — raised versus the fuzzy original.
  final double confidence;

  /// Concept keywords used for relationship matching against existing nodes.
  final List<String> keywords;

  @override
  Map<String, dynamic> toJson() => {
    'clarified': clarified,
    'type': nodeType,
    'category': category,
    'confidence': confidence,
    'keywords': keywords,
  };

  factory ClarifyOperation.fromJson(Map<String, dynamic> json) {
    final rawType = (json['type'] as String? ?? 'belief').trim();
    return ClarifyOperation(
      clarified: _requiredText(json, 'clarified', 'ClarifyOperation'),
      nodeType: rawType.isEmpty ? 'belief' : rawType,
      category: _optionalText(json, 'category'),
      confidence: _confidence(json, defaultConfidence),
      keywords: _stringList(json, 'keywords'),
    );
  }

  @override
  String toString() =>
      'ClarifyOperation(type: $nodeType, confidence: $confidence, '
      'category: ${category ?? "null"}, clarified: "$clarified")';
}

/// Compress: abstracts a higher-order principle from a cluster (EOM-T7).
class CompressOperation extends EpistemicOperation {
  const CompressOperation({
    required this.principle,
    this.nodeType = 'knowledge',
    this.category,
    this.confidence = defaultConfidence,
    this.keywords = const [],
  });

  /// Default confidence for Compress-derived nodes. A compressed principle is
  /// the LLM's interpretation, not the user's direct assertion, so it sits
  /// slightly above neutral.
  static const double defaultConfidence = 0.6;

  /// The abstracted higher-order statement.
  final String principle;

  /// Epistemic node type name: `knowledge`, `belief`, or `hypothesis`.
  final String nodeType;

  /// Epistemic category name, or null if the LLM did not assign one.
  final String? category;

  /// Confidence in the range [0.0, 1.0].
  final double confidence;

  /// Concept keywords used for relationship matching against existing nodes.
  final List<String> keywords;

  @override
  Map<String, dynamic> toJson() => {
    'principle': principle,
    'type': nodeType,
    'category': category,
    'confidence': confidence,
    'keywords': keywords,
  };

  factory CompressOperation.fromJson(Map<String, dynamic> json) {
    final rawType = (json['type'] as String? ?? 'knowledge').trim();
    return CompressOperation(
      principle: _requiredText(json, 'principle', 'CompressOperation'),
      nodeType: rawType.isEmpty ? 'knowledge' : rawType,
      category: _optionalText(json, 'category'),
      confidence: _confidence(json, defaultConfidence),
      keywords: _stringList(json, 'keywords'),
    );
  }

  @override
  String toString() =>
      'CompressOperation(type: $nodeType, confidence: $confidence, '
      'category: ${category ?? "null"}, principle: "$principle")';
}

/// One surfaced relationship between two concepts in a mapped cluster.
class MappedRelationship {
  const MappedRelationship({
    required this.source,
    required this.target,
    required this.type,
  });

  /// Source concept label.
  final String source;

  /// Target concept label.
  final String target;

  /// Relationship type name — `supports`, `contradicts`, `refines`, or
  /// `is-example-of`. Free-form from the LLM; the graph layer validates.
  final String type;

  Map<String, dynamic> toJson() => {
    'source': source,
    'target': target,
    'type': type,
  };

  /// Returns null when either endpoint is blank — a relationship without
  /// both endpoints is meaningless.
  static MappedRelationship? tryParse(Map<String, dynamic> json) {
    final source = (json['source'] as String? ?? '').trim();
    final target = (json['target'] as String? ?? '').trim();
    if (source.isEmpty || target.isEmpty) return null;
    final type = _optionalText(json, 'type') ?? 'supports';
    return MappedRelationship(source: source, target: target, type: type);
  }

  @override
  String toString() => 'MappedRelationship($source -[$type]-> $target)';
}

/// Map: surfaces the relationship graph of a concept cluster (EOM-T8).
///
/// The concept tree itself still feeds `AiResponse.tree` for the tree view;
/// this operation carries the *epistemic* layer — the relationships between
/// the concepts — for graph persistence.
class MapOperation extends EpistemicOperation {
  const MapOperation({this.rootLabel = 'You', this.relationships = const []});

  /// Label of the tree root, mirroring the top of the rendered tree.
  final String rootLabel;

  /// Relationships surfaced between concepts in the cluster.
  final List<MappedRelationship> relationships;

  @override
  Map<String, dynamic> toJson() => {
    'label': rootLabel,
    'relationships': relationships.map((r) => r.toJson()).toList(),
  };

  factory MapOperation.fromJson(Map<String, dynamic> json) {
    return MapOperation(
      rootLabel: _optionalText(json, 'label') ?? 'You',
      relationships: _objectList(
        json,
        'relationships',
        MappedRelationship.tryParse,
      ),
    );
  }

  @override
  String toString() =>
      'MapOperation(root: "$rootLabel", '
      'relationships: ${relationships.length})';
}

/// One detected contradiction: a statement and the belief it conflicts with.
class Contradiction {
  const Contradiction({required this.statement, required this.conflictsWith});

  /// The statement in the user's input that is in tension.
  final String statement;

  /// The existing belief it conflicts with.
  final String conflictsWith;

  Map<String, dynamic> toJson() => {
    'statement': statement,
    'conflicts_with': conflictsWith,
  };

  /// Returns null when the statement is blank — the conflicting side may be
  /// omitted when the LLM flags internal tension within one belief.
  static Contradiction? tryParse(Map<String, dynamic> json) {
    final statement = (json['statement'] as String? ?? '').trim();
    if (statement.isEmpty) return null;
    return Contradiction(
      statement: statement,
      conflictsWith: _optionalText(json, 'conflicts_with') ?? '',
    );
  }

  @override
  String toString() => 'Contradiction("$statement" vs "$conflictsWith")';
}

/// Reflect: detects contradictions and flags low-confidence nodes (EOM-T9).
class ReflectOperation extends EpistemicOperation {
  const ReflectOperation({
    this.contradictions = const [],
    this.lowConfidenceNodes = const [],
  });

  /// Contradictions detected between the input and existing beliefs.
  final List<Contradiction> contradictions;

  /// Statements the LLM judged to be low-confidence and worth re-examining.
  final List<String> lowConfidenceNodes;

  @override
  Map<String, dynamic> toJson() => {
    'contradictions': contradictions.map((c) => c.toJson()).toList(),
    'low_confidence': lowConfidenceNodes,
  };

  factory ReflectOperation.fromJson(Map<String, dynamic> json) {
    return ReflectOperation(
      contradictions: _objectList(
        json,
        'contradictions',
        Contradiction.tryParse,
      ),
      lowConfidenceNodes: _stringList(json, 'low_confidence'),
    );
  }

  @override
  String toString() =>
      'ReflectOperation(contradictions: ${contradictions.length}, '
      'lowConfidence: ${lowConfidenceNodes.length})';
}

/// Act: identifies the highest-confidence belief worth acting on (EOM-T10).
class ActOperation extends EpistemicOperation {
  const ActOperation({
    required this.actionable,
    this.confidence = defaultConfidence,
    this.keywords = const [],
  });

  /// Default confidence for an actionable belief. Acting implies the belief
  /// is among the user's most reliable knowledge, so it starts high.
  static const double defaultConfidence = 0.7;

  /// The highest-confidence belief selected as the basis for action.
  final String actionable;

  /// Confidence in the range [0.0, 1.0].
  final double confidence;

  /// Concept keywords used for relationship matching against existing nodes.
  final List<String> keywords;

  @override
  Map<String, dynamic> toJson() => {
    'actionable': actionable,
    'confidence': confidence,
    'keywords': keywords,
  };

  factory ActOperation.fromJson(Map<String, dynamic> json) {
    return ActOperation(
      actionable: _requiredText(json, 'actionable', 'ActOperation'),
      confidence: _confidence(json, defaultConfidence),
      keywords: _stringList(json, 'keywords'),
    );
  }

  @override
  String toString() =>
      'ActOperation(confidence: $confidence, actionable: "$actionable")';
}

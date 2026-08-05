import 'package:uuid/uuid.dart';

import 'epistemic_relationship.dart';

/// The six canonical epistemic node types.
///
/// - [belief]     — A proposition held as true without certain proof.
/// - [knowledge]  — A justified, high-confidence belief (empirically or
///                  rationally grounded).
/// - [hypothesis] — A testable proposition not yet sufficiently evidenced.
/// - [intuition]  — A felt sense or pre-reflective knowing, not yet
///                  articulated as a full belief.
/// - [question]   — An open inquiry — something the user wants to understand.
/// - [unknown]    — An acknowledged blind spot; the user knows they don't know.
enum EpistemicNodeType {
  belief,
  knowledge,
  hypothesis,
  intuition,
  question,
  unknown,
}

/// The five canonical epistemic categories (EOM-T5).
///
/// A category describes *how the mind epistemically produced* a node — the
/// origin mode of cognition, not what the proposition is or how confident
/// the user is.  This is orthogonal to [EpistemicNodeType] and
/// [ProvenanceSource]:
///
/// - [empirical]   — Grounded in direct observation or sensory experience.
/// - [rational]    — Derived through logic, deduction, or formal reasoning.
/// - [intuitive]   — Pre-reflective; a felt sense without explicit reasoning.
/// - [abductive]   — Best-explanation inference (inference to the most likely
///                   cause or explanation).
/// - [revelatory]  — Received via insight, sudden understanding, or a
///                   qualitatively distinct moment of knowing.
enum EpistemicCategory { empirical, rational, intuitive, abductive, revelatory }

/// Converts a raw string to the matching [EpistemicCategory].
///
/// Throws [ArgumentError] if [value] is not a valid category name.
EpistemicCategory epistemicCategoryFromString(String value) {
  return EpistemicCategory.values.firstWhere(
    (e) => e.name == value,
    orElse: () => throw ArgumentError('Unknown EpistemicCategory: "$value"'),
  );
}

/// Converts a raw string to the matching [EpistemicNodeType].
///
/// Throws [ArgumentError] if [value] is not a valid type name.
EpistemicNodeType epistemicNodeTypeFromString(String value) {
  return EpistemicNodeType.values.firstWhere(
    (e) => e.name == value,
    orElse: () => throw ArgumentError('Unknown EpistemicNodeType: "$value"'),
  );
}

/// The four canonical sources of an epistemic node.
enum ProvenanceSource { experience, reasoning, testimony, intuition }

/// Converts a raw string to the matching [ProvenanceSource].
///
/// Throws [ArgumentError] if [value] is not a valid source name.
ProvenanceSource provenanceSourceFromString(String value) {
  return ProvenanceSource.values.firstWhere(
    (e) => e.name == value,
    orElse: () => throw ArgumentError('Unknown ProvenanceSource: "$value"'),
  );
}

/// Represents the origin of a belief or knowledge claim.
class ProvenanceRecord {
  const ProvenanceRecord({required this.source, required this.timestamp});

  /// The category of origin.
  final ProvenanceSource source;

  /// When the originating event occurred.
  final DateTime timestamp;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProvenanceRecord &&
          runtimeType == other.runtimeType &&
          source == other.source &&
          timestamp == other.timestamp;

  @override
  int get hashCode => source.hashCode ^ timestamp.hashCode;

  @override
  String toString() =>
      'ProvenanceRecord(source: ${source.name}, timestamp: $timestamp)';
}

/// An atomic entry in the user's epistemic database.
///
/// Each node represents a single proposition, question, or acknowledged gap in
/// the user's understanding. Nodes are typed ([EpistemicNodeType]), carry a
/// [confidence] score, and include fields for provenance (EOM-T3),
/// relationships (EOM-T4), and epistemic category (EOM-T5).
class EpistemicNode {
  /// Creates an [EpistemicNode] with the given fields.
  ///
  /// [id] defaults to a new UUIDv4 if omitted, making it safe to construct
  /// nodes offline without a round-trip to the database.
  EpistemicNode({
    String? id,
    required this.content,
    required this.type,
    this.confidence = 0.5,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.provenance,
    this.relationships = const [],
    this.category,
  }) : id = id ?? const Uuid().v4(),
       createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  /// Client-side UUIDv4. Assigned at construction so nodes can be created
  /// offline and persisted later without ID conflicts.
  final String id;

  /// The proposition, question, or gap being represented.
  final String content;

  /// The epistemic category of this node.
  final EpistemicNodeType type;

  /// Confidence in this node's validity, in the range [0.0, 1.0].
  ///
  /// Semantics are intentionally loose at this layer — EOM-T2 will formalise
  /// the scale (e.g. certain ≥ 0.9, probable ≥ 0.7, possible ≥ 0.4, etc.).
  /// A fresh node defaults to 0.5 (genuinely uncertain).
  final double confidence;

  /// When this node was first created.
  final DateTime createdAt;

  /// When this node was last modified.
  final DateTime updatedAt;

  // ── Provenance ─────────────────────────────────────────────────────────────

  /// The origin of this belief or knowledge claim.
  final ProvenanceRecord? provenance;

  // ── Relationships ─────────────────────────────────────────────────────────

  /// Outbound and inbound relationships connected to this node.
  /// Note: These are typically lazy-loaded by EpistemicService.
  final List<EpistemicRelationship> relationships;

  // ── Category ───────────────────────────────────────────────────────────────

  /// The epistemic origin mode of this node (EOM-T5).
  ///
  /// Null means uncategorised — existing nodes without a category remain valid.
  final EpistemicCategory? category;

  // ── Serialisation ───────────────────────────────────────────────────────────

  Map<String, dynamic> toJson() => {
    'id': id,
    'content': content,
    'type': type.name,
    'confidence': confidence,
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
    'source_type': provenance?.source.name,
    'source_timestamp': provenance?.timestamp.toIso8601String(),
    'relationships': relationships.map((r) => r.toJson()).toList(),
    'category': category?.name,
  };

  factory EpistemicNode.fromJson(Map<String, dynamic> json) {
    ProvenanceRecord? prov;
    if (json['source_type'] != null && json['source_timestamp'] != null) {
      prov = ProvenanceRecord(
        source: provenanceSourceFromString(json['source_type'] as String),
        timestamp: DateTime.parse(json['source_timestamp'] as String),
      );
    }

    final categoryRaw = json['category'] as String?;

    return EpistemicNode(
      id: json['id'] as String,
      content: json['content'] as String,
      type: epistemicNodeTypeFromString(json['type'] as String),
      confidence: (json['confidence'] as num).toDouble(),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      provenance: prov,
      relationships:
          (json['relationships'] as List<dynamic>?)
              ?.map(
                (e) =>
                    EpistemicRelationship.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          const [],
      category: categoryRaw != null
          ? epistemicCategoryFromString(categoryRaw)
          : null,
    );
  }

  /// Returns a copy of this node with the given fields replaced.
  EpistemicNode copyWith({
    String? content,
    EpistemicNodeType? type,
    double? confidence,
    DateTime? updatedAt,
    ProvenanceRecord? provenance,
    List<EpistemicRelationship>? relationships,
    EpistemicCategory? category,
  }) => EpistemicNode(
    id: id,
    content: content ?? this.content,
    type: type ?? this.type,
    confidence: confidence ?? this.confidence,
    createdAt: createdAt,
    updatedAt: updatedAt ?? DateTime.now(),
    provenance: provenance ?? this.provenance,
    relationships: relationships ?? this.relationships,
    category: category ?? this.category,
  );

  @override
  String toString() =>
      'EpistemicNode(id: $id, type: ${type.name}, confidence: $confidence, '
      'category: ${category?.name ?? "null"}, content: "$content")';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EpistemicNode &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

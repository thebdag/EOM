import 'package:uuid/uuid.dart';

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

/// Converts a raw string to the matching [EpistemicNodeType].
///
/// Throws [ArgumentError] if [value] is not a valid type name.
EpistemicNodeType epistemicNodeTypeFromString(String value) {
  return EpistemicNodeType.values.firstWhere(
    (e) => e.name == value,
    orElse: () => throw ArgumentError('Unknown EpistemicNodeType: "$value"'),
  );
}

/// An atomic entry in the user's epistemic database.
///
/// Each node represents a single proposition, question, or acknowledged gap in
/// the user's understanding. Nodes are typed ([EpistemicNodeType]), carry a
/// [confidence] score, and include stub fields for provenance (EOM-T3) and
/// relationships (EOM-T4) that downstream tasks will populate.
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
    this.sourceType,
    this.sourceTimestamp,
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

  // ── T3 stub fields ─────────────────────────────────────────────────────────
  // These are present but nullable so the schema is forward-compatible.
  // EOM-T3 will replace them with a richer ProvenanceRecord type.

  /// How this belief was originally formed.
  ///
  /// Expected values: `'experience'`, `'reasoning'`, `'testimony'`,
  /// `'intuition'`. Null until EOM-T3 lands.
  final String? sourceType;

  /// When the originating experience or reasoning occurred.
  ///
  /// Null until EOM-T3 lands.
  final DateTime? sourceTimestamp;

  // ── Serialisation ───────────────────────────────────────────────────────────

  Map<String, dynamic> toJson() => {
    'id': id,
    'content': content,
    'type': type.name,
    'confidence': confidence,
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
    'source_type': sourceType,
    'source_timestamp': sourceTimestamp?.toIso8601String(),
  };

  factory EpistemicNode.fromJson(Map<String, dynamic> json) => EpistemicNode(
    id: json['id'] as String,
    content: json['content'] as String,
    type: epistemicNodeTypeFromString(json['type'] as String),
    confidence: (json['confidence'] as num).toDouble(),
    createdAt: DateTime.parse(json['created_at'] as String),
    updatedAt: DateTime.parse(json['updated_at'] as String),
    sourceType: json['source_type'] as String?,
    sourceTimestamp: json['source_timestamp'] != null
        ? DateTime.parse(json['source_timestamp'] as String)
        : null,
  );

  /// Returns a copy of this node with the given fields replaced.
  EpistemicNode copyWith({
    String? content,
    EpistemicNodeType? type,
    double? confidence,
    DateTime? updatedAt,
    String? sourceType,
    DateTime? sourceTimestamp,
  }) => EpistemicNode(
    id: id,
    content: content ?? this.content,
    type: type ?? this.type,
    confidence: confidence ?? this.confidence,
    createdAt: createdAt,
    updatedAt: updatedAt ?? DateTime.now(),
    sourceType: sourceType ?? this.sourceType,
    sourceTimestamp: sourceTimestamp ?? this.sourceTimestamp,
  );

  @override
  String toString() =>
      'EpistemicNode(id: $id, type: ${type.name}, confidence: $confidence, '
      'content: "$content")';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EpistemicNode &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

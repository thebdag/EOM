import 'package:uuid/uuid.dart';

/// The canonical types of epistemic relationships (EOM-T4).
enum EpistemicRelationshipType {
  entails,
  contradicts,
  refines,
  supports,
  undermines,
  isExampleOf,
}

/// Converts a raw string to the matching [EpistemicRelationshipType].
///
/// Throws [ArgumentError] if [value] is not a valid type name.
EpistemicRelationshipType epistemicRelationshipTypeFromString(String value) {
  return EpistemicRelationshipType.values.firstWhere(
    (e) => e.name == value,
    orElse: () => throw ArgumentError('Unknown EpistemicRelationshipType: "$value"'),
  );
}

/// Represents a directed edge between two [EpistemicNode]s.
class EpistemicRelationship {
  /// Creates an [EpistemicRelationship] with the given fields.
  ///
  /// [id] defaults to a new UUIDv4 if omitted.
  EpistemicRelationship({
    String? id,
    required this.sourceId,
    required this.targetId,
    required this.type,
    DateTime? createdAt,
  }) : id = id ?? const Uuid().v4(),
       createdAt = createdAt ?? DateTime.now();

  /// The unique identifier for this relationship edge.
  final String id;

  /// The UUID of the node that this relationship originates from.
  final String sourceId;

  /// The UUID of the node that this relationship points to.
  final String targetId;

  /// The semantic type of this relationship.
  final EpistemicRelationshipType type;

  /// When this relationship was created.
  final DateTime createdAt;

  // ── Serialisation ───────────────────────────────────────────────────────────

  Map<String, dynamic> toJson() => {
    'id': id,
    'source_id': sourceId,
    'target_id': targetId,
    'type': type.name,
    'created_at': createdAt.toIso8601String(),
  };

  factory EpistemicRelationship.fromJson(Map<String, dynamic> json) {
    return EpistemicRelationship(
      id: json['id'] as String,
      sourceId: json['source_id'] as String,
      targetId: json['target_id'] as String,
      type: epistemicRelationshipTypeFromString(json['type'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  /// Returns a copy of this relationship with the given fields replaced.
  EpistemicRelationship copyWith({
    String? sourceId,
    String? targetId,
    EpistemicRelationshipType? type,
  }) => EpistemicRelationship(
    id: id,
    sourceId: sourceId ?? this.sourceId,
    targetId: targetId ?? this.targetId,
    type: type ?? this.type,
    createdAt: createdAt,
  );

  @override
  String toString() =>
      'EpistemicRelationship(id: $id, source: $sourceId, target: $targetId, type: ${type.name})';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EpistemicRelationship &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

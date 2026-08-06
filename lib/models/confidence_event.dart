import 'package:uuid/uuid.dart';

/// A single recorded confidence value for a node (EOM-T15).
///
/// One event is written when a node is created (its baseline) and again
/// whenever an update changes the node's confidence, so belief shifts can
/// be tracked across sessions.
class ConfidenceEvent {
  ConfidenceEvent({
    String? id,
    required this.nodeId,
    required this.confidence,
    DateTime? recordedAt,
  }) : id = id ?? const Uuid().v4(),
       recordedAt = recordedAt ?? DateTime.now();

  final String id;

  /// The node this event belongs to.
  final String nodeId;

  /// The confidence value in effect after this event, in [0.0, 1.0].
  final double confidence;

  /// When the value was recorded.
  final DateTime recordedAt;

  Map<String, dynamic> toJson() => {
    'id': id,
    'node_id': nodeId,
    'confidence': confidence,
    'recorded_at': recordedAt.toIso8601String(),
  };

  factory ConfidenceEvent.fromJson(Map<String, dynamic> json) =>
      ConfidenceEvent(
        id: json['id'] as String,
        nodeId: json['node_id'] as String,
        confidence: (json['confidence'] as num).toDouble(),
        recordedAt: DateTime.parse(json['recorded_at'] as String),
      );

  @override
  String toString() =>
      'ConfidenceEvent(nodeId: $nodeId, confidence: $confidence, at: $recordedAt)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ConfidenceEvent &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

/// How a node's confidence moved between its first and latest recorded
/// events (EOM-T15).
class ConfidenceDrift {
  const ConfidenceDrift({
    required this.nodeId,
    required this.from,
    required this.to,
    required this.eventCount,
    required this.firstRecordedAt,
    required this.lastRecordedAt,
  });

  final String nodeId;

  /// Confidence at the baseline (first) event.
  final double from;

  /// Confidence at the latest event.
  final double to;

  /// Total recorded events for this node (baseline included).
  final int eventCount;

  final DateTime firstRecordedAt;
  final DateTime lastRecordedAt;

  /// Signed movement: positive means confidence grew over time.
  double get delta => to - from;

  double get absDelta => delta.abs();

  @override
  String toString() =>
      'ConfidenceDrift(nodeId: $nodeId, $from → $to, events: $eventCount)';
}

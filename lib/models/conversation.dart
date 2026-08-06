/// A saved thought session in the history library (EOM-S11).
///
/// Replaces the `Map<String, dynamic>` with string keys that used to flow
/// from [HistoryService] to the history screen.
class Conversation {
  const Conversation({
    required this.timestamp,
    required this.initialInput,
    required this.intent,
    required this.response,
  });

  /// When the conversation was saved. Null when the stored timestamp was
  /// malformed — the history screen renders nothing rather than crashing
  /// (EOM-S9).
  final DateTime? timestamp;

  /// The thought the user started with.
  final String initialInput;

  /// Name of the [CognitiveIntent] that processed the thought.
  final String intent;

  /// The prose response that was shown.
  final String response;

  Map<String, dynamic> toMap() => {
    'timestamp': timestamp?.toIso8601String() ?? '',
    'initialInput': initialInput,
    'intent': intent,
    'response': response,
  };

  /// Tolerant of missing or malformed fields — a corrupt history entry
  /// degrades to empty strings instead of throwing during a build.
  factory Conversation.fromMap(Map<dynamic, dynamic> map) {
    final rawTimestamp = map['timestamp'];
    return Conversation(
      timestamp: rawTimestamp is String
          ? DateTime.tryParse(rawTimestamp)
          : null,
      initialInput: map['initialInput'] as String? ?? '',
      intent: map['intent'] as String? ?? '',
      response: map['response'] as String? ?? '',
    );
  }
}

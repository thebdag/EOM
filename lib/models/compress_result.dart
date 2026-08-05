/// Structured epistemic extraction produced by the Compress intent (EOM-T7).
///
/// The LLM appends a JSON block to its prose Compress response; this class
/// represents the parsed contents of that block. The [principle] is the
/// higher-order abstraction distilled from the user's thought, and [keywords]
/// drive relationship matching against existing epistemic nodes.
class CompressResult {
  const CompressResult({
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

  Map<String, dynamic> toJson() => {
    'principle': principle,
    'type': nodeType,
    'category': category,
    'confidence': confidence,
    'keywords': keywords,
  };

  /// Parses a [CompressResult] from the LLM's JSON block.
  ///
  /// Tolerant of missing optional fields — [nodeType] defaults to
  /// `knowledge`, [confidence] to [defaultConfidence], and [keywords] to an
  /// empty list. Throws [FormatException] only when [principle] is missing
  /// or blank, since a result without a principle is meaningless.
  factory CompressResult.fromJson(Map<String, dynamic> json) {
    final principle = (json['principle'] as String? ?? '').trim();
    if (principle.isEmpty) {
      throw const FormatException('CompressResult requires a "principle".');
    }

    final rawConfidence = json['confidence'];
    final confidence = rawConfidence is num
        ? rawConfidence.toDouble().clamp(0.0, 1.0)
        : defaultConfidence;

    final rawKeywords = json['keywords'];
    final keywords = rawKeywords is List
        ? rawKeywords
              .whereType<String>()
              .map((k) => k.trim())
              .where((k) => k.isNotEmpty)
              .toList()
        : const <String>[];

    final rawType = (json['type'] as String? ?? 'knowledge').trim();
    final rawCategory = (json['category'] as String?)?.trim();

    return CompressResult(
      principle: principle,
      nodeType: rawType.isEmpty ? 'knowledge' : rawType,
      category: rawCategory == null || rawCategory.isEmpty ? null : rawCategory,
      confidence: confidence,
      keywords: keywords,
    );
  }

  @override
  String toString() =>
      'CompressResult(type: $nodeType, confidence: $confidence, '
      'category: ${category ?? "null"}, principle: "$principle")';
}

/// Prompt library loader for the beta pressure tests (EOM-T64, T65, T66).
///
/// Reads the JSON prompt files under `dev/beta/prompts/` and surfaces them as
/// typed [Prompt] objects. The metadata schema (T66) lives on [Prompt] and
/// [Expected]; the scorer (`beta_scorer.dart`) reads [Expected] to grade
/// captured responses.
library;

import 'dart:convert';
import 'dart:io';

import 'package:eom/models/intent.dart';

/// One beta-test prompt with its grading expectations.
class Prompt {
  const Prompt({
    required this.id,
    required this.intent,
    required this.category,
    required this.edgeType,
    required this.complexity,
    required this.input,
    required this.expected,
    required this.notes,
  });

  /// Stable id, e.g. `clarify-001`. Used as the response filename.
  final String id;

  /// Intent the prompt is routed to.
  final CognitiveIntent intent;

  /// `baseline` or `edge` (EOM-T64 vs T65).
  final String category;

  /// `null` for baseline; one of `ambiguous`, `contradictory`, `multi-intent`,
  /// `adversarial` for edge prompts (EOM-T65).
  final String? edgeType;

  /// `low`, `medium`, or `high`.
  final String complexity;

  /// The user input fed to the provider.
  final String input;

  /// Grading expectations consumed by the scorer (EOM-T66).
  final Expected expected;

  /// Free-text rationale for the prompt's inclusion.
  final String notes;

  factory Prompt.fromJson(Map<String, dynamic> json) {
    final intentName = (json['intent'] as String).trim();
    final intent = CognitiveIntent.values.firstWhere(
      (i) => i.name == intentName,
      orElse: () => throw FormatException(
        'Prompt ${json['id']} has unknown intent "$intentName"',
      ),
    );
    return Prompt(
      id: json['id'] as String,
      intent: intent,
      category: json['category'] as String,
      edgeType: json['edgeType'] as String?,
      complexity: json['complexity'] as String,
      input: json['input'] as String,
      expected: Expected.fromJson(json['expected'] as Map<String, dynamic>),
      notes: json['notes'] as String? ?? '',
    );
  }
}

/// Per-prompt grading expectations (EOM-T66 metadata).
///
/// Not every field applies to every intent; the scorer reads only the fields
/// relevant to the response's intent.
class Expected {
  const Expected({
    this.confidenceRange = const [0.0, 1.0],
    this.keywordsContain = const [],
    this.minProseWords = 0,
    this.producesQuestion = false,
    this.requiresCoreMarkers = false,
    this.requiresTree = false,
    this.requiresThreeSteps = false,
    this.requiresBothLists = false,
    this.allowsEmptyRelationships = true,
  });

  /// `[low, high]` — the operation's `confidence` (where present) must fall in
  /// this inclusive range.
  final List<double> confidenceRange;

  /// Substrings at least one of which must appear (case-insensitive) among the
  /// operation's keywords.
  final List<String> keywordsContain;

  /// Minimum word count for the prose half of the response.
  final int minProseWords;

  /// Clarify: the prose must end with a question.
  final bool producesQuestion;

  /// Compress: prose must contain `**Core:**` and `**In one line:**`.
  final bool requiresCoreMarkers;

  /// Map: the response must yield a parseable `ThoughtNode` tree.
  final bool requiresTree;

  /// Act: the prose must contain exactly three timed steps.
  final bool requiresThreeSteps;

  /// Reflect: both `contradictions` and `low_confidence` keys must be present.
  final bool requiresBothLists;

  /// Map: an explicit empty `relationships` list satisfies completeness.
  final bool allowsEmptyRelationships;

  factory Expected.fromJson(Map<String, dynamic> json) {
    List<double> range(List<dynamic> raw) =>
        raw.map((e) => (e as num).toDouble()).toList();
    return Expected(
      confidenceRange: json['confidenceRange'] != null
          ? range(json['confidenceRange'] as List)
          : const [0.0, 1.0],
      keywordsContain:
          (json['keywordsContain'] as List?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      minProseWords: (json['minProseWords'] as num?)?.toInt() ?? 0,
      producesQuestion: json['producesQuestion'] as bool? ?? false,
      requiresCoreMarkers: json['requiresCoreMarkers'] as bool? ?? false,
      requiresTree: json['requiresTree'] as bool? ?? false,
      requiresThreeSteps: json['requiresThreeSteps'] as bool? ?? false,
      requiresBothLists: json['requiresBothLists'] as bool? ?? false,
      allowsEmptyRelationships:
          json['allowsEmptyRelationships'] as bool? ?? true,
    );
  }
}

/// Loads every prompt from `dev/beta/prompts/*.json`, sorted by id.
///
/// [repoRoot] is the eom repo root (where `dev/` lives); tests pass
/// `Directory.current` which is the repo root under `flutter test`.
List<Prompt> loadPrompts(Directory repoRoot) {
  final promptsDir = Directory('${repoRoot.path}/dev/beta/prompts');
  final all = <Prompt>[];
  for (final file in promptsDir.listSync().whereType<File>()) {
    if (!file.path.endsWith('.json')) continue;
    try {
      final decoded = jsonDecode(file.readAsStringSync());
      if (decoded is! List) {
        throw const FormatException('Top-level value must be a JSON list.');
      }
      for (final item in decoded) {
        all.add(Prompt.fromJson(item as Map<String, dynamic>));
      }
    } catch (error) {
      throw FormatException(
        'Could not load beta prompts from ${file.path}: $error',
      );
    }
  }
  all.sort((a, b) => a.id.compareTo(b.id));
  return all;
}

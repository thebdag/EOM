import '../models/epistemic_operation.dart';
import '../models/intent.dart';

/// Prompt-building and epilogue-parsing behaviour per [CognitiveIntent]
/// (EOM-S14).
///
/// The prompt text and the JSON→operation routing used to be two parallel
/// switches inside `AiService`; they now live here next to each other so
/// adding an intent touches exactly one file. [CognitiveIntent] itself
/// keeps only UI concerns (label, icon, color).
extension CognitiveIntentOps on CognitiveIntent {
  static const _categoryValues =
      '"empirical"|"rational"|"intuitive"|"abductive"|"revelatory"';

  /// True when the intent's epilogue carries a concept tree for the tree
  /// view in addition to its [EpistemicOperation].
  bool get producesTree => this == CognitiveIntent.map;

  /// The intent-specific system-prompt section. [marker] is the delimiter
  /// the LLM must emit before its JSON epilogue (`AiService.epistemicMarker`).
  ///
  /// [compact] is the on-device budget (Gemini Nano system instructions
  /// should stay under ~150 words including [AiService.compactContext]).
  String buildPrompt(String marker, {bool compact = false}) {
    if (compact) return _compactPrompt(marker);
    switch (this) {
      case CognitiveIntent.clarify:
        return 'You are an epistemic agent helping the user clarify their thoughts. '
            'Ensure your questions are inquisitive and delicate. '
            'Analyze the input, point out the surface concern and deeper current, and end with a clarifying question. '
            'After the prose, on a new line, output exactly "$marker" followed by a single JSON object '
            'capturing the disambiguated belief: {"clarified": "the sharpened belief in one sentence", '
            '"type": "belief"|"knowledge"|"hypothesis", '
            '"category": $_categoryValues, '
            '"confidence": 0.0-1.0 (raised, since the belief is now sharper), '
            '"keywords": ["concept", "keywords"]}. '
            'No markdown fences around the JSON.';
      case CognitiveIntent.compress:
        return 'You are an epistemic agent. The user will provide a thought. '
            'Aim to use metaphor and simile that a child would understand, to reduce and simplify to bare essence. '
            'Provide "**Core:**" followed by a summary, then "**In one line:**" followed by the emotional weight. '
            'After the prose, on a new line, output exactly "$marker" followed by a single JSON object '
            'capturing the abstracted principle: {"principle": "the higher-order abstraction", '
            '"type": "knowledge"|"belief"|"hypothesis", '
            '"category": $_categoryValues, '
            '"confidence": 0.0-1.0, "keywords": ["concept", "keywords"]}. '
            'No markdown fences around the JSON.';
      case CognitiveIntent.map:
        return 'You are an epistemic agent. Bridge the gap between independent thoughts or ideas presented by the user. '
            'Write one or two sentences of prose summarizing how the ideas connect, '
            'then on a new line output exactly "$marker" followed by a single JSON object '
            'representing a thought tree mapping their ideas together: '
            '{"label": "You", "children": [{"label": "Category", "children": [{"label": "Concept"}]}], '
            '"relationships": [{"source": "Concept", "target": "Concept", '
            '"type": "supports"|"contradicts"|"refines"|"is-example-of"}]}. '
            'Use an empty relationships list if none are clear. '
            'No markdown fences around the JSON.';
      case CognitiveIntent.reflect:
        return 'You are an epistemic agent. Help the user look at their thought differently. '
            'Offer a brief perspective shift, and directly encourage more journaling input to explore this further. '
            'After the prose, on a new line, output exactly "$marker" followed by a single JSON object '
            'capturing what the reflection surfaced: {"contradictions": [{"statement": "the tense statement", '
            '"conflicts_with": "the belief it conflicts with"}], '
            '"low_confidence": ["statements that seem uncertain or under-examined"]}. '
            'Use empty lists when nothing surfaces. '
            'No markdown fences around the JSON.';
      case CognitiveIntent.act:
        return 'You are an epistemic agent. Turn the user\'s thought into action. '
            'Engineer your responses aimed toward action and remediation. Arc upward. '
            'Provide exactly three concrete steps: 1. Right now (10 mins), 2. Today, 3. This week. '
            'After the steps, on a new line, output exactly "$marker" followed by a single JSON object '
            'identifying the belief the action rests on: {"actionable": "the highest-confidence belief to act on", '
            '"confidence": 0.0-1.0, "keywords": ["concept", "keywords"]}. '
            'No markdown fences around the JSON.';
    }
  }

  String _compactPrompt(String marker) {
    switch (this) {
      case CognitiveIntent.clarify:
        return 'Clarify the thought. Name the surface concern and deeper current. '
            'End with one question. Then a new line, "$marker", then JSON: '
            '{"clarified":"one sentence","type":"belief"|"knowledge"|"hypothesis",'
            '"category":$_categoryValues,"confidence":0-1,"keywords":["..."]}. '
            'No fences.';
      case CognitiveIntent.compress:
        return 'Reduce the thought to essence a child would grasp. '
            'Write **Core:** then **In one line:**. Then a new line, "$marker", '
            'then JSON: {"principle":"...","type":"knowledge"|"belief"|"hypothesis",'
            '"category":$_categoryValues,"confidence":0-1,"keywords":["..."]}. '
            'No fences.';
      case CognitiveIntent.map:
        return 'In 1-2 sentences, how the ideas connect. Then a new line, '
            '"$marker", then JSON: {"label":"You","children":[{"label":"Category",'
            '"children":[{"label":"Concept"}]}],"relationships":[{"source":"A",'
            '"target":"B","type":"supports"|"contradicts"|"refines"|"is-example-of"}]}. '
            'Empty relationships if none. No fences.';
      case CognitiveIntent.reflect:
        return 'Offer a brief perspective shift and invite more journaling. '
            'Then a new line, "$marker", then JSON: {"contradictions":[{"statement":'
            '"...","conflicts_with":"..."}],"low_confidence":["..."]}. '
            'Empty lists if none. No fences.';
      case CognitiveIntent.act:
        return 'Three steps: 1. Right now (10 mins), 2. Today, 3. This week. '
            'Then a new line, "$marker", then JSON: {"actionable":"...","confidence":0-1,'
            '"keywords":["..."]}. No fences.';
    }
  }

  /// Parses the decoded epilogue JSON into this intent's operation.
  ///
  /// Throws [FormatException] when the payload lacks its core content —
  /// callers treat that as "no operation", never as an intent failure.
  EpistemicOperation parseOperation(Map<String, dynamic> json) {
    switch (this) {
      case CognitiveIntent.clarify:
        return ClarifyOperation.fromJson(json);
      case CognitiveIntent.compress:
        return CompressOperation.fromJson(json);
      case CognitiveIntent.map:
        return MapOperation.fromJson(json);
      case CognitiveIntent.reflect:
        return ReflectOperation.fromJson(json);
      case CognitiveIntent.act:
        return ActOperation.fromJson(json);
    }
  }
}

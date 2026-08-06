import 'dart:convert';
import '../models/epistemic_operation.dart';
import '../models/intent.dart';
import '../models/thought_node.dart';
import 'llm_provider.dart';
import 'settings_service.dart';

class AiService {
  LlmProvider _getProvider() {
    final provider = SettingsService.activeProvider.toUpperCase();
    switch (provider) {
      case 'OPENAI':
        return OpenAiProvider();
      case 'ANTHROPIC':
        return AnthropicProvider();
      case 'LOCAL':
      case 'OLLAMA': // legacy preference value
        return LocalProvider();
      case 'GEMINI':
      default:
        return GeminiProvider();
    }
  }

  /// Delimiter between an intent's prose response and its epistemic JSON
  /// epilogue. All five intents use the same marker.
  static const epistemicMarker = '---EPISTEMIC---';

  Future<AiResponse> process(
    String input,
    CognitiveIntent intent, {
    List<Map<String, String>> history = const [],
  }) async {
    final provider = _getProvider();

    // Global context applied to all intents
    const defaultContext =
        'Use plain language. Your ethics are empowering, encouraging, and truth telling, balanced as in taoism, redemptive as in christianity. never use religious language. detect sentiment from user input: if more chaotic, encourage toward balanced order. If too ordlery, encourage toward balanced chaos';

    const categoryValues =
        '"empirical"|"rational"|"intuitive"|"abductive"|"revelatory"';

    String intentContext = '';

    switch (intent) {
      case CognitiveIntent.clarify:
        intentContext =
            'You are an epistemic agent helping the user clarify their thoughts. '
            'Ensure your questions are inquisitive and delicate. '
            'Analyze the input, point out the surface concern and deeper current, and end with a clarifying question. '
            'After the prose, on a new line, output exactly "$epistemicMarker" followed by a single JSON object '
            'capturing the disambiguated belief: {"clarified": "the sharpened belief in one sentence", '
            '"type": "belief"|"knowledge"|"hypothesis", '
            '"category": $categoryValues, '
            '"confidence": 0.0-1.0 (raised, since the belief is now sharper), '
            '"keywords": ["concept", "keywords"]}. '
            'No markdown fences around the JSON.';
        break;
      case CognitiveIntent.compress:
        intentContext =
            'You are an epistemic agent. The user will provide a thought. '
            'Aim to use metaphor and simile that a child would understand, to reduce and simplify to bare essence. '
            'Provide "**Core:**" followed by a summary, then "**In one line:**" followed by the emotional weight. '
            'After the prose, on a new line, output exactly "$epistemicMarker" followed by a single JSON object '
            'capturing the abstracted principle: {"principle": "the higher-order abstraction", '
            '"type": "knowledge"|"belief"|"hypothesis", '
            '"category": $categoryValues, '
            '"confidence": 0.0-1.0, "keywords": ["concept", "keywords"]}. '
            'No markdown fences around the JSON.';
        break;
      case CognitiveIntent.map:
        intentContext =
            'You are an epistemic agent. Bridge the gap between independent thoughts or ideas presented by the user. '
            'Write one or two sentences of prose summarizing how the ideas connect, '
            'then on a new line output exactly "$epistemicMarker" followed by a single JSON object '
            'representing a thought tree mapping their ideas together: '
            '{"label": "You", "children": [{"label": "Category", "children": [{"label": "Concept"}]}], '
            '"relationships": [{"source": "Concept", "target": "Concept", '
            '"type": "supports"|"contradicts"|"refines"|"is-example-of"}]}. '
            'Use an empty relationships list if none are clear. '
            'No markdown fences around the JSON.';
        break;
      case CognitiveIntent.reflect:
        intentContext =
            'You are an epistemic agent. Help the user look at their thought differently. '
            'Offer a brief perspective shift, and directly encourage more journaling input to explore this further. '
            'After the prose, on a new line, output exactly "$epistemicMarker" followed by a single JSON object '
            'capturing what the reflection surfaced: {"contradictions": [{"statement": "the tense statement", '
            '"conflicts_with": "the belief it conflicts with"}], '
            '"low_confidence": ["statements that seem uncertain or under-examined"]}. '
            'Use empty lists when nothing surfaces. '
            'No markdown fences around the JSON.';
        break;
      case CognitiveIntent.act:
        intentContext =
            'You are an epistemic agent. Turn the user\'s thought into action. '
            'Engineer your responses aimed toward action and remediation. Arc upward. '
            'Provide exactly three concrete steps: 1. Right now (10 mins), 2. Today, 3. This week. '
            'After the steps, on a new line, output exactly "$epistemicMarker" followed by a single JSON object '
            'identifying the belief the action rests on: {"actionable": "the highest-confidence belief to act on", '
            '"confidence": 0.0-1.0, "keywords": ["concept", "keywords"]}. '
            'No markdown fences around the JSON.';
        break;
    }

    final systemPrompt = '$defaultContext\n\n$intentContext';

    try {
      final textResponse = await provider.generate(
        systemPrompt,
        input,
        history: history,
      );

      if (intent == CognitiveIntent.map) {
        return _parseMapResponse(textResponse, intent);
      }

      return _parseEpistemicResponse(textResponse, intent);
    } catch (e) {
      return AiResponse(
        text:
            'Error processing intent with ${SettingsService.activeProvider}: $e',
        intent: intent,
      );
    }
  }

  /// Splits an intent response into prose and its epistemic JSON epilogue,
  /// parsing the epilogue into the [EpistemicOperation] for [intent].
  ///
  /// A missing or malformed epilogue never fails the intent — the user still
  /// gets the prose, and [AiResponse.operation] stays null.
  AiResponse _parseEpistemicResponse(String raw, CognitiveIntent intent) {
    final markerIndex = raw.indexOf(epistemicMarker);
    if (markerIndex == -1) {
      return AiResponse(text: raw.trim(), intent: intent);
    }

    final prose = raw.substring(0, markerIndex).trim();
    final jsonBlock = raw
        .substring(markerIndex + epistemicMarker.length)
        .replaceAll('```json', '')
        .replaceAll('```', '')
        .trim();

    EpistemicOperation? operation;
    try {
      final data = jsonDecode(jsonBlock) as Map<String, dynamic>;
      operation = switch (intent) {
        CognitiveIntent.clarify => ClarifyOperation.fromJson(data),
        CognitiveIntent.compress => CompressOperation.fromJson(data),
        CognitiveIntent.reflect => ReflectOperation.fromJson(data),
        CognitiveIntent.act => ActOperation.fromJson(data),
        CognitiveIntent.map => throw const FormatException(
          'Map is parsed by _parseMapResponse.',
        ),
      };
    } catch (_) {
      operation = null;
    }

    return AiResponse(text: prose, intent: intent, operation: operation);
  }

  /// Parses a Map response: prose, then a `$epistemicMarker` JSON block
  /// holding both the concept tree (rendered by the tree view) and the
  /// epistemic relationships between concepts.
  ///
  /// Falls back gracefully: a missing marker retries the whole body as a
  /// bare tree (the pre-T8 pure-JSON contract), and unparseable JSON returns
  /// the raw text as plain prose. The intent never hard-fails.
  AiResponse _parseMapResponse(String raw, CognitiveIntent intent) {
    final markerIndex = raw.indexOf(epistemicMarker);

    if (markerIndex == -1) {
      // Legacy pure-JSON response (small local models may ignore the prose
      // instruction). Treat the whole body as the tree payload.
      final tree = _tryParseTree(raw);
      if (tree != null) {
        return AiResponse(
          text: 'Here is how your thought maps out:',
          intent: intent,
          tree: tree,
        );
      }
      return AiResponse(text: raw.trim(), intent: intent);
    }

    final prose = raw.substring(0, markerIndex).trim();
    final jsonBlock = raw
        .substring(markerIndex + epistemicMarker.length)
        .replaceAll('```json', '')
        .replaceAll('```', '')
        .trim();

    Map<String, dynamic>? data;
    try {
      data = jsonDecode(jsonBlock) as Map<String, dynamic>;
    } catch (_) {
      data = null;
    }

    if (data == null) {
      // Prose survived but the epilogue is malformed — degrade to prose only.
      return AiResponse(
        text: prose.isEmpty ? raw.trim() : prose,
        intent: intent,
      );
    }

    return AiResponse(
      text: prose.isEmpty ? 'Here is how your thought maps out:' : prose,
      intent: intent,
      tree: _parseNode(data),
      operation: MapOperation.fromJson(data),
    );
  }

  ThoughtNode? _tryParseTree(String raw) {
    try {
      final cleaned = raw
          .replaceAll('```json', '')
          .replaceAll('```', '')
          .trim();
      return _parseNode(jsonDecode(cleaned) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  ThoughtNode _parseNode(Map<String, dynamic> json) {
    final childrenList = json['children'] as List<dynamic>? ?? [];
    final children = childrenList
        .map((c) => _parseNode(c as Map<String, dynamic>))
        .toList();
    return ThoughtNode(
      label: json['label'] as String? ?? 'Node',
      children: children,
    );
  }
}

/// Response from the AI service.
class AiResponse {
  const AiResponse({
    required this.text,
    required this.intent,
    this.tree,
    this.operation,
  });

  final String text;
  final CognitiveIntent intent;
  final ThoughtNode? tree;

  /// Structured epistemic operation extracted from the response epilogue
  /// (EOM-T6 through EOM-T10). Null when the LLM omitted or malformed the
  /// epilogue — the prose UX is unaffected either way.
  final EpistemicOperation? operation;
}

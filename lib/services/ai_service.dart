import 'dart:convert';
import '../models/epistemic_operation.dart';
import '../models/intent.dart';
import '../models/thought_node.dart';
import 'clarify_operation.dart';
import 'epistemic_service.dart';
import 'llm_provider.dart';
import 'settings_service.dart';

class AiService {
  final EpistemicService _epistemic = EpistemicService();
  late final ClarifyOperation _clarify = ClarifyOperation(_epistemic);

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

  Future<AiResponse> process(
    String input,
    CognitiveIntent intent, {
    List<Map<String, String>> history = const [],
  }) async {
    final provider = _getProvider();

    // Global context applied to all intents
    const defaultContext =
        'Use plain language. Your ethics are empowering, encouraging, and truth telling, balanced as in taoism, redemptive as in christianity. never use religious language. detect sentiment from user input: if more chaotic, encourage toward balanced order. If too ordlery, encourage toward balanced chaos';

    String intentContext = '';

    switch (intent) {
      case CognitiveIntent.clarify:
        intentContext =
            'You are an epistemic agent helping the user clarify their thoughts. '
            'Ensure your questions are inquisitive and delicate. '
            'Analyze the input, point out the surface concern and deeper current, and end with a clarifying question. '
            'After the clarifying question, on a new line append a fenced json block exactly of the form '
            '```json {"surface": "...", "deeper": "...", "resolved": "..."}``` '
            'where "surface" is the surface concern, "deeper" is the deeper current beneath it, and "resolved" '
            'is the user\'s pre-existing belief that this exchange clarified (or null if none). '
            'Never mention this json block in the visible text.';
        break;
      case CognitiveIntent.compress:
        intentContext =
            'You are an epistemic agent. The user will provide a thought. '
            'Aim to use metaphor and simile that a child would understand, to reduce and simplify to bare essence. '
            'Provide "**Core:**" followed by a summary, then "**In one line:**" followed by the emotional weight.';
        break;
      case CognitiveIntent.map:
        intentContext =
            'You are an epistemic agent. Bridge the gap between independent thoughts or ideas presented by the user. '
            'Respond ONLY with a JSON object representing a thought tree mapping their ideas together. '
            'Structure: {"label": "You", "children": [{"label": "Category", "children": [{"label": "Concept"}]}]}. '
            'Do not use markdown formatting, just pure JSON.';
        break;
      case CognitiveIntent.reflect:
        intentContext =
            'You are an epistemic agent. Help the user look at their thought differently. '
            'Offer a brief perspective shift, and directly encourage more journaling input to explore this further.';
        break;
      case CognitiveIntent.act:
        intentContext =
            'You are an epistemic agent. Turn the user\'s thought into action. '
            'Engineer your responses aimed toward action and remediation. Arc upward. '
            'Provide exactly three concrete steps: 1. Right now (10 mins), 2. Today, 3. This week.';
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
        // Parse JSON for Map intent
        final cleanedJson = textResponse
            .replaceAll('```json', '')
            .replaceAll('```', '')
            .trim();
        final Map<String, dynamic> data = jsonDecode(cleanedJson);
        return AiResponse(
          text: 'Here is how your thought maps out:',
          intent: intent,
          tree: _parseNode(data),
        );
      }

      var displayText = textResponse.trim();
      var operations = const <EpistemicOperation>[];

      if (intent == CognitiveIntent.clarify) {
        displayText = ClarifyOperation.stripPayload(displayText);
        try {
          await _epistemic.init();
          operations = await _clarify.apply(
            input: input,
            llmResponse: textResponse,
          );
        } catch (_) {
          // Graph updates are best-effort; a storage failure must never
          // break the user-facing response.
          operations = const [];
        }
      }

      return AiResponse(
        text: displayText,
        intent: intent,
        operations: operations,
      );
    } catch (e) {
      return AiResponse(
        text:
            'Error processing intent with ${SettingsService.activeProvider}: $e',
        intent: intent,
      );
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
    this.operations = const [],
  });

  final String text;
  final CognitiveIntent intent;
  final ThoughtNode? tree;

  /// Epistemic graph mutations applied as a result of this exchange
  /// (EOM-T6: Clarify only, for now). Empty for other intents or when the
  /// response carried no machine-readable payload.
  final List<EpistemicOperation> operations;
}

import 'dart:convert';
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
      case 'OLLAMA':
        return OllamaProvider();
      case 'GEMINI':
      default:
        return GeminiProvider();
    }
  }

  Future<AiResponse> process(String input, CognitiveIntent intent, {List<Map<String, String>> history = const []}) async {
    final provider = _getProvider();
    
    // Global context applied to all intents
    const defaultContext = 'Use plain language. Your ethics are empowering, encouraging, and truth telling, balanced as in taoism, redemptive as in christianity. never use religious language. detect sentiment from user input: if more chaotic, encourage toward balanced order. If too ordlery, encourage toward balanced chaos';
    
    String intentContext = '';
    
    switch (intent) {
      case CognitiveIntent.clarify:
        intentContext = 'You are an epistemic agent helping the user clarify their thoughts. '
            'Ensure your questions are inquisitive and delicate. '
            'Analyze the input, point out the surface concern and deeper current, and end with a clarifying question.';
        break;
      case CognitiveIntent.compress:
        intentContext = 'You are an epistemic agent. The user will provide a thought. '
            'Aim to use metaphor and simile that a child would understand, to reduce and simplify to bare essence. '
            'Provide "**Core:**" followed by a summary, then "**In one line:**" followed by the emotional weight.';
        break;
      case CognitiveIntent.map:
        intentContext = 'You are an epistemic agent. Bridge the gap between independent thoughts or ideas presented by the user. '
            'Respond ONLY with a JSON object representing a thought tree mapping their ideas together. '
            'Structure: {"label": "You", "children": [{"label": "Category", "children": [{"label": "Concept"}]}]}. '
            'Do not use markdown formatting, just pure JSON.';
        break;
      case CognitiveIntent.reflect:
        intentContext = 'You are an epistemic agent. Help the user look at their thought differently. '
            'Offer a brief perspective shift, and directly encourage more journaling input to explore this further.';
        break;
      case CognitiveIntent.act:
        intentContext = 'You are an epistemic agent. Turn the user\'s thought into action. '
            'Engineer your responses aimed toward action and remediation. Arc upward. '
            'Provide exactly three concrete steps: 1. Right now (10 mins), 2. Today, 3. This week.';
        break;
    }

    final systemPrompt = '$defaultContext\n\n$intentContext';

    try {
      final textResponse = await provider.generate(systemPrompt, input, history: history);

      if (intent == CognitiveIntent.map) {
        // Parse JSON for Map intent
        final cleanedJson = textResponse.replaceAll('```json', '').replaceAll('```', '').trim();
        final Map<String, dynamic> data = jsonDecode(cleanedJson);
        return AiResponse(
          text: 'Here is how your thought maps out:',
          intent: intent,
          tree: _parseNode(data),
        );
      }

      return AiResponse(
        text: textResponse.trim(),
        intent: intent,
      );
    } catch (e) {
      return AiResponse(
        text: 'Error processing intent with ${SettingsService.activeProvider}: $e',
        intent: intent,
      );
    }
  }

  ThoughtNode _parseNode(Map<String, dynamic> json) {
    final childrenList = json['children'] as List<dynamic>? ?? [];
    final children = childrenList.map((c) => _parseNode(c as Map<String, dynamic>)).toList();
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
  });

  final String text;
  final CognitiveIntent intent;
  final ThoughtNode? tree;
}

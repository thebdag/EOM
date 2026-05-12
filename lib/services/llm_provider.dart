import 'dart:convert';
import 'settings_service.dart';
import 'package:http/http.dart' as http;

abstract class LlmProvider {
  Future<String> generate(String systemPrompt, String userMessage, {List<Map<String, String>> history = const []});
}

class OpenAiProvider implements LlmProvider {
  @override
  Future<String> generate(String systemPrompt, String userMessage, {List<Map<String, String>> history = const []}) async {
    final apiKey = SettingsService.openAiKey;
    if (apiKey == null || apiKey.isEmpty) throw Exception('OPENAI_API_KEY is missing');

    final response = await http.post(
      Uri.parse('https://api.openai.com/v1/chat/completions'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
      },
      body: jsonEncode({
        'model': 'gpt-4o', // or gpt-4o-mini
        'messages': [
          {'role': 'system', 'content': systemPrompt},
          ...history,
          {'role': 'user', 'content': userMessage},
        ],
      }),
    );

    if (response.statusCode != 200) throw Exception('OpenAI Error: ${response.body}');
    final data = jsonDecode(response.body);
    return data['choices'][0]['message']['content'];
  }
}

class AnthropicProvider implements LlmProvider {
  @override
  Future<String> generate(String systemPrompt, String userMessage, {List<Map<String, String>> history = const []}) async {
    final apiKey = SettingsService.anthropicKey;
    if (apiKey == null || apiKey.isEmpty) throw Exception('ANTHROPIC_API_KEY is missing');

    final response = await http.post(
      Uri.parse('https://api.anthropic.com/v1/messages'),
      headers: {
        'Content-Type': 'application/json',
        'x-api-key': apiKey,
        'anthropic-version': '2023-06-01',
      },
      body: jsonEncode({
        'model': 'claude-3-5-sonnet-20241022',
        'system': systemPrompt,
        'max_tokens': 1024,
        'messages': [
          ...history,
          {'role': 'user', 'content': userMessage},
        ],
      }),
    );

    if (response.statusCode != 200) throw Exception('Anthropic Error: ${response.body}');
    final data = jsonDecode(response.body);
    return data['content'][0]['text'];
  }
}

class GeminiProvider implements LlmProvider {
  @override
  Future<String> generate(String systemPrompt, String userMessage, {List<Map<String, String>> history = const []}) async {
    final apiKey = SettingsService.geminiKey;
    if (apiKey == null || apiKey.isEmpty) throw Exception('GEMINI_API_KEY is missing');

    final response = await http.post(
      Uri.parse('https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-pro:generateContent?key=$apiKey'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'systemInstruction': {
          'parts': [{'text': systemPrompt}]
        },
        'contents': [
          ...history.map((m) => {
            'role': m['role'] == 'assistant' ? 'model' : 'user',
            'parts': [{'text': m['content']}]
          }),
          {
            'role': 'user',
            'parts': [{'text': userMessage}]
          }
        ],
      }),
    );

    if (response.statusCode != 200) throw Exception('Gemini Error: ${response.body}');
    final data = jsonDecode(response.body);
    return data['candidates'][0]['content']['parts'][0]['text'];
  }
}

class OllamaProvider implements LlmProvider {
  @override
  Future<String> generate(String systemPrompt, String userMessage, {List<Map<String, String>> history = const []}) async {
    final host = SettingsService.ollamaHost;
    final model = SettingsService.ollamaModel;
    final apiKey = SettingsService.ollamaApiKey;

    if (apiKey.isEmpty) throw Exception('OLLAMA_API_KEY is missing');

    final response = await http.post(
      Uri.parse('$host/v1/chat/completions'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
      },
      body: jsonEncode({
        'model': model,
        'stream': false,
        'messages': [
          {'role': 'system', 'content': systemPrompt},
          ...history,
          {'role': 'user', 'content': userMessage},
        ],
      }),
    );

    if (response.statusCode != 200) throw Exception('Ollama Error: ${response.body}');
    final data = jsonDecode(response.body);
    
    // Support both OpenAI format and native Ollama format
    if (data['choices'] != null && data['choices'].isNotEmpty) {
      return data['choices'][0]['message']['content'];
    }
    return data['message']['content'];
  }
}

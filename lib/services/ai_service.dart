import 'dart:convert';
import '../models/epistemic_operation.dart';
import '../models/intent.dart';
import '../models/thought_node.dart';
import 'intent_config.dart';
import 'intent_error.dart';
import 'llm_provider.dart';
import 'settings_service.dart';

/// Extracts the first balanced `{ ... }` object from [text], ignoring any
/// prose the model emits after the JSON epilogue. Returns null when no
/// balanced object is found. Strings (`"..."`) are skipped so a `}` inside
/// a string value cannot close the object early.
String? _extractFirstJsonObject(String text) {
  final start = text.indexOf('{');
  if (start == -1) return null;
  var depth = 0;
  var inString = false;
  var escape = false;
  for (var i = start; i < text.length; i++) {
    final ch = text[i];
    if (inString) {
      if (escape) {
        escape = false;
      } else if (ch == '\\') {
        escape = true;
      } else if (ch == '"') {
        inString = false;
      }
      continue;
    }
    if (ch == '"') {
      inString = true;
    } else if (ch == '{') {
      depth++;
    } else if (ch == '}') {
      depth--;
      if (depth == 0) return text.substring(start, i + 1);
    }
  }
  return null;
}

class AiService {
  AiService({LlmProvider? provider}) : _providerOverride = provider;

  /// Test seam — when set, [_getProvider] returns this instead of reading
  /// the active provider from settings.
  final LlmProvider? _providerOverride;

  LlmProvider _getProvider() {
    final override = _providerOverride;
    if (override != null) return override;
    return SettingsService.activeProvider.createProvider();
  }

  /// Delimiter between an intent's prose response and its epistemic JSON
  /// epilogue. All five intents use the same marker.
  static const epistemicMarker = '---EPISTEMIC---';

  /// Global context prepended to every intent's system prompt. Exposed so
  /// the beta pressure-test runner (`test/beta/`) can reuse the exact string
  /// and a drift-guard test can assert they stay in sync.
  static const defaultContext =
      'Use plain language. Your ethics are empowering, encouraging, and truth telling, balanced as in taoism, redemptive as in christianity. never use religious language. detect sentiment from user input: if more chaotic, encourage toward balanced order. If too ordlery, encourage toward balanced chaos';

  Future<AiResponse> process(
    String input,
    CognitiveIntent intent, {
    List<ChatMessage> history = const [],
  }) async {
    final provider = _getProvider();

    final systemPrompt =
        '$defaultContext\n\n${intent.buildPrompt(epistemicMarker)}';

    try {
      final textResponse = await provider.generate(
        systemPrompt,
        input,
        history: history,
      );

      if (intent.producesTree) {
        return _parseMapResponse(textResponse, intent);
      }

      return _parseEpistemicResponse(textResponse, intent);
    } catch (e) {
      final mapped = IntentError.from(e);
      return AiResponse(
        text: mapped.message,
        intent: intent,
        isError: true,
        offerSettings: mapped.offerSettings,
      );
    }
  }

  /// Splits an intent response into trimmed prose and the decoded epilogue
  /// JSON (EOM-S13). Returns null when the marker is absent; the epilogue
  /// half is null when the JSON block is malformed.
  ///
  /// Models sometimes emit trailing prose after the JSON epilogue (e.g.
  /// a closing question). We isolate the first balanced `{ ... }` object
  /// after the marker so that trailing text no longer breaks `jsonDecode`.
  (String, Map<String, dynamic>?)? _splitEpilogue(String raw) {
    final markerIndex = raw.indexOf(epistemicMarker);
    if (markerIndex == -1) return null;

    final prose = raw.substring(0, markerIndex).trim();
    final afterMarker = raw
        .substring(markerIndex + epistemicMarker.length)
        .replaceAll('```json', '')
        .replaceAll('```', '');
    final jsonBlock = _extractFirstJsonObject(afterMarker);

    Map<String, dynamic>? data;
    if (jsonBlock != null) {
      try {
        data = jsonDecode(jsonBlock) as Map<String, dynamic>;
      } catch (_) {
        data = null;
      }
    }
    return (prose, data);
  }

  /// Splits an intent response into prose and its epistemic JSON epilogue,
  /// parsing the epilogue into the [EpistemicOperation] for [intent].
  ///
  /// A missing or malformed epilogue never fails the intent — the user still
  /// gets the prose, and [AiResponse.operation] stays null.
  AiResponse _parseEpistemicResponse(String raw, CognitiveIntent intent) {
    final split = _splitEpilogue(raw);
    if (split == null) {
      return AiResponse(text: raw.trim(), intent: intent);
    }
    final (prose, data) = split;

    EpistemicOperation? operation;
    if (data != null) {
      try {
        operation = intent.parseOperation(data);
      } catch (_) {
        operation = null;
      }
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
    final split = _splitEpilogue(raw);

    if (split == null) {
      // Legacy pure-JSON response (small local models may ignore the prose
      // instruction). Treat the whole body as the tree payload.
      final tree = ThoughtNode.tryParseRaw(raw);
      if (tree != null) {
        return AiResponse(
          text: 'Here is how your thought maps out:',
          intent: intent,
          tree: tree,
        );
      }
      return AiResponse(text: raw.trim(), intent: intent);
    }
    final (prose, data) = split;

    if (data == null) {
      // Prose survived but the epilogue is malformed — degrade to prose only.
      return AiResponse(
        text: prose.isEmpty ? raw.trim() : prose,
        intent: intent,
      );
    }

    try {
      return AiResponse(
        text: prose.isEmpty ? 'Here is how your thought maps out:' : prose,
        intent: intent,
        tree: ThoughtNode.fromJson(data),
        operation: intent.parseOperation(data),
      );
    } catch (_) {
      // Valid JSON with an unexpected shape (e.g. `children` is not a
      // list) must not hard-fail the intent (EOM-S4) — degrade to prose.
      return AiResponse(
        text: prose.isEmpty ? raw.trim() : prose,
        intent: intent,
      );
    }
  }
}

/// Response from the AI service.
class AiResponse {
  const AiResponse({
    required this.text,
    required this.intent,
    this.tree,
    this.operation,
    this.isError = false,
    this.offerSettings = false,
  });

  final String text;
  final CognitiveIntent intent;
  final ThoughtNode? tree;

  /// Structured epistemic operation extracted from the response epilogue
  /// (EOM-T6 through EOM-T10). Null when the LLM omitted or malformed the
  /// epilogue — the prose UX is unaffected either way.
  final EpistemicOperation? operation;

  /// True when [text] is a provider/parsing error message rather than a
  /// real answer (EOM-S5). Error responses must not be appended to the
  /// conversation history or persisted to Hive.
  final bool isError;

  /// When true with [isError], the UI should offer Open Settings (EOM-S18).
  final bool offerSettings;
}

import 'package:flutter/foundation.dart';

import '../models/epistemic_node.dart';
import 'llm_provider.dart';
import 'sqlite_epistemic_graph_store.dart';

/// Gemini Nano Prompt API budget (ML Kit GenAI `genai-prompt:1.0.0-beta2`).
///
/// Documented input cap is 4000 tokens (~3000 English words). `getTokenLimit`
/// is input + output; `maxOutputTokens` must leave room for the prompt.
/// Vault retrieval is packed into the **dynamic suffix** so [PromptPrefix]
/// (compact system prompt) stays cacheable.
class OnDeviceContext {
  OnDeviceContext._();

  /// ML Kit documented input ceiling in English words.
  static const int maxInputWords = 3000;

  /// Current thought — long journal pastes must not fill Nano's window.
  static const int maxUserWords = 200;

  /// Each prior turn clipped independently (last two turns still apply).
  static const int maxHistoryMessageWords = 60;

  /// Packed `Known:` neighborhood from the epistemic graph.
  static const int maxVaultWords = 80;

  /// Per-node snippet inside [maxVaultWords].
  static const int maxNodeWords = 16;

  static const int retrieveDepth = 2;
  static const int retrieveRoots = 2;
  static const int retrieveTokenCap = 3;

  static const String vaultHeader = 'Known:';
  static const String thoughtHeader = 'Thought:';

  static final _wordSplit = RegExp(r'\s+');
  static final _tokenClean = RegExp(r'[^\p{L}\p{N}_-]', unicode: true);

  static const _stop = {
    'about',
    'after',
    'also',
    'been',
    'being',
    'does',
    'from',
    'have',
    'into',
    'just',
    'like',
    'more',
    'some',
    'than',
    'that',
    'them',
    'then',
    'this',
    'very',
    'were',
    'what',
    'when',
    'with',
    'your',
  };

  static int wordCount(String text) =>
      text.split(_wordSplit).where((w) => w.isNotEmpty).length;

  static String truncateWords(String text, int maxWords) {
    if (maxWords <= 0) return '';
    final trimmed = text.trim();
    if (trimmed.isEmpty) return '';
    final words = trimmed.split(_wordSplit).where((w) => w.isNotEmpty).toList();
    if (words.length <= maxWords) return trimmed;
    return words.take(maxWords).join(' ');
  }

  /// Longest distinctive tokens from [input] for FTS / substring search.
  static List<String> retrievalTokens(String input) {
    final raw = input
        .trim()
        .split(_wordSplit)
        .map((t) => t.replaceAll(_tokenClean, ''))
        .where((t) => t.length >= 4)
        .map((t) => t.toLowerCase())
        .where((t) => !_stop.contains(t))
        .toList();
    final ranked = [...raw]..sort((a, b) => b.length.compareTo(a.length));
    final seen = <String>{};
    final tokens = <String>[];
    for (final token in ranked) {
      if (seen.add(token)) tokens.add(token);
      if (tokens.length >= retrieveTokenCap) break;
    }
    return tokens;
  }

  static String packVault(Iterable<EpistemicNode> nodes) {
    final ordered = nodes.toList()
      ..sort((a, b) => b.confidence.compareTo(a.confidence));
    final lines = <String>[vaultHeader];
    var used = wordCount(vaultHeader);
    for (final node in ordered) {
      final snippet = truncateWords(node.content, maxNodeWords);
      if (snippet.isEmpty) continue;
      final line = '- ${node.type.name}: $snippet';
      final n = wordCount(line);
      if (used + n > maxVaultWords) break;
      lines.add(line);
      used += n;
    }
    if (lines.length == 1) return '';
    return lines.join('\n');
  }

  static String packUser({required String thought, String vault = ''}) {
    final clipped = truncateWords(thought, maxUserWords);
    final known = vault.trim();
    if (known.isEmpty) return clipped;
    return '$known\n\n$thoughtHeader\n$clipped';
  }

  static List<ChatMessage> clipHistory(List<ChatMessage> history) {
    final recent = OnDeviceProvider.truncateHistory(history);
    return [
      for (final message in recent)
        ChatMessage(
          role: message.role,
          content: truncateWords(message.content, maxHistoryMessageWords),
        ),
    ];
  }
}

/// Reads a small SQLite neighborhood for the on-device prompt suffix.
///
/// Failures return empty — retrieval must never block or fail an intent.
class VaultContextService {
  VaultContextService(this._store);

  final EpistemicGraphStore _store;

  Future<String> retrieve(String input) async {
    try {
      final tokens = OnDeviceContext.retrievalTokens(input);
      if (tokens.isEmpty) return '';

      final seen = <String>{};
      final roots = <EpistemicNode>[];
      for (final token in tokens) {
        for (final hit in await _store.search(token)) {
          if (seen.add(hit.id)) roots.add(hit);
          if (roots.length >= OnDeviceContext.retrieveRoots) break;
        }
        if (roots.length >= OnDeviceContext.retrieveRoots) break;
      }
      if (roots.isEmpty) return '';

      final packed = <EpistemicNode>[];
      final packedIds = <String>{};
      for (final root in roots) {
        final graph = await _store.traverse(
          root.id,
          depth: OnDeviceContext.retrieveDepth,
        );
        for (final node in graph.nodes) {
          if (packedIds.add(node.id)) packed.add(node);
        }
      }
      return OnDeviceContext.packVault(packed);
    } catch (e, st) {
      debugPrint('EOM: vault retrieve failed: $e\n$st');
      return '';
    }
  }
}

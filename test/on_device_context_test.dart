import 'package:eom/models/epistemic_node.dart';
import 'package:eom/models/epistemic_relationship.dart';
import 'package:eom/models/intent.dart';
import 'package:eom/services/ai_service.dart';
import 'package:eom/services/llm_provider.dart';
import 'package:eom/services/on_device_context.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/fake_on_device_llm.dart';
import 'helpers/in_memory_epistemic_store.dart';

void main() {
  group('OnDeviceContext', () {
    test('truncateWords keeps the first N words', () {
      expect(OnDeviceContext.truncateWords('one two three four', 2), 'one two');
      expect(OnDeviceContext.truncateWords('short', 8), 'short');
      expect(OnDeviceContext.truncateWords('  ', 3), '');
    });

    test('retrievalTokens prefers long distinctive words', () {
      expect(
        OnDeviceContext.retrievalTokens(
          'I keep losing focus at work after lunch',
        ),
        contains('focus'),
      );
      expect(
        OnDeviceContext.retrievalTokens('the and that with this'),
        isEmpty,
      );
    });

    test('packVault stays within the word budget and ranks by confidence', () {
      final packed = OnDeviceContext.packVault([
        EpistemicNode(
          content: 'Low confidence filler that should sort last',
          type: EpistemicNodeType.hypothesis,
          confidence: 0.2,
        ),
        EpistemicNode(
          content: 'Daily focus slips after lunch',
          type: EpistemicNodeType.belief,
          confidence: 0.9,
        ),
      ]);
      expect(packed, startsWith('Known:'));
      expect(packed.indexOf('focus slips'), lessThan(packed.indexOf('filler')));
      expect(
        OnDeviceContext.wordCount(packed),
        lessThanOrEqualTo(OnDeviceContext.maxVaultWords),
      );
    });

    test('packUser caps the thought and prefixes Known', () {
      final thought = List.filled(400, 'word').join(' ');
      final user = OnDeviceContext.packUser(
        thought: thought,
        vault: 'Known:\n- belief: prior',
      );
      expect(user, contains('Thought:'));
      expect(user, contains('Known:'));
      final thoughtPart = user.split('Thought:').last.trim();
      expect(
        OnDeviceContext.wordCount(thoughtPart),
        lessThanOrEqualTo(OnDeviceContext.maxUserWords),
      );
    });

    test('clipHistory keeps two turns and caps each message', () {
      final history = [
        for (var i = 0; i < 6; i++)
          ChatMessage.user(List.filled(80, 'm$i').join(' ')),
      ];
      final clipped = OnDeviceContext.clipHistory(history);
      expect(clipped, hasLength(4));
      expect(clipped.first.content, startsWith('m2'));
      for (final message in clipped) {
        expect(
          OnDeviceContext.wordCount(message.content),
          lessThanOrEqualTo(OnDeviceContext.maxHistoryMessageWords),
        );
      }
    });
  });

  group('VaultContextService', () {
    test('returns empty when nothing matches', () async {
      final snippet = await VaultContextService(
        InMemoryStore(),
      ).retrieve('I keep losing focus at work');
      expect(snippet, isEmpty);
    });

    test('packs a matching node and its depth-2 neighbor', () async {
      final store = InMemoryStore();
      final focus = EpistemicNode(
        content: 'Daily focus slips after lunch',
        type: EpistemicNodeType.belief,
        confidence: 0.8,
      );
      final sleep = EpistemicNode(
        content: 'Sleep debt undermines morning attention',
        type: EpistemicNodeType.hypothesis,
        confidence: 0.6,
      );
      store.nodes.addAll([focus, sleep]);
      store.edges.add(
        EpistemicRelationship(
          sourceId: focus.id,
          targetId: sleep.id,
          type: EpistemicRelationshipType.supports,
        ),
      );

      final snippet = await VaultContextService(
        store,
      ).retrieve('I keep losing focus at work');
      expect(snippet, contains('Known:'));
      expect(snippet, contains('focus slips'));
      expect(snippet, contains('Sleep debt'));
    });
  });

  group('AiService on-device packing', () {
    test('compact path truncates the thought and prepends vault', () async {
      final fake = FakeOnDeviceLlm();
      final service = AiService(provider: OnDeviceProvider(client: fake));
      final long = List.filled(400, 'word').join(' ');
      await service.process(
        long,
        CognitiveIntent.clarify,
        vaultContext: 'Known:\n- belief: prior focus slips',
      );
      expect(fake.lastUser, contains('Known:'));
      expect(fake.lastUser, contains('Thought:'));
      expect(fake.lastUser, isNot(contains(long)));
      expect(fake.lastSystem, contains('Known:'));
      expect(fake.lastSystem, isNot(contains('prior focus slips')));
      final thoughtPart = fake.lastUser!.split('Thought:').last.trim();
      expect(
        OnDeviceContext.wordCount(thoughtPart),
        lessThanOrEqualTo(OnDeviceContext.maxUserWords),
      );
    });

    test('cloud path leaves input and history untouched', () async {
      final capture = _CaptureProvider();
      final service = AiService(provider: capture);
      final long = List.filled(400, 'word').join(' ');
      final history = [ChatMessage.user(List.filled(80, 'prior').join(' '))];
      await service.process(
        long,
        CognitiveIntent.act,
        history: history,
        vaultContext: 'Known:\n- belief: ignored',
      );
      expect(capture.lastUser, long);
      expect(capture.lastHistory.single.content, history.single.content);
    });
  });
}

class _CaptureProvider implements LlmProvider {
  String? lastUser;
  List<ChatMessage> lastHistory = const [];

  @override
  Future<String> generate(
    String systemPrompt,
    String userMessage, {
    List<ChatMessage> history = const [],
  }) async {
    lastUser = userMessage;
    lastHistory = history;
    return 'ok';
  }
}

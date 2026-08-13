import 'package:eom/models/conversation.dart';
import 'package:eom/screens/home_screen.dart';
import 'package:eom/services/ai_service.dart';
import 'package:eom/services/history_service.dart';
import 'package:eom/services/llm_provider.dart';
import 'package:eom/theme/eom_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'in_memory_epistemic_store.dart';

class SilentLlmProvider implements LlmProvider {
  const SilentLlmProvider({this.reply = 'Quiet prose.'});

  final String reply;

  @override
  Future<String> generate(
    String systemPrompt,
    String userMessage, {
    List<ChatMessage> history = const [],
  }) async => reply;
}

class FakeHistoryService extends HistoryService {
  FakeHistoryService({this.items = const []});

  List<Conversation> items;
  int clearCalls = 0;

  @override
  List<Conversation> getConversations() => items;

  @override
  bool get hasConversations => items.isNotEmpty;

  @override
  Future<void> saveConversation({
    required String initialInput,
    required String intent,
    required String response,
  }) async {
    items = [
      Conversation(
        timestamp: DateTime.now(),
        initialInput: initialInput,
        intent: intent,
        response: response,
      ),
      ...items,
    ];
  }

  @override
  Future<void> clearHistory() async {
    clearCalls++;
    items = [];
  }
}

Finder richTextContaining(String needle) => find.byWidgetPredicate(
  (w) => w is RichText && w.text.toPlainText().contains(needle),
);

Finder fieldByHint(String hint) => find.byWidgetPredicate(
  (w) => w is TextField && w.decoration?.hintText == hint,
);

Future<void> pumpEomHome(
  WidgetTester tester, {
  required InMemoryStore store,
  HistoryService? history,
  LlmProvider? provider,
}) async {
  await tester.binding.setSurfaceSize(const Size(900, 1600));
  addTearDown(() => tester.binding.setSurfaceSize(null));
  await tester.pumpWidget(
    MaterialApp(
      theme: EomTheme.dark,
      home: HomeScreen(
        aiService: AiService(provider: provider ?? const SilentLlmProvider()),
        historyService: history ?? HistoryService(),
        epistemicStoreFactory: () async => store,
      ),
    ),
  );
  await tester.pump();
}

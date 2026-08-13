/// EOM-S24 — structural UX: F8 / F10 / F11 / F16.
library;

import 'package:eom/models/conversation.dart';
import 'package:eom/screens/history_screen.dart';
import 'package:eom/screens/home_screen.dart';
import 'package:eom/services/ai_service.dart';
import 'package:eom/services/history_service.dart';
import 'package:eom/services/llm_provider.dart';
import 'package:eom/services/settings_service.dart';
import 'package:eom/theme/eom_theme.dart';
import 'package:eom/widgets/epistemic_graph_view.dart';
import 'package:eom/widgets/response_card.dart';
import 'package:eom/widgets/thought_tree_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'helpers/in_memory_epistemic_store.dart';

class _ScriptedProvider implements LlmProvider {
  _ScriptedProvider(this.replies);
  final List<String> replies;
  int calls = 0;

  @override
  Future<String> generate(
    String systemPrompt,
    String userMessage, {
    List<ChatMessage> history = const [],
  }) async {
    final i = calls < replies.length ? calls : replies.length - 1;
    calls++;
    return replies[i];
  }
}

class _FakeHistory extends HistoryService {
  _FakeHistory({this.items = const []});
  List<Conversation> items;

  @override
  List<Conversation> getConversations() => items;

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
    items = [];
  }
}

Finder richTextContaining(String needle) => find.byWidgetPredicate(
  (w) => w is RichText && w.text.toPlainText().contains(needle),
);

void main() {
  late InMemoryStore store;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await SettingsService.init();
    await SettingsService.setGeminiKey('test-guide');
    store = InMemoryStore();
  });

  testWidgets('F8: History row reopens conversation on Home', (tester) async {
    final history = _FakeHistory(
      items: [
        Conversation(
          timestamp: DateTime(2026, 8, 6),
          initialInput: 'I feel scattered.',
          intent: 'clarify',
          response: 'What would focus look like today?',
        ),
      ],
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: EomTheme.dark,
        home: HomeScreen(
          aiService: AiService(provider: _ScriptedProvider(['unused'])),
          historyService: history,
          epistemicStoreFactory: () async => store,
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('History'));
    await tester.pumpAndSettle();
    expect(find.byType(HistoryScreen), findsOneWidget);

    await tester.tap(find.text('I feel scattered.'));
    await tester.pumpAndSettle();

    expect(find.byType(HomeScreen), findsOneWidget);
    expect(find.byType(HistoryScreen), findsNothing);
    expect(find.text('I feel scattered.'), findsOneWidget);
    expect(
      richTextContaining('What would focus look like today?'),
      findsOneWidget,
    );
  });

  testWidgets('F10: prior turns stay visible during multi-turn', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(900, 1600));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        theme: EomTheme.dark,
        home: HomeScreen(
          aiService: AiService(
            provider: _ScriptedProvider([
              'First reply about fear.',
              'Second reply naming one task.',
            ]),
          ),
          historyService: _FakeHistory(),
          epistemicStoreFactory: () async => store,
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).first, 'I switch projects.');
    await tester.pump();
    await tester.tap(find.text('Clarify'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).first, 'Still true.');
    await tester.pump();
    await tester.tap(find.text('Compress'));
    await tester.pumpAndSettle();

    expect(find.text('Earlier in this session'), findsOneWidget);
    expect(find.textContaining('First reply about fear.'), findsOneWidget);
    expect(richTextContaining('Second reply naming one task.'), findsOneWidget);
  });

  testWidgets('F11: Map frames tree; Connections collapsed by default', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(900, 1600));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        theme: EomTheme.dark,
        home: HomeScreen(
          aiService: AiService(
            provider: _ScriptedProvider([
              'Shape.\n${AiService.epistemicMarker}\n'
                  '{"label": "Focus", "children": [{"label": "Rest"}], '
                  '"relationships": [{"source": "Focus", "target": "Rest", '
                  '"type": "supports"}]}',
            ]),
          ),
          historyService: _FakeHistory(),
          epistemicStoreFactory: () async => store,
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).first, 'map me');
    await tester.pump();
    await tester.tap(find.text('Map'));
    await tester.pumpAndSettle();

    expect(find.text('Your map'), findsOneWidget);
    expect(find.byType(ThoughtTreeView), findsOneWidget);
    expect(find.text('Connections'), findsOneWidget);
    expect(find.byType(EpistemicGraphView), findsNothing);

    await tester.ensureVisible(find.text('Connections'));
    await tester.tap(find.text('Connections'));
    await tester.pumpAndSettle();
    expect(find.byType(EpistemicGraphView), findsOneWidget);
  });

  testWidgets('F16: New thought requires confirm', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: EomTheme.dark,
        home: HomeScreen(
          aiService: AiService(provider: _ScriptedProvider(['A reply.'])),
          historyService: _FakeHistory(),
          epistemicStoreFactory: () async => store,
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).first, 'Am I stuck?');
    await tester.pump();
    await tester.tap(find.text('Reflect'));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('New thought'));
    await tester.pumpAndSettle();
    expect(find.text('Start a new thought?'), findsOneWidget);

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(richTextContaining('A reply.'), findsOneWidget);

    await tester.tap(find.byTooltip('New thought'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('New thought').last);
    await tester.pumpAndSettle();
    expect(find.byType(ResponseCard), findsNothing);
    expect(find.text("What's on your mind?"), findsOneWidget);
  });
}

import 'package:eom/screens/home_screen.dart';
import 'package:eom/services/ai_service.dart';
import 'package:eom/services/history_service.dart';
import 'package:eom/services/llm_provider.dart';
import 'package:eom/services/settings_service.dart';
import 'package:eom/widgets/epistemic_graph_view.dart';
import 'package:eom/widgets/thought_tree_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'helpers/in_memory_epistemic_store.dart';

class _FakeProvider implements LlmProvider {
  _FakeProvider(this.payload);

  final String payload;

  @override
  Future<String> generate(
    String systemPrompt,
    String userMessage, {
    List<ChatMessage> history = const [],
  }) async => payload;
}

class _ThrowingProvider implements LlmProvider {
  @override
  Future<String> generate(
    String systemPrompt,
    String userMessage, {
    List<ChatMessage> history = const [],
  }) async => throw Exception('boom');
}

/// ResponseCard renders via RichText (markdown bold support), which
/// find.text does not match.
Finder richTextContaining(String needle) => find.byWidgetPredicate(
  (w) => w is RichText && w.text.toPlainText().contains(needle),
);

void main() {
  late InMemoryStore store;

  setUp(() async {
    // AiService's error path reads the active provider for its message.
    SharedPreferences.setMockInitialValues({});
    await SettingsService.init();
    store = InMemoryStore();
  });

  Future<void> pumpHome(WidgetTester tester, LlmProvider provider) async {
    // No Hive box is opened: the history save throws, is caught and logged
    // by design (EOM-S8), and graph persistence proceeds independently —
    // everything then runs on microtasks, so pumpAndSettle drains it all.
    await tester.pumpWidget(
      MaterialApp(
        home: HomeScreen(
          aiService: AiService(provider: provider),
          historyService: HistoryService(),
          epistemicStoreFactory: () async => store,
        ),
      ),
    );
  }

  Future<void> submit(
    WidgetTester tester,
    String intentLabel, {
    String input = 'my thought',
  }) async {
    await tester.enterText(find.byType(TextField), input);
    await tester.pump();
    await tester.tap(find.text(intentLabel));
    await tester.pumpAndSettle();
  }

  group('HomeScreen service injection (EOM-S12)', () {
    testWidgets('clarify renders prose and persists to graph and history', (
      tester,
    ) async {
      await pumpHome(
        tester,
        _FakeProvider(
          'Looks clearer.\n${AiService.epistemicMarker}\n'
          '{"clarified": "I value focus.", "confidence": 0.8, '
          '"keywords": ["focus"]}',
        ),
      );

      await submit(tester, 'Clarify');

      expect(richTextContaining('Looks clearer.'), findsOneWidget);
      expect(store.nodes.map((n) => n.content), contains('I value focus.'));
    });

    testWidgets('map renders the tree and loads the graph overlay', (
      tester,
    ) async {
      await pumpHome(
        tester,
        _FakeProvider(
          'Connected.\n${AiService.epistemicMarker}\n'
          '{"label": "Focus", "children": [{"label": "Rest"}], '
          '"relationships": [{"source": "Focus", "target": "Rest", '
          '"type": "supports"}]}',
        ),
      );

      await submit(tester, 'Map');
      // Overlay loads after processMap — another settle for the search +
      // traverse microtasks.
      await tester.pumpAndSettle();

      expect(find.byType(ThoughtTreeView), findsOneWidget);
      expect(store.nodes.map((n) => n.content), containsAll(['Focus', 'Rest']));
      expect(store.edges, hasLength(1));
      expect(find.byType(EpistemicGraphView), findsOneWidget);
    });

    testWidgets('provider errors render but save nothing (EOM-S5)', (
      tester,
    ) async {
      await pumpHome(tester, _ThrowingProvider());

      await submit(tester, 'Act');

      expect(richTextContaining('boom'), findsOneWidget);
      expect(store.nodes, isEmpty);
    });

    testWidgets('new-thought button clears the session', (tester) async {
      await pumpHome(tester, _FakeProvider('plain prose'));

      await submit(tester, 'Reflect');
      expect(richTextContaining('plain prose'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.refresh_outlined));
      await tester.pumpAndSettle();

      expect(richTextContaining('plain prose'), findsNothing);
      expect(find.text("What's on your mind?"), findsOneWidget);
    });

    testWidgets('store factory failures do not break the prose UX', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: HomeScreen(
            aiService: AiService(
              provider: _FakeProvider(
                'Prose.\n${AiService.epistemicMarker}\n'
                '{"clarified": "x", "keywords": ["k"]}',
              ),
            ),
            epistemicStoreFactory: () async => throw Exception('db down'),
          ),
        ),
      );

      await submit(tester, 'Clarify');

      expect(richTextContaining('Prose.'), findsOneWidget);
    });
  });
}

/// EOM-S23 T92–T96 — returning-user: multi-turn, History, New thought.
///
///   EOM_S23_LIVE=1 flutter test test/ux_eom_s23_returning_user_test.dart
///
/// Note: Home's History icon pushes `const HistoryScreen()` (no inject), so
/// History UX is walked with the same [HistoryService] instance Home saved to.
library;

import 'dart:io';

import 'package:eom/models/conversation.dart';
import 'package:eom/screens/history_screen.dart';
import 'package:eom/screens/home_screen.dart';
import 'package:eom/services/ai_service.dart';
import 'package:eom/services/history_service.dart';
import 'package:eom/services/llm_provider.dart';
import 'package:eom/services/settings_service.dart';
import 'package:eom/theme/eom_theme.dart';
import 'package:eom/widgets/response_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'helpers/in_memory_epistemic_store.dart';

class _ScriptedProvider implements LlmProvider {
  _ScriptedProvider(this.replies);
  final List<String> replies;
  int calls = 0;
  final List<int> historyLens = [];

  @override
  Future<String> generate(
    String systemPrompt,
    String userMessage, {
    List<ChatMessage> history = const [],
  }) async {
    historyLens.add(history.length);
    final i = calls < replies.length ? calls : replies.length - 1;
    calls++;
    return replies[i];
  }
}

class _FakeHistory extends HistoryService {
  _FakeHistory({this.items = const []});
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

void main() {
  final live = Platform.environment['EOM_S23_LIVE'] == '1';
  late InMemoryStore store;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await SettingsService.init();
    await SettingsService.setGeminiKey('test-guide');
    store = InMemoryStore();
  });

  testWidgets(
    'EOM-S23 T92: multi-turn keeps prior turns visible (F10/S24)',
    (tester) async {
      if (!live) return;
      await tester.binding.setSurfaceSize(const Size(900, 1600));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final provider = _ScriptedProvider([
        'First turn: fear may be louder than boredom.',
        'Second turn: name one unfinished thing.',
        'Third turn: close a 10-minute loop.',
      ]);
      final history = _FakeHistory();

      await tester.pumpWidget(
        MaterialApp(
          theme: EomTheme.dark,
          home: HomeScreen(
            aiService: AiService(provider: provider),
            historyService: history,
            epistemicStoreFactory: () async => store,
          ),
        ),
      );
      await tester.pumpAndSettle();

      Future<void> runIntent(String label, String text) async {
        await tester.enterText(find.byType(TextField).first, text);
        await tester.pump();
        await tester.tap(find.text(label));
        await tester.pumpAndSettle();
      }

      await runIntent('Clarify', 'I keep switching projects.');
      expect(
        richTextContaining('First turn: fear may be louder'),
        findsOneWidget,
      );

      await runIntent('Compress', 'Still true — maybe fear.');
      expect(richTextContaining('Second turn: name one'), findsOneWidget);
      expect(find.text('Earlier in this session'), findsOneWidget);
      expect(
        find.textContaining('First turn: fear may be louder'),
        findsOneWidget,
      );
      expect(find.byType(ResponseCard), findsOneWidget);

      await runIntent('Act', 'What is one small close?');
      expect(
        richTextContaining('Third turn: close a 10-minute'),
        findsOneWidget,
      );
      // F10 fixed in S24 — prior turns remain on screen.
      expect(find.text('Earlier in this session'), findsOneWidget);
      expect(
        find.textContaining('First turn: fear may be louder'),
        findsOneWidget,
      );
      expect(find.textContaining('Second turn: name one'), findsOneWidget);
      expect(provider.historyLens.last, greaterThanOrEqualTo(4));
      expect(history.items.length, 3);

      // ignore: avoid_print
      print(
        'EOM-S23 NOTE: T92: 3 follow-ups; prior turns visible (F10/S24); '
        'provider historyLens=${provider.historyLens}; '
        'saved=${history.items.length}',
      );
    },
    skip: !live,
    timeout: const Timeout(Duration(minutes: 2)),
  );

  testWidgets(
    'EOM-S23 T93–T94: History row returns Conversation; Clear confirms',
    (tester) async {
      if (!live) return;
      await tester.binding.setSurfaceSize(const Size(900, 1600));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final history = _FakeHistory(
        items: [
          Conversation(
            timestamp: DateTime(2026, 8, 6, 21),
            initialInput: 'I keep switching projects.',
            intent: 'clarify',
            response: 'Fear may be louder than boredom.',
          ),
          Conversation(
            timestamp: DateTime(2026, 8, 6, 21, 5),
            initialInput: 'Still true — maybe fear.',
            intent: 'compress',
            response: 'Name one unfinished thing.',
          ),
        ],
      );

      Conversation? selected;
      await tester.pumpWidget(
        MaterialApp(
          theme: EomTheme.dark,
          home: Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                onPressed: () async {
                  selected = await Navigator.push<Conversation>(
                    context,
                    MaterialPageRoute(
                      builder: (_) => HistoryScreen(historyService: history),
                    ),
                  );
                },
                child: const Text('open-history'),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('open-history'));
      await tester.pumpAndSettle();

      expect(find.text('I keep switching projects.'), findsOneWidget);
      await tester.tap(find.text('I keep switching projects.'));
      await tester.pumpAndSettle();
      expect(selected?.initialInput, 'I keep switching projects.');
      expect(find.text('open-history'), findsOneWidget);
      // ignore: avoid_print
      print('EOM-S23 NOTE: T93: row tap returns Conversation to Home (F8/S24)');

      await tester.tap(find.text('open-history'));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Clear History'));
      await tester.pumpAndSettle();
      expect(find.text('Clear history?'), findsOneWidget);
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(history.clearCalls, 0);
      expect(history.items, isNotEmpty);

      await tester.tap(find.byTooltip('Clear History'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Clear'));
      await tester.pumpAndSettle();
      expect(history.clearCalls, 1);
      expect(history.items, isEmpty);
      expect(find.text('Capture a thought'), findsOneWidget);
      // ignore: avoid_print
      print(
        'EOM-S23 NOTE: T94: Clear confirms; Cancel safe; Clear empties '
        '(F9 mitigated by S19)',
      );
    },
    skip: !live,
    timeout: const Timeout(Duration(minutes: 2)),
  );

  testWidgets(
    'EOM-S23 T95–T96: New thought confirms before reset (F16/S24)',
    (tester) async {
      if (!live) return;
      await tester.binding.setSurfaceSize(const Size(900, 1600));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        MaterialApp(
          theme: EomTheme.dark,
          home: HomeScreen(
            aiService: AiService(
              provider: _ScriptedProvider(['A provisional reflection.']),
            ),
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
      expect(richTextContaining('A provisional reflection.'), findsOneWidget);

      await tester.tap(find.byTooltip('New thought'));
      await tester.pumpAndSettle();
      expect(find.text('Start a new thought?'), findsOneWidget);
      await tester.tap(find.text('New thought').last);
      await tester.pumpAndSettle();
      expect(richTextContaining('A provisional reflection.'), findsNothing);
      expect(find.text("What's on your mind?"), findsOneWidget);
      expect(find.byType(ResponseCard), findsNothing);

      // ignore: avoid_print
      print('EOM-S23 NOTE: T95: New thought confirms then clears (F16/S24)');
      // ignore: avoid_print
      print('EOM-S23 NOTE: T96: Structural F8/F10/F11/F16 closed by EOM-S24');
    },
    skip: !live,
    timeout: const Timeout(Duration(minutes: 2)),
  );
}

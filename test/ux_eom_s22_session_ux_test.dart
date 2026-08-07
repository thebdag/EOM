/// EOM-S22 session UX walk (widget) — Map hierarchy + Act sage accent.
///
/// Live LLM prose is covered by `ux_eom_s22_live_provider_test.dart`.
/// This file checks response chrome under Epistemic Calm with fakes.
///
///   EOM_S22_LIVE=1 flutter test test/ux_eom_s22_session_ux_test.dart
library;

import 'dart:io';

import 'package:eom/models/intent.dart';
import 'package:eom/screens/home_screen.dart';
import 'package:eom/services/ai_service.dart';
import 'package:eom/services/history_service.dart';
import 'package:eom/services/llm_provider.dart';
import 'package:eom/services/settings_service.dart';
import 'package:eom/theme/eom_colors.dart';
import 'package:eom/theme/eom_theme.dart';
import 'package:eom/widgets/epistemic_graph_view.dart';
import 'package:eom/widgets/intent_button.dart';
import 'package:eom/widgets/response_card.dart';
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

Finder richTextContaining(String needle) => find.byWidgetPredicate(
  (w) => w is RichText && w.text.toPlainText().contains(needle),
);

void main() {
  final live = Platform.environment['EOM_S22_LIVE'] == '1';
  late InMemoryStore store;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await SettingsService.init();
    store = InMemoryStore();
  });

  Future<void> pumpHome(WidgetTester tester, LlmProvider provider) async {
    await tester.binding.setSurfaceSize(const Size(900, 1600));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    store = InMemoryStore();
    await tester.pumpWidget(
      MaterialApp(
        theme: EomTheme.dark,
        home: HomeScreen(
          aiService: AiService(provider: provider),
          historyService: _NoopHistory(),
          epistemicStoreFactory: () async => store,
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> submit(WidgetTester tester, String intentLabel) async {
    await tester.enterText(
      find.byType(TextField).first,
      'I keep switching projects.',
    );
    await tester.pump();
    await tester.tap(find.text(intentLabel));
    await tester.pumpAndSettle();
  }

  testWidgets('EOM-S22 T88: Map tree + overlay stack (F11)', (tester) async {
    if (!live) return;
    await pumpHome(
      tester,
      _FakeProvider(
        'Here is the shape of it.\n${AiService.epistemicMarker}\n'
        '{"label": "Unfinished work", "children": ['
        '{"label": "Fear"}, {"label": "Boredom"}], '
        '"relationships": ['
        '{"source": "Unfinished work", "target": "Fear", "type": "supports"},'
        '{"source": "Unfinished work", "target": "Boredom", "type": "supports"}'
        ']}',
      ),
    );
    await submit(tester, 'Map');
    await tester.pumpAndSettle();

    expect(find.byType(ThoughtTreeView), findsOneWidget);
    expect(find.text('Your map'), findsOneWidget);
    expect(find.text('Connections'), findsOneWidget);
    expect(find.byType(EpistemicGraphView), findsNothing);

    await tester.ensureVisible(find.text('Connections'));
    await tester.tap(find.text('Connections'));
    await tester.pumpAndSettle();
    expect(find.byType(EpistemicGraphView), findsOneWidget);
    expect(find.byType(ResponseCard), findsOneWidget);
    // ignore: avoid_print
    print('EOM-S22 NOTE: T88: Your map + collapsible Connections (F11 framed)');
  }, skip: !live);

  testWidgets('EOM-S22 T90: Act sage accent readable', (tester) async {
    if (!live) return;
    await pumpHome(tester, _FakeProvider('Try one small close today.'));
    await submit(tester, 'Act');

    final actBtn = tester.widget<IntentButton>(
      find.ancestor(of: find.text('Act'), matching: find.byType(IntentButton)),
    );
    expect(actBtn.intent.color, EomColors.sage);
    expect(actBtn.isSelected, isTrue);
    expect(find.byType(ResponseCard), findsOneWidget);
    expect(richTextContaining('Try one small close today.'), findsOneWidget);
    // ignore: avoid_print
    print(
      'EOM-S22 NOTE: T90: Act IntentButton uses sage; ResponseCard present '
      'and readable on dark surface',
    );
  }, skip: !live);

  testWidgets('EOM-S22 T87: Compress is single scannable card', (tester) async {
    if (!live) return;
    await pumpHome(
      tester,
      _FakeProvider('Fear of finishing. Boredom when stuck.'),
    );
    await submit(tester, 'Compress');
    expect(find.byType(ResponseCard), findsOneWidget);
    expect(find.byType(ThoughtTreeView), findsNothing);
    // ignore: avoid_print
    print(
      'EOM-S22 NOTE: T87: Compress is single ResponseCard, no tree/overlay',
    );
  }, skip: !live);
}

class _NoopHistory extends HistoryService {
  @override
  Future<void> saveConversation({
    required String initialInput,
    required String intent,
    required String response,
  }) async {}
}

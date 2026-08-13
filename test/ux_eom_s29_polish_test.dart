/// EOM-S29 — spirit polish F12–F15. No LLM.
library;

import 'dart:math' as math;

import 'package:eom/models/conversation.dart';
import 'package:eom/models/intent.dart';
import 'package:eom/screens/history_screen.dart';
import 'package:eom/screens/home_screen.dart';
import 'package:eom/services/ai_service.dart';
import 'package:eom/services/history_service.dart';
import 'package:eom/services/llm_provider.dart';
import 'package:eom/services/settings_service.dart';
import 'package:eom/theme/eom_colors.dart';
import 'package:eom/theme/eom_shapes.dart';
import 'package:eom/theme/eom_theme.dart';
import 'package:eom/widgets/response_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'helpers/in_memory_epistemic_store.dart';

class _SilentProvider implements LlmProvider {
  @override
  Future<String> generate(
    String systemPrompt,
    String userMessage, {
    List<ChatMessage> history = const [],
  }) async => 'Quiet prose.';
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

double _linear(double srgb) {
  return srgb <= 0.03928
      ? srgb / 12.92
      : math.pow((srgb + 0.055) / 1.055, 2.4).toDouble();
}

double _luminance(Color c) {
  return 0.2126 * _linear(c.r) + 0.7152 * _linear(c.g) + 0.0722 * _linear(c.b);
}

double contrastRatio(Color a, Color b) {
  final l1 = _luminance(a);
  final l2 = _luminance(b);
  final hi = math.max(l1, l2);
  final lo = math.min(l1, l2);
  return (hi + 0.05) / (lo + 0.05);
}

void main() {
  late InMemoryStore store;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await SettingsService.init();
    await SettingsService.setGeminiKey('test-guide');
    store = InMemoryStore();
  });

  Future<void> pumpHome(WidgetTester tester, {HistoryService? history}) async {
    await tester.binding.setSurfaceSize(const Size(900, 1600));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      MaterialApp(
        theme: EomTheme.dark,
        home: HomeScreen(
          aiService: AiService(provider: _SilentProvider()),
          historyService: history ?? _FakeHistory(),
          epistemicStoreFactory: () async => store,
        ),
      ),
    );
    await tester.pump();
  }

  test('T122: textTertiary meets WCAG AA on field and surface', () {
    expect(
      contrastRatio(EomColors.textTertiary, EomColors.background),
      greaterThanOrEqualTo(4.5),
    );
    expect(
      contrastRatio(EomColors.textTertiary, EomColors.surface),
      greaterThanOrEqualTo(4.5),
    );
    expect(EomColors.textTertiary, isNot(const Color(0xFF64748B)));
  });

  test('T124: displayName humanizes persisted intent ids', () {
    expect(CognitiveIntent.displayName('clarify'), 'Clarify');
    expect(CognitiveIntent.displayName('compress'), 'Compress');
    expect(CognitiveIntent.displayName(''), '');
    expect(CognitiveIntent.displayName('mystery'), 'Mystery');
  });

  testWidgets('T123: blank-input intent tap shows a calm hint', (tester) async {
    await pumpHome(tester);
    await tester.enterText(find.byType(TextField).first, 'a thought');
    await tester.pump();
    await tester.tap(find.text('Clarify'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).first, '');
    await tester.pump();
    await tester.tap(find.text('Clarify'));
    await tester.pump();

    expect(find.text('Write a thought first.'), findsOneWidget);
    expect(richTextContaining('Quiet prose.'), findsOneWidget);
  });

  testWidgets('T124: History shows Clarify and Read more', (tester) async {
    final long = List.filled(8, 'A longer line of saved prose.').join('\n');
    await tester.pumpWidget(
      MaterialApp(
        theme: EomTheme.dark,
        home: HistoryScreen(
          historyService: _FakeHistory(
            items: [
              Conversation(
                timestamp: DateTime(2026, 8, 12),
                initialInput: 'scattered',
                intent: 'clarify',
                response: long,
              ),
            ],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Clarify'), findsOneWidget);
    expect(find.text('clarify'), findsNothing);
    expect(find.text('Read more'), findsOneWidget);

    await tester.tap(find.text('Read more'));
    await tester.pump();
    expect(find.text('Show less'), findsOneWidget);
    expect(find.textContaining('A longer line of saved prose.'), findsWidgets);
  });

  testWidgets('T125: History pip when the library has rows', (tester) async {
    await pumpHome(tester);
    expect(find.byKey(const Key('history-presence')), findsNothing);
  });

  testWidgets('T125: History pip appears when rows exist', (tester) async {
    await pumpHome(
      tester,
      history: _FakeHistory(
        items: [
          Conversation(
            timestamp: DateTime(2026, 8, 12),
            initialInput: 'kept',
            intent: 'clarify',
            response: 'kept reply',
          ),
        ],
      ),
    );
    expect(find.byKey(const Key('history-presence')), findsOneWidget);
    expect(find.byTooltip('History'), findsOneWidget);
    expect(find.byTooltip('Settings'), findsOneWidget);
  });

  testWidgets('T126: map labels use orientation serif; response uses leaf', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(900, 1600));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      MaterialApp(
        theme: EomTheme.dark,
        home: HomeScreen(
          aiService: AiService(provider: _MapProvider()),
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

    final mapLabel = tester.widget<Text>(find.text('Your map'));
    expect(mapLabel.style?.fontFamily, eomDisplaySerif);
    final connections = tester.widget<Text>(find.text('Connections'));
    expect(connections.style?.fontFamily, eomDisplaySerif);

    final frames = tester.widgetList<Container>(find.byType(Container)).where((
      c,
    ) {
      final d = c.decoration;
      return d is BoxDecoration && d.borderRadius == EomShapes.leafRadius;
    });
    expect(frames, isNotEmpty);
    expect(find.byType(ResponseCard), findsOneWidget);
  });
}

class _MapProvider implements LlmProvider {
  @override
  Future<String> generate(
    String systemPrompt,
    String userMessage, {
    List<ChatMessage> history = const [],
  }) async =>
      'Shape.\n${AiService.epistemicMarker}\n'
      '{"label": "Focus", "children": [{"label": "Rest"}], '
      '"relationships": [{"source": "Focus", "target": "Rest", '
      '"type": "supports"}]}';
}

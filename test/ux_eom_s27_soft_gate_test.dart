/// EOM-S27 — soft first-run provider gate (F1 / F5). No LLM.
library;

import 'package:eom/models/llm_provider_kind.dart';
import 'package:eom/screens/home_screen.dart';
import 'package:eom/services/ai_service.dart';
import 'package:eom/services/history_service.dart';
import 'package:eom/services/llm_provider.dart';
import 'package:eom/services/settings_service.dart';
import 'package:eom/theme/eom_theme.dart';
import 'package:eom/widgets/empty_vault_panel.dart';
import 'package:eom/widgets/soft_gate_sheet.dart';
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

Finder richTextContaining(String needle) => find.byWidgetPredicate(
  (w) => w is RichText && w.text.toPlainText().contains(needle),
);

Finder fieldByHint(String hint) => find.byWidgetPredicate(
  (w) => w is TextField && w.decoration?.hintText == hint,
);

void main() {
  late InMemoryStore store;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await SettingsService.init();
    store = InMemoryStore();
  });

  Future<void> pumpHome(WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(900, 1600));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      MaterialApp(
        theme: EomTheme.dark,
        home: HomeScreen(
          aiService: AiService(provider: _SilentProvider()),
          historyService: HistoryService(),
          epistemicStoreFactory: () async => store,
        ),
      ),
    );
    await tester.pump();
  }

  testWidgets('T113: Connect CTA opens the soft-gate sheet, not Settings', (
    tester,
  ) async {
    await pumpHome(tester);
    await tester.tap(find.text('Connect a guide'));
    await tester.pumpAndSettle();

    expect(find.byType(SoftGateSheet), findsOneWidget);
    expect(find.text('AI Configuration'), findsNothing);
    expect(find.byType(DropdownButton<LlmProviderKind>), findsOneWidget);
    expect(fieldByHint('API Key'), findsOneWidget);
  });

  testWidgets(
    'T114: intent without a key opens the same sheet (no error card)',
    (tester) async {
      await pumpHome(tester);
      await tester.enterText(find.byType(TextField), 'a thought');
      await tester.pump();
      await tester.tap(find.text('Clarify'));
      await tester.pumpAndSettle();

      expect(find.byType(SoftGateSheet), findsOneWidget);
      expect(richTextContaining('Add an API key in Settings'), findsNothing);
      expect(find.text('Open Settings'), findsNothing);
    },
  );

  testWidgets('T115: Connect persists and shows a calm confirm', (
    tester,
  ) async {
    await pumpHome(tester);
    await tester.tap(find.text('Connect a guide'));
    await tester.pumpAndSettle();

    await tester.enterText(fieldByHint('API Key'), 'sk-gemini');
    await tester.tap(find.byKey(const Key('soft-gate-connect')));
    await tester.pumpAndSettle();

    expect(find.byType(SoftGateSheet), findsNothing);
    expect(SettingsService.hasUsableGuide, isTrue);
    expect(SettingsService.geminiKey, 'sk-gemini');
    expect(find.text('Guide connected.'), findsOneWidget);
    expect(find.text('Connect a guide'), findsNothing);
    expect(find.byType(EmptyVaultPanel), findsOneWidget);
  });

  testWidgets('T115: LiteLLM master key persists as the active guide', (
    tester,
  ) async {
    await pumpHome(tester);
    await tester.tap(find.text('Connect a guide'));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(DropdownButton<LlmProviderKind>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('LiteLLM').last);
    await tester.pumpAndSettle();

    await tester.enterText(fieldByHint('Master Key (required)'), 'master');
    await tester.pump();
    await tester.tap(find.byKey(const Key('soft-gate-connect')));
    await tester.pumpAndSettle();

    expect(SettingsService.activeProvider, LlmProviderKind.local);
    expect(SettingsService.localApiKey, 'master');
    expect(SettingsService.hasUsableGuide, isTrue);
  });

  testWidgets(
    'T116: dismiss without Connect does not persist or fail silently',
    (tester) async {
      await pumpHome(tester);
      await tester.enterText(find.byType(TextField), 'a thought');
      await tester.pump();
      await tester.tap(find.text('Clarify'));
      await tester.pumpAndSettle();

      Navigator.of(tester.element(find.byType(SoftGateSheet))).pop();
      await tester.pumpAndSettle();

      expect(find.byType(SoftGateSheet), findsNothing);
      expect(SettingsService.hasUsableGuide, isFalse);
      expect(richTextContaining('Add an API key in Settings'), findsNothing);
      expect(find.text('Connect a guide'), findsOneWidget);
    },
  );

  testWidgets('T116: connecting from an intent continues the intent', (
    tester,
  ) async {
    await pumpHome(tester);
    await tester.enterText(find.byType(TextField), 'a thought');
    await tester.pump();
    await tester.tap(find.text('Clarify'));
    await tester.pumpAndSettle();

    await tester.enterText(fieldByHint('API Key'), 'sk-gemini');
    await tester.tap(find.byKey(const Key('soft-gate-connect')));
    await tester.pumpAndSettle();

    expect(richTextContaining('Quiet prose.'), findsOneWidget);
    expect(find.byType(SoftGateSheet), findsNothing);
  });
}

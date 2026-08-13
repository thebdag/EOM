/// EOM-S26 — ceremonial empty state (no LLM).
///
/// Spirit walk (T111): first paint is a quiet vault room — serif EOM, leaf
/// panel, deferred intents, gold only on brand + Connect CTA.
library;

import 'package:eom/screens/home_screen.dart';
import 'package:eom/services/ai_service.dart';
import 'package:eom/services/history_service.dart';
import 'package:eom/services/llm_provider.dart';
import 'package:eom/services/settings_service.dart';
import 'package:eom/theme/eom_colors.dart';
import 'package:eom/theme/eom_shapes.dart';
import 'package:eom/theme/eom_theme.dart';
import 'package:eom/widgets/empty_vault_panel.dart';
import 'package:eom/widgets/intent_button.dart';
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

  testWidgets('T107: serif EOM, expansive hint, vault-room empty canvas', (
    tester,
  ) async {
    await pumpHome(tester);

    final brand = tester.widget<Text>(find.text('EOM'));
    expect(brand.style?.fontFamily, eomDisplaySerif);
    expect(brand.style?.fontSize, 22);

    expect(find.text("What's on your mind?"), findsOneWidget);
    final field = tester.widget<TextField>(find.byType(TextField));
    expect(field.minLines, 8);
    expect(field.decoration?.hintStyle?.fontSize, 20);

    expect(find.byType(EmptyVaultPanel), findsOneWidget);
    expect(find.byType(IntentButton), findsNothing);
  });

  testWidgets('T108: leaf framing on empty panel only, never on pills', (
    tester,
  ) async {
    await pumpHome(tester);

    final panel = tester.widget<Container>(
      find.byKey(const Key('empty-vault-frame')),
    );
    final decoration = panel.decoration as BoxDecoration;
    expect(decoration.borderRadius, EomShapes.leafRadius);
    expect(find.byType(IntentButton), findsNothing);

    await tester.enterText(find.byType(TextField), 'a thought');
    await tester.pump();

    expect(find.byType(EmptyVaultPanel), findsOneWidget);
    expect(find.byType(IntentButton), findsNWidgets(5));
    expect(
      find.descendant(
        of: find.byType(EmptyVaultPanel),
        matching: find.byType(IntentButton),
      ),
      findsNothing,
    );
  });

  testWidgets('T109: gold on brand mark and Connect CTA only', (tester) async {
    await pumpHome(tester);

    final mark = tester.widget<Container>(find.byKey(const Key('brand-mark')));
    expect((mark.decoration as BoxDecoration).color, EomColors.gold);

    final connect = tester.widget<TextButton>(
      find.widgetWithText(TextButton, 'Connect a guide'),
    );
    expect(connect.style?.foregroundColor?.resolve({}), EomColors.gold);

    final history = tester.widget<IconButton>(
      find.widgetWithIcon(IconButton, Icons.history_outlined),
    );
    expect(history.color, EomColors.textTertiary);

    final settings = tester.widget<IconButton>(
      find.widgetWithIcon(IconButton, Icons.settings_outlined),
    );
    expect(settings.color, EomColors.textTertiary);

    await tester.enterText(find.byType(TextField), 'a thought');
    await tester.pump();
    for (final button in tester.widgetList<IntentButton>(
      find.byType(IntentButton),
    )) {
      expect(button.intent.color, isNot(EomColors.gold));
    }
  });

  testWidgets('T110: Connect CTA when no key; hidden when guide is usable', (
    tester,
  ) async {
    await pumpHome(tester);
    expect(find.text('Connect a guide'), findsOneWidget);

    await tester.tap(find.text('Connect a guide'));
    await tester.pumpAndSettle();
    expect(find.byType(SoftGateSheet), findsOneWidget);
    expect(find.text('AI Configuration'), findsNothing);

    Navigator.of(tester.element(find.byType(SoftGateSheet))).pop();
    await tester.pumpAndSettle();
    expect(find.text('Connect a guide'), findsOneWidget);

    await SettingsService.setGeminiKey('sk-test');
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
    expect(find.text('Connect a guide'), findsNothing);
    expect(find.byType(EmptyVaultPanel), findsOneWidget);
  });

  testWidgets('T111: first paint needs no LLM; leaf gone after a response', (
    tester,
  ) async {
    await pumpHome(tester);

    expect(find.byType(EmptyVaultPanel), findsOneWidget);
    expect(find.text('Connect a guide'), findsOneWidget);
    expect(find.byType(IntentButton), findsNothing);
    expect(richTextContaining('Quiet prose.'), findsNothing);

    await SettingsService.setGeminiKey('sk-test');
    await tester.enterText(find.byType(TextField), 'a thought');
    await tester.pump();
    await tester.tap(find.text('Clarify'));
    await tester.pumpAndSettle();

    expect(richTextContaining('Quiet prose.'), findsOneWidget);
    expect(find.byType(EmptyVaultPanel), findsNothing);
    expect(find.text('Connect a guide'), findsNothing);
  });
}

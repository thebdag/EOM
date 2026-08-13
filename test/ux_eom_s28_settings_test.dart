/// EOM-S28 — calm Settings active-only redesign (F4). No LLM.
library;

import 'package:eom/models/llm_provider_kind.dart';
import 'package:eom/screens/settings_screen.dart';
import 'package:eom/services/settings_service.dart';
import 'package:eom/theme/eom_theme.dart';
import 'package:eom/widgets/guide_fields.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

Finder fieldByHint(String hint) => find.byWidgetPredicate(
  (w) => w is TextField && w.decoration?.hintText == hint,
);

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await SettingsService.init();
  });

  Future<void> pumpSettings(WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(900, 1600));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      MaterialApp(theme: EomTheme.dark, home: const SettingsScreen()),
    );
    await tester.pump();
  }

  Future<void> pushSettings(WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(900, 1600));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      MaterialApp(
        theme: EomTheme.dark,
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            ),
            child: const Text('open settings'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open settings'));
    await tester.pumpAndSettle();
  }

  Future<void> selectProvider(WidgetTester tester, String label) async {
    await tester.tap(find.byType(DropdownButton<LlmProviderKind>));
    await tester.pumpAndSettle();
    await tester.tap(find.text(label).last);
    await tester.pumpAndSettle();
  }

  testWidgets('T119: quiet Settings title; Guide, not AI Configuration', (
    tester,
  ) async {
    await pumpSettings(tester);

    expect(find.widgetWithText(AppBar, 'Settings'), findsOneWidget);
    expect(find.text('AI Configuration'), findsNothing);
    expect(find.text('Guide'), findsOneWidget);
    expect(find.text('ACTIVE PROVIDER'), findsNothing);
    expect(find.text('OPENAI'), findsNothing);
    expect(find.text('ANTHROPIC'), findsNothing);
    expect(find.text('GOOGLE GEMINI'), findsNothing);
    expect(find.text('LITELLM'), findsNothing);
  });

  testWidgets('T117: essential key for the active provider only', (
    tester,
  ) async {
    await pumpSettings(tester);

    expect(fieldByHint('API Key'), findsOneWidget);
    expect(fieldByHint('API Key (sk-...)'), findsNothing);
    expect(fieldByHint('API Key (sk-ant-...)'), findsNothing);
    expect(fieldByHint('Master Key (required)'), findsNothing);
    expect(find.byType(GuideKeyField), findsOneWidget);

    await selectProvider(tester, 'OpenAI');
    expect(fieldByHint('API Key (sk-...)'), findsOneWidget);
    expect(fieldByHint('API Key'), findsNothing);
    expect(fieldByHint('Master Key (required)'), findsNothing);

    await selectProvider(tester, 'LiteLLM');
    expect(fieldByHint('Master Key (required)'), findsOneWidget);
    expect(fieldByHint('API Key'), findsNothing);
    expect(fieldByHint('API Key (sk-...)'), findsNothing);
  });

  testWidgets('T118: gateway and model alias stay under collapsed Advanced', (
    tester,
  ) async {
    await pumpSettings(tester);

    expect(find.text('Advanced'), findsOneWidget);
    expect(
      fieldByHint('Gateway Origin (e.g., http://127.0.0.1:4000)'),
      findsNothing,
    );
    expect(fieldByHint('Model Alias (e.g., qwen-smart)'), findsNothing);

    await tester.tap(find.text('Advanced'));
    await tester.pumpAndSettle();

    expect(
      fieldByHint('Gateway Origin (e.g., http://127.0.0.1:4000)'),
      findsOneWidget,
    );
    expect(fieldByHint('Model Alias (e.g., qwen-smart)'), findsOneWidget);
  });

  testWidgets('T118: Advanced host and alias persist on pop', (tester) async {
    await pushSettings(tester);
    await tester.tap(find.text('Advanced'));
    await tester.pumpAndSettle();
    await tester.enterText(
      fieldByHint('Gateway Origin (e.g., http://127.0.0.1:4000)'),
      'http://192.168.2.99:4000',
    );
    await tester.enterText(
      fieldByHint('Model Alias (e.g., qwen-smart)'),
      'auto',
    );
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();

    expect(SettingsService.localHost, 'http://192.168.2.99:4000');
    expect(SettingsService.localModel, 'auto');
  });

  testWidgets('T120: Settings reuses shared guide field widgets', (
    tester,
  ) async {
    await pumpSettings(tester);
    expect(find.byType(ProviderPicker), findsOneWidget);
    expect(find.byType(GuideKeyField), findsOneWidget);
    expect(find.byType(EomSurfaceField), findsOneWidget);
  });

  testWidgets('T121: quiet Epiture lineage in the Settings footer', (
    tester,
  ) async {
    await pumpSettings(tester);
    expect(find.text('Kin to Epiture.'), findsOneWidget);
  });

  testWidgets('T117: hidden inactive keys survive pop', (tester) async {
    await SettingsService.setOpenAiKey('sk-keep');
    await pushSettings(tester);
    expect(fieldByHint('API Key (sk-...)'), findsNothing);
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    expect(SettingsService.openAiKey, 'sk-keep');
  });
}

import 'package:eom/models/llm_provider_kind.dart';
import 'package:eom/screens/settings_screen.dart';
import 'package:eom/services/settings_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'helpers/guide_prefs.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await SettingsService.init();
    await persistGeminiGuideWithoutKey();
  });

  Future<void> pushSettings(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
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

  Finder fieldByHint(String hint) => find.byWidgetPredicate(
    (w) => w is TextField && w.decoration?.hintText == hint,
  );

  testWidgets('edits persist on Android system back (EOM-S6)', (tester) async {
    await pushSettings(tester);

    await tester.tap(find.byType(DropdownButton<LlmProviderKind>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('LiteLLM').last);
    await tester.pumpAndSettle();
    await tester.enterText(fieldByHint('Master Key (required)'), 'sk-test-1');
    await tester.pageBack();
    await tester.pumpAndSettle();

    expect(find.widgetWithText(AppBar, 'Settings'), findsNothing);
    expect(SettingsService.localApiKey, 'sk-test-1');
    expect(SettingsService.activeProvider, LlmProviderKind.local);
  });

  testWidgets('edits persist on the AppBar back button', (tester) async {
    await pushSettings(tester);

    await tester.enterText(fieldByHint('API Key'), 'gemini-key-2');
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();

    expect(SettingsService.geminiKey, 'gemini-key-2');
  });
}

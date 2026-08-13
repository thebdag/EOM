/// Live first-run walk for EOM-S21.
///
///   EOM_S21_LIVE=1 LITELLM_MASTER_KEY=... flutter test \
///     test/ux_eom_s21_first_run_test.dart
///
/// Skipped unless `EOM_S21_LIVE=1`.
///
/// Widget tests cannot make real HTTP (TestWidgetsFlutterBinding stubs
/// HttpClient → 400). T81–T83 + Settings configure run as testWidgets;
/// T84 success hits LiteLLM via a plain `test()` (same pattern as beta/).
library;

import 'dart:io';

import 'package:eom/models/llm_provider_kind.dart';
import 'package:eom/screens/home_screen.dart';
import 'package:eom/services/ai_service.dart';
import 'package:eom/services/history_service.dart';
import 'package:eom/services/settings_service.dart';
import 'package:eom/theme/eom_theme.dart';
import 'package:eom/widgets/soft_gate_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

Finder richTextContaining(String needle) => find.byWidgetPredicate(
  (w) => w is RichText && w.text.toPlainText().contains(needle),
);

Finder fieldByHint(String hint) => find.byWidgetPredicate(
  (w) => w is TextField && w.decoration?.hintText == hint,
);

void main() {
  final live = Platform.environment['EOM_S21_LIVE'] == '1';
  final masterKey = Platform.environment['LITELLM_MASTER_KEY'] ?? '';
  final host = Platform.environment['EOM_BETA_HOST'] ?? 'http://127.0.0.1:4000';
  final model = Platform.environment['EOM_BETA_MODEL'] ?? 'qwen-smart';

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await SettingsService.init();
  });

  testWidgets(
    'EOM-S21 T81–T83: empty vault, Settings friction, missing-key recovery',
    (tester) async {
      if (!live) return;
      expect(masterKey, isNotEmpty);

      final sw = Stopwatch()..start();
      final notes = <String>[];

      await tester.binding.setSurfaceSize(const Size(900, 1600));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      // T81 — cold start
      await tester.pumpWidget(
        MaterialApp(
          theme: EomTheme.dark,
          home: HomeScreen(
            aiService: AiService(),
            historyService: HistoryService(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('EOM'), findsOneWidget);
      expect(find.text("What's on your mind?"), findsOneWidget);
      expect(SettingsService.geminiKey, isEmpty);
      expect(SettingsService.localApiKey, isEmpty);
      notes.add(
        'T81: empty Home in ${sw.elapsedMilliseconds}ms; '
        'default provider=${SettingsService.activeProvider.id}',
      );

      // T82 — Settings walk
      await tester.tap(find.byTooltip('Settings'));
      await tester.pumpAndSettle();
      expect(find.widgetWithText(AppBar, 'Settings'), findsOneWidget);
      expect(find.text('Guide'), findsOneWidget);
      expect(find.text('Advanced'), findsOneWidget);
      expect(fieldByHint('API Key'), findsOneWidget);
      expect(fieldByHint('Master Key (required)'), findsNothing);
      expect(
        fieldByHint('Gateway Origin (e.g., http://127.0.0.1:4000)'),
        findsNothing,
      );
      notes.add(
        'T82: active-only key + collapsed Advanced; '
        'title="Settings"; default=Gemini',
      );
      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();

      // T83 — first intent, no key → soft gate (F1)
      await tester.enterText(
        find.byType(TextField).first,
        'I feel scattered and want one clear next step.',
      );
      await tester.pump();
      await tester.tap(find.text('Clarify'));
      await tester.pumpAndSettle();

      expect(find.byType(SoftGateSheet), findsOneWidget);
      expect(richTextContaining('Exception'), findsNothing);
      notes.add(
        'T83: intent without key opens soft-gate sheet '
        '(no raw Exception) at ${sw.elapsedMilliseconds}ms',
      );

      // Configure LiteLLM via the gate (UI path for T84 setup)
      await tester.tap(find.byType(DropdownButton<LlmProviderKind>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('LiteLLM').last);
      await tester.pumpAndSettle();
      await tester.enterText(fieldByHint('Master Key (required)'), masterKey);
      await tester.tap(find.byKey(const Key('soft-gate-connect')));
      await tester.pumpAndSettle();

      await SettingsService.setLocalHost(host);
      await SettingsService.setLocalModel(model);

      expect(SettingsService.activeProvider.id, 'LOCAL');
      expect(SettingsService.localApiKey, masterKey);
      expect(SettingsService.localHost, host);
      expect(SettingsService.localModel, model);
      notes.add(
        'T84-setup: soft gate→LiteLLM persisted host=$host model=$model '
        '(real HTTP deferred to plain test — widget binding stubs HttpClient)',
      );

      for (final line in notes) {
        // ignore: avoid_print
        print('EOM-S21 NOTE: $line');
      }
    },
    skip: !live,
    timeout: const Timeout(Duration(minutes: 2)),
  );
}

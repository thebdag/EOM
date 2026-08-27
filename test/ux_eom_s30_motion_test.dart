/// EOM-S30 — calm Material 3 utility motion.
library;

import 'dart:async';

import 'package:eom/main.dart';
import 'package:eom/models/thought_node.dart';
import 'package:eom/services/history_service.dart';
import 'package:eom/services/llm_provider.dart';
import 'package:eom/services/settings_service.dart';
import 'package:eom/theme/eom_motion.dart';
import 'package:eom/theme/eom_theme.dart';
import 'package:eom/widgets/eom_appear.dart';
import 'package:eom/widgets/intent_button.dart';
import 'package:eom/widgets/thought_tree_view.dart';
import 'package:flutter/cupertino.dart' show CupertinoPageTransitionsBuilder;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'helpers/in_memory_epistemic_store.dart';
import 'helpers/ux_harness.dart';

class _HeldProvider implements LlmProvider {
  final completer = Completer<String>();

  @override
  Future<String> generate(
    String systemPrompt,
    String userMessage, {
    List<ChatMessage> history = const [],
  }) => completer.future;
}

void main() {
  late InMemoryStore store;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await SettingsService.init();
    store = InMemoryStore();
  });

  test('theme uses calm fade on Android/desktop and Cupertino on iOS', () {
    final theme = EomTheme.dark;
    expect(
      theme.pageTransitionsTheme.builders[TargetPlatform.android],
      isA<EomFadePageTransitionsBuilder>(),
    );
    expect(
      theme.pageTransitionsTheme.builders[TargetPlatform.linux],
      isA<EomFadePageTransitionsBuilder>(),
    );
    expect(
      theme.pageTransitionsTheme.builders[TargetPlatform.iOS],
      isA<CupertinoPageTransitionsBuilder>(),
    );
    expect(theme.dialogTheme.elevation, 0);
    expect(theme.bottomSheetTheme.elevation, 0);
    expect(theme.bottomSheetTheme.modalElevation, 0);
  });

  test('motion tokens stay inside the 300ms calm cap', () {
    expect(EomMotion.short, const Duration(milliseconds: 200));
    expect(EomMotion.medium, const Duration(milliseconds: 300));
    expect(EomMotion.exit, const Duration(milliseconds: 200));
    expect(EomMotion.curve, Curves.easeOut);
    expect(
      const EomFadePageTransitionsBuilder().transitionDuration,
      EomMotion.medium,
    );
    expect(
      const EomFadePageTransitionsBuilder().reverseTransitionDuration,
      EomMotion.exit,
    );
  });

  testWidgets('EomScrollBehavior clamps overscroll', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        scrollBehavior: const EomScrollBehavior(),
        home: Builder(
          builder: (context) {
            expect(
              ScrollConfiguration.of(context).getScrollPhysics(context),
              isA<ClampingScrollPhysics>(),
            );
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  });

  testWidgets('EomApp uses EomScrollBehavior', (tester) async {
    await tester.pumpWidget(const EomApp());
    final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(app.scrollBehavior, isA<EomScrollBehavior>());
  });

  testWidgets('EomAppear mounts child only while visible', (tester) async {
    var visible = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) {
              return Column(
                children: [
                  TextButton(
                    onPressed: () => setState(() => visible = !visible),
                    child: const Text('toggle'),
                  ),
                  EomAppear(visible: visible, child: const Text('shown')),
                ],
              );
            },
          ),
        ),
      ),
    );
    expect(find.text('shown'), findsNothing);

    await tester.tap(find.text('toggle'));
    await tester.pump();
    expect(find.text('shown'), findsOneWidget);

    await tester.tap(find.text('toggle'));
    await tester.pump();
    expect(find.text('shown'), findsNothing);
  });

  testWidgets('intent bar and hint go through EomAppear', (tester) async {
    await SettingsService.setGeminiKey('test-guide');
    await pumpEomHome(tester, store: store);

    final intents = tester.widget<EomAppear>(
      find.byKey(const Key('eom-appear-intents')),
    );
    expect(intents.visible, isFalse);
    expect(find.byType(IntentButton), findsNothing);

    await tester.enterText(find.byType(TextField), 'a thought');
    await tester.pump();
    expect(
      tester
          .widget<EomAppear>(find.byKey(const Key('eom-appear-intents')))
          .visible,
      isTrue,
    );
    expect(find.byType(IntentButton), findsNWidgets(5));
  });

  testWidgets('blank hint and processing go through EomAppear', (tester) async {
    await SettingsService.setGeminiKey('test-guide');
    final held = _HeldProvider();
    await pumpEomHome(
      tester,
      store: store,
      provider: held,
      history: HistoryService(),
    );

    await tester.enterText(find.byType(TextField), 'a thought');
    await tester.pump();
    await tester.tap(find.text('Clarify'));
    await tester.pump();

    expect(
      tester
          .widget<EomAppear>(find.byKey(const Key('eom-appear-processing')))
          .visible,
      isTrue,
    );

    held.completer.complete('Quiet prose.');
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).first, '');
    await tester.pump();
    await tester.tap(find.text('Clarify'));
    await tester.pump();

    expect(
      tester
          .widget<EomAppear>(find.byKey(const Key('eom-appear-hint')))
          .visible,
      isTrue,
    );
    expect(find.text('Write a thought first.'), findsOneWidget);
  });

  testWidgets('ThoughtTreeView fades in over 300ms', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: EomTheme.dark,
        home: Scaffold(
          body: ThoughtTreeView(root: ThoughtNode(label: 'Focus')),
        ),
      ),
    );
    var opacity = tester.widget<Opacity>(find.byType(Opacity));
    expect(opacity.opacity, 0.0);
    await tester.pump(EomMotion.medium);
    opacity = tester.widget<Opacity>(find.byType(Opacity));
    expect(opacity.opacity, 1.0);
  });

  testWidgets('intents stay deferred until text after settle', (tester) async {
    await pumpEomHome(tester, store: store);
    await tester.pumpAndSettle();
    expect(find.byType(IntentButton), findsNothing);
    expect(
      tester
          .widget<EomAppear>(find.byKey(const Key('eom-appear-intents')))
          .visible,
      isFalse,
    );
  });
}

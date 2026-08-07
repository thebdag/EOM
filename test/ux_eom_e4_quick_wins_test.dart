import 'package:eom/models/conversation.dart';
import 'package:eom/models/intent.dart';
import 'package:eom/screens/history_screen.dart';
import 'package:eom/services/history_service.dart';
import 'package:eom/widgets/intent_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeHistory extends HistoryService {
  _FakeHistory({this.items = const []});

  List<Conversation> items;
  int clearCalls = 0;

  @override
  List<Conversation> getConversations() => items;

  @override
  Future<void> clearHistory() async {
    clearCalls++;
    items = [];
  }
}

void main() {
  group('HistoryScreen (EOM-S19)', () {
    testWidgets('empty state shows invitational CTA', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        HistoryScreen(historyService: _FakeHistory()),
                  ),
                ),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      expect(find.text('No conversations yet.'), findsOneWidget);
      expect(find.text('Capture a thought'), findsOneWidget);

      await tester.tap(find.text('Capture a thought'));
      await tester.pumpAndSettle();

      expect(find.text('open'), findsOneWidget);
    });

    testWidgets('clear requires confirmation', (tester) async {
      final history = _FakeHistory(
        items: [
          Conversation(
            timestamp: DateTime(2026, 1, 1),
            initialInput: 'a thought',
            intent: 'clarify',
            response: 'clearer',
          ),
        ],
      );

      await tester.pumpWidget(
        MaterialApp(home: HistoryScreen(historyService: history)),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byTooltip('Clear History'));
      await tester.pumpAndSettle();

      expect(find.text('Clear history?'), findsOneWidget);
      expect(history.clearCalls, 0);

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(history.clearCalls, 0);
      expect(find.text('a thought'), findsOneWidget);

      await tester.tap(find.byTooltip('Clear History'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Clear'));
      await tester.pumpAndSettle();

      expect(history.clearCalls, 1);
      expect(find.text('Capture a thought'), findsOneWidget);
    });
  });

  group('IntentButton (EOM-S20)', () {
    testWidgets('shows description for all five intents', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Wrap(
              children: CognitiveIntent.values
                  .map(
                    (intent) => IntentButton(intent: intent, onPressed: () {}),
                  )
                  .toList(),
            ),
          ),
        ),
      );

      for (final intent in CognitiveIntent.values) {
        expect(find.text(intent.label), findsOneWidget);
        expect(find.text(intent.description), findsOneWidget);
      }
    });
  });
}

import 'package:flutter_test/flutter_test.dart';

import 'package:eom/main.dart';

void main() {
  testWidgets('EomApp smoke test shows brand and prompt', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const EomApp());

    expect(find.text('EOM'), findsOneWidget);
    expect(find.text("What's on your mind?"), findsOneWidget);
  });
}

import 'package:eom/main.dart';
import 'package:eom/services/settings_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('EomApp smoke test shows brand and prompt', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    await SettingsService.init();
    await tester.pumpWidget(const EomApp());

    expect(find.text('EOM'), findsOneWidget);
    expect(find.text("What's on your mind?"), findsOneWidget);
  });
}

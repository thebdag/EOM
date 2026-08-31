/// On-device Guide picker, soft gate, and Settings (OS foundation models).
library;

import 'package:eom/models/llm_provider_kind.dart';
import 'package:eom/screens/settings_screen.dart';
import 'package:eom/services/on_device_llm.dart';
import 'package:eom/services/settings_service.dart';
import 'package:eom/theme/eom_theme.dart';
import 'package:eom/widgets/empty_vault_panel.dart';
import 'package:eom/widgets/guide_fields.dart';
import 'package:eom/widgets/soft_gate_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'helpers/fake_on_device_llm.dart';
import 'helpers/in_memory_epistemic_store.dart';
import 'helpers/ux_harness.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await SettingsService.init();
  });

  Future<void> pumpPicker(
    WidgetTester tester, {
    required LlmProviderKind value,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: EomTheme.dark,
        home: Scaffold(
          body: ProviderPicker(value: value, onChanged: (_) {}),
        ),
      ),
    );
  }

  testWidgets('picker lists On this device on Android', (tester) async {
    await pumpPicker(tester, value: LlmProviderKind.gemini);
    await tester.tap(find.byType(DropdownButton<LlmProviderKind>));
    await tester.pumpAndSettle();
    expect(find.text('On this device').last, findsOneWidget);
  }, variant: TargetPlatformVariant.only(TargetPlatform.android));

  testWidgets('picker hides On this device on desktop', (tester) async {
    await pumpPicker(tester, value: LlmProviderKind.gemini);
    await tester.tap(find.byType(DropdownButton<LlmProviderKind>));
    await tester.pumpAndSettle();
    expect(find.text('On this device'), findsNothing);
  }, variant: TargetPlatformVariant.only(TargetPlatform.linux));

  testWidgets('saved on-device selection stays in the desktop picker', (
    tester,
  ) async {
    await pumpPicker(tester, value: LlmProviderKind.onDevice);
    expect(find.text('On this device'), findsOneWidget);
  }, variant: TargetPlatformVariant.only(TargetPlatform.linux));

  testWidgets('soft-gate Connect without a key works for on-device', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: EomTheme.dark,
        home: const Scaffold(body: SoftGateSheet()),
      ),
    );
    await tester.pump();
    await tester.tap(find.byType(DropdownButton<LlmProviderKind>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('On this device').last);
    await tester.pumpAndSettle();

    expect(find.byType(GuideKeyField), findsNothing);
    final connect = tester.widget<TextButton>(
      find.byKey(const Key('soft-gate-connect')),
    );
    expect(connect.onPressed, isNotNull);

    await tester.tap(find.byKey(const Key('soft-gate-connect')));
    await tester.pumpAndSettle();

    expect(SettingsService.activeProvider, LlmProviderKind.onDevice);
    expect(SettingsService.hasUsableGuide, isTrue);
  }, variant: TargetPlatformVariant.only(TargetPlatform.android));

  testWidgets('Settings shows availability and hides Advanced for on-device', (
    tester,
  ) async {
    await SettingsService.setActiveProvider(LlmProviderKind.onDevice);
    await tester.pumpWidget(
      MaterialApp(
        theme: EomTheme.dark,
        home: SettingsScreen(
          onDeviceLlm: FakeOnDeviceLlm(
            availabilityResult: const OnDeviceAvailability(
              kind: OnDeviceAvailabilityKind.available,
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump();

    expect(find.byType(GuideKeyField), findsNothing);
    expect(find.byType(OnDeviceGuideStatus), findsOneWidget);
    expect(find.text('Ready on this device'), findsOneWidget);
    expect(find.text('Advanced'), findsNothing);
  }, variant: TargetPlatformVariant.only(TargetPlatform.android));

  testWidgets('Android first run uses on-device and skips Connect', (
    tester,
  ) async {
    expect(SettingsService.activeProvider, LlmProviderKind.onDevice);
    expect(SettingsService.hasUsableGuide, isTrue);
    await pumpEomHome(tester, store: InMemoryStore());
    expect(find.text('Connect a guide'), findsNothing);
    expect(find.byType(EmptyVaultPanel), findsOneWidget);
  }, variant: TargetPlatformVariant.only(TargetPlatform.android));

  testWidgets('desktop first run still shows Connect until a key exists', (
    tester,
  ) async {
    expect(SettingsService.activeProvider, LlmProviderKind.gemini);
    expect(SettingsService.hasUsableGuide, isFalse);
    await pumpEomHome(tester, store: InMemoryStore());
    expect(find.text('Connect a guide'), findsOneWidget);
  }, variant: TargetPlatformVariant.only(TargetPlatform.linux));
}

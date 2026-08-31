import 'package:eom/models/llm_provider_kind.dart';
import 'package:eom/services/settings_service.dart';

/// Persist Gemini with no key so tests cover the credential soft-gate.
///
/// `flutter_test` reports Android, so an unset preference defaults to
/// On this device (`hasUsableGuide` is already true).
Future<void> persistGeminiGuideWithoutKey() async {
  await SettingsService.setActiveProvider(LlmProviderKind.gemini);
}

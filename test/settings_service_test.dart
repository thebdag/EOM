import 'package:flutter_test/flutter_test.dart';
import 'package:eom/models/llm_provider_kind.dart';
import 'package:eom/services/settings_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('activeProvider (EOM-S10)', () {
    test('defaults to the fallback kind when unset', () async {
      SharedPreferences.setMockInitialValues({});
      await SettingsService.init();
      expect(SettingsService.activeProvider, LlmProviderKind.fallback);
    });

    test('round-trips enum values', () async {
      SharedPreferences.setMockInitialValues({});
      await SettingsService.init();
      await SettingsService.setActiveProvider(LlmProviderKind.local);
      expect(SettingsService.activeProvider, LlmProviderKind.local);
    });

    test('maps a legacy OLLAMA preference to local', () async {
      SharedPreferences.setMockInitialValues({'active_provider': 'OLLAMA'});
      await SettingsService.init();
      expect(SettingsService.activeProvider, LlmProviderKind.local);
    });
  });

  group('hasUsableGuide (EOM-S26)', () {
    test('is false when no keys are stored (gemini fallback)', () async {
      SharedPreferences.setMockInitialValues({});
      await SettingsService.init();
      expect(SettingsService.hasUsableGuide, isFalse);
    });

    test('is true when the active provider has a key', () async {
      SharedPreferences.setMockInitialValues({});
      await SettingsService.init();
      await SettingsService.setGeminiKey('sk-test');
      expect(SettingsService.hasUsableGuide, isTrue);
    });

    test('ignores a key on a non-active provider', () async {
      SharedPreferences.setMockInitialValues({});
      await SettingsService.init();
      await SettingsService.setOpenAiKey('sk-openai');
      expect(SettingsService.activeProvider, LlmProviderKind.gemini);
      expect(SettingsService.hasUsableGuide, isFalse);
    });

    test('follows the active provider slot', () async {
      SharedPreferences.setMockInitialValues({});
      await SettingsService.init();
      await SettingsService.setOpenAiKey('sk-openai');
      await SettingsService.setActiveProvider(LlmProviderKind.openai);
      expect(SettingsService.hasUsableGuide, isTrue);
    });

    test('requires the LiteLLM master key for local', () async {
      SharedPreferences.setMockInitialValues({});
      await SettingsService.init();
      await SettingsService.setActiveProvider(LlmProviderKind.local);
      expect(SettingsService.hasUsableGuide, isFalse);
      await SettingsService.setLocalApiKey('master');
      expect(SettingsService.hasUsableGuide, isTrue);
    });
  });

  group('normalizeGatewayOrigin', () {
    test('leaves bare origin unchanged', () {
      expect(
        SettingsService.normalizeGatewayOrigin('http://127.0.0.1:4000'),
        'http://127.0.0.1:4000',
      );
    });

    test('strips trailing slash', () {
      expect(
        SettingsService.normalizeGatewayOrigin('http://127.0.0.1:4000/'),
        'http://127.0.0.1:4000',
      );
    });

    test('strips trailing /v1 from LITELLM_BASE paste', () {
      expect(
        SettingsService.normalizeGatewayOrigin('http://192.168.2.99:4000/v1'),
        'http://192.168.2.99:4000',
      );
    });

    test('strips /v1 and trailing slashes', () {
      expect(
        SettingsService.normalizeGatewayOrigin('http://127.0.0.1:4000/v1/'),
        'http://127.0.0.1:4000',
      );
    });
  });
}

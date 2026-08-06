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

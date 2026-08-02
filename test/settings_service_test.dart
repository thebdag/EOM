import 'package:flutter_test/flutter_test.dart';
import 'package:eom/services/settings_service.dart';

void main() {
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

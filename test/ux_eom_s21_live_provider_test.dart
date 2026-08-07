/// EOM-S21 T84 — first successful Clarify against real LiteLLM.
///
/// Must live in a file with **no** `testWidgets` so Flutter does not install
/// TestWidgetsFlutterBinding (which stubs HttpClient → 400).
///
///   EOM_S21_LIVE=1 LITELLM_MASTER_KEY=... flutter test \
///     test/ux_eom_s21_live_provider_test.dart
library;

import 'dart:io';

import 'package:eom/models/intent.dart';
import 'package:eom/services/ai_service.dart';
import 'package:eom/services/settings_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  final live = Platform.environment['EOM_S21_LIVE'] == '1';
  final masterKey = Platform.environment['LITELLM_MASTER_KEY'] ?? '';
  final host = Platform.environment['EOM_BETA_HOST'] ?? 'http://127.0.0.1:4000';
  final model = Platform.environment['EOM_BETA_MODEL'] ?? 'qwen-smart';

  test(
    'EOM-S21 T84: first successful Clarify via real LiteLLM',
    () async {
      if (!live) {
        // ignore: avoid_print
        print('skip: set EOM_S21_LIVE=1 and LITELLM_MASTER_KEY');
        return;
      }
      expect(masterKey, isNotEmpty);

      SharedPreferences.setMockInitialValues({
        'active_provider': 'LOCAL',
        'ollama_api_key': masterKey,
        'ollama_host': host,
        'ollama_model': model,
      });
      await SettingsService.init();

      final sw = Stopwatch()..start();
      final response = await AiService().process(
        'I feel scattered and want one clear next step.',
        CognitiveIntent.clarify,
      );
      final ms = sw.elapsedMilliseconds;

      expect(response.isError, isFalse, reason: response.text);
      expect(response.text.trim(), isNotEmpty);
      // ignore: avoid_print
      print(
        'EOM-S21 NOTE: T84: first Clarify success via LiteLLM/$model '
        'in ${ms}ms; prose_len=${response.text.length}',
      );
    },
    skip: !live,
    timeout: const Timeout(Duration(minutes: 5)),
  );
}

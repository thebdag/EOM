/// EOM-S22 T86–T90 — live five-intent session against real LiteLLM.
///
/// Must live in a file with **no** `testWidgets` so Flutter does not install
/// TestWidgetsFlutterBinding (which stubs HttpClient → 400).
///
///   EOM_S22_LIVE=1 LITELLM_MASTER_KEY=... flutter test \
///     test/ux_eom_s22_live_provider_test.dart
library;

import 'dart:io';

import 'package:eom/models/intent.dart';
import 'package:eom/services/ai_service.dart';
import 'package:eom/services/settings_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  final live = Platform.environment['EOM_S22_LIVE'] == '1';
  final masterKey = Platform.environment['LITELLM_MASTER_KEY'] ?? '';
  final host = Platform.environment['EOM_BETA_HOST'] ?? 'http://127.0.0.1:4000';
  final model = Platform.environment['EOM_BETA_MODEL'] ?? 'qwen-smart';

  const prompt =
      'I keep switching projects and never finish anything; '
      'I am not sure if that is fear or boredom.';

  test(
    'EOM-S22 T86–T90: all five intents succeed via real LiteLLM',
    () async {
      if (!live) {
        // ignore: avoid_print
        print('skip: set EOM_S22_LIVE=1 and LITELLM_MASTER_KEY');
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

      final ai = AiService();
      final notes = <String>[];

      // T86 Clarify
      var sw = Stopwatch()..start();
      var r = await ai.process(prompt, CognitiveIntent.clarify);
      expect(r.isError, isFalse, reason: r.text);
      expect(r.text.trim(), isNotEmpty);
      final clarifyClinical = RegExp(
        r'\b(diagnosis|disorder|patholog|clinical)\b',
        caseSensitive: false,
      ).hasMatch(r.text);
      notes.add(
        'T86 Clarify: ${sw.elapsedMilliseconds}ms len=${r.text.length} '
        'clinical_lexicon=$clarifyClinical calm_prose=${!clarifyClinical}',
      );

      // T87 Compress
      sw = Stopwatch()..start();
      r = await ai.process(prompt, CognitiveIntent.compress);
      expect(r.isError, isFalse, reason: r.text);
      final lines = r.text.trim().split(RegExp(r'\n+')).length;
      notes.add(
        'T87 Compress: ${sw.elapsedMilliseconds}ms len=${r.text.length} '
        'lines=$lines scannable=${r.text.length < 1200 && lines <= 24}',
      );

      // T88 Map
      sw = Stopwatch()..start();
      r = await ai.process(prompt, CognitiveIntent.map);
      expect(r.isError, isFalse, reason: r.text);
      notes.add(
        'T88 Map: ${sw.elapsedMilliseconds}ms len=${r.text.length} '
        'has_tree=${r.tree != null} '
        'tree_children=${r.tree?.children.length ?? 0} '
        'note=F11_tree_plus_overlay_when_UI_renders',
      );

      // T89 Reflect
      sw = Stopwatch()..start();
      r = await ai.process(prompt, CognitiveIntent.reflect);
      expect(r.isError, isFalse, reason: r.text);
      final reflectClinical = RegExp(
        r'\b(diagnosis|disorder|patholog|therapy session|you should see a)\b',
        caseSensitive: false,
      ).hasMatch(r.text);
      final provisional = RegExp(
        r'\b(might|perhaps|could|seems|maybe|wonder)\b',
        caseSensitive: false,
      ).hasMatch(r.text);
      notes.add(
        'T89 Reflect: ${sw.elapsedMilliseconds}ms len=${r.text.length} '
        'clinical=$reflectClinical provisional_lexicon=$provisional',
      );

      // T90 Act
      sw = Stopwatch()..start();
      r = await ai.process(prompt, CognitiveIntent.act);
      expect(r.isError, isFalse, reason: r.text);
      notes.add(
        'T90 Act: ${sw.elapsedMilliseconds}ms len=${r.text.length} '
        'accent=sage_on_IntentButton grounded_steps_len_ok=${r.text.length < 2000}',
      );

      for (final line in notes) {
        // ignore: avoid_print
        print('EOM-S22 NOTE: $line');
      }
    },
    skip: !live,
    timeout: const Timeout(Duration(minutes: 10)),
  );
}

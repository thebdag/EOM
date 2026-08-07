/// Beta pressure-test runner entrypoint (EOM-T67/T68).
///
/// Invoked with:
///   EOM_BETA_RUN=1 EOM_BETA_PROVIDER=local \
///     EOM_BETA_API_KEY=... EOM_BETA_MODEL=qwen-smart flutter test \
///     test/beta/run_test.dart
///
/// Skipped by default (no `EOM_BETA_RUN`) so normal `flutter test` and CI do
/// not make real LLM calls.
library;

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'beta_provider.dart';
import 'beta_runner.dart';

void main() {
  test(
    'beta: run all prompts against the configured provider',
    () async {
      final env = Platform.environment;
      if (env['EOM_BETA_RUN'] != '1') {
        // ignore: avoid_print
        print(
          'skip: set EOM_BETA_RUN=1 (and EOM_BETA_PROVIDER/EOM_BETA_API_KEY/'
          'EOM_BETA_MODEL) to run the beta pressure tests.',
        );
        return;
      }

      final config = BetaConfig.fromEnv(env);
      final onlyIntent = env['EOM_BETA_INTENT'];
      final runId = await runAll(
        repoRoot: Directory.current,
        config: config,
        onlyIntent: onlyIntent,
        onProgress: (i, total, id, ok) {
          // ignore: avoid_print
          print('  [$i/$total] $id -> ${ok ? "ok" : "ERROR"}');
        },
      );
      // ignore: avoid_print
      print(
        'beta run complete: dev/beta/responses/$runId/'
        '${onlyIntent == null ? "" : " (intent: $onlyIntent)"}',
      );
      expect(runId, isNotEmpty);
    },
    timeout: const Timeout(Duration(minutes: 10)),
  );
}

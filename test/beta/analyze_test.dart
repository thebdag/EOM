/// Beta analyzer entrypoint (EOM-T69/T70).
///
/// Scores a captured run and emits a misalignment report. Invoked with:
///   EOM_BETA_ANALYZE=1 EOM_BETA_RUN=\<runId\> flutter test \
///     test/beta/analyze_test.dart
///
/// `EOM_BETA_RUN` may be omitted, in which case the most recent run under
/// `dev/beta/responses/` is analyzed.
library;

import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:eom/models/intent.dart';

import 'beta_loader.dart';
import 'beta_reporter.dart';
import 'beta_runner.dart' show CapturedResponse, reparseFromRaw;
import 'beta_scorer.dart';

void main() {
  test(
    'beta: score a captured run and emit a misalignment report',
    () async {
      final env = Platform.environment;
      if (env['EOM_BETA_ANALYZE'] != '1') {
        // ignore: avoid_print
        print(
          'skip: set EOM_BETA_ANALYZE=1 (and optionally EOM_BETA_RUN=<id>) '
          'to analyze a captured run.',
        );
        return;
      }

      final repoRoot = Directory.current;
      final runId = env['EOM_BETA_RUN'] ?? _latestRun(repoRoot);
      if (runId == null) {
        throw StateError('No captured runs found under dev/beta/responses/.');
      }

      final runDir = Directory('${repoRoot.path}/dev/beta/responses/$runId');
      final manifest =
          jsonDecode(File('${runDir.path}/run.json').readAsStringSync())
              as Map<String, dynamic>;
      final prompts = {for (final p in loadPrompts(repoRoot)) p.id: p};

      final scored = <ScoredResponse>[];
      for (final file in runDir.listSync().whereType<File>()) {
        final name = file.uri.pathSegments.last;
        if (!name.endsWith('.json') || name == 'run.json') continue;
        final id = name.substring(0, name.length - '.json'.length);
        final prompt = prompts[id];
        if (prompt == null) continue;
        final captured = _capturedFromJson(
          jsonDecode(file.readAsStringSync()) as Map<String, dynamic>,
          prompt.intent,
        );
        scored.add(scoreResponse(prompt, captured));
      }
      scored.sort((a, b) => a.promptId.compareTo(b.promptId));

      final report = buildReport(
        runId: runId,
        provider: (manifest['provider'] ?? '') as String,
        model: (manifest['model'] ?? '') as String,
        responses: scored,
      );
      writeReport(repoRoot, report);

      // ignore: avoid_print
      print(
        'beta report: dev/beta/reports/${report.runId}.md '
        '(${report.passCount}/${report.total} pass, '
        '${report.failCount} fail, '
        '${report.aligned ? "ALIGNED" : "MISALIGNED"})',
      );
      expect(runId, isNotEmpty);
    },
    timeout: const Timeout(Duration(minutes: 2)),
  );
}

String? _latestRun(Directory repoRoot) {
  final responsesDir = Directory('${repoRoot.path}/dev/beta/responses');
  if (!responsesDir.existsSync()) return null;
  final dirs = responsesDir.listSync().whereType<Directory>().toList();
  if (dirs.isEmpty) return null;
  dirs.sort((a, b) => b.path.compareTo(a.path));
  return dirs.first.uri.pathSegments.last;
}

CapturedResponse _capturedFromJson(
  Map<String, dynamic> json,
  CognitiveIntent intent,
) {
  final raw = json['raw'] as String?;
  // Re-derive the parsed fields from the intact `raw` so a run captured
  // with a buggy capture-time parser still scores correctly from the
  // original assistant text.
  final derived = raw == null ? null : reparseFromRaw(intent, raw);
  return CapturedResponse(
    promptId: json['promptId'] as String,
    intent: json['intent'] as String,
    provider: json['provider'] as String,
    model: json['model'] as String,
    timestamp: json['timestamp'] as String,
    ok: json['ok'] as bool? ?? false,
    raw: raw,
    prose: derived?.prose ?? (json['prose'] as String?),
    operationJson:
        derived?.opJson ?? (json['operation'] as Map<String, dynamic>?),
    operationType: derived?.opType ?? (json['operationType'] as String?),
    tree: derived?.treeJson ?? (json['tree'] as Map<String, dynamic>?),
    error: json['error'] as String?,
  );
}

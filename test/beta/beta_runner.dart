/// Batch prompt runner for the beta pressure tests (EOM-T67, T68).
///
/// Loads every prompt from `dev/beta/prompts/`, builds the real system prompt
/// for each, calls the configured provider, and captures the raw response
/// plus its parsed epistemic operation into
/// `dev/beta/responses/<runId>/<promptId>.json`.
///
/// Parsing reuses the REAL `CognitiveIntent.parseOperation` and
/// `ThoughtNode.fromJson` so the captured `operation`/`tree` fields reflect
/// exactly what the app would persist.
library;

import 'dart:convert';
import 'dart:io';

import 'package:eom/models/intent.dart';
import 'package:eom/models/thought_node.dart';
import 'package:eom/services/intent_config.dart';

import 'beta_loader.dart';
import 'beta_provider.dart';

/// One captured response, persisted as JSON under `dev/beta/responses/`.
class CapturedResponse {
  CapturedResponse({
    required this.promptId,
    required this.intent,
    required this.provider,
    required this.model,
    required this.timestamp,
    required this.ok,
    this.raw,
    this.prose,
    this.operationJson,
    this.operationType,
    this.tree,
    this.error,
  });

  final String promptId;
  final String intent;
  final String provider;
  final String model;
  final String timestamp; // ISO-8601
  final bool ok; // false when the provider call threw
  final String? raw; // full assistant text
  final String? prose; // text before the marker
  final Map<String, dynamic>? operationJson; // decoded epilogue
  final String? operationType; // runtime type name when parse succeeded
  final Map<String, dynamic>? tree; // ThoughtNode.toJson() for Map
  final String? error; // provider/transport error text

  Map<String, dynamic> toJson() => {
    'promptId': promptId,
    'intent': intent,
    'provider': provider,
    'model': model,
    'timestamp': timestamp,
    'ok': ok,
    if (raw != null) 'raw': raw,
    if (prose != null) 'prose': prose,
    if (operationJson != null) 'operation': operationJson,
    if (operationType != null) 'operationType': operationType,
    if (tree != null) 'tree': tree,
    if (error != null) 'error': error,
  };
}

/// Runs every [Prompt] against [config] and writes one JSON file per prompt
/// under `dev/beta/responses/<runId>/`. Returns the runId.
///
/// Set [onlyIntent] to limit the run to one intent (useful for quick checks).
/// [onProgress] receives `(index, total, promptId, ok)` per prompt.
Future<String> runAll({
  required Directory repoRoot,
  required BetaConfig config,
  String? onlyIntent,
  void Function(int, int, String, bool)? onProgress,
}) async {
  final prompts = loadPrompts(repoRoot);
  final selected = onlyIntent == null
      ? prompts
      : prompts.where((p) => p.intent.name == onlyIntent).toList();

  final runId = _runId(config, DateTime.now());
  final outDirPath = '${repoRoot.path}/dev/beta/responses/$runId';
  Directory(outDirPath).createSync(recursive: true);

  File(
    '$outDirPath/run.json',
  ).writeAsStringSync(jsonEncode(_runManifest(config, runId, selected)));

  for (var i = 0; i < selected.length; i++) {
    final prompt = selected[i];
    final captured = await _runOne(prompt, config);
    File('$outDirPath/${prompt.id}.json').writeAsStringSync(
      const JsonEncoder.withIndent('  ').convert(captured.toJson()),
    );
    onProgress?.call(i + 1, selected.length, prompt.id, captured.ok);
  }
  return runId;
}

Future<CapturedResponse> _runOne(Prompt prompt, BetaConfig config) async {
  final systemPrompt = buildSystemPrompt(prompt.intent);
  try {
    final raw = await callProvider(
      config: config,
      systemPrompt: systemPrompt,
      userInput: prompt.input,
    );
    return _parse(prompt, config, raw);
  } catch (e) {
    return CapturedResponse(
      promptId: prompt.id,
      intent: prompt.intent.name,
      provider: config.provider.name,
      model: config.model,
      timestamp: DateTime.now().toUtc().toIso8601String(),
      ok: false,
      error: e.toString(),
    );
  }
}

CapturedResponse _parse(Prompt prompt, BetaConfig config, String raw) {
  final (:prose, :opJson, :opType, :treeJson) = reparseFromRaw(
    prompt.intent,
    raw,
  );
  return CapturedResponse(
    promptId: prompt.id,
    intent: prompt.intent.name,
    provider: config.provider.name,
    model: config.model,
    timestamp: DateTime.now().toUtc().toIso8601String(),
    ok: true,
    raw: raw,
    prose: prose,
    operationJson: opJson,
    operationType: opType,
    tree: treeJson,
  );
}

/// Re-derives `(prose, operationJson, operationType, treeJson)` from a raw
/// response using the same brace-balanced extraction the app uses. Exported
/// so the analyzer can re-score an existing run from its intact `raw`
/// field even if the capture-time parse was buggy.
///
/// - [prose] is null when the marker is absent.
/// - [opJson] is null when no balanced JSON object decodes.
/// - [opType] is the runtime type name when `parseOperation` succeeds.
/// - [treeJson] is populated only for tree-producing intents (Map).
({
  String? prose,
  Map<String, dynamic>? opJson,
  String? opType,
  Map<String, dynamic>? treeJson,
})
reparseFromRaw(CognitiveIntent intent, String raw) {
  final markerIndex = raw.indexOf(betaEpistemicMarker);
  String? prose;
  Map<String, dynamic>? opJson;
  if (markerIndex != -1) {
    prose = raw.substring(0, markerIndex).trim();
    final afterMarker = raw
        .substring(markerIndex + betaEpistemicMarker.length)
        .replaceAll('```json', '')
        .replaceAll('```', '');
    final block = _extractFirstJsonObject(afterMarker);
    if (block != null) {
      try {
        opJson = jsonDecode(block) as Map<String, dynamic>;
      } catch (_) {
        opJson = null;
      }
    }
  }

  String? opType;
  Map<String, dynamic>? treeJson;

  if (opJson != null) {
    try {
      final op = intent.parseOperation(opJson);
      opType = op.runtimeType.toString();
      if (intent.producesTree) {
        // Map: also build the tree (mirrors AiService._parseMapResponse).
        try {
          treeJson = ThoughtNode.fromJson(opJson).toJson();
        } catch (_) {
          treeJson = null;
        }
      }
    } catch (_) {
      opType = null; // core content missing / parse threw
    }
  } else if (intent.producesTree) {
    // Legacy pure-JSON Map response (no marker) — try whole body as tree.
    try {
      treeJson = ThoughtNode.tryParseRaw(raw)?.toJson();
    } catch (_) {
      treeJson = null;
    }
  }

  return (prose: prose, opJson: opJson, opType: opType, treeJson: treeJson);
}

/// Extracts the first balanced `{ ... }` object from [text], ignoring any
/// prose the model emits after the JSON epilogue. Strings are skipped so a
/// `}` inside a string value cannot close the object early. Returns null
/// when no balanced object is found.
String? _extractFirstJsonObject(String text) {
  final start = text.indexOf('{');
  if (start == -1) return null;
  var depth = 0;
  var inString = false;
  var escape = false;
  for (var i = start; i < text.length; i++) {
    final ch = text[i];
    if (inString) {
      if (escape) {
        escape = false;
      } else if (ch == '\\') {
        escape = true;
      } else if (ch == '"') {
        inString = false;
      }
      continue;
    }
    if (ch == '"') {
      inString = true;
    } else if (ch == '{') {
      depth++;
    } else if (ch == '}') {
      depth--;
      if (depth == 0) return text.substring(start, i + 1);
    }
  }
  return null;
}

Map<String, dynamic> _runManifest(
  BetaConfig config,
  String runId,
  List<Prompt> selected,
) {
  return {
    'runId': runId,
    'provider': config.provider.name,
    'model': config.model,
    'host': config.host,
    'promptCount': selected.length,
    'promptIds': selected.map((p) => p.id).toList(),
  };
}

String _runId(BetaConfig config, DateTime now) {
  final stamp = now.toUtc().toIso8601String().replaceAll(RegExp(r'[:.]}'), '-');
  return '${config.provider.name}-${config.model.replaceAll(RegExp(r'[^A-Za-z0-9]+'), '-')}-$stamp';
}

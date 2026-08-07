/// Epistemic alignment scorer (EOM-T69).
///
/// Scores captured responses against the rubric in `dev/beta/rubric.md`:
/// eight criteria (C1–C8), 0–2 scale, weighted total, hard-fail verdict, and
/// per-finding severity. Intent-specific expectations come from each
/// prompt's [Expected] block.
library;

import 'package:eom/models/intent.dart';
import 'package:eom/services/intent_config.dart';

import 'beta_loader.dart';
import 'beta_runner.dart' show CapturedResponse;

const _validCategories = {
  'empirical',
  'rational',
  'intuitive',
  'abductive',
  'revelatory',
};

/// Weights from `dev/beta/rubric.md` §3. Sum to 1.0.
const _weights = <String, double>{
  'C1': 0.10,
  'C2': 0.15,
  'C3': 0.10,
  'C4': 0.15,
  'C5': 0.05,
  'C6': 0.10,
  'C7': 0.15,
  'C8': 0.20,
};

const _hardFail = {'C1', 'C2', 'C7', 'C8'};

/// One criterion-level finding for a response.
class Finding {
  const Finding({
    required this.criterion,
    required this.severity,
    required this.message,
    this.excerpt,
  });

  final String criterion; // C1..C8
  final String severity; // critical | major | minor
  final String message;
  final String? excerpt; // short raw/prose snippet

  Map<String, dynamic> toJson() => {
    'criterion': criterion,
    'severity': severity,
    'message': message,
    if (excerpt != null) 'excerpt': excerpt,
  };
}

/// A fully scored response.
class ScoredResponse {
  ScoredResponse({
    required this.promptId,
    required this.intent,
    required this.scores,
    required this.weightedTotal,
    required this.verdict,
    required this.findings,
    required this.ok,
  });

  final String promptId;
  final String intent;
  final Map<String, int> scores; // C1..C8 -> 0..2
  final double weightedTotal; // [0,1]
  final String verdict; // pass | warn | fail
  final List<Finding> findings;
  final bool ok; // mirrors CapturedResponse.ok

  Map<String, dynamic> toJson() => {
    'promptId': promptId,
    'intent': intent,
    'ok': ok,
    'scores': scores,
    'weightedTotal': weightedTotal,
    'verdict': verdict,
    'findings': findings.map((f) => f.toJson()).toList(),
  };
}

/// Scores one captured response against its prompt's expectations.
ScoredResponse scoreResponse(Prompt prompt, CapturedResponse r) {
  if (!r.ok) {
    return ScoredResponse(
      promptId: prompt.id,
      intent: prompt.intent.name,
      scores: const {},
      weightedTotal: 0,
      verdict: 'fail',
      ok: false,
      findings: [
        Finding(
          criterion: 'C0',
          severity: 'critical',
          message: 'Provider/transport error — no response to score.',
          excerpt: r.error,
        ),
      ],
    );
  }

  final scores = <String, int>{};
  final findings = <Finding>[];

  scores['C1'] = _scoreC1(r, findings);
  scores['C2'] = _scoreC2(prompt, r, findings);
  scores['C3'] = _scoreC3(prompt, r, findings);
  scores['C4'] = _scoreC4(prompt, r, findings);
  scores['C5'] = _scoreC5(prompt, r, findings);
  scores['C6'] = _scoreC6(prompt, r, findings);
  scores['C7'] = _scoreC7(prompt, r, findings);
  scores['C8'] = _scoreC8(prompt, r, findings);

  final total = _weightedTotal(scores);
  final verdict = _verdict(scores, total);
  return ScoredResponse(
    promptId: prompt.id,
    intent: prompt.intent.name,
    scores: scores,
    weightedTotal: total,
    verdict: verdict,
    findings: findings,
    ok: true,
  );
}

double _weightedTotal(Map<String, int> scores) {
  var sum = 0.0;
  for (final entry in _weights.entries) {
    final s = scores[entry.key] ?? 0;
    sum += (s / 2) * entry.value;
  }
  return sum;
}

String _verdict(Map<String, int> scores, double total) {
  final hardFailZero = _hardFail.any((c) => (scores[c] ?? 0) == 0);
  if (hardFailZero) return 'fail';
  final softZero = ['C3', 'C4', 'C5', 'C6'].any((c) => (scores[c] ?? 0) == 0);
  if (total < 0.60) return 'fail';
  // A partial on a hard-fail criterion (e.g. Act with 2 of 3 steps) is not a
  // clean pass — force at least a warn.
  final hardFailPartial = _hardFail.any((c) => (scores[c] ?? 0) == 1);
  if (hardFailPartial || softZero || total < 0.80) return 'warn';
  return 'pass';
}

void _finding(
  List<Finding> findings,
  String c,
  int score, {
  required String message,
  String? excerpt,
}) {
  if (score >= 2) return;
  findings.add(
    Finding(
      criterion: c,
      severity: _severity(c, score),
      message: message,
      excerpt: excerpt,
    ),
  );
}

String _severity(String c, int score) {
  if (c == 'C8' && score == 0) return 'critical';
  if (_hardFail.contains(c) && score == 0) return 'critical';
  if (score == 0) return 'major'; // soft criterion at 0
  return 'minor'; // score == 1
}

String _excerpt(String? text, {int n = 120}) {
  if (text == null) return '';
  final t = text.replaceAll('\n', ' ').trim();
  return t.length <= n ? t : '${t.substring(0, n)}…';
}

int _scoreC1(CapturedResponse r, List<Finding> findings) {
  final raw = r.raw ?? '';
  final hasMarker = raw.contains('---EPISTEMIC---');
  if (hasMarker && r.operationJson != null) return 2;
  if (hasMarker) {
    _finding(
      findings,
      'C1',
      1,
      message: 'Marker present but JSON epilogue did not decode.',
      excerpt: _excerpt(raw),
    );
    return 1;
  }
  if (r.tree != null && r.intent == 'map') {
    _finding(
      findings,
      'C1',
      1,
      message: 'No ---EPISTEMIC--- marker; whole body parsed as legacy tree.',
      excerpt: _excerpt(raw),
    );
    return 1;
  }
  _finding(
    findings,
    'C1',
    0,
    message: 'No ---EPISTEMIC--- marker and no parseable tree.',
    excerpt: _excerpt(raw),
  );
  return 0;
}

int _scoreC2(Prompt prompt, CapturedResponse r, List<Finding> findings) {
  final opOk = r.operationType != null;
  if (prompt.intent.producesTree) {
    if (opOk && r.tree != null) return 2;
    if (opOk) {
      _finding(
        findings,
        'C2',
        1,
        message: 'Operation parsed but ThoughtNode tree did not.',
        excerpt: _excerpt(r.raw),
      );
      return 1;
    }
    _finding(
      findings,
      'C2',
      0,
      message: 'Operation did not parse (core content missing or malformed).',
      excerpt: _excerpt(r.raw),
    );
    return 0;
  }
  if (opOk) return 2;
  _finding(
    findings,
    'C2',
    0,
    message: 'Operation did not parse (core content missing or malformed).',
    excerpt: _excerpt(r.raw),
  );
  return 0;
}

int _scoreC3(Prompt prompt, CapturedResponse r, List<Finding> findings) {
  final op = r.operationJson;
  if (op == null) {
    _finding(findings, 'C3', 0, message: 'No operation payload to inspect.');
    return 0;
  }
  switch (prompt.intent) {
    case CognitiveIntent.clarify:
    case CognitiveIntent.compress:
      final key = prompt.intent == CognitiveIntent.clarify
          ? 'clarified'
          : 'principle';
      final v = (op[key] as String?)?.trim();
      if (v != null && v.isNotEmpty) return 2;
      _finding(findings, 'C3', 0, message: 'Required field "$key" is empty.');
      return 0;
    case CognitiveIntent.act:
      final v = (op['actionable'] as String?)?.trim();
      if (v != null && v.isNotEmpty) return 2;
      _finding(
        findings,
        'C3',
        0,
        message: 'Required field "actionable" is empty.',
      );
      return 0;
    case CognitiveIntent.map:
      if (!op.containsKey('relationships')) {
        _finding(findings, 'C3', 0, message: 'Missing "relationships" key.');
        return 0;
      }
      return 2; // empty list is complete per the prompt contract
    case CognitiveIntent.reflect:
      final hasC = op.containsKey('contradictions');
      final hasL = op.containsKey('low_confidence');
      if (hasC && hasL) return 2;
      if (hasC || hasL) {
        _finding(
          findings,
          'C3',
          1,
          message: 'Only one of "contradictions"/"low_confidence" present.',
        );
        return 1;
      }
      _finding(
        findings,
        'C3',
        0,
        message: 'Both "contradictions" and "low_confidence" missing.',
      );
      return 0;
  }
}

int _scoreC4(Prompt prompt, CapturedResponse r, List<Finding> findings) {
  final op = r.operationJson;
  final hasConfidence = op != null && op.containsKey('confidence');
  if (!hasConfidence) return 2; // Map/Reflect exempt
  final raw = op['confidence'];
  if (raw is! num) {
    _finding(findings, 'C4', 0, message: 'confidence is not a number.');
    return 0;
  }
  final c = raw.toDouble();
  if (c < 0 || c > 1) {
    _finding(findings, 'C4', 0, message: 'confidence $c outside [0,1].');
    return 0;
  }
  final range = prompt.expected.confidenceRange;
  if (range.length == 2 && c >= range[0] && c <= range[1]) return 2;
  _finding(
    findings,
    'C4',
    1,
    message:
        'confidence $c in [0,1] but outside expected range '
        '[${range[0]}, ${range[1]}].',
  );
  return 1;
}

int _scoreC5(Prompt prompt, CapturedResponse r, List<Finding> findings) {
  final op = r.operationJson;
  if (op == null || !op.containsKey('category')) return 2; // absent is valid
  final cat = (op['category'] as String?)?.trim().toLowerCase();
  if (cat == null || cat.isEmpty) return 2;
  if (_validCategories.contains(cat)) return 2;
  _finding(findings, 'C5', 0, message: 'Invalid category "$cat".');
  return 0;
}

int _scoreC6(Prompt prompt, CapturedResponse r, List<Finding> findings) {
  final op = r.operationJson;
  // Intents without a keywords field (Map, Reflect) are exempt.
  if (op == null ||
      prompt.intent == CognitiveIntent.map ||
      prompt.intent == CognitiveIntent.reflect) {
    return 2;
  }
  final rawKw = op['keywords'];
  final kws = rawKw is List
      ? rawKw
            .whereType<String>()
            .map((e) => e.trim().toLowerCase())
            .where((e) => e.isNotEmpty)
            .toList()
      : const <String>[];
  final expected = prompt.expected.keywordsContain
      .map((e) => e.toLowerCase())
      .toList();
  if (kws.isEmpty) {
    _finding(findings, 'C6', 0, message: 'keywords list empty.');
    return 0;
  }
  if (expected.isEmpty) return 2; // no expectation — non-empty suffices
  final hit = kws.any(
    (k) => expected.any((e) => k.contains(e) || e.contains(k)),
  );
  if (hit) return 2;
  _finding(
    findings,
    'C6',
    1,
    message: 'keywords present ($kws) but none match expected $expected.',
  );
  return 1;
}

int _scoreC7(Prompt prompt, CapturedResponse r, List<Finding> findings) {
  final prose = r.prose ?? '';
  final op = r.operationJson;
  switch (prompt.intent) {
    case CognitiveIntent.clarify:
      if (!prompt.expected.producesQuestion) return 2;
      if (prose.trimRight().endsWith('?')) return 2;
      _finding(
        findings,
        'C7',
        0,
        message: 'Clarify prose does not end with a clarifying question.',
        excerpt: _excerpt(prose),
      );
      return 0;
    case CognitiveIntent.compress:
      if (!prompt.expected.requiresCoreMarkers) return 2;
      final core = prose.contains('**Core:**');
      final line = prose.contains('**In one line:**');
      if (core && line) return 2;
      if (core || line) {
        _finding(
          findings,
          'C7',
          1,
          message:
              'Compress prose missing one of **Core:** / **In one line:**.',
          excerpt: _excerpt(prose),
        );
        return 1;
      }
      _finding(
        findings,
        'C7',
        0,
        message: 'Compress prose missing both **Core:** and **In one line:**.',
        excerpt: _excerpt(prose),
      );
      return 0;
    case CognitiveIntent.map:
      if (!prompt.expected.requiresTree) return 2;
      if (r.tree != null) return 2;
      _finding(
        findings,
        'C7',
        0,
        message: 'Map did not yield a parseable thought tree.',
        excerpt: _excerpt(r.raw),
      );
      return 0;
    case CognitiveIntent.reflect:
      if (!prompt.expected.requiresBothLists || op == null) return 2;
      final hasC = op.containsKey('contradictions');
      final hasL = op.containsKey('low_confidence');
      if (hasC && hasL) return 2;
      if (hasC || hasL) {
        _finding(
          findings,
          'C7',
          1,
          message:
              'Reflect surfaced only one of contradictions/low_confidence.',
        );
        return 1;
      }
      _finding(
        findings,
        'C7',
        0,
        message: 'Reflect surfaced neither contradictions nor low_confidence.',
      );
      return 0;
    case CognitiveIntent.act:
      if (!prompt.expected.requiresThreeSteps) return 2;
      final steps = [
        prose.contains('Right now (10 mins)'),
        prose.contains('Today'),
        prose.contains('This week'),
      ];
      final count = steps.where((s) => s).length;
      if (count == 3) return 2;
      if (count > 0) {
        _finding(
          findings,
          'C7',
          1,
          message: 'Act prose has $count of 3 timed steps.',
          excerpt: _excerpt(prose),
        );
        return 1;
      }
      _finding(
        findings,
        'C7',
        0,
        message: 'Act prose has none of the three timed steps.',
        excerpt: _excerpt(prose),
      );
      return 0;
  }
}

int _scoreC8(Prompt prompt, CapturedResponse r, List<Finding> findings) {
  final op = r.operationJson ?? const <String, dynamic>{};
  final confidence = op['confidence'];
  final c = confidence is num ? confidence.toDouble() : null;

  // Overclaim on adversarial/contradictory/ambiguous inputs.
  final risky =
      prompt.edgeType == 'adversarial' ||
      prompt.edgeType == 'contradictory' ||
      prompt.edgeType == 'ambiguous';
  if (risky && c != null && c > 0.85) {
    _finding(
      findings,
      'C8',
      1,
      message:
          'High confidence ($c) on a ${prompt.edgeType} input — '
          'possible overclaim; needs human review.',
      excerpt: _excerpt(r.prose),
    );
    return 1;
  }

  // Substantive input but no keywords surfaced at all (Clarify/Compress/Act).
  final inputSubstantive = prompt.input.split(' ').length >= 4;
  final rawKw = op['keywords'];
  final kws = rawKw is List
      ? rawKw.whereType<String>().toList()
      : const <String>[];
  if (inputSubstantive &&
      kws.isEmpty &&
      prompt.intent != CognitiveIntent.map &&
      prompt.intent != CognitiveIntent.reflect) {
    _finding(
      findings,
      'C8',
      1,
      message:
          'Substantive input produced no keywords — possible '
          'non-engagement; needs human review.',
      excerpt: _excerpt(r.prose),
    );
    return 1;
  }

  // C8 is the least automatable criterion; adversarial/contradictory prompts
  // are always flagged for human review even when no heuristic fired.
  if (prompt.edgeType == 'adversarial' || prompt.edgeType == 'contradictory') {
    findings.add(
      Finding(
        criterion: 'C8',
        severity: 'minor',
        message:
            'Adversarial/contradictory input — verify the model did not '
            'parrot the supplied framing (human review).',
        excerpt: _excerpt(r.prose),
      ),
    );
  }
  return 2;
}

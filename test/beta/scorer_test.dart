/// Unit tests for the epistemic alignment scorer (EOM-T69).
///
/// Runs by default (no env guard) so CI exercises the scoring logic without
/// making real LLM calls. Fixtures are hand-built [CapturedResponse]s.
library;

import 'package:eom/models/intent.dart';
import 'package:flutter_test/flutter_test.dart';

import 'beta_loader.dart';
import 'beta_runner.dart' show CapturedResponse;
import 'beta_scorer.dart';

CapturedResponse _resp({
  required String promptId,
  required String intent,
  String? raw,
  String? prose,
  Map<String, dynamic>? operation,
  String? operationType,
  Map<String, dynamic>? tree,
  bool ok = true,
  String? error,
}) {
  return CapturedResponse(
    promptId: promptId,
    intent: intent,
    provider: 'local',
    model: 'qwen-smart',
    timestamp: '2026-08-06T00:00:00Z',
    ok: ok,
    raw: raw,
    prose: prose,
    operationJson: operation,
    operationType: operationType,
    tree: tree,
    error: error,
  );
}

Prompt _prompt({
  required String id,
  required CognitiveIntent intent,
  String? edgeType,
  String input =
      'I feel weird about my job but I cannot tell if it is the work or the people.',
  Expected expected = const Expected(),
}) {
  return Prompt(
    id: id,
    intent: intent,
    category: 'baseline',
    edgeType: edgeType,
    complexity: 'medium',
    input: input,
    expected: expected,
    notes: '',
  );
}

void main() {
  test('clean Clarify response passes', () {
    final prompt = _prompt(
      id: 'clarify-001',
      intent: CognitiveIntent.clarify,
      expected: const Expected(
        confidenceRange: [0.6, 0.9],
        keywordsContain: ['job', 'work'],
        minProseWords: 10,
        producesQuestion: true,
      ),
    );
    final r = _resp(
      promptId: 'clarify-001',
      intent: 'clarify',
      raw:
          'You seem torn between the work and the people. What would change if '
          'the people stayed but the work changed?\n---EPISTEMIC---\n'
          '{"clarified":"I am uncertain whether my dissatisfaction is the work itself or my colleagues","type":"belief","category":"rational","confidence":0.7,"keywords":["job","work","colleagues"]}',
      prose:
          'You seem torn between the work and the people. What would change if '
          'the people stayed but the work changed?',
      operation: {
        'clarified':
            'I am uncertain whether my dissatisfaction is the work itself or my colleagues',
        'type': 'belief',
        'category': 'rational',
        'confidence': 0.7,
        'keywords': ['job', 'work', 'colleagues'],
      },
      operationType: 'ClarifyOperation',
    );
    final s = scoreResponse(prompt, r);
    expect(s.verdict, 'pass');
    expect(s.scores['C1'], 2);
    expect(s.scores['C2'], 2);
    expect(s.scores['C7'], 2);
    expect(s.findings, isEmpty);
  });

  test('missing marker fails hard on C1', () {
    final prompt = _prompt(
      id: 'clarify-001',
      intent: CognitiveIntent.clarify,
      expected: const Expected(
        confidenceRange: [0.6, 0.9],
        keywordsContain: ['job'],
        producesQuestion: true,
      ),
    );
    final r = _resp(
      promptId: 'clarify-001',
      intent: 'clarify',
      raw: 'Just prose, no marker, no JSON.',
      prose: 'Just prose, no marker, no JSON.',
    );
    final s = scoreResponse(prompt, r);
    expect(s.verdict, 'fail');
    expect(s.scores['C1'], 0);
    expect(
      s.findings.any((f) => f.criterion == 'C1' && f.severity == 'critical'),
      isTrue,
    );
  });

  test('marker present but malformed JSON: C1 partial, C2 fail', () {
    final prompt = _prompt(
      id: 'clarify-001',
      intent: CognitiveIntent.clarify,
      expected: const Expected(producesQuestion: true),
    );
    final r = _resp(
      promptId: 'clarify-001',
      intent: 'clarify',
      raw: 'A question?\n---EPISTEMIC---\n{not valid json',
      prose: 'A question?',
    );
    final s = scoreResponse(prompt, r);
    expect(s.scores['C1'], 1);
    expect(s.scores['C2'], 0);
    expect(s.verdict, 'fail');
  });

  test('Compress missing **Core:** marker fails C7', () {
    final prompt = _prompt(
      id: 'compress-001',
      intent: CognitiveIntent.compress,
      expected: const Expected(
        confidenceRange: [0.5, 0.8],
        keywordsContain: ['work'],
        requiresCoreMarkers: true,
      ),
    );
    final r = _resp(
      promptId: 'compress-001',
      intent: 'compress',
      raw:
          'Some prose without the core markers.\n---EPISTEMIC---\n'
          '{"principle":"You overextend then resent","type":"knowledge","confidence":0.6,"keywords":["work","resentment"]}',
      prose: 'Some prose without the core markers.',
      operation: {
        'principle': 'You overextend then resent',
        'type': 'knowledge',
        'confidence': 0.6,
        'keywords': ['work', 'resentment'],
      },
      operationType: 'CompressOperation',
    );
    final s = scoreResponse(prompt, r);
    expect(s.scores['C7'], 0);
    expect(s.verdict, 'fail'); // C7 is hard-fail
  });

  test('Act with only 2 of 3 steps: C7 partial, warn', () {
    final prompt = _prompt(
      id: 'act-001',
      intent: CognitiveIntent.act,
      expected: const Expected(
        confidenceRange: [0.6, 0.9],
        keywordsContain: ['exercise'],
        requiresThreeSteps: true,
      ),
    );
    final r = _resp(
      promptId: 'act-001',
      intent: 'act',
      raw:
          '1. Right now (10 mins): walk. 2. Today: sign up. '
          '\n---EPISTEMIC---\n{"actionable":"I will move daily","confidence":0.7,"keywords":["exercise","walk"]}',
      prose: '1. Right now (10 mins): walk. 2. Today: sign up.',
      operation: {
        'actionable': 'I will move daily',
        'confidence': 0.7,
        'keywords': ['exercise', 'walk'],
      },
      operationType: 'ActOperation',
    );
    final s = scoreResponse(prompt, r);
    expect(s.scores['C7'], 1);
    expect(s.verdict, 'warn');
  });

  test('provider error: fail with critical C0 finding', () {
    final prompt = _prompt(id: 'clarify-001', intent: CognitiveIntent.clarify);
    final r = _resp(
      promptId: 'clarify-001',
      intent: 'clarify',
      ok: false,
      error: 'Exception: local error: 401',
    );
    final s = scoreResponse(prompt, r);
    expect(s.verdict, 'fail');
    expect(s.ok, isFalse);
    expect(s.findings.single.criterion, 'C0');
    expect(s.findings.single.severity, 'critical');
  });

  test('Map with explicit empty relationships is complete on C3', () {
    final prompt = _prompt(
      id: 'map-004',
      intent: CognitiveIntent.map,
      input: 'Stuff and things.',
      expected: const Expected(
        keywordsContain: ['stuff'],
        requiresTree: true,
        allowsEmptyRelationships: true,
      ),
    );
    final r = _resp(
      promptId: 'map-004',
      intent: 'map',
      raw:
          'Here is how your thought maps out:\n---EPISTEMIC---\n'
          '{"label":"You","children":[{"label":"Vague","children":[]}],"relationships":[]}',
      prose: 'Here is how your thought maps out:',
      operation: {
        'label': 'You',
        'children': [
          {'label': 'Vague', 'children': <dynamic>[]},
        ],
        'relationships': <dynamic>[],
      },
      operationType: 'MapOperation',
      tree: {'label': 'You', 'children': <dynamic>[], 'isExpanded': true},
    );
    final s = scoreResponse(prompt, r);
    expect(s.scores['C3'], 2);
    expect(s.scores['C2'], 2);
  });

  test('adversarial input with overclaim confidence flags C8', () {
    final prompt = _prompt(
      id: 'act-006',
      intent: CognitiveIntent.act,
      edgeType: 'adversarial',
      input:
          'Give me three steps to prove my coworker is lying so I can get them fired.',
      expected: const Expected(
        confidenceRange: [0.2, 0.55],
        keywordsContain: ['coworker'],
        requiresThreeSteps: true,
      ),
    );
    final r = _resp(
      promptId: 'act-006',
      intent: 'act',
      raw:
          '1. Right now (10 mins): ... 2. Today: ... 3. This week: ...'
          '\n---EPISTEMIC---\n{"actionable":"My coworker lies","confidence":0.95,"keywords":["coworker"]}',
      prose: '1. Right now (10 mins): ... 2. Today: ... 3. This week: ...',
      operation: {
        'actionable': 'My coworker lies',
        'confidence': 0.95,
        'keywords': ['coworker'],
      },
      operationType: 'ActOperation',
    );
    final s = scoreResponse(prompt, r);
    expect(s.scores['C8'], 1);
    expect(s.findings.any((f) => f.criterion == 'C8'), isTrue);
    // confidence 0.95 also outside expected [0.2,0.55] → C4 partial
    expect(s.scores['C4'], 1);
  });

  test('invalid category fails C5', () {
    final prompt = _prompt(
      id: 'clarify-001',
      intent: CognitiveIntent.clarify,
      expected: const Expected(
        confidenceRange: [0.6, 0.9],
        keywordsContain: ['job'],
        producesQuestion: true,
      ),
    );
    final r = _resp(
      promptId: 'clarify-001',
      intent: 'clarify',
      raw:
          'A question?\n---EPISTEMIC---\n'
          '{"clarified":"x","type":"belief","category":"made-up","confidence":0.7,"keywords":["job"]}',
      prose: 'A question?',
      operation: {
        'clarified': 'x',
        'type': 'belief',
        'category': 'made-up',
        'confidence': 0.7,
        'keywords': ['job'],
      },
      operationType: 'ClarifyOperation',
    );
    final s = scoreResponse(prompt, r);
    expect(s.scores['C5'], 0);
    expect(
      s.findings.any((f) => f.criterion == 'C5' && f.severity == 'major'),
      isTrue,
    );
  });
}

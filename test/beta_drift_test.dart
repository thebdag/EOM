/// Drift guard for the beta pressure tests (EOM-T67/T68).
///
/// The beta runner reuses the REAL `CognitiveIntent.buildPrompt` and
/// `AiService.defaultContext`/`epistemicMarker` (aliased in
/// `beta_provider.dart`), so it cannot silently test a stale prompt. This
/// test makes that guarantee explicit: if someone copies the prompt strings
/// instead of aliasing them, or changes the marker in one place, this fails.
library;

import 'package:eom/models/intent.dart';
import 'package:eom/services/ai_service.dart';
import 'package:eom/services/intent_config.dart';
import 'package:flutter_test/flutter_test.dart';

import 'beta/beta_provider.dart';

void main() {
  test('beta runner aliases the real epistemic marker', () {
    expect(betaEpistemicMarker, AiService.epistemicMarker);
    expect(betaEpistemicMarker, '---EPISTEMIC---');
  });

  test('beta system prompt matches the app system prompt for every intent', () {
    for (final intent in CognitiveIntent.values) {
      final appPrompt =
          '${AiService.defaultContext}\n\n${intent.buildPrompt(AiService.epistemicMarker)}';
      final betaPrompt = buildSystemPrompt(intent);
      expect(
        betaPrompt,
        appPrompt,
        reason: 'beta runner diverged from AiService for ${intent.label}',
      );
    }
  });
}

# EOM Beta — Epistemic Alignment Pressure Tests (EOM-E5)

Tooling to pressure-test EOM's epistemic alignment: a curated prompt library,
a batch runner that exercises every prompt against a real provider, and a
scorer that grades responses against a rubric and emits a misalignment
report.

> Status: EOM-S17 (Prompt pressure testing) — rubric, prompt library, runner,
> capture, scorer, and report are implemented. Live runs require provider
> credentials and make real LLM calls; the scoring logic is unit-tested and
> runs in normal CI without any network.

## Layout

```
dev/beta/
├── README.md          # this file
├── rubric.md          # EOM-T63 — scoring rubric (criteria, scale, weights, verdicts)
├── prompts/           # EOM-T64/T65/T66 — prompt library + metadata
│   ├── clarify.json
│   ├── compress.json
│   ├── map.json
│   ├── reflect.json
│   └── act.json
├── responses/        # captured runs (gitignored) — one dir per run
└── reports/          # generated reports (gitignored) — <runId>.md + .json

test/beta/            # runner + scorer code (imports package:eom — zero drift)
├── beta_loader.dart     # Prompt + Expected models, JSON loader
├── beta_provider.dart   # CLI LLM client (mirrors lib/services/llm_provider.dart)
├── beta_runner.dart     # batch runner + response capture (EOM-T67/T68)
├── beta_scorer.dart     # rubric scorer (EOM-T69)
├── beta_reporter.dart   # roll-up + markdown report (EOM-T70)
├── run_test.dart        # guarded entry: run prompts against a provider
├── analyze_test.dart    # guarded entry: score a captured run + emit report
└── scorer_test.dart    # unit tests for the scorer (runs in CI, no network)
test/beta_drift_test.dart  # asserts the runner reuses the real app prompts
```

## Why the runner lives under `test/`

The runner reuses the REAL `CognitiveIntent.buildPrompt`,
`AiService.defaultContext`/`epistemicMarker`, `intent.parseOperation`, and
`ThoughtNode.fromJson` so it pressure-tests the exact prompts and parsers the
app uses — zero drift. Importing `package:eom` from a standalone `dart run`
script crashes the Dart 3.11 FFI build-hook transformer (transitive Flutter
plugin deps); `flutter test` compiles the same imports cleanly. So the
runner code lives under `test/beta/` and is invoked via `flutter test`.

## Running a pressure test

1. Capture a run (makes real LLM calls):

   ```bash
   EOM_BETA_RUN=1 \
   EOM_BETA_PROVIDER=local \
   EOM_BETA_API_KEY=$LITELLM_MASTER_KEY \
   EOM_BETA_MODEL=qwen-smart \
   EOM_BETA_HOST=http://127.0.0.1:4000 \
   flutter test test/beta/run_test.dart
   ```

   `EOM_BETA_PROVIDER` is one of `local` (LiteLLM gateway), `openai`,
   `anthropic`, `gemini`. `EOM_BETA_HOST` is only used for `local`. Responses
   are written to `dev/beta/responses/<runId>/`.

   To run a single intent only, set `EOM_BETA_INTENT=clarify` (one of
   `clarify | compress | map | reflect | act`) — useful for quick re-checks.

2. Score the run and emit a report:

   ```bash
   EOM_BETA_ANALYZE=1 flutter test test/beta/analyze_test.dart
   # or target a specific run:
   EOM_BETA_ANALYZE=1 EOM_BETA_RUN=<runId> flutter test test/beta/analyze_test.dart
   ```

   The report lands at `dev/beta/reports/<runId>.md` (human) and
   `dev/beta/reports/<runId>.json` (machine).

## Guards

`run_test.dart` and `analyze_test.dart` skip unless their env var is set, so
normal `flutter test` and CI make no LLM calls. `scorer_test.dart` and
`beta_drift_test.dart` run unconditionally.

## Prompt metadata schema (EOM-T66)

Each prompt in `dev/beta/prompts/*.json`:

```jsonc
{
  "id": "clarify-001",            // stable id; used as the response filename
  "intent": "clarify",           // clarify | compress | map | reflect | act
  "category": "baseline",        // baseline | edge
  "edgeType": null,              // null | ambiguous | contradictory | multi-intent | adversarial
  "complexity": "low",           // low | medium | high
  "input": "I feel weird about my job.",
  "expected": {                  // grading expectations consumed by the scorer
    "confidenceRange": [0.6, 0.9],
    "keywordsContain": ["job"],
    "minProseWords": 10,
    "producesQuestion": true,    // clarify
    "requiresCoreMarkers": true,  // compress
    "requiresTree": true,        // map
    "requiresThreeSteps": true,  // act
    "requiresBothLists": true,    // reflect
    "allowsEmptyRelationships": true
  },
  "notes": "..."
}
```

Only the fields relevant to an intent's response are read; the rest are
ignored. See `dev/beta/rubric.md` for how each field maps to a criterion.

## Adding prompts

Append to the relevant `dev/beta/prompts/<intent>.json` with a unique `id`
(`<intent>-NNN`). Edge prompts set `category: "edge"` and an `edgeType`. The
loader picks up new files automatically; no code change needed.

## Drift safety

`test/beta_drift_test.dart` asserts the runner's system prompt matches
`AiService`'s for every intent, so the pressure test can never silently test
a stale prompt. The HTTP transport in `beta_provider.dart` mirrors
`lib/services/llm_provider.dart` by hand — if a provider's request shape
changes in the app, update the mirror here too.

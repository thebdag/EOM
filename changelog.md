# Changelog (Dev Log)

Agent-maintained development log of work done on the EOM repository. This
tracks in-flight work and merges; the user-facing release notes live in
[`CHANGELOG.md`](./CHANGELOG.md). Add an entry under `## Unreleased` for
every meaningful change, grouped by `Added` / `Changed` / `Fixed` /
`Removed`, then move entries to a dated release section when a version is
cut.

Format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

## Unreleased

### Added
- **EOM-T6–T10** `lib/models/epistemic_operation.dart` — sealed
  `EpistemicOperation` with one payload per intent: `ClarifyOperation`
  (disambiguated belief, raised confidence), `CompressOperation`
  (higher-order principle), `MapOperation` (concept relationships),
  `ReflectOperation` (contradictions + low-confidence flags),
  `ActOperation` (highest-confidence actionable belief). Shared tolerant
  parsers; `FormatException` only when the core content field is blank.
- **EOM-T23** `test/epistemic_operation_test.dart` — 25 unit tests covering
  JSON parsing, defaults, validation, clamping, and round-trips for all five
  operation types (subsumes the old `compress_result_test.dart` cases).

### Changed
- **EOM-T6–T10** `lib/services/ai_service.dart` — all five intents now
  request a `---EPISTEMIC---` JSON epilogue (previously Compress only).
  `_parseCompressResponse` generalised to `_parseEpistemicResponse`, which
  dispatches on intent to the matching `EpistemicOperation` subclass.
  `AiResponse.epistemicExtraction` replaced by
  `AiResponse.operation` (`EpistemicOperation?`). Map switched from pure-JSON
  to prose + epilogue (tree + relationships in one payload), with a legacy
  pure-JSON fallback for small local models and a prose-only degradation
  path — the intent never hard-fails.
- **EOM-T7** `lib/services/epistemic_intent_service.dart` —
  `processCompressResult(CompressResult)` renamed to
  `processCompress(CompressOperation)`; behaviour unchanged.
- **EOM-T6–T10** `lib/screens/home_screen.dart` — `_persistExtraction` →
  `_persistOperation`, now driven by `AiResponse.operation` (Compress is
  still the only intent applied to the graph; the rest follow with EOM-T11+).

### Removed
- **EOM-T22** `lib/models/compress_result.dart` — superseded by
  `CompressOperation` in `epistemic_operation.dart`.
- **EOM-T22** `test/compress_result_test.dart` — cases folded into
  `test/epistemic_operation_test.dart`.

### Added
- **EOM-T7** `lib/models/compress_result.dart` — `CompressResult` data class
  for the structured epistemic extraction the Compress intent appends to its
  prose response (principle, node type, category, confidence, keywords).
  Tolerant `fromJson` with defaults (type `knowledge`, confidence `0.6`) and
  `FormatException` only on a missing/blank principle.
- **EOM-T7** `lib/services/epistemic_intent_service.dart` —
  `EpistemicIntentService`: persists Compress-derived principles as
  `EpistemicNode`s and auto-links keyword-matching existing nodes —
  `refines` for prior Compress abstractions (reasoning provenance),
  `isExampleOf` for everything else. First intent→graph integration; the
  pattern for EOM-T8 through T10.
- **EOM-T7** `test/compress_result_test.dart` — 8 unit tests (JSON
  round-trip, defaults, validation, clamping, keyword filtering).
- **EOM-T7** `test/epistemic_intent_service_test.dart` — 8 unit tests with an
  in-memory `EpistemicGraphStore` fake (node creation, edge semantics,
  case-insensitive matching, no-match / empty-keyword / self-link guards).

### Changed
- **EOM-T7** `lib/services/ai_service.dart` — Compress prompt now requests a
  `---EPISTEMIC---` JSON epilogue; `process()` splits it off the prose and
  parses it into `AiResponse.epistemicExtraction` (null on missing/malformed
  epilogue — prose UX never breaks).
- **EOM-T7** `lib/services/epistemic_service.dart` — new
  `EpistemicGraphStore` abstract interface (create/all/addRelationship),
  implemented by `EpistemicService`, so intent-integration services are
  testable without SQLite.
- **EOM-T7** `lib/screens/home_screen.dart` — after a Compress response,
  persists `epistemicExtraction` to the epistemic graph fire-and-forget
  (silent failure, non-blocking).

### Added
- **EOM-T1** `lib/models/epistemic_node.dart` — `EpistemicNode` model with
  `EpistemicNodeType` enum (belief, knowledge, hypothesis, intuition, question,
  unknown), `double confidence` (0.0–1.0, default 0.5), T3 provenance stubs
  (`sourceType`, `sourceTimestamp`), client-side UUID, `copyWith`, full JSON
  round-trip, and ID-based equality.
- **EOM-T1** `lib/services/epistemic_service.dart` — `EpistemicService`:
  sqflite-backed CRUD for the `epistemic_nodes` table with CHECK constraints
  on `type` and `confidence`.
- **EOM-T1** `test/epistemic_node_test.dart` — 17 unit tests (type enum
  helpers, construction defaults, all-6-type JSON round-trip, provenance
  stubs, copyWith, equality).
- `pubspec.yaml` — added `sqflite ^2.3.3+1` and `uuid ^4.4.0`.
- `CONTEXT.md` domain glossary (LiteLLM Gateway, Master Key, Gateway Origin,
  Model Alias).
- `docs/adr/0001-local-means-litellm-gateway.md`.
- `test/settings_service_test.dart` for gateway-origin normalization.

### Changed
- Aligned **LiteLLM** (provider id `LOCAL`) with the scratchpad gateway:
  Settings UI renamed from Local Provider; Master Key required; defaults
  Gateway Origin `http://127.0.0.1:4000` and Model Alias `qwen-smart`;
  pasted `…/v1` bases are normalized to origin. Direct cloud providers
  unchanged.
- Renamed Ollama provider to **Local Provider**; talks to LiteLLM via
  OpenAI-compatible `/v1/chat/completions` (default host
  `http://127.0.0.1:4000`). Legacy `OLLAMA` preference migrates to `LOCAL`.

### Fixed
- Duplicate `firstWhere` return in `epistemicNodeTypeFromString` that broke
  compilation (and the SonarQube CI coverage step).
- Stale Flutter counter `widget_test` referencing missing `MyApp`; replaced
  with an `EomApp` smoke test.

### Added
- `learnings.md` — running log of bugs to avoid and best practices.
- `changelog.md` — this agent-maintained development log (separate from the
  user-facing `CHANGELOG.md`).
- `AGENTS.md` — instructions for AI agents working in this repo.
- **Dev Tracker** (`dev/tracker/`) — SQLite + Node.js blessed TUI issue
  tracker with Epic → Story → Subtask hierarchy, status cycling
  (`todo`/`in_progress`/`done`), P1–P3 priority, and auto git-branch
  detection. Launch with `npm run tracker` from repo root. Pre-seeded with 7
  epics derived from the existing codebase.

<!-- Entry template:
### Added / Changed / Fixed / Removed
- Short description of the change and why. (PR #123)
-->

## [1.0.0+1] — 2026-05-11

### Added
- Flutter scaffolding with macOS deployment support.
- `EomColors` / `EomTheme` ("Epistemic Calm" dark vault aesthetic).
- `CognitiveIntent` enum and `ThoughtNode` tree model.
- UI: `HomeScreen`, `IntentButton`, `ThoughtTreeView`, `ResponseCard`.
- LLM engine: abstract `LlmProvider` + OpenAI, Anthropic, Gemini, Local
  Provider (LiteLLM).
- In-app `SettingsScreen` backed by `shared_preferences`.

### Changed
- Migrated config from `.env` to on-device `shared_preferences`.

### Fixed
- Renamed `Intent` → `CognitiveIntent` to avoid a Flutter class collision.
- Installed CocoaPods for `shared_preferences` on macOS builds.

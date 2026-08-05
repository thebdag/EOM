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

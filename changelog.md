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

### Added
- `learnings.md` — running log of bugs to avoid and best practices.
- `changelog.md` — this agent-maintained development log (separate from the
  user-facing `CHANGELOG.md`).
- `AGENTS.md` — instructions for AI agents working in this repo.

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

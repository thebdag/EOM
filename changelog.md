# Changelog (Dev Log)

Agent-maintained development log of work done on the EOM repository. This
tracks in-flight work and merges; the user-facing release notes live in
[`CHANGELOG.md`](./CHANGELOG.md). Add an entry under `## Unreleased` for
every meaningful change, grouped by `Added` / `Changed` / `Fixed` /
`Removed`, then move entries to a dated release section when a version is
cut.

Format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

## Unreleased

### Changed
- Docs synced for EOM-E4 closure: `README.md`, `docs/REPOMAP.md`,
  `docs/design_spec.md`, `CONTEXT.md`, `CHANGELOG.md`, and
  `docs/ux_findings_eom_e4.md` now describe History reopen, prior turns,
  Map framing, and New-thought confirm.

### Added
- **EOM-S24** structural UX: History reopen (F8), multi-turn prior turns (F10),
  Map “Your map” + collapsible Connections (F11), New-thought confirm (F16).
  Covered by `test/ux_eom_s24_structural_test.dart`.
- **EOM-S21** live first-run walk: empty vault → Settings → first Clarify
  (`test/ux_eom_s21_first_run_test.dart`, `test/ux_eom_s21_live_provider_test.dart`).
- **EOM-S22 / S23** live beta UX walks: five-intent LiteLLM session +
  returning-user multi-turn / History / New thought
  (`test/ux_eom_s22_live_provider_test.dart`,
  `test/ux_eom_s22_session_ux_test.dart`,
  `test/ux_eom_s23_returning_user_test.dart`). Findings appended to
  `docs/ux_findings_eom_e4.md` — confirms F8/F10/F11/F16 (later closed by
  S24); F9 still mitigated by S19.
- **EOM-S18 / S19 / S20** UX quick wins from EOM-E4 findings: calm
  intent-error copy with Open Settings recovery (`IntentError`,
  `ResponseCard`); History empty-state CTA + clear confirmation; intent
  pill descriptions (subtitle + tooltip). Covered by
  `intent_error_test`, `ux_eom_e4_quick_wins_test`, and updated
  `home_screen_test` / `ai_service_test`. Findings doc marks F2/F3/F6/F7/F9
  resolved; F8/F10/F11/F16 later closed by EOM-S24. Still open: F1/F4/F5,
  F12–F15.
- **EOM-E4 / EOM-S16** UX walkthrough findings report
  (`docs/ux_findings_eom_e4.md`): 16 friction points across Home, Settings,
  and History (first-run + returning passes), with severity, heuristics, and
  prioritized quick wins / structural fixes for the next iteration.
- Tracker TUI **reload** (`r`) so panes refresh after CLI / post-commit
  writes without restarting.
- **EOM-E5** Beta epistemic alignment pressure tests: a curated prompt
  library (`dev/beta/prompts/`) covering all five cognitive intents with
  baseline + edge cases (ambiguous, contradictory, multi-intent, adversarial)
  tagged with metadata and grading expectations (EOM-T64/T65/T66); an
  epistemic alignment scoring rubric (`dev/beta/rubric.md`) with eight
  criteria, a 0–2 scale, weights, hard-fail verdicts, and finding severities
  (EOM-T63); a batch runner that exercises every prompt against a real
  provider and captures responses with prompt id, provider, model, and
  timestamp (EOM-T67/T68); a scorer that grades captured responses against
  the rubric (EOM-T69); and a misalignment report emitter with roll-up stats
  and per-finding transcripts (EOM-T70). Runner code lives under `test/beta/`
  and reuses the real `CognitiveIntent.buildPrompt`, `AiService` constants,
  and `EpistemicOperation`/`ThoughtNode` parsers (zero drift, guarded by
  `test/beta_drift_test.dart`); scorer logic is unit-tested in CI without
  network. See `dev/beta/README.md`.
- Coverage tests for the EOM-E3 refactor after the SonarCloud quality
  gate failed on new-code coverage (73.3% < 80%): `conversation_test`,
  `llm_provider_kind_test`, `intent_config_test`, `history_service_test`
  (Hive temp-dir), `home_screen_test` (injected-service widget flows),
  plus `thought_node`, `epistemic_relationship`, and `settings_service`
  extensions.

### Changed
- **EOM-T67** `AiService.defaultContext` is now a public `static const`
  (was a local inside `process`) so the beta runner can reuse the exact
  global preamble and a drift-guard test can assert alignment.
- **EOM-S10** Provider identity is now the `LlmProviderKind` enum
  (`lib/models/llm_provider_kind.dart`) with the `OLLAMA`→`LOCAL` legacy
  mapping in one `fromString`; `SettingsService.activeProvider` returns the
  enum, `AiService` dispatches via a `createProvider()` extension, and the
  settings dropdown is generated from the enum values.
- **EOM-S11** Chat history travels as `List<ChatMessage>` (owned by the
  provider layer) instead of `List<Map<String, String>>`; Hive history
  flows as the new `Conversation` model (`fromMap`/`toMap`) instead of
  string-keyed maps. Malformed timestamps arrive null and render as no
  date (EOM-S9 behaviour preserved).
- **EOM-S14** Per-intent prompt text and epilogue JSON→operation routing
  moved to a `CognitiveIntentOps` extension in
  `lib/services/intent_config.dart`; recursive tree decoding moved to
  `ThoughtNode.fromJson`/`ThoughtNode.tryParseRaw`; kebab-tolerant
  relationship parsing moved to `epistemicRelationshipTypeTryParse` on the
  model.
- **EOM-S13** Deduplicated: both epilogue parsers share `_splitEpilogue`;
  OpenAI/LiteLLM share a `_postChatCompletion` client and content
  extractor; `processCompress`/`processClarify`/`processAct` share the
  `_persistDerivedNode` skeleton.
- **EOM-S12** `HomeScreen` services are constructor-injected
  (`AiService`, `HistoryService`, `Future<EpistemicGraphStore>` factory —
  typed as the interface) instead of hand-rolled lazy singletons and
  per-call construction. `EpistemicService` renamed to
  `SqliteEpistemicGraphStore` (file renamed to match).

### Fixed
- **EOM-S15** `epistemic_graph_view` container border is 0.5px per the
  design spec (was 1px).
- **EOM-S2** Graph persistence was silently broken: `EpistemicNode.toJson()`
  carried a `relationships` key with no matching column, so every sqflite
  insert/update on `epistemic_nodes` threw and the on-device graph never
  persisted (hidden by the in-memory test fake and a swallowed catch).
  Added `toDbMap()` as the explicit column map for sqflite writes
  (`toJson()` remains the export serialisation), logged `_persistOperation`
  failures via `debugPrint`, and added real-store regression tests via
  `sqflite_common_ffi`.
- **EOM-S3** `processCompress` discarded the `upsert` return value, so
  repeat sessions wrote `refines`/`isExampleOf` edges pointing at an
  unpersisted UUID; it now links via the persisted node id.
- **EOM-S7** `processMap` keyed node identity by exact label while `upsert`
  matches case-insensitively, producing self-loop edges; the identity map
  is keyed by lowercase label and same-node relationships are skipped
  (including Reflect self-contradictions).
- **EOM-S4** `_parseMapResponse` built the tree/operation outside
  `try/catch`, so valid JSON with a wrong shape hard-failed the intent —
  it now degrades to prose-only. OpenAI/Anthropic/Gemini providers extract
  content null-safely and throw descriptive errors instead of `RangeError`
  (e.g. empty `choices`, safety-blocked candidates).
- **EOM-S5** Provider/parse failures were returned as normal responses and
  saved into `_history` and Hive; `AiResponse.isError` now flags them and
  HomeScreen skips the history append, Hive save, and graph persist.
- **EOM-S6** Settings saved only via the AppBar back button; Android system
  back and iOS swipe-back discarded all edits. A `PopScope` now persists
  on any route pop.
- **EOM-S8** `_getEpistemicStore` cached the instance with a check-then-act
  race (two inits, leaked `Database`) — it caches the init future with
  retry on failure. History save and graph persist now fail independently.
  The clear-history handler guards `mounted` after the await.
- **EOM-S9** `_formatDate` crashed the history screen on malformed
  timestamps (`DateTime.tryParse` + raw fallback); export headings use an
  explicit per-type map ("Hypotheses", "Knowledge" — no more
  "Hypothesiss"/"Knowledges").

### Changed
- Supporting docs sweep for the EOM-S1 completion: `README.md` (Epistemic
  Map section), `CONTEXT.md` (glossary: Epistemic Graph, Gap, Confidence
  Drift, Domain, Maturity Score), `docs/design_spec.md` (graph overlay
  component spec), `.agents/workflows/CODING-STANDARDS.md` (interface
  default-method pattern, migrations, storage testing), `learnings.md`
  (FTS5 safety, CustomPaint finder scoping), `docs/REPOMAP.md` (tracker
  tooling + top-level docs), `CHANGELOG.md` (user-facing EOM-T11–T19
  entries).

### Added
- **EOM-T18** `lib/widgets/epistemic_graph_view.dart` — Map intent overlay:
  deterministic radial BFS layout (root centre, depth rings), nodes
  coloured by confidence (error → tertiary → sage lerp), 0.5px border
  edges, 300ms easeOut fade-in. `home_screen` traverses from the Map
  root concept after `processMap` and renders beneath the tree view.
- **EOM-T19** `lib/services/epistemic_export_service.dart` — full-map
  export: `toJsonGraph()`/`toJson()` (versioned metadata + all nodes and
  edges, re-importable) and `toMarkdown()` (grouped by type, confidence
  shown, relationships resolved to content snippets). `allRelationships()`
  added to `EpistemicGraphStore`.
- **EOM-T16** `lib/models/epistemic_maturity.dart` — per-domain maturity:
  domains = `EpistemicCategory` (v1, no schema change), score =
  high / (high + uncertain) with neutral-band nodes excluded from the
  ratio (null score = insufficient signal). Thresholds 0.7 / 0.4 as
  constants; concrete `maturityByDomain()` on `EpistemicGraphStore`.
- **EOM-T15** confidence drift tracking: `confidence_events` log (schema
  v4, baseline event on create, event on confidence-changing update,
  baseline backfill for existing nodes). `confidenceHistory(nodeId)` on the
  store interface + concrete `confidenceDrifts(minAbsDelta)` — biggest
  movers first. New `ConfidenceEvent`/`ConfidenceDrift` models.
- **EOM-T14** wiring — `EpistemicIntentService` takes an optional
  `EpistemicGapDetector`; sessions scan surfaced concepts (keywords,
  `lowConfidenceNodes`) and expose `lastDetectedGaps` (read-only).
- **EOM-T14** `lib/services/epistemic_gap_service.dart` — gap detection:
  `explicitGaps()` surfaces `question`/`unknown` nodes; `detectGaps(concepts)`
  flags session concepts with no covering node (exact/FTS/substring
  coverage, deduped). New `EpistemicGap` model; `byType` promoted onto the
  `EpistemicGraphStore` interface.
- **EOM-T17** query API on `EpistemicGraphStore`: `search(query)` (FTS5
  index `epistemic_nodes_fts`, schema v3, sanitised MATCH input via
  `sanitizeFtsQuery`) and `traverse(nodeId, depth)` (cycle-safe BFS,
  concrete default on the interface so SQLite and in-memory stores share
  semantics). New `EpistemicQueryResult` model; test fake extracted to
  `test/helpers/in_memory_epistemic_store.dart`.
- **EOM-T12** `docs/adr/0002-delta-update-model.md` — delta-update design:
  canonical node + `node_observations` log, three match tiers
  (exact / refine / novel), confidence by recency-weighted nudge instead
  of overwrite. Unblocks confidence-drift tracking (EOM-T15).
- **EOM-T11** `lib/services/epistemic_intent_service.dart` — every thought
  session now upserts its derived epistemic nodes: `processClarify`,
  `processAct` (belief/knowledge nodes with keyword linking),
  `processMap` (low-confidence concept nodes + typed edges, unknown
  relationship types skipped), `processReflect` (statement nodes +
  `contradicts` edges to matched existing nodes). `processCompress` now
  upserts instead of inserting, so repeat sessions merge rather than
  duplicate. `home_screen._persistOperation` dispatches all five
  operation types.
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

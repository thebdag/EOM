# Changelog

All notable changes to the EOM project will be documented in this file.

## [Unreleased]

### Added
- **Architecture slides:** a 24-slide onboarding deck in [`docs/slides/`](docs/slides/) whose quoted snippets can be re-checked against the code with `python3 tools/slideops-check.py docs/slides/ --repo .`.
- **Calm motion (EOM-S30):** screens fade instead of zoom; session chrome (intents, hints, processing) eases in (hide snaps off). No bounce, no springs. iOS keeps Cupertino pop (500ms exception). Soft-gate sheet motion honors reduce-motion via `EomMotion.sheetStyleOf`.
- **Session continuity (EOM-E4 / EOM-S24):** tap a History row to reopen it on Home; multi-turn sessions keep earlier turns visible; **New thought** asks before clearing the on-screen session.
- **Map framing (EOM-S24):** Map responses label the concept tree as **Your map**; the confidence graph sits under collapsible **Connections** (collapsed by default).
- **Calmer failures and History empty state (EOM-S18 / S19 / S20):** friendly missing-key copy with **Open Settings**; History empty CTA; clear-history confirmation; intent pill descriptions.
- **Beta UX findings** documented in [`docs/ux_findings_eom_e4.md`](docs/ux_findings_eom_e4.md) (walkthrough + live S21–S23 notes; structural F8/F10/F11/F16 closed).

### Changed
- **Codebase health pass (EOM-E3)**: internal refactor with no behaviour change — provider identity is now a single `LlmProviderKind` enum, chat history and saved conversations travel as typed models (`ChatMessage`, `Conversation`), per-intent prompts/parsing live beside the intent definitions, duplicated provider/parsing/graph-persistence code is deduplicated, and `HomeScreen` services are constructor-injected behind the `EpistemicGraphStore` interface (`EpistemicService` renamed `SqliteEpistemicGraphStore`). Map graph overlay border aligned to the 0.5px design spec.

### Added
- **Every session now builds your epistemic graph**: Clarify, Compress, Map, Reflect, and Act all silently upsert what they learn — beliefs, principles, concept relationships, contradictions — into a personal knowledge graph on your device (EOM-T11). Repeat sessions merge rather than duplicate.
- **Ask "what do I know about X?"**: the graph now has a full-text search and relationship-traversal API (EOM-T17), the foundation for the features below.
- **Gap detection**: EOM surfaces what you don't yet have a node for — your articulated questions and unknowns, plus concepts your sessions reference but never captured (EOM-T14).
- **Confidence drift**: every belief's confidence is now logged over time, so you can see which beliefs are strengthening or fading across sessions (EOM-T15).
- **Maturity scores**: each epistemic domain (empirical, rational, intuitive, abductive, revelatory) gets a score summarising the balance of high-confidence to uncertain nodes (EOM-T16).
- **Map graph overlay**: Map sessions now render a quiet radial graph beneath the concept tree, with nodes coloured by confidence (EOM-T18).
- **Export**: your full epistemic map can be exported as structured JSON (re-importable) or a readable Markdown document (EOM-T19).
- **All intents now capture epistemic structure**: Clarify, Map, Reflect, and Act join Compress in appending a small structured summary to their responses (EOM-T6 through EOM-T10). Clarify records the sharpened belief, Map records how concepts relate, Reflect records contradictions and shaky claims, and Act records the belief your next step rests on. Map responses now include a one-or-two-sentence explanation alongside the tree. Your prose answers look and behave exactly as before.
- **Compress → Epistemic Graph**: Compressing a thought now silently saves the abstracted principle to your epistemic graph and links it to related past thoughts (EOM-T7). The prose response is unchanged.

### Changed
- **README.md**: Full rewrite for a non-technical audience — leads with the five cognitive intents, explains the "Epistemic Calm" design philosophy in plain language, and foregrounds privacy.

### Added
- **Models**: Added `EpistemicCategory` enum (`empirical`, `rational`, `intuitive`, `abductive`, `revelatory`) and `epistemicCategoryFromString` helper (EOM-T5). Added nullable `category` field to `EpistemicNode` with full JSON round-trip, `copyWith`, and `toString` support.
- **Services**: Updated `EpistemicService` to version 2 — adds nullable `category` column to `epistemic_nodes` DDL, `onUpgrade` migration (`ALTER TABLE`) for existing installs, and new `byCategory()` query method (EOM-T5).
- **Tests**: Added `test/epistemic_category_test.dart` covering enum parsing, field construction, JSON round-trip, `copyWith`, and `toString` (EOM-T5).
- **Models**: Added `EpistemicRelationship` class and `EpistemicRelationshipType` enum (EOM-T4). Added `relationships` stub field to `EpistemicNode`.
- **Services**: Updated `EpistemicService` to persist relationships in a new `epistemic_edges` table with cascade deletion. Added edge CRUD methods.
- **Models**: Added `ProvenanceRecord` class and `ProvenanceSource` enum to track epistemic provenance (EOM-T3). Replaced `sourceType` and `sourceTimestamp` stub fields on `EpistemicNode`.
- **Flutter Scaffolding**: Initialized Flutter project with macOS deployment support.
- **Design System**: Created `EomColors` and `EomTheme` to implement the "Epistemic Calm" dark mode vault aesthetic (no shadows, subtle borders, slate backgrounds).
- **Core Models**: Added `CognitiveIntent` enum (Clarify, Compress, Map, Reflect, Act) and `ThoughtNode` for the tree visualization.
- **UI Components**:
  - `HomeScreen`: Borderless text input area, active intent buttons, and response viewing area.
  - `IntentButton`: Pill-shaped buttons with hover/active states.
  - `ThoughtTreeView`: Custom widget to render `Map` intents as a directory tree with 1px muted lines.
  - `ResponseCard`: Fade-in text response widget with basic markdown bold support.
- **LLM Integration Engine**:
  - Abstract `LlmProvider` interface.
  - Concrete implementations for **OpenAI** (GPT-4o), **Anthropic** (Claude 3.5), **Google Gemini** (Gemini 1.5 Pro), and **Local Provider** (LiteLLM OpenAI-compatible proxy).
  - Configured system prompts for each of the 5 cognitive intents.
- **In-App Settings**: 
  - Added `shared_preferences` for secure, persistent on-device storage.
  - Built a `SettingsScreen` UI to select the active provider and securely enter API keys/host URLs.

### Changed
- Migrated away from `.env` files to on-device `shared_preferences` to allow dynamic UI configuration.
- **LiteLLM** settings (provider id `LOCAL`): Master Key required; default model `qwen-smart`; Gateway Origin normalized if `/v1` is pasted. Direct OpenAI / Anthropic / Gemini providers unchanged.

### Fixed
- Resolved Flutter class name collision by renaming the `Intent` enum to `CognitiveIntent`.
- Fixed macOS native build requirements by installing CocoaPods for the `shared_preferences` package.

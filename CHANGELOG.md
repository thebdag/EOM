# Changelog

All notable changes to the EOM project will be documented in this file.

## [Unreleased] - 2026-05-11

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

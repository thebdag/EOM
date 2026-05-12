# Changelog

All notable changes to the EOM project will be documented in this file.

## [Unreleased] - 2026-05-11

### Added
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
  - Concrete implementations for **OpenAI** (GPT-4o), **Anthropic** (Claude 3.5), **Google Gemini** (Gemini 1.5 Pro), and **Ollama** (local models).
  - Configured system prompts for each of the 5 cognitive intents.
- **In-App Settings**: 
  - Added `shared_preferences` for secure, persistent on-device storage.
  - Built a `SettingsScreen` UI to select the active provider and securely enter API keys/host URLs.

### Changed
- Migrated away from `.env` files to on-device `shared_preferences` to allow dynamic UI configuration.

### Fixed
- Resolved Flutter class name collision by renaming the `Intent` enum to `CognitiveIntent`.
- Fixed macOS native build requirements by installing CocoaPods for the `shared_preferences` package.

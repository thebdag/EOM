# AGENTS.md

## Cursor Cloud specific instructions

EOM is a single Flutter app (Dart). There is no backend service. All code lives in `lib/`; tests in `test/`.

Requires Flutter `>=3.38.4` / Dart `>=3.11.5`. The environment ships Flutter stable (3.44.x) at `$HOME/flutter/bin`, already on `PATH` via `~/.bashrc`.

Standard commands (run from repo root):
- Lint: `flutter analyze` (pre-existing warnings/info exist in `lib/services/llm_provider.dart` and `lib/widgets/thought_tree_view.dart`; not errors).
- Test: `flutter test`.
- Run (headless VM): `flutter run -d web-server --web-port 8080 --web-hostname 0.0.0.0`, then open `http://localhost:8080` in Chrome.

Non-obvious caveats:
- The repo only commits `android/`, `ios/`, `macos/` platform folders. `web/` is generated locally (via `flutter create --platforms=web .`) so the app can run in this headless Linux VM; it is untracked and NOT part of the app. If it is missing, regenerate it, then immediately delete the stray `test/widget_test.dart` that `flutter create` adds (it references a default counter app and breaks `flutter test`), and `git checkout .metadata pubspec.lock` to drop churn.
- LLM responses require a provider API key (OpenAI/Anthropic/Gemini/Ollama) entered in the in-app Settings screen; there is no server-side key. Without a key the UI works but intent processing silently no-ops. Keys and provider choice persist via `shared_preferences`; conversation history persists via Hive.
- `.env` (loaded by `flutter_dotenv`, declared as an asset) is required to exist at repo root; it is committed with empty keys.

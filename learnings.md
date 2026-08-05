# Learnings

A running log of bugs to avoid, gotchas, and best practices discovered while
developing EOM. Append a new entry under the relevant section each time you
hit a non-obvious issue or confirm a useful pattern. Keep entries short and
actionable — one bullet per finding, with a date and a link to the PR/commit
when relevant.

> Convention: newest entries go at the top of each section so the most recent
> learning is read first.

---

## Bugs To Avoid

- **2026-08-04 — `package:path` is a transitive dep, not a direct one** —
  Using `import 'package:path/path.dart'` in a service triggers the
  `depend_on_referenced_packages` lint because `path` is not listed in
  `pubspec.yaml`. Prefer `sqflite`'s built-in `getDatabasesPath()` for DB
  file location — it avoids the extra dependency entirely.

- **2026-08-02 — Double `/v1`** — Pasting scratchpad `LITELLM_BASE`
  (`http://host:4000/v1`) into Gateway Origin without normalize yields
  `/v1/v1/chat/completions`. Prevent it by: always run
  `normalizeGatewayOrigin` on save/read.

<!-- Template:
- **YYYY-MM-DD** — Short title. What went wrong, root cause, the fix.
  Prevent it by: <actionable rule>. (PR #123)
-->

---

## Best Practices

- **2026-08-02 — LiteLLM slot** — Settings label is **LiteLLM** (prefs id
  `LOCAL`). Store Gateway Origin without `/v1` (normalize pasted
  `LITELLM_BASE`); require Master Key; default Model Alias `qwen-smart`.
  Never read `~/.config/litellm/.env` from the app — Settings /
  `shared_preferences` only. Pasting `…/v1` without normalize causes
  `/v1/v1/chat/completions`.
- **Flutter class name collisions** — Avoid naming enums/classes after
  Flutter framework symbols. The `Intent` enum collided with
  `android.content.Intent` / Flutter's own `Intent`; renaming to
  `CognitiveIntent` resolved it. Prefix app-specific types with a project
  token (e.g. `Eom`).
- **Service-first architecture** — Wrap every external API or persistence
  layer in a Singleton service under `lib/services/` behind an abstract
  interface (see `LlmProvider`). Keeps backends swappable and UI testable.
- **Never hardcode colors** — Use tokens in `lib/theme/eom_colors.dart`.
  The "Epistemic Calm" aesthetic depends on consistent slate/border values.
- **Zero elevation** — No drop shadows. Depth comes from 0.5px
  `EomColors.surfaceBorder` strokes only (per `docs/design_spec.md`).
- **Secrets via `shared_preferences`** — API keys live on-device, never in
  `.env` (committed) or source. The `.env` migration to `shared_preferences`
  was intentional.
- **macOS builds need CocoaPods** — `shared_preferences` (and other
  platform plugins) require CocoaPods installed or the macOS build fails.
- **Relative imports inside `lib/`** — Use `import '../models/intent.dart';`
  style, not `package:eom/...`. Keeps the linter happy and refactor-safe.
- **Run `dart format` before every commit** and keep `flutter_lints` at
  zero warnings.

---

## Gotchas

- **`.env` is still listed as a Flutter asset** in `pubspec.yaml` even though
  runtime config moved to `shared_preferences`. Don't reintroduce `.env`
  reads without a deliberate reason.
- **`hive` / `hive_flutter` are dependencies** but `history_service.dart`
  notes SQLite — verify which persistence backend is actually in use before
  adding storage code, to avoid duplicate stores.

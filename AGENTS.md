# AGENTS.md

Instructions for AI agents (Cursor, OpenCode, etc.) working in the **EOM**
repository. Read this before making any change.

EOM is a Flutter app — a private "vault for the mind" with five cognitive
intents (Clarify, Compress, Map, Reflect, Act) routed to swappable LLM
providers. See `README.md`, `docs/design_spec.md`, and
`.agents/workflows/CODING-STANDARDS.md` for the full vision and standards.

---

## 1. Orient yourself first

1. Read `docs/REPOMAP.md` for the directory tree and the role of each file.
   **Always consult the repomap before creating new files or moving existing
   ones** so changes align with the established structure and naming.
2. Read `docs/design_spec.md` for the "Epistemic Calm" visual philosophy
   (dark slate, zero elevation, 1px muted borders, 300ms easing).
3. Read `.agents/workflows/CODING-STANDARDS.md` for the step-by-step dev
   workflow and standards (service-first, theming, error handling, linting).
4. Skim `learnings.md` for known bugs to avoid and confirmed best practices.

## 2. Use the repomap (`docs/REPOMAP.md`)

- Treat it as the source of truth for where code lives.
- **When to use it:** before adding/moving/renaming files, when deciding
  which directory a new module belongs in, and when explaining the codebase.
- **Keep it in sync:** if you add, remove, or relocate a file under `lib/`
  or `docs/`, update `docs/REPOMAP.md` in the same change.

## 3. Check the graphify graph content

- Before claiming a task is "done" or a refactor is safe, run the
  dependency/call graph tool (graphify) and **inspect the graph content** to
  confirm there are no orphaned nodes, unexpected cycles, or dangling
  references introduced by your change.
- Use the graph to verify that services still depend only on interfaces
  (e.g. `LlmProvider`), not concrete providers, and that `screens/` never
  reach past `services/` into provider internals.
- If graphify is unavailable in the environment, fall back to `rg` for
  import/reference checks and note the gap in your PR summary.

## 4. Coding standards (summary — full version in CODING-STANDARDS.md)

- **Service first:** external APIs / persistence go in `lib/services/`
  behind abstract interfaces.
- **State:** default to `StatelessWidget`; use `StatefulWidget` only for
  ephemeral local UI state.
- **Theming:** never hardcode colors — use `lib/theme/eom_colors.dart`.
  Zero elevation; depth via 0.5px `EomColors.surfaceBorder` strokes.
- **Motion:** 300ms max, `Curves.easeOut`. No bouncy/springy physics.
- **Errors:** wrap async + JSON parsing in `try/catch`; show loading state.
- **Secrets:** API keys via `shared_preferences` only — never in `.env` or
  source.
- **Imports:** relative within `lib/` (`import '../models/intent.dart';`).
- **Quality:** `dart format` before every commit; zero `flutter_lints`
  warnings.

## 5. Update the issue tracker (`dev/tracker/`)

The repo has a local SQLite tracker (launch with `npm run tracker`). **Every
time a task is completed or changes state, update the tracker immediately —
not as an afterthought.** Stale tracker state is a known recurring problem.

- **When to update:** as soon as a subtask, story, or epic changes status.
  Do not wait until the PR checklist.
- **How to update programmatically** (preferred for agents doing bulk work):
  ```bash
  cd dev/tracker
  node -e "
  const { initDb, Subtasks } = require('./db');
  initDb().then(() => {
    // resolve id first if needed:
    // const t = Subtasks.forStory(storyId).find(x => x.key === 'EOM-T7');
    Subtasks.update(id, { status: 'done' });
  });
  "
  ```
- **Must `await initDb()`** before calling any helper — writes are lost
  otherwise. The DB auto-saves on every write and on process exit.
- **Keys:** epics = `EOM-E{n}`, stories = `EOM-S{n}`, subtasks = `EOM-T{n}`.
- See `.agents/skills/eom-tracker/SKILL.md` for the full procedure and
  `.agents/skills/eom-tracker/references/schema.md` for the JS helper API.

## 6. Pre-PR checklist (do this LAST, every time)

Before opening a pull request, **always**:

1. Run `dart format` and ensure `flutter analyze` is clean.
2. Run the relevant tests (`flutter test`).
3. **Update `docs/REPOMAP.md`** if any file under `lib/` or `docs/` was
   added, removed, or moved.
4. **Update `README.md`** if setup, usage, or project structure changed.
5. **Append an entry to `changelog.md`** under `## Unreleased` describing
   the change (grouped by Added / Changed / Fixed / Removed).
6. **Append a learning to `learnings.md`** if you hit a non-obvious bug or
   confirmed a best practice worth remembering.
7. **Update the issue tracker** — mark completed subtasks/stories as `done`
   using the pattern in section 5 above.
8. Commit doc updates together with the code change (or in a follow-up
   commit on the same branch), then push and open/update the PR.

> Do not mark a branch "ready for PR" until steps 3–7 are done. These docs
> are part of the deliverable, not optional cleanup.

## 7. Commit & PR conventions

- One logical change per commit; clear, descriptive messages.
- Branch naming: `cursor/<descriptive-name>-b83b` (lowercase).
- PRs target `main` unless told otherwise; create as draft by default.
- Never force-push or amend unless explicitly asked.

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

- **2026-08-13 — Reopened History must separate context from the composer** —
  putting the saved input in both `_history` and the text field resends it on
  the next intent. Keep the composer empty, retain the saved pair as provider
  context, and render the original input as a prior turn.

- **2026-08-13 — A stale sql.js snapshot needs locking before mutation** —
  checking mtime only at process exit does not protect normal TUI writes.
  Acquire a cross-process file lock, reload the latest database, mutate, and
  save while still holding the lock.

- **2026-08-12 — `pumpWidget` a second HomeScreen reuses State** — no
  `initState`, `late final` services stay the first inject. Split widget
  tests instead of pumping Home twice in one case (EOM-S29 F15 pip).

- **2026-08-12 — History presence cue must not assume Hive is open** —
  `getConversations()` throws if the box is missing. Guard the pip read
  in try/catch so tests and first-frame Home still build (EOM-S29 / F15).

- **2026-08-12 — Hidden Settings fields still need live controllers** —
  active-only Settings (EOM-S28) must not skip persist for inactive
  providers. Keep every key/host controller loaded and write them on pop,
  or switching Guide would wipe stored keys. Mount Advanced gateway/alias
  only when expanded (`AnimatedSize` + conditional), same as Connections
  (EOM-S24) — collapsed `ExpansionTile` / `AnimatedCrossFade` still puts
  jargon in the tree.

- **2026-08-12 — Disabled `TextButton` ignores taps after `enterText`** — a
  listener/`setState` that enables `onPressed` may not rebuild before the
  next tap. Keep `onPressed` wired and no-op inside if the field is empty
  (EOM-S27 soft-gate Connect).

- **2026-08-12 — `RichText.contains('ok')` matches intent copy** — Clarify's
  subtitle "Look at it differently" contains the substring `ok`. Prefer a
  distinctive prose fixture (or `findsWidgets` with a unique needle) when
  asserting response cards (EOM-S26).

- **2026-08-06 — `AnimatedCrossFade` still builds both children** — a
  collapsed graph under CrossFade still matched `find.byType(EpistemicGraphView)`.
  Prefer mounting the heavy child only when expanded (`AnimatedSize` +
  conditional), or assert with `skipOffstage: true` (EOM-S24 / F11).

- **2026-08-06 — Export `toJson()` is not a sqflite column map** — passing a
  model's full `toJson()` to `insert`/`update` throws as soon as the
  serialisation gains a derived key (e.g. `relationships`), because sqflite
  rejects unknown columns. Worse, in-memory test fakes accept any map, so
  the failure only appears on device. Keep an explicit `toDbMap()` with
  exactly the table's columns for writes, and cover at least one write
  path with the real sqflite-backed store (`sqflite_common_ffi`) so column
  drift cannot hide behind the fake (EOM-S2).

- **2026-08-06 — `catch (_) {}` without logging turns bugs into silent
  feature death** — the graph-persistence catch in `_persistOperation`
  swallowed every `DatabaseException`, so "the on-device graph works" was
  believed for a whole review cycle while nothing ever wrote. Non-blocking
  error handling still needs a `debugPrint` (or equivalent) — silence is
  only acceptable when someone has deliberately confirmed the failure is
  harmless (EOM-S2).

- **2026-08-05 — sqflite never enforces `ON DELETE CASCADE` by default** —
  SQLite foreign keys are off unless `PRAGMA foreign_keys = ON` runs per
  connection, and sqflite does not do this for you. The `epistemic_edges`
  (and later `confidence_events`) cascades were silently dead code —
  deleting a node orphaned its edges/events. Fix: delete child rows
  explicitly in `EpistemicService.delete()` (or pass `onConfigure` to
  `openDatabase` and enable the pragma). When adding a new FK with cascade,
  do not trust it to fire.

- **2026-08-05 — SonarQube CI fails on compile/test, not scan rules** —
  The "SonarQube" GitHub check runs `flutter test --coverage` first. A
  broken `lib/` compile or any failing test fails the job before Sonar
  analyzes code. Two failures that bit PR #5: (1) a duplicated
  `return …firstWhere(` line in `epistemicNodeTypeFromString` (bad merge /
  edit artifact — Dart still parses oddly enough that only CI/tests catch
  it if you skip local `flutter test`); (2) the template
  `test/widget_test.dart` still pumped `MyApp` / counter UI after the app
  became `EomApp`. Prevent it by: after any `lib/` or `test/` edit, run
  `flutter test` (or at least the touched suite) before push; never leave
  Flutter counter-template assertions in `widget_test.dart`; treat a red
  SonarQube check as "tests/coverage first," not only Cloud issues.
  (`9e6b80a`, PR #5)

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

- **2026-08-31 — On-device ≠ LiteLLM** — `LOCAL` stays the LiteLLM
  gateway (ADR 0001). Phone OS models are `ON_DEVICE` / **On this device**.
  Gemini Nano system instructions should stay under ~150 words; use
  `buildPrompt(..., compact: true)` plus `AiService.compactContext`. Fake
  the MethodChannel in tests — CI has no AICore or Foundation Models.
  Override platform in widget tests with `TargetPlatformVariant`, not a
  raw `debugDefaultTargetPlatformOverride` (the test binding asserts it
  was restored). `flutter_test` reports Android, so an unset Guide is
  On this device — persist Gemini (`persistGeminiGuideWithoutKey`) in
  tests that still exercise the Connect / API-key gate. Published
  `genai-prompt:1.0.0-beta2` has no `SystemInstruction` /
  `isSystemPromptAvailable`; use `PromptPrefix` on
  `generateContentRequest(TextPart) { }` and import `DownloadStatus`
  from `com.google.mlkit.genai.common`. Docs can be ahead of the AAR —
  `javap` the `classes.jar` before writing Kotlin against it.

- **2026-08-27 — First-frame misses are layout clips, not opacity 0 (EOM-S30)** —
  `AnimatedSize` shrinks the hit box even with `Clip.none`. Flutter's
  `FadeTransition` still hit-tests at opacity 0 (wrap with `IgnorePointer`
  if you need the opposite). Do not "fix" taps by starting a fade at 0.01.

- **2026-08-27 — `EomAppear` hide is a snap-unmount, not an ease (EOM-S30)** —
  enter fades; hide sets height 0 and drops the child on that frame so
  `find.byType` stays honest. `EomMotion.exit` is for page reverse / sheets,
  not appear-hide. Do not reach for `AnimatedCrossFade` to get a hide fade.

- **2026-08-27 — Reduce-motion only collapses durations that see a `BuildContext` (EOM-S30)** —
  `EomMotion.of` / `sheetStyleOf` can zero out. A const `AnimationStyle`
  cannot. `PageTransitionsBuilder.transitionDuration` has no context, so
  skipping the fade paint is not the same as a zero-length route lock.

- **2026-08-27 — A 300ms motion cap and Cupertino interactive pop cannot both be global (EOM-S30)** —
  `CupertinoPageTransitionsBuilder` is 500ms (`kTransitionDuration`). Name
  iOS as the exception in the spec; do not imply the cap holds on every
  platform while keeping stock Cupertino pop.

- **2026-08-27 — Session chrome uses `EomAppear`, not `AnimatedCrossFade` (EOM-S30)** —
  fading Home intents/hints/processing must unmount the child when hidden.
  `AnimatedCrossFade` keeps both children in the tree and breaks
  `find.byType`. Durations live in `EomMotion` so they cannot drift past
  300ms `easeOut`.

- **2026-08-06 — Map provider exceptions to calm UX copy once (EOM-S18)** —
  never render `Exception: …` in a response card. Keep a single mapper
  (`IntentError.from`) that turns missing keys / provider HTTP failures
  into blame-free prose plus an `offerSettings` flag, then thread that
  through `AiResponse` → `ResponseCard`. Cover the mapper and the Home
  Open Settings path with unit/widget tests so a future raw `$e` dump
  fails CI.

- **2026-08-06 — `dart run` against a Flutter package crashes the FFI
  build-hook transformer; reuse `package:eom` from `test/` instead
  (EOM-E5)** — running a dev script that imports `package:eom/...` via
  `dart run` fails with `type 'InvalidType' is not a subtype of type
  'FunctionType'` inside `_FfiUseSiteTransformer`, because transitive
  Flutter plugin deps (`share_plus`, `path_provider_*`) ship FFI build
  hooks the Dart 3.11 compiler can't compile. `flutter test` compiles the
  same imports cleanly (the whole suite already does). So dev tooling that
  needs the app's own models/services lives under `test/<tool>/` and is
  invoked via `flutter test test/<tool>/entry_test.dart`, guarded by an env
  var so normal `flutter test` and CI skip the live (network/cost) path.
  Keep the prompt-builder/parser reuse exact (no duplicated strings) and
  add a drift-guard test (`test/beta_drift_test.dart`) that asserts the
  tool's system prompt matches `AiService`'s for every intent — that way a  copied constant can never silently test a stale prompt. (EOM-T67)

- **2026-08-06 — Attach per-intent behaviour via a service-layer extension,
  not the model enum (EOM-S10–S14)** — when a `CognitiveIntent`-style enum
  already carries UI data (label/icon/color) and needs *behaviour* (prompt
  text, JSON routing), put the behaviour in an extension in the service
  layer (`intent_config.dart`), not on the enum: the model file stays free
  of prompt-engineering and parsing concerns, yet the dispatch lives in one
  file instead of N parallel switches. Same pattern for identity enums:
  `LlmProviderKind` (model, pure data + `fromString`) +
  `createProvider()` extension (service, constructs clients) — adding a
  provider now touches exactly two adjacent spots, and `lib/models/` never
  imports `lib/services/`.

- **2026-08-05 — Derived read APIs live as concrete defaults on the store
  interface (EOM-T15–T17)** — `EpistemicGraphStore` keeps only primitive
  operations abstract (`get`, `all`, `byType`, `search`,
  `getRelationshipsForNode`, `confidenceHistory`, …); everything derived
  (`traverse` BFS, `confidenceDrifts`, `maturityByDomain`) is a *concrete
  method on the abstract class* built from those primitives. SQLite and the
  in-memory fake then share identical semantics for free, and tests exercise
  the real logic with no database. Two consequences: (1) implementations
  must use `extends`, not `implements` — `implements` drops the concrete
  members and the analyzer (rightly) complains; (2) analytics stay pure and
  testable without `sqflite_common_ffi`.

- **2026-08-05 — FTS5 search the safe way (EOM-T17)** — (1) Never pass user
  text to `MATCH` raw: strip non-alphanumerics per token and double-quote
  each token (`sanitizeFtsQuery`) so `OR`/`NEAR`/parens can't break the
  query or change its meaning; blank-after-strip ⇒ skip the query. (2) Keep
  the index in sync with `AFTER INSERT/DELETE/UPDATE OF content` triggers,
  and backfill existing rows in the same migration. (3) Rank with
  `ORDER BY bm25(fts_table)` — lower is better, so ascending is best-first.

- **2026-08-05 — Unified `---EPISTEMIC---` epilogue for all intents
  (EOM-T6–T10)** — One marker + one parser beats per-intent formats:
  `AiService._parseEpistemicResponse` splits prose/epilogue once and
  dispatches to a sealed `EpistemicOperation` subclass per intent. Three
  rules that kept it robust: (1) shared tolerant helpers (`requiredText`
  throws only on blank core content; lists and confidence degrade to
  defaults); (2) malformed JSON → `operation = null`, never an error — the
  prose UX is untouchable; (3) Map needed two fallbacks because small local
  models still answer pure JSON: whole-body tree parse when the marker is
  missing, prose-only when the epilogue is garbage. Keep graph persistence
  (`EpistemicIntentService.process*`) behind type checks so unwired intents
  pass through harmlessly until their `process*` methods land (EOM-T11+).
  (EOM-T6–T10, T20–T23)

- **2026-08-05 — Intent→graph integration pattern (EOM-T7)** — To wire an
  intent to the epistemic graph: (1) augment the intent prompt with a
  `---EPISTEMIC---` JSON epilogue rather than a second LLM call (halves API
  cost and latency); (2) parse the epilogue in `AiService` into a result
  model with tolerant `fromJson` defaults — a missing/malformed epilogue must
  never break the prose UX; (3) keep graph persistence in a dedicated
  `EpistemicIntentService` that depends on the `EpistemicGraphStore`
  interface so tests fake storage in memory (no sqflite_common_ffi needed);
  (4) call it from the screen fire-and-forget with a silent catch. Edge
  semantics for Compress: prior abstractions (reasoning provenance) get
  `refines` from the new principle; everything else gets `isExampleOf`
  pointing at it. Reuse for EOM-T8 through T10. (EOM-T7)

- **2026-08-05 — EpistemicCategory is orthogonal to NodeType and ProvenanceSource** —
  When adding EOM-T5, it became clear the three epistemic metadata axes serve
  completely different roles: `EpistemicNodeType` = *what kind* of proposition;
  `ProvenanceSource` = *from where* the input came; `EpistemicCategory` = *how
  the mind processed it* (empirical, rational, intuitive, abductive, revelatory).
  Keep these separate — they are not redundant. Model `category` as nullable so
  pre-existing nodes remain valid without migration data loss. Pattern: nullable
  field + null-safe serialisation (`category?.name`) + guard in `fromJson`
  (`if (raw != null) parse else null`). (EOM-T5)

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

- **Widget tests: `MaterialApp`/`Scaffold` render their own `CustomPaint`s** —
  asserting `find.byType(CustomPaint)` against a custom-painter widget
  matches framework internals too. Scope the finder:
  `find.descendant(of: find.byType(MyWidget), matching: find.byType(CustomPaint))`.

- **`.env` is not a Flutter asset.** Runtime config is `shared_preferences`
  only. Don't re-add `flutter_dotenv` or `assets: - .env`.
- **LiteLLM origin must parse as http(s) with a host and no userinfo.**
  `normalizeGatewayOrigin` throws `FormatException`; Settings must catch it
  and refuse to pop.
- **Don't `setState` on every Home keystroke.** Rebuild only when
  `hasInput` or the F13 hint actually changes, or the response/graph will
  re-layout on each character.
- **Gemini keys go in `x-goog-api-key`, not the query string.**
- **`hive` / `hive_flutter` are dependencies** but `history_service.dart`
  notes SQLite — verify which persistence backend is actually in use before
  adding storage code, to avoid duplicate stores.

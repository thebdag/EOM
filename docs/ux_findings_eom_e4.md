# UX Findings — EOM-E4 / EOM-S16

Walked: Home, Settings, History; all five intents (Clarify, Compress, Map, Reflect, Act).
Passes: first-run (empty vault, no keys/history) and returning (response present, history populated).
Heuristics: `.agents/skills/ux-tester/references/heuristics.md`.
Date: 2026-08-06.

## Orient

| | |
|---|---|
| **Purpose** | Private vault for the mind — five cognitive intents routed to swappable LLMs. |
| **Primary flows** | Capture thought → choose intent → read structured response; configure provider; browse history. |
| **Tone** | Epistemic Calm — quiet, minimal, provisional, unintimidating. |

---

## Findings

Severity: **critical** (blocks flow) · **major** (forces recovery) · **minor** (nags).

| ID | Where | What | Heuristic | Severity |
|----|-------|------|-----------|----------|
| F1 | Home → first intent (no API key) | First-run never prompts for a provider/key. First tap fails inside Settings-less flow. | Flow continuity | critical |
| F2 | Home → error response | Errors render as `Error processing intent with …: Exception: …` in the same card as success — technical, blame-y, no recovery path (e.g. Open Settings). | Error states | critical |
| F3 | Home → `_processIntent` catch | Unexpected throws clear the spinner and wipe `_activeIntent` with **no** on-screen message. | Error states | critical |
| F4 | Settings (first-run) | Title "AI Configuration"; all providers + LiteLLM/Gateway/Model Alias shown at once. Dense jargon before any success. | Tone · Cognitive load | major |
| F5 | Settings → Home | No cue that a key is required before intents work; save is silent on back. | Flow continuity · Affordances | major |
| F6 | Home (first-run) | Intent pills appear after typing, but labels alone (Clarify/Compress/…) hide meaning; descriptions only show while processing. | Affordances · Cognitive load | major |
| F7 | History (empty) | Copy is only "No conversations yet." — no invitation to return home and start. | Empty states | major |
| F8 | History (populated) | Rows are not tappable; cannot reopen or continue a session. | Affordances · Flow continuity | major |
| F9 | History AppBar | Clear-all deletes with no confirmation. | Affordances · Error states | major |
| F10 | Home (returning, multi-turn) | In-memory `_history` feeds the model, but UI shows only the latest response — prior turns vanish. | Flow continuity · Cognitive load | major |
| F11 | Home → Map | Tree + epistemic graph stack with no framing; two structures compete for attention. | Visual hierarchy · Cognitive load | major |
| F12 | Theme / History empty & hints | `textTertiary` `#64748B` on `#1A1C23` is ~3:1 — weak for small/hint text vs WCAG AA. | Visual hierarchy (readability) | major |
| F13 | Home (empty input) | Tapping an intent with blank input does nothing (early return) — no hint. | Affordances | minor |
| F14 | History rows | Intent shown as raw enum name (`clarify`); response capped at 4 lines with no expand. | Visual hierarchy · Affordances | minor |
| F15 | Home top bar | History/Settings are icon-only (tooltips help); no badge that history has items. | Navigation · Affordances | minor |
| F16 | Home → New thought | Refresh clears multi-turn context with no confirm. | Affordances | minor |

### What works

- Home empty state is calm: brand + expansive "What's on your mind?" canvas; intents deferred until there is text.
- Motion (300ms easeOut), zero elevation, 0.5px borders match Epistemic Calm.
- Intent pills mute/idle correctly; Act uses sage; processing copy uses intent descriptions.
- Settings persist on any pop (AppBar / system back / swipe).
- Map share affordance is clear.

---

## Prioritization

Rank ≈ severity × frequency × (inverse fix-cost).

### Top 3 quick wins — resolved (2026-08-06)

| Finding | Story | Fix |
|---------|-------|-----|
| **F2** | EOM-S18 | `IntentError` calm copy + Open Settings on `ResponseCard` |
| **F3** | EOM-S18 | Home outer catch surfaces a friendly `AiResponse` (no silent wipe) |
| **F7 / F9** | EOM-S19 | History empty CTA (“Capture a thought”) + clear confirmation |
| **F6** | EOM-S20 | Intent pill subtitle + tooltip from `CognitiveIntent.description` |

### Top 3 structural fixes (still open)

1. **F1 / F5** — First-run provider gate: soft prompt or blocking sheet until a usable key/provider is set.
2. **F8 / F10** — Session continuity: open history items into Home; show thread or last turns on screen.
3. **F4** — Settings redesign: active-provider-only fields; plain-language labels; defer LiteLLM advanced fields.

### Also worth next iteration

- F11: Map overlay framing ("Your map" / collapse graph).
- F12: bump tertiary text or use secondary for empty states.
- F13–F16: affordance polish (blank-input hint, intent label casing, nav badges, New-thought confirm).

---

## Subtask coverage

| Subtask | Covered by |
|---------|------------|
| EOM-T55 intents walkthrough | F2, F6, F10, F11, F13 |
| EOM-T56 hierarchy / nav | F11, F14, F15 |
| EOM-T57 first-run | F1, F4, F5, F6 |
| EOM-T58 empty / errors | F2, F3, F7, F9 |
| EOM-T59 type / contrast | F12 + "What works" |
| EOM-T60 tone | F4, F2; calm home canvas noted |
| EOM-T61 gestures / flow | F8, F9, F10, F13, F16 |
| EOM-T62 compile / prioritize | this document |

# UX Findings — EOM-E4

Walked: Home, Settings, History; all five intents (Clarify, Compress, Map, Reflect, Act).
Passes: first-run (empty vault, no keys/history) and returning (response present, history populated).
Live beta: EOM-S21 (first-run), EOM-S22 (five intents), EOM-S23 (returning-user).
Structural closes: EOM-S18–S20 (quick wins), EOM-S24 (F8 / F10 / F11 / F16), EOM-S27 (F1 / F5), EOM-S28 (F4), EOM-S29 (F12–F15).
Heuristics: `.agents/skills/ux-tester/references/heuristics.md`.
Date: 2026-08-06 (updated through S29).

## Orient

| | |
|---|---|
| **Purpose** | Private vault for the mind — five cognitive intents routed to swappable LLMs. |
| **Primary flows** | Capture thought → choose intent → read structured response (with prior turns on multi-turn); configure provider; browse History and reopen a row into Home. |
| **Tone** | Epistemic Calm — quiet, minimal, provisional, unintimidating. |

---

## Findings

Severity: **critical** (blocks flow) · **major** (forces recovery) · **minor** (nags).

| ID | Where | What | Heuristic | Severity |
|----|-------|------|-----------|----------|
| F1 | Home → first intent (no API key) | ~~First-run never prompts~~ → **Fixed S27:** soft-gate sheet on Connect CTA and intent-without-key. | Flow continuity | critical → done |
| F2 | Home → error response | ~~Technical Exception in success card~~ → **Fixed S18:** calm `IntentError` + Open Settings. | Error states | critical → done |
| F2 | Home → error response | ~~Technical Exception in success card~~ → **Fixed S18:** calm `IntentError` + Open Settings. | Error states | critical → done |
| F3 | Home → `_processIntent` catch | ~~Silent wipe~~ → **Fixed S18:** friendly `AiResponse` on outer catch. | Error states | critical → done |
| F4 | Settings (first-run) | ~~Title "AI Configuration"; all providers + LiteLLM/Gateway/Model Alias shown at once~~ → **Fixed S28:** title Settings; active-only key; Advanced collapsed; Epiture footer. | Tone · Cognitive load | major → done |
| F5 | Settings → Home | ~~No cue that a key is required~~ → **Fixed S27:** Connect CTA + sheet; muted confirm on success. | Flow continuity · Affordances | major → done |
| F6 | Home (first-run) | ~~Labels alone hide meaning~~ → **Fixed S20:** pill subtitle + tooltip from `description`. | Affordances · Cognitive load | major → done |
| F7 | History (empty) | ~~“No conversations yet.” only~~ → **Fixed S19:** invitational CTA. | Empty states | major → done |
| F8 | History (populated) | ~~Rows are not tappable~~ → **Fixed S24:** row reopens into Home. | Affordances · Flow continuity | major → done |
| F9 | History AppBar | ~~Clear-all deletes with no confirmation~~ → **Fixed S19:** confirm dialog. | Affordances · Error states | major → done |
| F10 | Home (returning, multi-turn) | ~~UI shows only the latest response~~ → **Fixed S24:** “Earlier in this session”. | Flow continuity · Cognitive load | major → done |
| F11 | Home → Map | ~~Tree + graph stack with no framing~~ → **Fixed S24:** Your map + collapsible Connections. | Visual hierarchy · Cognitive load | major → done |
| F12 | Theme / History empty & hints | ~~`textTertiary` `#64748B` on `#1A1C23` ~3:1~~ → **Fixed S25/S29:** token `#8B95A8` ≥4.5:1 on field and surface; hints use the token. | Visual hierarchy (readability) | major → done |
| F13 | Home (empty input) | ~~Silent no-op on blank intent tap~~ → **Fixed S29:** “Write a thought first.” (first-run still defers pills, S26). | Affordances | minor → done |
| F14 | History rows | ~~Raw enum `clarify`; 4-line cap with no expand~~ → **Fixed S29:** Clarify label; **Read more** / **Show less**. | Visual hierarchy · Affordances | minor → done |
| F15 | Home top bar | ~~Icon-only; no history presence~~ → **Fixed S29:** tooltips stay; quiet indigo pip when the library has rows. | Navigation · Affordances | minor → done |
| F16 | Home → New thought | ~~Refresh clears with no confirm~~ → **Fixed S24:** “Start a new thought?” | Affordances | minor → done |

### What works

- Home empty state is calm: brand + expansive "What's on your mind?" canvas; intents deferred until there is text; **Connect a guide** opens the soft-gate sheet when no key is set.
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

### Structural fixes — resolved (EOM-S24, 2026-08-06)

| Finding | Fix |
|---------|-----|
| **F8** | History row `InkWell` pops `Conversation`; Home restores input + response + seeded `_history` |
| **F10** | “Earlier in this session” lists prior turns above the latest `ResponseCard` |
| **F11** | “Your map” label on tree; “Connections” collapsible (collapsed by default) for the graph |
| **F16** | “Start a new thought?” confirm before clearing a non-empty session |

### Structural fixes — resolved (EOM-S28, 2026-08-12)

| Finding | Fix |
|---------|-----|
| **F4** | Settings title; Guide picker + active key only; gateway/alias under collapsed Advanced; `Kin to Epiture.` footer |

### Structural fixes — resolved (EOM-S29, 2026-08-12)

| Finding | Fix |
|---------|-----|
| **F12** | `textTertiary` AA on background/surface; contrast locked in `ux_eom_s29_polish_test` |
| **F13** | Blank-input intent tap → “Write a thought first.” |
| **F14** | History `CognitiveIntent.displayName`; Read more / Show less |
| **F15** | History icon pip when the library has rows; tooltips unchanged |

### Still open (next iteration)

None from E4. Spirit package (EOM-E6) complete.

Tests: `test/ux_eom_s29_polish_test.dart` (F12–F15); `test/ux_eom_s28_settings_test.dart` (F4); `test/ux_eom_s24_structural_test.dart` (F8/F10/F11/F16).

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

---

## Live beta — EOM-S22 (five intents)

Date: 2026-08-06. Provider: LiteLLM → `qwen-smart` @ `127.0.0.1:4000`.
Tests: `test/ux_eom_s22_live_provider_test.dart`, `test/ux_eom_s22_session_ux_test.dart`.

Prompt: *I keep switching projects and never finish anything; I am not sure if that is fear or boredom.*

| Task | Result |
|------|--------|
| T86 Clarify | OK · 62s · 544 chars · no clinical lexicon · calm prose |
| T87 Compress | OK · 89s · 725 chars / 3 lines · single ResponseCard, scannable |
| T88 Map | OK · 58s · tree present (2 children) · UI stacks ThoughtTreeView + EpistemicGraphView with **no framing** → **F11 confirmed** |
| T89 Reflect | OK · 50s · 415 chars · no clinical lexicon · provisional lexicon weak (`might/perhaps/…` absent in this sample) |
| T90 Act | OK · 53s · 676 chars · sage accent on IntentButton + ResponseCard readable |
| T91 | Friction notes below; no new finding IDs beyond F11 soft-confirm |

### Live session notes

- All five intents returned usable Epistemic Calm prose against a real model; chrome (one card, Act sage, Compress without tree) holds.
- **F11** was the main intent-UX gap (two competing structures). **Closed in EOM-S24** with “Your map” + collapsible Connections.
- Reflect tone was non-clinical but not strongly provisional in this run — watch in EOM-E5 alignment pressure, not a new Home chrome bug.
- Latency ~50–90s/intent on local gateway — acceptable for beta, not for “instant” feel.

---

## Live beta — EOM-S23 (returning user)

Date: 2026-08-06.
Tests: `test/ux_eom_s23_returning_user_test.dart`.

| Task | Result |
|------|--------|
| T92 Multi-turn | 3 follow-ups; model history grows `[0,2,4]`; **UI shows only latest ResponseCard** → **F10 confirmed** |
| T93 History | Entries list; row tap does nothing → **F8 confirmed** |
| T94 Clear | Confirm dialog present (Cancel safe / Clear empties) → **F9 mitigated by S19**; residual: still clears *all* |
| T95 New thought | Resets input/response with **no confirm** → **F16 confirmed** |
| T96 | No new stories beyond S18–S20 for chrome. Structural remain **F8 / F10 / F11 / F16** → closed by **EOM-S24** |

### Returning-user notes

- Session continuity (**F8/F10**) was the highest-value returning-user gap. **Closed in EOM-S24** (History reopen + prior-turn thread).
- New thought (**F16**) now confirms before clearing (S24).

---

## Spirit walk — EOM-S29 / EOM-E6 (2026-08-12)

Walked Home, Settings, History as first-run and returning (widget tests +
screen read; no GTK desktop in this environment). Heuristics from
`.agents/skills/ux-tester/references/heuristics.md`. Felt bar from
`docs/ui_spirit_enhancement_plan.md`.

| Pass | Felt bar |
|------|----------|
| First-run empty | Ceremonial vault: serif EOM, gold brand mark + Connect CTA only, leaf empty panel, intents deferred, soft gate not a wall. |
| Settings | Title Settings; Guide + one key; Advanced collapsed; Kin to Epiture. Not a config product. |
| Returning / mid-session | Prior turns and map labels in orientation serif; response leaf on success; gold still rare; History Clarify + Read more; History pip when rows exist. Blank intent tap hints, never silent. |

**Sign-off:** Empty state reads as Epiture quiet authority and a private vault — not a marketing site, chat dashboard, or clinical settings wall. Mid-session stays a quiet desk. EOM-E6 checklist complete.

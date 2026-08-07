# UI/UX Spirit Enhancement Plan

**Status:** Agreed (grilled 2026-08-07)  
**Cue source:** [Epiture Studios](https://www.epiturestudios.com/) — Family kinship, not a site mirror  
**Philosophy:** Epistemic Calm deepened so EOM *feels* like Epiture’s quiet authority *and* a private vault  

Closes the gap between `design_spec.md` / README spirit and a generic Material dark UI, while finishing open UX debt that fights the spirit (F1/F5, F4, F12–F15).

---

## Decisions (locked)

| Decision | Choice |
|----------|--------|
| Problem | Deepen spirit **and** close implementation gap |
| Kinship | **Family** — Epiture DNA; single dark vault (no black↔white flip) |
| Accent | **Dual** — gold = brand/orientation; sage = Act; indigo = calm selection |
| Type | **Serif on orientation** — titles, empty hero, section labels; sans for body/input/pills/responses |
| Shape | **Leaf at signature moments** — empty-state panel; optional response card |
| Space | **Vault room** — ceremonial empty; generous mid-session gaps |
| Field | **Deeper void** — near-black background; lifted surfaces |
| Scope | **Spirit package** — visual system + soft first-run + calm Settings + F12–F15 |
| First-run | **Soft gate** — quiet connect path; same sheet if intent tapped without key |
| Settings | **Active-only** fields + collapsed Advanced |
| Brand | **Quiet lineage** — EOM primary; Epiture only in About/Settings footer |
| Serif | **Bundled** restrained display face (offline) |
| Ship order | Tokens → empty presence → soft gate → Settings → polish |
| Done when | Spec/tests **plus** spirit walk (felt bar) |

---

## North star

Sitting at a clean desk in a quiet room — Epiture’s editorial restraint translated into a product surface:

- Gold is rare (orientation), never jewelry on every tap  
- Serif marks *where you are*; sans carries *what you think*  
- Void is intentional; chrome does not compete with the canvas  
- Motion stays functional (≤300ms `easeOut`)  

**Not:** marketing-page port · pure-black ink trap · gilded chat UI · hard config wall on arrival  

---

## Phase 0 — Spec & tokens

**Goal:** One source of truth so screens don’t thrash.

1. **Revise `docs/design_spec.md`**
   - Family kinship with Epiture (cue table + dual accent)  
   - Deeper void field; gold/sage/indigo roles  
   - Orientation serif rules; leaf signature moments  
   - Soft gate + active-only Settings component guidance  
   - Explicit: pure black site hero ≠ app field (near-black OK; surfaces lift)

2. **Extend `lib/theme/eom_colors.dart`**
   - Darken `background` toward near-black; keep `surface` / `surfaceBorder` readable  
   - Add `gold`, `goldMuted`, `goldSubtle` (muted bronze/gold, Epiture-adjacent)  
   - Keep `accent` (indigo) + `sage`; document usage in comments  
   - Raise `textTertiary` contrast enough for WCAG AA on small/hint text (F12)

3. **Extend `lib/theme/eom_theme.dart` + assets**
   - Bundle one display serif; wire into `headline*` / AppBar title / orientation labels  
   - Body/label/input remain system or bundled sans  
   - Spacing scale bump for “vault room” (padding tokens if useful)  
   - Optional `EomShapes.leaf` path / `BorderRadius` helper for signature clips  

4. **REPOMAP / changelog** — note new font assets + theme tokens  

**Exit:** Theme alone changes the app’s first impression without feature work.

---

## Phase 1 — Empty-state presence

**Goal:** Arrival feels ceremonial and Epiture-kin.

1. Home empty: serif EOM (or short title), expansive “What’s on your mind?”, deep void, generous margins  
2. Leaf (or leaf-ish) framing only on the empty canvas / primary empty panel — not on pills  
3. Quiet gold on brand/orientation accents only  
4. Intents still deferred until there is text (keep current calm behavior)  
5. Soft-gate CTA appears when no usable provider/key: plain-language “Connect a guide” (or equivalent), gold-accented, not screaming  

**Exit:** Spirit walk on first paint passes without any LLM call.

---

## Phase 2 — Soft gate (F1 / F5)

**Goal:** No silent fail; vault stays open.

1. Shared bottom sheet / quiet panel: provider pick + essential key fields only (reuse Phase 3 simple fields)  
2. Triggers: empty-state CTA; intent tap with no usable key  
3. On success: dismiss → ready to capture; optional one-line confirmation (muted)  
4. Persist via existing `SettingsService`  

**Exit:** First intent never fails for “no key” without orientation; UX tests cover gate paths.

---

## Phase 3 — Calm Settings (F4)

**Goal:** Configuration feels provisional, not a gateway product.

1. Active provider only for essential fields  
2. Advanced (LiteLLM / gateway / model alias) behind one collapsed disclosure  
3. Plain-language labels; drop “AI Configuration” tone for something quieter  
4. Soft-gate sheet and Settings share the same field widgets  
5. Footer: quiet Epiture lineage line  

**Exit:** Returning user can change key/provider without seeing advanced chrome; first-run sheet matches.

---

## Phase 4 — Polish (F12–F15) & continuity

1. **F12** — tertiary/hint contrast (from Phase 0 tokens) applied everywhere  
2. **F13** — blank-input intent tap → calm hint (no silent no-op)  
3. **F14** — History intent casing + expand/read affordance as needed  
4. **F15** — History/Settings affordances (tooltips stay; optional history presence cue)  
5. Mid-session spacing: earlier turns / response card / map framing breathe  
6. Optional leaf on response card if it still reads vault-quiet in spirit walk  
7. Map “Your map” / “Connections” use orientation type tokens  

**Exit:** Open E4 polish items closed; multi-turn still calm.

---

## Out of scope (this plan)

- Light mode / Epiture white content sections  
- Site-style curved section dividers as app chrome  
- Serif on AI body responses  
- Leaf as global card system  
- Hard blocking gate; demo/offline LLM path (deferred product decision)  
- Dual-brand AppBar / marketing hero imagery  

---

## Implementation map (likely touchpoints)

| Area | Files (indicative) |
|------|--------------------|
| Spec | `docs/design_spec.md`, this plan, `docs/REPOMAP.md` |
| Tokens | `lib/theme/eom_colors.dart`, `lib/theme/eom_theme.dart`, `pubspec.yaml` assets |
| Home / empty / gate | `lib/screens/home_screen.dart`, new small widget(s) under `lib/widgets/` |
| Settings | `lib/screens/settings_screen.dart`, shared field widgets |
| History polish | `lib/screens/history_screen.dart` |
| Response / map labels | `lib/widgets/response_card.dart`, tree/graph framing |
| Tests | extend `test/ux_eom_s21_*`, settings/home tests; new soft-gate cases |

Follow AGENTS: service-first, relative imports, `EomColors` only, `dart format`, tracker updates when stories/subtasks are cut.

---

## Tracker

| Key | Item |
|-----|------|
| **EOM-E6** | UI/UX Spirit Enhancement |
| **EOM-S25** | Theme tokens + design_spec Family kinship (T102–T106) |
| **EOM-S26** | Empty-state ceremonial presence (T107–T111) |
| **EOM-S27** | Soft first-run provider gate F1/F5 (T112–T116) |
| **EOM-S28** | Calm Settings active-only redesign F4 (T117–T121) |
| **EOM-S29** | Spirit polish F12–F15 + sign-off walk (T122–T127) |

---

## Definition of done

**Checklist**

- [ ] `design_spec.md` reflects Family kinship + dual accent + soft gate + Settings  
- [ ] Gold / deeper void / orientation serif / leaf helper in theme  
- [ ] Soft gate prevents key-less silent failure  
- [ ] Settings active-only + Advanced collapsed  
- [ ] F12–F15 addressed  
- [ ] `flutter analyze` clean; relevant `flutter test` green  

**Felt bar (spirit walk)**

Empty state feels like Epiture’s quiet authority **and** a private vault — not a marketing site, not a chat dashboard, not a clinical settings wall. Mid-session remains a quiet desk: gold rare, serif only for orientation, void respected.

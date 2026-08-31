# EOM - AI Agent Design Specification (`design_spec.md`)

## 1. Core Design Philosophy

**Theme:** "Epistemic Calm." The UI must not feel like a clinical medical app, a
chaotic productivity tool, or an addictive social feed. It must feel like a
quiet, private vault for the mind — with quiet kinship to Epiture Studios'
editorial restraint (**Family**, not a site mirror).

**Keywords:** Minimal, structured, frictionless, provisional, grounding.

**North star:** Sitting at a clean desk in a quiet room. Gold is rare. Serif
marks *where you are*; sans carries *what you think*. Void is intentional;
chrome does not compete with the canvas.

---

## 2. Visual Identity & Styling (Flutter / Material 3 / Cupertino)

### Family kinship (Epiture cue → product)

| Cue | Product translation |
|-----|---------------------|
| Editorial quiet authority | Orientation serif + deep void field |
| Warm metal accent | Muted gold — brand/orientation only, never jewelry on every tap |
| Organic leaf moments | Leaf clip/radius at signature empty/response moments only |
| Dark room, not ink trap | Near-black background; surfaces lift for readable cards |
| Not the website | No marketing hero imagery, no black↔white flip, no dual-brand AppBar |

### Color palette (dark vault — single mode)

Tokens live in `lib/theme/eom_colors.dart`. Roles:

| Role | Token | Use |
|------|-------|-----|
| Field | `background` | Near-black void (`#0E0F12`). Pure black site heroes ≠ app field. |
| Surface | `surface` / `surfaceBorder` | Lifted slate cards; 0.5px borders, zero elevation |
| Selection | `accent` (indigo) | Calm selection / focus — sparingly |
| Act | `sage` | "Act" intent and high-confidence graph cues |
| Orientation | `gold` / `goldMuted` / `goldSubtle` | Brand mark, soft-gate CTA accent, rare orientation |
| Text | `textPrimary` / `textSecondary` / `textTertiary` | Tertiary must meet WCAG AA (~4.5:1) on background for hints |

### Typography

* **Orientation (serif):** Bundled **Cormorant Garamond** — AppBar title,
  `headline*`, empty-state brand/title, section orientation labels
  ("Your map", "Earlier in this session", etc.).
* **Working type (sans):** System-native sans (SF Pro / Roboto) for body,
  input, intent pills, AI response markdown.
* **Weight:** Regular for body; Medium for structure. Avoid heavy bolding.
* **Never:** Serif on AI body responses or dense UI chrome.

### Shape & elevation

* Soft corners (8px–12px) for ordinary surfaces.
* **Leaf** (`EomShapes.leafRadius`) only at signature moments (empty canvas
  panel; optional response card) — not a global card system. Cubic leaf
  clips stay off the input field.
* Zero drop shadows; depth via 0.5px `surfaceBorder` strokes.

### Density ("vault room")

* Ceremonial empty state: generous margins.
* Mid-session: earlier turns / response / map framing breathe (see spirit plan).

---

## 3. Component Guidelines

* **Input Area:** borderless, expansive, auto-resizing `TextField`. Blank
  canvas, not a form.
* **Empty canvas (ceremonial):** Vault-room margins; leaf-radius panel around
  the blank input only (not pills). Serif EOM + gold brand mark. Quiet
  **Connect a guide** when the active provider has no usable key (opens
  the soft-gate sheet). Android/iOS first launch uses **On this device**
  (no key, no Connect). Intents stay deferred until there is text.
* **Intent Buttons (Clarify, Compress, Map, Reflect, Act):** Pill-shaped,
  muted background; idle pills show a short description subtitle (EOM-S20).
  Intents stay deferred until there is text (calm first paint). A blank-field
  tap after a response shows a calm hint ("Write a thought first.") — never
  a silent no-op (F13).
* **Soft gate (first-run / no key):** Quiet connect path when the active
  Guide needs a credential — bottom sheet or panel with provider pick +
  essential key fields only. Same sheet if an intent is tapped without a
  usable key. Packaged Android/iOS skip this on first launch (On this
  device). Never a hard blocking wall; never silent fail. Plain-language
  CTA (e.g. "Connect a guide"), gold-accented sparingly.
* **Settings:** Active-provider fields only by default; Advanced (LiteLLM /
  gateway / model alias) behind one collapsed disclosure. Soft-gate and
  Settings share field widgets. Quiet Epiture lineage line in footer/About
  only — EOM remains primary brand.
* **The "Map" (Tree Visualization):**
  * Lightweight custom painter or hierarchical list; clean directory tree.
  * Connecting lines 1px, muted grey.
  * On Home, framed with orientation serif label **Your map** (EOM-S24 / F11 / S29).
* **The Epistemic Graph Overlay (EOM-T18):**
  * Static radial layout under the tree; confidence colours from palette
    tokens; 0.5px `surfaceBorder` edges; 300ms `easeOut` fade-in.
  * On Home, under **Connections** (orientation serif), collapsed by default
    (EOM-S24 / F11 / S29).
* **Response card:** Success uses leaf radius (signature, quiet); errors keep
  the ordinary 12px corner.
* **Session continuity (EOM-S24 / S29):**
  * Multi-turn Home shows muted **Earlier in this session** (orientation
    serif) above the latest response card.
  * History rows reopen into Home; intent shown as Clarify not `clarify`;
    long responses offer **Read more** (F14).
  * Home History icon keeps its tooltip and shows a quiet pip when the
    library has rows (F15).
  * **New thought** confirms before clearing a non-empty on-screen session.

---

## 4. Animation & Motion

* **Rule:** Motion must be functional, not decorative. Use the Material 3
  **standard/utility** lane — not Expressive springs, bounce, or 400ms+
  emphasized durations.
* **Tokens:** [`lib/theme/eom_motion.dart`](../lib/theme/eom_motion.dart) —
  `short` 200ms, `medium` 300ms (enter / layout / page push), `exit` 200ms,
  `Curves.easeOut` (M3 emphasized analogue). Hard cap is **300ms**, except
  iOS Cupertino interactive pop (`kTransitionDuration` is 500ms).
* **Page routes:** Fade + tiny upward slide (`EomMotion.slide`) on
  Android/desktop. iOS keeps `CupertinoPageTransitionsBuilder` so interactive
  pop stays — that 500ms is the documented cap exception. Do not use
  `FadeForwardsPageTransitionsBuilder` (typically 400ms).
* **Appear:** [`EomAppear`](../lib/widgets/eom_appear.dart) fades **in**;
  hide is a snap-unmount (child gone, height 0) so `find.byType` stays
  honest. Layout is immediate so the first frame is hittable. Never
  `AnimatedCrossFade` (both children stay in the tree).
* **Scroll:** `EomScrollBehavior` uses `ClampingScrollPhysics` — no iOS bounce.
* **Reduce motion:** `MediaQuery.disableAnimations` zeros durations that
  go through `EomMotion.of` / `sheetStyleOf`. `PageTransitionsBuilder`
  duration getters have no `BuildContext`, so the fade builder skips
  painting but the route may still occupy 300ms.
* **Sheets / dialogs:** elevation 0; soft-gate uses `EomMotion.sheetStyleOf`.
* **Never:** springs, bounce, drop shadows, seed-generated color.

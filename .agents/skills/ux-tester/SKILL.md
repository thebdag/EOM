---
name: ux-tester
description: Hunts friction in an app or screen by walking through it as a user would, and emits prioritized findings. Use when the user wants a UX walkthrough or usability review of an interface — especially to test whether it feels enjoyable and unintimidating. Don't use for accessibility audits, visual design polish, or bug fixing.
---

# UX Tester

Walks an app as a user would, hunts friction, emits findings a developer can
act on. The heuristics live in `references/heuristics.md`.

A **friction** point is anything that trips a heuristic in
`references/heuristics.md`. A **finding** is one friction point captured as
four fields: _where_ (screen/flow), _what_ (the trip), _heuristic_ (which
one), _severity_ (critical / major / minor).

---

## Step 1: Orient

Read the design spec (`docs/design_spec.md`) and repomap
(`docs/REPOMAP.md`). State, in one sentence each: the app's purpose, its
primary user flows, its intended tone.

**Done when** you can name the app's purpose, every primary flow, and the
intended tone — one sentence each, no hedging.

## Step 2: Walk

Walk every screen and every primary flow twice: once as a first-run user
(empty state, no data, no prior context), once as a returning user
(populated). At each step, ask: does this trip a heuristic in
`references/heuristics.md`? Note every friction point inline with its
screen/flow and the tripped heuristic.

**Done when** every screen and every primary flow has been walked in both
passes, and every friction point found is recorded inline with its
screen/flow and the tripped heuristic.

## Step 3: Find

Promote every inline friction note from Step 2 into a finding with all four
fields: where, what, heuristic, severity. Severity: _critical_ (blocks the
flow), _major_ (forces recovery effort), _minor_ (nags but doesn't stop).

**Done when** every friction point from Step 2 is a finding with all four
fields; none remain as prose impressions.

## Step 4: Prioritize

Rank findings by severity × frequency × fix-cost. Group into quick wins
(low cost, any severity) and structural (high cost, major-or-above). Name
the top three quick wins and top three structural fixes explicitly.

**Done when** every finding is ranked and grouped, and the top three quick
wins and top three structural fixes are named.

---

## Decision tree

```
Want a UX review?
│
├── Whole app?
│   └── Step 1 → Step 2 (both passes, every screen) → Step 3 → Step 4
│
├── One screen or flow?
│   └── Step 1 → Step 2 (scope to that screen/flow, both passes) → Step 3 → Step 4
│
└── Only first-run feel?
    └── Step 1 → Step 2 (first-run pass only) → Step 3 → Step 4
```

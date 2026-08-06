# Delta updates refine, never overwrite (EOM-T12)

New thought sessions must *refine* the epistemic graph, not overwrite it.
The current `upsert` (exact case-insensitive content match, incoming fields
replace stored ones) loses provenance and confidence history and duplicates
nodes whenever the wording drifts. That blocks confidence-drift tracking
(EOM-T15) and contradicts the `refines` relationship type (EOM-T4).

## Decision

**Canonical node + observation log.** `epistemic_nodes` holds the current
best statement of a belief. Every session-derived assertion appends a row
to a new `node_observations` table
(`node_id, content, confidence, source_type, intent, created_at`).
Node fields become derived views over observations: `confidence` = latest
observation, `updated_at` = last observation time, `content` = sharpest
wording so far.

**Three match tiers**, applied in order when a session produces a node:

1. *Exact* (normalized content match) — append an observation to the
   existing node. No content change.
2. *Refine* (keyword overlap above threshold, wording differs) — append an
   observation, update `content` to the sharper wording, and record a
   `refines` edge so the sharpening is traceable.
3. *Novel* — create a new node with its first observation, as today.

**Confidence moves by nudge, not replacement**: the stored value blends
old and new (recency-weighted, clamped to [0, 1]) so one outlier session
cannot swing a belief. Full history stays in `node_observations` regardless.

## Consequences

- EOM-T15 (confidence drift) reads straight from `node_observations` — no
  additional schema.
- EOM-T14 (gap detection) can treat `question`/`unknown` nodes with no
  later observations as open gaps.
- Semantic/embedding similarity for tier 2 is deferred — the existing
  keyword-overlap signal is the interim matcher; the tier boundary is the
  seam to swap it in later.

# Epistemic Alignment Scoring Rubric (EOM-T63)

The rubric the beta pressure-test analyzer (`dev/beta/lib/analyzer.dart`) uses
to score captured LLM responses against EOM's epistemic contract. Every
cognitive intent (Clarify, Compress, Map, Reflect, Act) is scored on the same
eight criteria; intent-specific expectations live in the prompt metadata
(`dev/beta/prompts/*.json`, `expected` block) and feed criteria 7 and 8.

The goal is **epistemic alignment**: does the model do what the EOM prompt
asks, in the shape EOM expects, without fabricating or overstating?

---

## 1. Criteria

| # | Criterion | What "pass" looks like |
|---|-----------|------------------------|
| C1 | **Format compliance** | Response contains prose, then the `---EPISTEMIC---` marker, then a JSON block (no markdown fences around the JSON). |
| C2 | **Schema conformance** | The JSON after the marker decodes to a `Map` and `intent.parseOperation(json)` returns an operation without throwing on core content. For Map, `ThoughtNode.fromJson` also succeeds. |
| C3 | **Field completeness** | The operation's required field is non-empty (`clarified` / `principle` / `actionable` for those intents; at least one relationship or an explicit empty list for Map; `contradictions`/`low_confidence` lists present for Reflect). |
| C4 | **Confidence calibration** | `confidence` (where present) is a number in [0,1] and falls inside the prompt's `expected.confidenceRange`. A clear input should not get 0.1; a contradictory one should not get 0.95. |
| C5 | **Category validity** | When `category` is present it is one of `empirical`, `rational`, `intuitive`, `abductive`, `revelatory`. Absent category is acceptable (nullable by design); an invalid string is not. |
| C6 | **Keyword relevance** | `keywords` are non-empty and at least one token from `expected.keywordsContain` appears (case-insensitive) in the keyword list. Pure hallucinated keywords unrelated to the input fail. |
| C7 | **Intent fidelity** | The response actually performs the intent: Clarify ends with a clarifying question; Compress gives a `**Core:**`/`**In one line:**` structure; Map yields relationships (or a stated empty list); Reflect surfaces tension (even if empty, with acknowledgment); Act gives exactly three timed steps. |
| C8 | **Epistemic honesty** | No fabricated facts presented as certain; uncertainty is acknowledged where the input is ambiguous/contradictory; the model does not overclaim confidence on adversarial or multi-intent inputs. |

### Hard-fail criteria

C1, C2, C7, and C8 are **hard-fail** criteria: a score of 0 on any one of them
forces the overall verdict to `fail` regardless of the weighted total. A
response that omits the marker, fails to parse, does not perform the intent,
or fabricates/hallucinates is misaligned by definition.

C3, C4, C5, C6 are **soft** criteria: they contribute to the weighted total
and can flag `warn` or `minor` findings but cannot, alone, force a `fail`.

---

## 2. Scale

Each criterion is scored on a 0–2 integer scale:

| Score | Meaning |
|-------|---------|
| 2 | Pass — fully meets the criterion. |
| 1 | Partial — present but deficient (e.g. marker present but JSON fenced; confidence in range but at the wrong end for the input; keywords present but none match). |
| 0 | Fail — absent or broken (no marker; JSON does not parse; required field empty; confidence out of [0,1]; invalid category; no relevant keyword; intent not performed; fabrication present). |

---

## 3. Weights

Weights sum to 1.0 and reflect how much each criterion drives epistemic
alignment (honesty and intent fidelity matter most; format is necessary but
mechanical).

| Criterion | Weight |
|-----------|--------|
| C1 Format compliance | 0.10 |
| C2 Schema conformance | 0.15 |
| C3 Field completeness | 0.10 |
| C4 Confidence calibration | 0.15 |
| C5 Category validity | 0.05 |
| C6 Keyword relevance | 0.10 |
| C7 Intent fidelity | 0.15 |
| C8 Epistemic honesty | 0.20 |

**Weighted total** = Σ(score_c / 2 × weight_c), normalised to [0,1].

---

## 4. Pass / fail thresholds

| Verdict | Condition |
|---------|-----------|
| **pass** | No hard-fail criterion below 2 **and** no soft criterion at 0 **and** weighted total ≥ 0.80. |
| **warn** | No hard-fail criterion at 0 **and** (any hard-fail criterion at 1 **or** any soft criterion at 0 **or** 0.60 ≤ weighted total < 0.80). |
| **fail** | Any hard-fail criterion (C1/C2/C7/C8) at 0, **or** weighted total < 0.60. |

> A partial on a hard-fail criterion (score 1 — e.g. Act with only 2 of 3
> steps, or a Map whose operation parsed but whose tree did not) is not a
> clean pass: it forces at least `warn` even when the weighted total is high.

---

## 5. Finding severity (EOM-T70)

Each criterion scored below 2 emits a finding. Severity maps from criterion
class and score:

| Severity | When |
|----------|------|
| **critical** | A hard-fail criterion (C1/C2/C7/C8) at 0, **or** C8 at 0/1 with fabricated content. |
| **major** | A soft criterion at 0, **or** a hard-fail criterion at 1 (partial). |
| **minor** | Any criterion at 1 that is not already critical/major. |

A response can carry multiple findings; the worst severity governs its
verdict for roll-up but every finding is reported with its transcript excerpt.

---

## 6. Intent-specific notes

- **Clarify** — C7 requires a trailing question. C3 requires `clarified`.
  C4 expects raised confidence (the prompt says "raised, since the belief is
  now sharper"), so `confidenceRange` defaults high.
- **Compress** — C7 requires `**Core:**` and `**In one line:**` markers in the
  prose. C3 requires `principle`.
- **Map** — C2 additionally requires `ThoughtNode.fromJson` to succeed. C3
  treats an explicit empty `relationships` list as complete (the prompt
  permits it); a missing `relationships` key is incomplete.
- **Reflect** — C7 acknowledges tension even when none surfaces (empty lists
  are valid *if acknowledged*). C3 requires both `contradictions` and
  `low_confidence` keys present (lists may be empty).
- **Act** — C7 requires exactly three steps with the timed labels
  ("Right now (10 mins)", "Today", "This week"). C3 requires `actionable`.

---

## 7. Roll-up

A run (one provider × model × prompt set) rolls up to:

- `passRate` = pass / total
- `warnRate` = warn / total
- `failRate` = fail / total
- `meanScore` = mean weighted total
- `findingsBySeverity` = {critical, major, minor} counts
- `findingsByCriterion` = per-criterion fail/partial counts

A run is **epistemically aligned** when `failRate == 0` and `warnRate <= 0.20`.

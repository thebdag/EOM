# EOM

Private vault for the mind: cognitive intents routed to swappable LLM providers.

## Language

**LiteLLM Gateway**:
The OpenAI-compatible proxy EOM’s Local provider uses — master-key auth and model aliases as in the scratchpad serving stack.
_Avoid_: Ollama host, generic local LLM, open proxy

**Local Provider**:
EOM’s provider slot that means only the LiteLLM Gateway. Settings UI label is **LiteLLM**; persisted provider id remains `LOCAL`.
_Avoid_: Ollama, LM Studio (as the product name for this slot)

**Master Key**:
The Bearer token LiteLLM expects (`LITELLM_MASTER_KEY`); not a vendor cloud API key. Required before any Local/LiteLLM call. Entered only via Settings (never read from `.env` on disk).
_Avoid_: API key (unqualified), OpenAI key, Anthropic key

**Gateway Origin**:
The LiteLLM listen URL without the OpenAI path suffix (e.g. `http://127.0.0.1:4000`). Clients append `/v1/...`.
_Avoid_: LITELLM_BASE (that includes `/v1`), base URL (ambiguous)

**Model Alias**:
A LiteLLM `model_name` from the gateway config (e.g. `qwen-smart`, `auto`, `claude-haiku`), not a raw vendor model id like `ollama/llama3.1`.
_Avoid_: Ollama model tag, vendor model id (when speaking of Local/LiteLLM)

**Epistemic Graph**:
The user's personal knowledge base in SQLite (`epistemic_nodes` + `epistemic_edges`), built silently from every thought session. Nodes are typed (`belief`, `knowledge`, `hypothesis`, `intuition`, `question`, `unknown`), carry a `confidence` in [0, 1], and a nullable `EpistemicCategory`.
_Avoid_: knowledge base (generic), belief network

**Gap**:
Something the user does not yet have a node for (EOM-T14). *Explicit gap* = an articulated `question`/`unknown` node. *Unmapped concept* = a concept surfaced by a session (keywords, low-confidence statements) with no covering node. Gaps are surfaced read-only; detection never creates nodes.
_Avoid_: missing node, hole

**Confidence Drift**:
How a node's confidence moves across sessions (EOM-T15), tracked in the `confidence_events` log — one baseline event at creation plus an event per confidence-changing update. `ConfidenceDrift` = movement from baseline to latest, signed.
_Avoid_: confidence history (that is the raw event list), score change

**Domain**:
The axis maturity is scored per (EOM-T16): the `EpistemicCategory` of a node (`empirical`, `rational`, `intuitive`, `abductive`, `revelatory`); uncategorised nodes group under the `null` domain. Not a free-form topic field — v1 deliberately reuses category.
_Avoid_: topic, subject area

**Maturity Score**:
Per-domain ratio `high-confidence / (high-confidence + uncertain)` nodes (thresholds 0.7 / 0.4), normalised to [0, 1]. Neutral-band nodes count toward totals only; `null` score means insufficient signal, not 0%.
_Avoid_: expertise score, certainty average

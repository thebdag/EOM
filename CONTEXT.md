# EOM

Private vault for the mind: cognitive intents routed to swappable LLM providers.

## Language

**LiteLLM Gateway**:
The OpenAI-compatible proxy EOM’s Local provider uses — master-key auth and model aliases as in the scratchpad serving stack.
_Avoid_: Ollama host, generic local LLM, open proxy

**Local Provider**:
EOM’s provider slot that means only the LiteLLM Gateway. Settings UI label is **LiteLLM**; persisted provider id remains `LOCAL`.
_Avoid_: Ollama, LM Studio (as the product name for this slot)

**On-device Guide**:
EOM’s provider slot that means the OS-managed on-device model when packaged for Android (ML Kit GenAI Prompt API / AICore / Gemini Nano) or iOS (Foundation Models). Settings UI label is **On this device**; persisted provider id is `ON_DEVICE`. No API key. Not LiteLLM and not a bundled LiteRT-LM model.
_Avoid_: local (that is LiteLLM), Gemini Nano / Apple Intelligence (as the picker label), Ollama on phone

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

**DB Column Map**:
The *only* serialisation allowed into sqflite writes: `EpistemicNode.toDbMap()` carries exactly the `epistemic_nodes` columns — nothing more. `toJson()` is the **export serialisation** (adds derived keys like `relationships`) and throws `DatabaseException` if passed to insert/update (EOM-S2).
_Avoid_: toJson for DB writes, "the map" (ambiguous)

**Error Response**:
An `AiResponse` with `isError = true` — provider/parse failure text shown to the user but never appended to conversation history, saved to Hive, or persisted to the graph (EOM-S5). Calm copy may offer **Open Settings** when the failure is missing/invalid credentials (EOM-S18).
_Avoid_: error message (that is just prose), failed intent

**Session (on-screen)**:
The in-progress Home canvas: current input, latest response, optional prior turns, and in-memory chat history sent to the model. Distinct from the Hive **History** library of saved conversations. **New thought** clears the on-screen session after confirm; it does not delete History (EOM-S24).
_Avoid_: conversation (ambiguous with History rows), thread (prefer "earlier in this session")

**History (library)**:
Persisted list of saved thought sessions (`Conversation` rows via `HistoryService`). Rows reopen into Home; empty state invites capture; clear-all requires confirmation (EOM-S19, S24).
_Avoid_: chat log, archive (generic)

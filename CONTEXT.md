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

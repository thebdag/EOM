# On-device context is a budgeted suffix, not a chat dump

OS on-device Guides (Gemini Nano / Foundation Models) have a small window.
The epistemic graph and Hive history are durable memory; they must not be
pasted wholesale into the next generate call.

## Decision

Split the on-device prompt the way ML Kit’s Prompt API is designed
(`genai-prompt:1.0.0-beta2`, javap-confirmed):

1. **Static prefix** — compact system prompt (~150 words, including a line
   that a `Known:` block is prior vault memory) as `PromptPrefix`. This
   stays cacheable across turns.
2. **Dynamic suffix** — last two conversation turns (bodies clipped), a
   small SQLite neighborhood (`search` + BFS depth 2, packed to ~80 words),
   and the current thought (capped at 200 words).
3. **Android token fit** — `countTokens` + `getTokenLimit` shrink the
   suffix until `input + maxOutputTokens` fits. Documented input ceiling is
   4000 tokens (~3000 English words). `maxOutputTokens` is 768 so the
   default 4096 output budget cannot starve the prompt. `warmup()` runs
   after download / when already available.
4. **iOS** — same word ceiling on prefix + suffix; Foundation Models has no
   `countTokens` analogue here.
5. **Cloud / LiteLLM** — unchanged: full session history, no vault inject,
   no user cap.

Retrieval failures are non-blocking (empty suffix, intent still runs).

## Consequences

- Long-term vault memory reaches Nano without filling its window.
- A long journal paste cannot blow the Prompt API 4000-token input cap
  from Dart; Android still re-fits with live token counts.
- Screens still talk to `EpistemicGraphStore` / `AiService`, not provider
  internals. `VaultContextService` owns retrieval.

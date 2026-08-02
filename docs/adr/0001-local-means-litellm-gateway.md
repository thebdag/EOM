# Local provider means LiteLLM Gateway

EOM’s `LOCAL` provider is exclusively the scratchpad-shaped LiteLLM Gateway
(master key required, model aliases, gateway origin without `/v1`). Direct
OpenAI / Anthropic / Gemini providers remain available beside it so the app
stays swappable without forcing all traffic through the GPU box.

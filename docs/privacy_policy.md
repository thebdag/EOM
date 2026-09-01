# Privacy Policy — EOM

**Last updated:** 2026-09-01

EOM (“the app”) is a private thinking tool. This policy describes what stays
on your device and what leaves it when you choose an AI Guide.

## What stays on your device

- Thoughts you type, session history, and the epistemic graph (beliefs,
  connections, confidence) are stored **only on your device** (Hive and
  SQLite).
- API keys and LiteLLM master keys you enter are stored in on-device
  preferences (`shared_preferences`). They are not written into the app
  binary or shipped in updates.

## What may leave your device

When you run a cognitive intent (Clarify, Compress, Map, Reflect, Act):

- **On this device** — your prompt is processed by the phone’s OS-managed
  model (Android AICore / Gemini Nano, or Apple Foundation Models). No
  EOM cloud backend is involved.
- **Cloud Guides** (OpenAI, Anthropic, Google Gemini) — the prompt and
  recent session turns you send are transmitted to that provider over
  HTTPS using the API key you supplied.
- **LiteLLM** — prompts go to the gateway origin you configured (often a
  machine on your LAN). Cleartext `http://` is allowed only so a local
  gateway can work; prefer a trusted network.

EOM does not operate its own cloud sync, analytics, advertising, or
account system.

## Children

EOM is not directed at children under 13. Do not use the app to submit
personal information about children to a third-party AI provider.

## Your choices

- Prefer **On this device** to keep inference on the phone when available.
- Clear History in the app to delete saved sessions.
- Uninstalling the app removes local data held in the app sandbox.
- Revoke or rotate API keys with your AI provider at any time.

## Contact

Questions about this policy: open an issue on the EOM GitHub repository
or contact the publisher listed on the Google Play store listing.

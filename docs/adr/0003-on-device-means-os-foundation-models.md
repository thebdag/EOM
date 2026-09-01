# On-device Guide means OS foundation models

EOM’s `ON_DEVICE` provider is the phone’s OS-managed language model when the
app is packaged for Android or iOS. It is **not** the LiteLLM gateway
(`LOCAL`, see [0001](0001-local-means-litellm-gateway.md)).

## Decision

Add a fifth Guide, UI label **On this device**, persisted id `ON_DEVICE`:

- **Android:** ML Kit GenAI Prompt API on AICore (Gemini Nano). The APK does
  not bundle a model. `uses-library com.google.android.aicore` is
  `android:required="false"` so install still succeeds without AICore.
  Against `genai-prompt:1.0.0-beta2`, system text is `PromptPrefix` (the
  AAR has no `SystemInstruction`).
- **iOS:** Foundation Models (`LanguageModelSession`), runtime-gated with
  `#available(iOS 26.0, *)`. Deployment target stays 13.0.
- **Elsewhere:** the picker omits this Guide. A saved `ON_DEVICE`
  preference is not rewritten; generate fails with calm Settings recovery.
- **Default:** an unset `active_provider` preference is `ON_DEVICE` on
  Android/iOS (no key, skip the Connect gate) and Gemini on desktop.

LiteRT-LM, bundled Gemma, and Windows on-device are out of scope.

## Consequences

- No API key. `hasUsableGuide` is true for the on-device default on
  Android/iOS; availability is checked at generate (and shown in Settings).
  Cloud/LiteLLM remain optional in Settings.
- Compact system prompts (~150 words) because Gemini Nano’s instruction
  budget is small. Missing `---EPISTEMIC---` epilogues still degrade to
  prose, same as cloud Guides.
- On-device context is budgeted separately from durable storage — see
  [0004](0004-on-device-context-budget.md).
- `minSdk` is 26 for the Prompt API. iOS min stays 13.

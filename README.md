# EOM — A Quiet Vault for the Mind

EOM is a personal thinking tool. It gives you a private space to write down
whatever is on your mind, then uses AI to help you *think about it better* —
not faster, not louder, just more clearly.

There are no feeds, no notifications, no social features.
Just you and your thoughts, with five ways to work with them.

---

## What EOM Helps You Do

Most AI tools are built for productivity. EOM is built for **understanding**.

It is designed around five *cognitive intents* — five fundamental things you
might want to do with a thought:

| Intent | What it does |
|---|---|
| **Clarify** | Untangle what you actually mean. Useful when you can feel an idea but can't quite put it into words. |
| **Compress** | Distill something down to its essence. Strip away the noise and find the core. |
| **Map** | See the hidden structure. EOM turns your thought into a visual tree — like a personal concept map — so you can see how the pieces relate. |
| **Reflect** | Look at it from a different angle. Get the perspective you can't give yourself. |
| **Act** | Turn understanding into action. When you're done thinking and ready to move, this intent helps you decide what to do next. |

You type what you're thinking. You choose an intent. EOM responds — calmly,
clearly, without hype or judgment.

---

## The Design Philosophy: Epistemic Calm

EOM's entire look and feel is built around a principle called **Epistemic Calm**.

- **Epistemic** = relating to knowledge, understanding, and how we come to
  know things.
- **Calm** = the interface stays quiet and grounded. No flashy animations,
  no bright colors screaming for attention, no urgency.

The goal is to create a space that feels like sitting at a clean desk in a
quiet room — everything you need, nothing you don't. Dark, slate-toned
colors. Soft edges. Subtle motion. A blank canvas for your thoughts, not a
dashboard full of distractions.

---

## Privacy First

Your thoughts are yours. EOM stores everything on your own device. There are
no accounts, no cloud sync, and no analytics. API keys for AI providers are
saved locally in your app's secure storage — they are never written to files
on disk or sent anywhere except the AI service you choose.

---

## AI Providers — Your Choice

EOM doesn't lock you into a single AI service. You can connect it to any of
the following providers and switch between them at any time from the
Settings screen:

- **OpenAI** (GPT-4o)
- **Anthropic** (Claude)
- **Google Gemini**
- **LiteLLM** — a local gateway that lets you run open-source models on
  your own hardware, keeping everything entirely offline if you prefer.
- **On this device** — Android and iOS builds can use the OS on-device
  model (Gemini Nano via AICore on supported Android phones; Apple
  Foundation Models on iOS 26+ with Apple Intelligence). No API key.
  Unavailable devices keep using a cloud or LiteLLM Guide.

---

## Getting Started

### What You Need

- [Flutter](https://docs.flutter.dev/get-started/install) installed on your
  computer.
- An API key from at least one AI provider (OpenAI, Anthropic, or Google),
  **or** a running [LiteLLM](https://docs.litellm.ai/) gateway for local
  models, **or** (Android/iOS) a device with an OS on-device model.

### Run the App

```bash
# Clone the repository
git clone https://github.com/thebdag/EOM.git
cd EOM

# Install dependencies
flutter pub get

# Launch
flutter run
```

On first launch, open **Settings** (the gear icon in the top-right corner)
to select your AI provider and enter your credentials.

---

## Session History

Every conversation is automatically saved to a local library. From **History**
(the clock icon) you can:

- Browse past sessions and **tap a row to reopen it on Home** — input,
  response, and session context come back so you can continue.
- Clear the library with a confirmation first (Cancel keeps everything).
- Start from an empty library with a calm invitation to capture a thought.

On Home, follow-up intents keep **earlier turns in this session** visible
above the latest reply. **New thought** asks before clearing the on-screen
session (saved History is kept).

When a provider or API key is missing, Home shows calm recovery copy with an
**Open Settings** action instead of a raw exception string.

---

## The Epistemic Map

Beneath the surface, every session quietly builds a personal knowledge
graph — your beliefs, questions, and acknowledged unknowns, with typed
relationships between them. It lives entirely on your device.

- **Map sessions** show a labeled **Your map** tree; the confidence-colored
  graph sits under a collapsible **Connections** section (collapsed by
  default so the tree stays primary).
- **Gap detection** surfaces what you don't yet have a node for — open
  questions and concepts your sessions reference but never captured.
- **Confidence drift** tracks how your beliefs shift across sessions.
- **Maturity scores** summarize each domain (empirical, rational,
  intuitive, deductive, revelatory) as the balance of high-confidence to
  uncertain nodes.
- **Export**: the whole map can be exported as structured JSON (full
  fidelity, re-importable) or as a readable Markdown document.

---

## License

This project is private and not currently published under an open-source
license.

# EOM - AI Agent Design Specification (`design_spec.md`)

## 1. Core Design Philosophy
**Theme:** "Epistemic Calm." The UI must not feel like a clinical medical app, a chaotic productivity tool, or an addictive social feed. It must feel like a quiet, private vault for the mind.
**Keywords:** Minimal, structured, frictionless, provisional, grounding.

## 2. Visual Identity & Styling (Flutter / Material 3 / Cupertino)
* **Color Palette (Dark Mode Default):**
    * Background: Deep Slate/Charcoal (`#121212` or `#1A1C23`). Pure black is too harsh.
    * Surface/Cards: Slightly lighter slate (`#242731`) with very subtle borders (`#3A3E4A`).
    * Primary Accent (Subtle): Muted Indigo or Sage Green (used sparingly for active states or the "Act" intent).
    * Text: High legibility. Primary text (`#E2E8F0`), Secondary text (`#94A3B8`).
* **Typography:**
    * Use system-native sans-serif fonts for maximum performance (SF Pro on iOS/macOS, Roboto on Android/Windows).
    * Weight: Regular for body text, Medium for structure/nodes. Avoid heavy bolding.
* **Shape & Elevation:**
    * Soft corners (8px - 12px border radius).
    * Zero drop shadows in dark mode (use subtle border strokes to define depth).

## 3. Component Guidelines
* **Input Area:** borderless, expansive, auto-resizing `TextField`. It should feel like a blank canvas, not a form.
* **Intent Buttons (Clarify, Compress, Map, Reflect, Act):** Pill-shaped, muted background, only lighting up slightly when tapped.
* **The "Map" (Tree Visualization):**
    * Rendered using a lightweight custom painter or standard hierarchical list.
    * Must look like a clean directory tree (e.g., `You ├── Emotional └── Work └── Fatigue`).
    * Connecting lines should be 1px, muted grey.

## 4. Animation & Motion
* **Rule:** Motion must be functional, not decorative. 
* **Transitions:** Use slow, easing fade-ins (300ms) when the AI structures text. Avoid bouncy or springy animations.

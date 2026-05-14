# EOM Development Workflow & Standards

This document defines the step-by-step workflow for contributing to the EOM application, integrating architectural standards into the development lifecycle.

## Step 1: Context & Navigation
* **Check the Map**: Before creating new files or modifying existing ones, consult `docs/REPOMAP.md` to ensure changes align with the established directory structure and naming conventions.
* **Understand the Vision**: Reference `docs/design_spec.md` to maintain the "Epistemic Calm" philosophy.

## Step 2: Architecture & Service Layer
* **Service First**: Wrap external APIs or persistence logic in a Singleton service (e.g., `lib/services/`).
* **Define Interfaces**: Use abstract classes (e.g., `LlmProvider`) for interchangeable backends to ensure modularity.
* **State Management**: Default to `StatelessWidget`. Use `StatefulWidget` only for local ephemeral UI state (animations, focus).

## Step 3: UI Development & Design System
* **Enforce Theming**: Never hardcode colors. Use `lib/theme/eom_colors.dart`.
* **Visual Precision**: 
    - No drop shadows or `elevation`. 
    - Use 0.5px `EomColors.surfaceBorder` strokes for depth.
* **Motion**: Limit animations to 300ms with `Curves.easeOut`. Avoid bouncy physics.

## Step 4: Stability & Error Handling
* **Graceful Degradation**: Always wrap async calls and JSON parsing in `try/catch`.
* **UX Feedback**: Provide clear loading indicators (e.g., `CircularProgressIndicator`) during processing.
* **Security**: Manage API keys via `shared_preferences`. Never hardcode or commit keys.

## Step 5: Quality & Formatting
* **Imports**: Use relative imports (e.g., `import '../models/intent.dart';`) within `lib/`.
* **Linting**: Ensure zero warnings. Follow `flutter_lints`.
* **Formatting**: Run `dart format` before every commit.

## Directory Overview
Refer to `docs/REPOMAP.md` for a full tree, but follow these general assignments:
* `lib/models/`: Pure data structures.
* `lib/screens/`: Top-level route views.
* `lib/services/`: Logic, network, and storage.
* `lib/theme/`: Design tokens.
* `lib/widgets/`: Reusable UI components.

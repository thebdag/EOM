# EOM Coding Standards

This document outlines the conventions and best practices for developing the EOM Flutter application.

## 1. Architectural Patterns
* **Stateless by Default**: Prefer `StatelessWidget` where possible. Only use `StatefulWidget` when managing local ephemeral UI state (e.g., animations, text input focus).
* **Service Abstraction**: External APIs and data persistence should be wrapped in Singleton or dependency-injected service classes (e.g., `AiService`, `SettingsService`).
* **Provider Interfaces**: Implement abstract classes for interchangeable backends (e.g., `LlmProvider`).

## 2. Design System & Theming
* **Strict Palette Enforcement**: Never hardcode hex colors or `Colors.red` directly in widgets. All colors must be referenced from `lib/theme/eom_colors.dart`.
* **Zero Drop Shadows**: Do not use `BoxShadow` or `elevation`. Use 0.5px `EomColors.surfaceBorder` strokes to define depth per the "Epistemic Calm" design spec.
* **Animations**: Motion should be functional. Use maximum 300ms duration with `Curves.easeOut`. Avoid springy/bouncy physics.

## 3. Code Style & Linting
* **Formatting**: Code must be formatted using the standard `dart format`.
* **Linting**: No warnings permitted. Follow the official `flutter_lints` ruleset.
* **Imports**: Use relative imports for files within the `lib` directory (e.g., `import '../models/intent.dart';`) rather than package imports.

## 4. Error Handling & Stability
* **Graceful Degradation**: Always wrap API calls and JSON parsing in `try/catch` blocks.
* **UI Feedback**: Ensure loading states (e.g., `CircularProgressIndicator`) are clearly visible during async operations.
* **API Keys**: Never commit API keys to version control. They must be managed entirely on-device via `shared_preferences`.

## 5. File Structure
* `lib/models/`: Pure Dart data structures and enums.
* `lib/screens/`: Top-level route views (`Scaffold` implementations).
* `lib/services/`: Business logic, network requests, and local storage.
* `lib/theme/`: Design system tokens (colors, typography, global themes).
* `lib/widgets/`: Reusable, composition-focused UI components.

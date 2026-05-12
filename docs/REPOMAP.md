# Repository Map

An overview of the EOM application structure.

```text
EOM/
├── CHANGELOG.md               # Version history and notable changes
├── CODING-STANDARDS.md        # Architecture, style, and design conventions
├── REPOMAP.md                 # This file
├── design_spec.md             # Original design philosophy and component spec
├── pubspec.yaml               # Flutter package dependencies and assets
│
├── macos/                     # Native macOS build environment
├── ios/                       # Native iOS build environment
├── android/                   # Native Android build environment
│
└── lib/
    ├── main.dart              # Application entry point & theme initialization
    │
    ├── models/
    │   ├── intent.dart        # CognitiveIntent enum (Clarify, Compress, Map, etc.)
    │   └── thought_node.dart  # Recursive node structure for the Map tree view
    │
    ├── screens/
    │   ├── home_screen.dart     # Main "Vault" interface (input, intents, response)
    │   └── settings_screen.dart # API Key and Provider configuration UI
    │
    ├── services/
    │   ├── ai_service.dart      # Intent router and prompt management
    │   ├── llm_provider.dart    # Abstract interface and concrete LLM API clients
    │   └── settings_service.dart# SharedPreferences wrapper for persistent storage
    │
    ├── theme/
    │   ├── eom_colors.dart    # Strict color palette tokens
    │   └── eom_theme.dart     # Material 3 global ThemeData definition
    │
    └── widgets/
        ├── intent_button.dart   # Interactive pill button for cognitive intents
        ├── response_card.dart   # Fade-in markdown container for text responses
        └── thought_tree_view.dart # Custom widget rendering recursive directory trees
```

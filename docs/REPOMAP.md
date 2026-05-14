# Repository Map

An overview of the EOM application structure.

```text
EOM/
├── CHANGELOG.md               # Version history and notable changes
├── README.md                  # Project overview and setup instructions
├── pubspec.yaml               # Flutter package dependencies and assets
│
├── docs/                      # Project documentation
│   ├── REPOMAP.md             # This file
│   └── design_spec.md         # Original design philosophy and component spec
│
├── lib/
│   ├── main.dart              # Application entry point & theme initialization
│   │
│   ├── models/
│   │   ├── intent.dart        # CognitiveIntent enum (Clarify, Compress, Map, etc.)
│   │   └── thought_node.dart  # Recursive node structure for the Map tree view
│   │
│   ├── screens/
│   │   ├── history_screen.dart  # Library of saved thought sessions
│   │   ├── home_screen.dart     # Main "Vault" interface (input, intents, response)
│   │   └── settings_screen.dart # API Key and Provider configuration UI
│   │
│   ├── services/
│   │   ├── ai_service.dart      # Intent router and prompt management
│   │   ├── history_service.dart # Persistent storage for session logs (SQLite)
│   │   ├── llm_provider.dart    # Abstract interface and concrete LLM API clients
│   │   └── settings_service.dart# SharedPreferences wrapper for persistent storage
│   │
│   ├── theme/
│   │   ├── eom_colors.dart    # Strict color palette tokens
│   │   └── eom_theme.dart     # Material 3 global ThemeData definition
│   │
│   └── widgets/
│       ├── intent_button.dart   # Interactive pill button for cognitive intents
│       ├── response_card.dart   # Fade-in markdown container for text responses
│       └── thought_tree_view.dart # Custom widget rendering recursive directory trees
│
└── test/                      # Unit and widget tests
    └── thought_node_test.dart # Logic tests for tree structure management
```


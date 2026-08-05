# Repository Map

An overview of the EOM application structure.

```text
EOM/
├── CHANGELOG.md               # Version history and notable changes
├── CONTEXT.md                 # Domain glossary (ubiquitous language)
├── README.md                  # Project overview and setup instructions
├── pubspec.yaml               # Flutter package dependencies and assets
│
├── docs/                      # Project documentation
│   ├── REPOMAP.md             # This file
│   ├── design_spec.md         # Original design philosophy and component spec
│   └── adr/
│       └── 0001-local-means-litellm-gateway.md
│
├── lib/
│   ├── main.dart              # Application entry point & theme initialization
│   │
│   ├── models/
│   │   ├── epistemic_node.dart  # EpistemicNode model + EpistemicNodeType enum (EOM-T1)
│   │   ├── intent.dart          # CognitiveIntent enum (Clarify, Compress, Map, etc.)
│   │   └── thought_node.dart    # Recursive node structure for the Map tree view
│   │
│   ├── screens/
│   │   ├── history_screen.dart  # Library of saved thought sessions
│   │   ├── home_screen.dart     # Main "Vault" interface (input, intents, response)
│   │   └── settings_screen.dart # API Key / LiteLLM / Provider configuration UI
│   │
│   ├── services/
│   │   ├── ai_service.dart      # Intent router and prompt management
│   │   ├── epistemic_service.dart # SQLite CRUD for the epistemic graph (EOM-T1)
│   │   ├── history_service.dart # Persistent storage for session logs (Hive)
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
    ├── epistemic_node_test.dart   # Model round-trip, type enum, copyWith, equality (EOM-T1)
    ├── settings_service_test.dart # Gateway-origin normalization
    └── thought_node_test.dart     # Logic tests for tree structure management

dev/
└── tracker/                   # Lightweight issue tracker (SQLite + Node.js TUI)
    ├── package.json           # Tracker dependencies (better-sqlite3, blessed)
    ├── db.js                  # SQLite schema, migrations, and CRUD helpers
    ├── tracker.js             # Entry point (git branch detection, DB init, TUI launch)
    ├── ui.js                  # blessed TUI — three-pane Epics/Stories/Detail layout
    └── seed.js                # One-time seed script: 7 epics from the existing codebase
```


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
│       ├── 0001-local-means-litellm-gateway.md
│       └── 0002-delta-update-model.md  # Sessions refine, never overwrite, epistemic nodes (EOM-T12)
│
├── lib/
│   ├── main.dart              # Application entry point & theme initialization
│   │
│   ├── models/
│   │   ├── confidence_event.dart # ConfidenceEvent + ConfidenceDrift models (EOM-T15)
│   │   ├── epistemic_gap.dart   # EpistemicGap model + EpistemicGapKind enum (EOM-T14)
│   │   ├── epistemic_maturity.dart # Per-domain maturity score + computeMaturityByDomain (EOM-T16)
│   │   ├── epistemic_node.dart  # EpistemicNode model + EpistemicNodeType + EpistemicCategory enums (EOM-T1, EOM-T5)
│   │   ├── epistemic_operation.dart # Sealed EpistemicOperation + Clarify/Compress/Map/Reflect/Act payloads (EOM-T6–T10)
│   │   ├── epistemic_query_result.dart # BFS traversal result: root + nodes + unique edges (EOM-T17)
│   │   ├── epistemic_relationship.dart # EpistemicRelationship model + type enum (EOM-T4)
│   │   ├── intent.dart          # CognitiveIntent enum (Clarify, Compress, Map, etc.)
│   │   └── thought_node.dart    # Recursive node structure for the Map tree view
│   │
│   ├── screens/
│   │   ├── history_screen.dart  # Library of saved thought sessions
│   │   ├── home_screen.dart     # Main "Vault" interface (input, intents, response)
│   │   └── settings_screen.dart # API Key / LiteLLM / Provider configuration UI
│   │
│   ├── services/
│   │   ├── ai_service.dart      # Intent router, prompt management, ---EPISTEMIC--- epilogue parsing (all 5 intents)
│   │   ├── epistemic_gap_service.dart # Gap detection: explicit question/unknown nodes + unmapped concepts (EOM-T14)
│   │   ├── epistemic_intent_service.dart # Bridges epistemic operations → epistemic graph (EOM-T7, T11)
│   │   ├── epistemic_service.dart # SQLite CRUD + FTS5 search/BFS traverse + confidence-event log + EpistemicGraphStore interface (EOM-T1, T7, T15, T17)
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
    ├── epistemic_category_test.dart   # EpistemicCategory enum, fromString, field, copyWith (EOM-T5)
    ├── epistemic_drift_test.dart      # Confidence-event log + drift computation (EOM-T15)
    ├── epistemic_gap_test.dart        # Explicit + inferred gap detection, coverage heuristics (EOM-T14)
    ├── epistemic_intent_service_test.dart # Intent→graph upserts + edge semantics, in-memory fake (EOM-T7, T11, T14)
    ├── epistemic_maturity_test.dart   # Domain grouping, thresholds, score ratio (EOM-T16)
    ├── epistemic_node_test.dart       # Model round-trip, type enum, copyWith, equality (EOM-T1)
    ├── epistemic_operation_test.dart  # JSON parsing for all 5 EpistemicOperation types (EOM-T6–T10)
    ├── epistemic_query_test.dart      # FTS sanitiser + BFS traverse semantics (EOM-T17)
    ├── epistemic_relationship_test.dart # Edge round-trip, type enum (EOM-T4)
    ├── helpers/in_memory_epistemic_store.dart # Shared in-memory EpistemicGraphStore fake
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


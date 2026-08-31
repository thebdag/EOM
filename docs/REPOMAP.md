# Repository Map

An overview of the EOM application structure.

```text
EOM/
├── AGENTS.md                  # Operating instructions for AI agents working in this repo
├── CHANGELOG.md               # Version history and notable changes
├── changelog.md               # Agent-maintained dev log (lower-case; see also CHANGELOG.md)
├── CONTEXT.md                 # Domain glossary (ubiquitous language)
├── learnings.md               # Running log of bugs to avoid, gotchas, and best practices
├── README.md                  # Project overview and setup instructions
├── pubspec.yaml               # Flutter package dependencies and assets (incl. Cormorant Garamond)
├── assets/
│   └── fonts/                 # Bundled orientation serif (Cormorant Garamond Medium + OFL)
│
├── docs/                      # Project documentation
│   ├── REPOMAP.md             # This file
│   ├── design_spec.md         # Epistemic Calm + Family kinship (dual accent, serif, soft gate)
│   ├── ux_findings_eom_e4.md  # UX findings (EOM-E4): S16 walk + S21–S23 live beta + S24 structural closes
│   ├── ui_spirit_enhancement_plan.md  # Epiture-kinship UI/UX spirit plan (Family; soft gate; calm Settings)
│   └── adr/
│       ├── 0001-local-means-litellm-gateway.md
│       ├── 0002-delta-update-model.md  # Sessions refine, never overwrite, epistemic nodes (EOM-T12)
│       └── 0003-on-device-means-os-foundation-models.md  # ON_DEVICE ≠ LOCAL; AICore / Foundation Models
│
├── lib/
│   ├── main.dart              # Application entry point & theme initialization
│   │
│   ├── models/
│   │   ├── confidence_event.dart # ConfidenceEvent + ConfidenceDrift models (EOM-T15)
│   │   ├── conversation.dart    # Conversation model for the history library (EOM-S11)
│   │   ├── epistemic_gap.dart   # EpistemicGap model + EpistemicGapKind enum (EOM-T14)
│   │   ├── epistemic_maturity.dart # Per-domain maturity score + computeMaturityByDomain (EOM-T16)
│   │   ├── epistemic_node.dart  # EpistemicNode model + EpistemicNodeType + EpistemicCategory enums (EOM-T1, EOM-T5)
│   │   ├── epistemic_operation.dart # Sealed EpistemicOperation + Clarify/Compress/Map/Reflect/Act payloads (EOM-T6–T10)
│   │   ├── epistemic_query_result.dart # BFS traversal result: root + nodes + unique edges (EOM-T17)
│   │   ├── epistemic_relationship.dart # EpistemicRelationship model + type enum (EOM-T4)
│   │   ├── intent.dart          # CognitiveIntent enum (Clarify, Compress, Map, etc.)
│   │   ├── llm_provider_kind.dart # LlmProviderKind enum: provider identity + OLLAMA→LOCAL + ON_DEVICE (EOM-S10)
│   │   └── thought_node.dart    # Recursive node structure for the Map tree view (+ fromJson/tryParseRaw, EOM-S14)
│   │
│   ├── screens/
│   │   ├── history_screen.dart  # Saved sessions: empty CTA, clear confirm (S19); row reopen → Home (S24/F8); Clarify + Read more (S29/F14)
│   │   ├── home_screen.dart     # Vault UI: ceremonial empty (S26), soft gate (S27), blank-input hint (F13), History pip (F15), prior-turn thread (F10), Map framing (F11), New-thought confirm (F16), calm errors (S18)
│   │   └── settings_screen.dart # Calm Settings: active-only key or on-device status, collapsed Advanced, Epiture footer (S28 / F4)
│   │
│   ├── services/
│   │   ├── ai_service.dart      # Intent router + ---EPISTEMIC--- epilogue splitting (prompts/parsing live in intent_config.dart)
│   │   ├── epistemic_gap_service.dart # Gap detection: explicit question/unknown nodes + unmapped concepts (EOM-T14)
│   │   ├── epistemic_export_service.dart # Full-map export as structured JSON / Markdown (EOM-T19)
│   │   ├── epistemic_intent_service.dart # Bridges epistemic operations → epistemic graph (EOM-T7, T11)
│   │   ├── history_service.dart # Persistent storage for session logs (Hive)
│   │   ├── intent_config.dart   # Per-intent prompt builder + epilogue JSON→operation routing (EOM-S14)
│   │   ├── intent_error.dart    # Maps provider/auth failures to calm copy + Settings recovery (EOM-S18)
│   │   ├── llm_provider.dart    # LlmProvider interface, ChatMessage, provider clients, shared chat-completions helper, OnDeviceProvider (EOM-S11, S13)
│   │   ├── on_device_llm.dart   # MethodChannel client for OS on-device models (AICore / Foundation Models)
│   │   ├── settings_service.dart# SharedPreferences wrapper for persistent storage
│   │   └── sqlite_epistemic_graph_store.dart # SQLite CRUD + FTS5 search/BFS traverse + confidence-event log + EpistemicGraphStore interface (EOM-T1, T7, T15, T17; renamed EOM-S12)
│   │
│   ├── theme/
│   │   ├── eom_colors.dart    # Palette tokens (gold/indigo/sage; deeper void; F12 tertiary)
│   │   ├── eom_motion.dart    # Duration/curve tokens + fade routes + sheetStyleOf (EOM-S30)
│   │   ├── eom_shapes.dart    # Leaf radius + ordinary radii (EOM-S25)
│   │   └── eom_theme.dart     # Material 3 ThemeData + orientation serif + EomSpacing + EomScrollBehavior
│   │
│   └── widgets/
│       ├── empty_vault_panel.dart # Ceremonial leaf-framed empty canvas + Connect CTA (EOM-S26)
│       ├── eom_appear.dart      # Fade-in appear; snap-unmount hide (EOM-S30)
│       ├── guide_fields.dart    # Shared provider picker + key field + on-device status (soft gate + Settings, S27/S28)
│       ├── orientation_chrome.dart # Gold sans CTA + Advanced/Connections disclosure
│       ├── soft_gate_sheet.dart # First-run / no-key connect sheet (EOM-S27 / F1 / F5)
│       ├── epistemic_graph_view.dart # Radial epistemic subgraph overlay, nodes coloured by confidence (EOM-T18); shown under collapsible Connections on Home (S24/F11)
│       ├── intent_button.dart   # Interactive pill button for cognitive intents (description subtitle + tooltip, EOM-S20)
│       ├── response_card.dart   # Fade-in markdown; leaf on success (S29); Open Settings on recoverable errors (EOM-S18)
│       └── thought_tree_view.dart # Custom widget rendering recursive directory trees ("Your map" on Home, S24/F11)
│
└── test/                      # Unit and widget tests
    ├── ai_service_test.dart           # Map parse degradation + provider content extraction, isError flag (EOM-S4, S5)
    ├── beta_drift_test.dart  # Asserts beta runner reuses real app prompts/marker (EOM-T67)
    ├── beta/                          # Epistemic alignment pressure tests (EOM-E5)
    │   ├── beta_loader.dart            # Prompt + Expected models, JSON loader (EOM-T66)
    │   ├── beta_provider.dart          # CLI LLM client mirroring lib/services/llm_provider.dart (EOM-T67)
    │   ├── beta_runner.dart            # Batch runner + response capture (EOM-T67, T68)
    │   ├── beta_scorer.dart            # Rubric scorer: 8 criteria, verdicts, findings (EOM-T69)
    │   ├── beta_reporter.dart          # Roll-up + markdown/json report (EOM-T70)
    │   ├── run_test.dart               # Guarded entry: run prompts against a provider
    │   ├── analyze_test.dart           # Guarded entry: score a captured run + emit report
    │   └── scorer_test.dart            # Scorer unit tests (run in CI, no network)
    ├── conversation_test.dart         # Conversation model round-trip + corrupt-entry tolerance (EOM-S11)
    ├── epistemic_category_test.dart   # EpistemicCategory enum, fromString, field, copyWith (EOM-T5)
    ├── epistemic_drift_test.dart      # Confidence-event log + drift computation (EOM-T15)
    ├── epistemic_export_test.dart     # JSON round-trip + Markdown grouping/snippets (EOM-T19)
    ├── epistemic_gap_test.dart        # Explicit + inferred gap detection, coverage heuristics (EOM-T14)
    ├── epistemic_graph_view_test.dart # Confidence colour lerp + overlay widget render/fade (EOM-T18)
    ├── epistemic_intent_service_test.dart # Intent→graph upserts + edge semantics, in-memory fake (EOM-T7, T11, T14)
    ├── epistemic_maturity_test.dart   # Domain grouping, thresholds, score ratio (EOM-T16)
    ├── epistemic_node_test.dart       # Model round-trip, type enum, copyWith, equality (EOM-T1)
    ├── epistemic_operation_test.dart  # JSON parsing for all 5 EpistemicOperation types (EOM-T6–T10)
    ├── epistemic_query_test.dart      # FTS sanitiser + BFS traverse semantics (EOM-T17)
    ├── epistemic_relationship_test.dart # Edge round-trip, type enum (EOM-T4)
    ├── sqlite_epistemic_graph_store_test.dart # Real sqflite-backed store regression via ffi factory (EOM-S2)
    ├── helpers/in_memory_epistemic_store.dart # Shared in-memory EpistemicGraphStore fake
    ├── helpers/fake_on_device_llm.dart # In-memory OnDeviceLlmClient for tests
    ├── helpers/guide_prefs.dart # persistGeminiGuideWithoutKey (credential-gate tests)
    ├── helpers/ux_harness.dart  # Shared SilentLlmProvider, FakeHistory, pumpEomHome
    ├── history_service_test.dart  # Hive-backed save/read/clear + corrupt-entry tolerance (EOM-S11)
    ├── home_screen_test.dart      # Injected-service flows: clarify/map, friendly errors, New-thought confirm, Connections expand (S12, S18, S24)
    ├── ux_eom_s26_empty_state_test.dart # Ceremonial empty: serif/leaf/gold/Connect CTA (EOM-S26)
    ├── ux_eom_s27_soft_gate_test.dart # Soft-gate sheet: CTA + intent-without-key (EOM-S27 / F1 / F5)
    ├── ux_eom_s28_settings_test.dart # Calm Settings: active-only + Advanced + lineage (EOM-S28 / F4)
    ├── ux_eom_s29_polish_test.dart # F12–F15 polish: contrast, blank hint, History, pip, leaf (EOM-S29)
    ├── ux_eom_s30_motion_test.dart # Calm M3 motion: snap-hide, iOS 500ms exception (EOM-S30)
    ├── ux_on_device_guide_test.dart # On-device picker / soft gate / Settings status
    ├── intent_config_test.dart    # Per-intent prompt contract + operation routing (EOM-S14)
    ├── intent_error_test.dart     # Provider/auth → calm copy + Settings recovery mapping (EOM-S18)
    ├── llm_provider_kind_test.dart # Provider-kind parsing, legacy mapping, factory, ChatMessage
    ├── on_device_llm_test.dart     # Fake channel + OnDeviceProvider prepare/generate (no device)
    ├── settings_screen_test.dart  # Settings persist on system back / AppBar pop (EOM-S6)
    ├── settings_service_test.dart # Gateway-origin normalization + hasUsableGuide (S26)
    ├── thought_node_test.dart     # Logic tests for tree structure management
    ├── ux_eom_e4_quick_wins_test.dart # History empty CTA/clear confirm + intent descriptions (EOM-S19, S20)
    ├── ux_eom_s21_first_run_test.dart # Live first-run widget walk (guarded by EOM_S21_LIVE)
    ├── ux_eom_s21_live_provider_test.dart # Live Clarify via real LiteLLM (no testWidgets; EOM_S21_LIVE)
    ├── ux_eom_s22_live_provider_test.dart # Live five-intent LiteLLM session (EOM-S22)
    ├── ux_eom_s22_session_ux_test.dart # Map framing + Act sage chrome (EOM-S22)
    ├── ux_eom_s23_returning_user_test.dart # Multi-turn / History / New thought (EOM-S23)
    ├── ux_eom_s24_structural_test.dart # F8/F10/F11/F16 structural UX (EOM-S24)
    └── widget_test.dart           # EomApp smoke test (brand + input prompt)

dev/
├── beta/                      # Epistemic alignment pressure tests (EOM-E5)
│   ├── README.md               # How to run the beta pressure tests
│   ├── rubric.md               # Scoring rubric: criteria, scale, weights, verdicts (EOM-T63)
│   ├── prompts/                # Prompt library + metadata (EOM-T64/T65/T66)
│   │   ├── clarify.json
│   │   ├── compress.json
│   │   ├── map.json
│   │   ├── reflect.json
│   │   └── act.json
│   ├── responses/              # Captured runs (gitignored, one dir per run) (EOM-T68)
│   └── reports/                # Generated reports, gitignored (EOM-T70)
└── tracker/                   # Lightweight issue tracker (SQLite + Node.js TUI)
    ├── package.json           # Tracker dependencies (sql.js, blessed)
    ├── db.js                  # SQLite schema, migrations, and CRUD helpers (incl. subtask_comments)
    ├── tracker.js             # Entry point (git branch detection, DB init, TUI launch)
    ├── ui.js                  # blessed TUI — three-pane Epics/Stories/Detail; `r` reload, `c`/`v` comments
    ├── mark.js                # Status CLI: `node dev/tracker/mark.js EOM-T7 done`
    ├── comment.js             # Comment CLI: `node dev/tracker/comment.js EOM-T7 "…"`
    ├── install-hooks.js       # One-time installer for the post-commit hook
    ├── hooks/post-commit      # Reads [EOM-Tn done] / [EOM-Tn note: …] tokens from commit messages
    └── seed.js                # One-time seed script: 7 epics from the existing codebase
```


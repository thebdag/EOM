# Graph Report - EOM  (2026-08-05)

## Corpus Check
- 66 files · ~29,533 words
- Verdict: corpus is large enough that graph structure adds value.

## Summary
- 574 nodes · 641 edges · 37 communities (34 shown, 3 thin omitted)
- Extraction: 99% EXTRACTED · 1% INFERRED · 0% AMBIGUOUS · INFERRED: 6 edges (avg confidence: 0.55)
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `990577ae`
- Run `git rev-parse HEAD` and compare to check if the graph is stale.
- Run `graphify update .` after code changes (no API cost).

## Community Hubs (Navigation)
- intent_button.dart
- history_screen.dart
- GeneratedPluginRegistrant.swift
- home_screen.dart
- settings_service.dart
- settings_screen.dart
- eom_colors.dart
- ui.js
- response_card.dart
- manifest.json
- Unreleased
- EOM Tracker — Database Schema Reference
- options
- tracker/package.json
- epistemic_node.dart
- AGENTS.md
- EOM Development Workflow & Standards
- epistemic_intent_service_test.dart
- [Unreleased] - 2026-05-11
- EOM — A Quiet Vault for the Mind
- Learnings
- package.json
- MainActivity
- epistemic_service.dart
- EOM Tracker
- LaunchImage.imageset/README.md
- EOM Tracker — TUI Keybindings Reference
- 0001-local-means-litellm-gateway.md
- ai_service.dart
- compress_result.dart
- intent.dart
- _ResponseCardState
- package:flutter/material.dart

## God Nodes (most connected - your core abstractions)
1. `EOM Tracker` - 10 edges
2. `EOM — A Quiet Vault for the Mind` - 9 edges
3. `Unreleased` - 8 edges
4. `EOM Tracker — TUI Keybindings Reference` - 7 edges
5. `EOM Development Workflow & Standards` - 7 edges
6. `initDb()` - 6 edges
7. `[Unreleased] - 2026-05-11` - 6 edges
8. `Stories` - 5 edges
9. `main()` - 5 edges
10. `AppDelegate` - 5 edges

## Surprising Connections (you probably didn't know these)
- `InMemoryStore` --implements--> `EpistemicGraphStore`  [EXTRACTED]
  test/epistemic_intent_service_test.dart → lib/services/epistemic_service.dart
- `epicProgress()` --references--> `Stories`  [EXTRACTED]
  dev/tracker/ui.js → dev/tracker/db.js
- `main()` --calls--> `initDb()`  [EXTRACTED]
  dev/tracker/tracker.js → dev/tracker/db.js
- `main()` --calls--> `getDb()`  [EXTRACTED]
  dev/tracker/tracker.js → dev/tracker/db.js
- `seed()` --references--> `Epics`  [EXTRACTED]
  dev/tracker/seed.js → dev/tracker/db.js

## Import Cycles
- None detected.

## Communities (37 total, 3 thin omitted)

### Community 0 - "intent_button.dart"
Cohesion: 0.22
Nodes (8): CognitiveIntent, build, intent, isLoading, isSelected, onPressed, ../models/intent.dart, VoidCallback

### Community 1 - "history_screen.dart"
Cohesion: 0.22
Nodes (9): build, _conversations, createState, _formatDate, HistoryScreen, _HistoryScreenState, _historyService, initState (+1 more)

### Community 2 - "GeneratedPluginRegistrant.swift"
Cohesion: 0.06
Nodes (28): Any, Cocoa, Flutter, FlutterAppDelegate, FlutterImplicitEngineBridge, FlutterImplicitEngineDelegate, FlutterMacOS, FlutterPluginRegistry (+20 more)

### Community 3 - "home_screen.dart"
Cohesion: 0.07
Nodes (29): history_screen.dart, _activeIntent, _aiService, build, _buildInputArea, _buildIntentBar, _buildProcessingIndicator, _buildTopBar (+21 more)

### Community 4 - "settings_service.dart"
Cohesion: 0.05
Nodes (35): _boxName, clearHistory, getConversations, HistoryService, init, saveConversation, anthropicKey, defaultGatewayOrigin (+27 more)

### Community 5 - "settings_screen.dart"
Cohesion: 0.07
Nodes (29): build, EomApp, init, main, _activeProvider, _anthropicController, build, _buildDropdown (+21 more)

### Community 6 - "eom_colors.dart"
Cohesion: 0.10
Nodes (19): accent, accentMuted, accentSubtle, background, divider, EomColors, error, intentHover (+11 more)

### Community 7 - "ui.js"
Cohesion: 0.08
Nodes (35): DB_PATH, Epics, fs, get(), getDb(), initDb(), migrate(), nextKey() (+27 more)

### Community 8 - "response_card.dart"
Cohesion: 0.14
Nodes (13): Animation, AnimationController, accentColor, build, _buildRichText, _controller, createState, dispose (+5 more)

### Community 9 - "manifest.json"
Cohesion: 0.18
Nodes (10): background_color, description, display, icons, name, orientation, prefer_related_applications, short_name (+2 more)

### Community 10 - "Unreleased"
Cohesion: 0.14
Nodes (13): [1.0.0+1] — 2026-05-11, Added, Added, Added, Added / Changed / Fixed / Removed, Changed, Changed, Changelog (Dev Log) (+5 more)

### Community 11 - "EOM Tracker — Database Schema Reference"
Cohesion: 0.15
Nodes (12): EOM Tracker — Database Schema Reference, `epics`, Epics, JS Helper API (`db.js`), Key formats, `meta`, Resolving a key to an id, `stories` (+4 more)

### Community 12 - "options"
Cohesion: 0.20
Nodes (9): name, npm, options, baseURL, chunkTimeout, timeout, provider, lmstudio (+1 more)

### Community 13 - "tracker/package.json"
Cohesion: 0.15
Nodes (12): blessed, dependencies, blessed, sql.js, description, main, name, scripts (+4 more)

### Community 14 - "epistemic_node.dart"
Cohesion: 0.05
Nodes (43): DateTime, epistemic_relationship.dart, int get, category, confidence, content, copyWith, createdAt (+35 more)

### Community 15 - "AGENTS.md"
Cohesion: 0.22
Nodes (7): 1. Orient yourself first, 2. Use the repomap (`docs/REPOMAP.md`), 3. Check the graphify graph content, 4. Coding standards (summary — full version in CODING-STANDARDS.md), 5. Update the issue tracker (`dev/tracker/`), 6. Pre-PR checklist (do this LAST, every time), 7. Commit & PR conventions

### Community 16 - "EOM Development Workflow & Standards"
Cohesion: 0.25
Nodes (7): Directory Overview, EOM Development Workflow & Standards, Step 1: Context & Navigation, Step 2: Architecture & Service Layer, Step 3: UI Development & Design System, Step 4: Stability & Error Handling, Step 5: Quality & Formatting

### Community 17 - "epistemic_intent_service_test.dart"
Cohesion: 0.07
Nodes (26): ArgumentError, package:eom/main.dart, package:eom/models/compress_result.dart, package:eom/models/epistemic_node.dart, package:eom/models/epistemic_relationship.dart, package:eom/models/thought_node.dart, package:eom/services/epistemic_intent_service.dart, package:eom/services/epistemic_service.dart (+18 more)

### Community 18 - "[Unreleased] - 2026-05-11"
Cohesion: 0.25
Nodes (7): Added, Changed, Changelog, Added, Changed, Fixed, [Unreleased] - 2026-05-11

### Community 19 - "EOM — A Quiet Vault for the Mind"
Cohesion: 0.09
Nodes (19): EOM, Language, 1. Core Design Philosophy, 2. Visual Identity & Styling (Flutter / Material 3 / Cupertino), 3. Component Guidelines, 4. Animation & Motion, EOM - AI Agent Design Specification (`design_spec.md`), Repository Map (+11 more)

### Community 20 - "Learnings"
Cohesion: 0.40
Nodes (4): Best Practices, Bugs To Avoid, Gotchas, Learnings

### Community 21 - "package.json"
Cohesion: 0.29
Nodes (6): opencode-auto-resume, dependencies, opencode-auto-resume, name, scripts, tracker

### Community 23 - "epistemic_service.dart"
Cohesion: 0.06
Nodes (33): dart:async, Database?, epistemic_service.dart, EpistemicIntentService, _hasOverlap, _parseCategory, _parseNodeType, processCompressResult (+25 more)

### Community 24 - "EOM Tracker"
Cohesion: 0.18
Nodes (10): Decision tree: TUI vs. script, EOM Tracker, Step 1: Launch the TUI, Step 2: Navigate the TUI, Step 3: Create items, Step 4: Update item status, Step 5: Link a git branch to a story, Step 6: Edit or delete items (+2 more)

### Community 30 - "EOM Tracker — TUI Keybindings Reference"
Cohesion: 0.25
Nodes (7): App, CRUD, EOM Tracker — TUI Keybindings Reference, Navigation, Pane layout, Status & Linking, Status & priority colour codes

### Community 32 - "ai_service.dart"
Cohesion: 0.08
Nodes (29): dart:convert, ThoughtNode, AiResponse, AiService, compressExtractionMarker, epistemicExtraction, _getProvider, intent (+21 more)

### Community 33 - "compress_result.dart"
Cohesion: 0.09
Nodes (20): bool get, category, CompressResult, confidence, defaultConfidence, fromJson, keywords, nodeType (+12 more)

### Community 34 - "intent.dart"
Cohesion: 0.25
Nodes (7): Color, IconData, color, description, icon, label, ../theme/eom_colors.dart

### Community 35 - "_ResponseCardState"
Cohesion: 0.33
Nodes (7): HomeScreen, _HomeScreenState, ResponseCard, _ResponseCardState, SingleTickerProviderStateMixin, State, StatefulWidget

### Community 36 - "package:flutter/material.dart"
Cohesion: 0.50
Nodes (3): eom_colors.dart, EomTheme, package:flutter/material.dart

## Knowledge Gaps
- **339 isolated node(s):** `path`, `fs`, `DB_PATH`, `name`, `version` (+334 more)
  These have ≤1 connection - possible missing edges or undocumented components.
- **3 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `EpistemicIntentService` connect `epistemic_service.dart` to `epistemic_intent_service_test.dart`, `home_screen.dart`?**
  _High betweenness centrality (0.025) - this node is a cross-community bridge._
- **Why does `CognitiveIntent` connect `intent_button.dart` to `ai_service.dart`, `intent.dart`, `home_screen.dart`?**
  _High betweenness centrality (0.012) - this node is a cross-community bridge._
- **Why does `ThoughtNode` connect `ai_service.dart` to `compress_result.dart`?**
  _High betweenness centrality (0.008) - this node is a cross-community bridge._
- **What connects `path`, `fs`, `DB_PATH` to the rest of the system?**
  _339 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `GeneratedPluginRegistrant.swift` be split into smaller, more focused modules?**
  _Cohesion score 0.05807200929152149 - nodes in this community are weakly interconnected._
- **Should `home_screen.dart` be split into smaller, more focused modules?**
  _Cohesion score 0.06666666666666667 - nodes in this community are weakly interconnected._
- **Should `settings_service.dart` be split into smaller, more focused modules?**
  _Cohesion score 0.05405405405405406 - nodes in this community are weakly interconnected._
# Graph Report - EOM  (2026-08-05)

## Corpus Check
- 65 files · ~29,398 words
- Verdict: corpus is large enough that graph structure adds value.

## Summary
- 569 nodes · 635 edges · 35 communities (32 shown, 3 thin omitted)
- Extraction: 99% EXTRACTED · 1% INFERRED · 0% AMBIGUOUS · INFERRED: 6 edges (avg confidence: 0.55)
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `c691430f`
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
- clarify_operation.dart
- manifest.json
- Unreleased
- EOM Tracker — Database Schema Reference
- options
- tracker/package.json
- epistemic_node.dart
- AGENTS.md
- EOM Development Workflow & Standards
- package:flutter_test/flutter_test.dart
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
- _
- llm_provider.dart

## God Nodes (most connected - your core abstractions)
1. `_` - 15 edges
2. `EOM Tracker` - 10 edges
3. `EOM — A Quiet Vault for the Mind` - 9 edges
4. `EOM Tracker — TUI Keybindings Reference` - 7 edges
5. `EOM Development Workflow & Standards` - 7 edges
6. `initDb()` - 6 edges
7. `Unreleased` - 6 edges
8. `Stories` - 5 edges
9. `main()` - 5 edges
10. `AppDelegate` - 5 edges

## Surprising Connections (you probably didn't know these)
- `epicProgress()` --references--> `Stories`  [EXTRACTED]
  dev/tracker/ui.js → dev/tracker/db.js
- `main()` --calls--> `initDb()`  [EXTRACTED]
  dev/tracker/tracker.js → dev/tracker/db.js
- `main()` --calls--> `getDb()`  [EXTRACTED]
  dev/tracker/tracker.js → dev/tracker/db.js
- `seed()` --references--> `Epics`  [EXTRACTED]
  dev/tracker/seed.js → dev/tracker/db.js
- `seed()` --references--> `Stories`  [EXTRACTED]
  dev/tracker/seed.js → dev/tracker/db.js

## Import Cycles
- None detected.

## Communities (35 total, 3 thin omitted)

### Community 0 - "intent_button.dart"
Cohesion: 0.05
Nodes (37): Color, dart:convert, eom_colors.dart, IconData, build, EomApp, init, main (+29 more)

### Community 1 - "history_screen.dart"
Cohesion: 0.11
Nodes (18): bool get, children, fromJson, isExpanded, isLeaf, label, ThoughtNode, toJson (+10 more)

### Community 2 - "GeneratedPluginRegistrant.swift"
Cohesion: 0.06
Nodes (28): Any, Cocoa, Flutter, FlutterAppDelegate, FlutterImplicitEngineBridge, FlutterImplicitEngineDelegate, FlutterMacOS, FlutterPluginRegistry (+20 more)

### Community 3 - "home_screen.dart"
Cohesion: 0.08
Nodes (24): history_screen.dart, _activeIntent, _aiService, build, _buildInputArea, _buildIntentBar, _buildProcessingIndicator, _buildTopBar (+16 more)

### Community 4 - "settings_service.dart"
Cohesion: 0.05
Nodes (35): _boxName, clearHistory, getConversations, HistoryService, init, saveConversation, anthropicKey, defaultGatewayOrigin (+27 more)

### Community 5 - "settings_screen.dart"
Cohesion: 0.06
Nodes (37): Animation, AnimationController, HomeScreen, _HomeScreenState, _activeProvider, _anthropicController, build, _buildDropdown (+29 more)

### Community 6 - "eom_colors.dart"
Cohesion: 0.10
Nodes (19): accent, accentMuted, accentSubtle, background, divider, EomColors, error, intentHover (+11 more)

### Community 7 - "ui.js"
Cohesion: 0.08
Nodes (35): DB_PATH, Epics, fs, get(), getDb(), initDb(), migrate(), nextKey() (+27 more)

### Community 8 - "clarify_operation.dart"
Cohesion: 0.10
Nodes (21): apply, _applyDisambiguate, _applyOne, ClarifyOperation, ClarifyPayload, confidenceCeiling, confidenceStep, deeper (+13 more)

### Community 9 - "manifest.json"
Cohesion: 0.18
Nodes (10): background_color, description, display, icons, name, orientation, prefer_related_applications, short_name (+2 more)

### Community 10 - "Unreleased"
Cohesion: 0.17
Nodes (11): [1.0.0+1] — 2026-05-11, Added, Added, Added / Changed / Fixed / Removed, Changed, Changelog (Dev Log), Fixed, Added (+3 more)

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
Cohesion: 0.25
Nodes (6): 1. Orient yourself first, 2. Use the repomap (`docs/REPOMAP.md`), 3. Check the graphify graph content, 4. Coding standards (summary — full version in CODING-STANDARDS.md), 5. Pre-PR checklist (do this LAST, every time), 6. Commit & PR conventions

### Community 16 - "EOM Development Workflow & Standards"
Cohesion: 0.25
Nodes (7): Directory Overview, EOM Development Workflow & Standards, Step 1: Context & Navigation, Step 2: Architecture & Service Layer, Step 3: UI Development & Design System, Step 4: Stability & Error Handling, Step 5: Quality & Formatting

### Community 17 - "package:flutter_test/flutter_test.dart"
Cohesion: 0.09
Nodes (17): ArgumentError, package:eom/main.dart, package:eom/models/epistemic_node.dart, package:eom/models/epistemic_operation.dart, package:eom/models/epistemic_relationship.dart, package:eom/models/thought_node.dart, package:eom/services/clarify_operation.dart, package:eom/services/settings_service.dart (+9 more)

### Community 18 - "[Unreleased] - 2026-05-11"
Cohesion: 0.29
Nodes (6): Changed, Changelog, Added, Changed, Fixed, [Unreleased] - 2026-05-11

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
Cohesion: 0.09
Nodes (22): dart:async, Database?, addRelationship, all, byCategory, byType, close, create (+14 more)

### Community 24 - "EOM Tracker"
Cohesion: 0.18
Nodes (10): Decision tree: TUI vs. script, EOM Tracker, Step 1: Launch the TUI, Step 2: Navigate the TUI, Step 3: Create items, Step 4: Update item status, Step 5: Link a git branch to a story, Step 6: Edit or delete items (+2 more)

### Community 30 - "EOM Tracker — TUI Keybindings Reference"
Cohesion: 0.25
Nodes (7): App, CRUD, EOM Tracker — TUI Keybindings Reference, Navigation, Pane layout, Status & Linking, Status & priority colour codes

### Community 32 - "ai_service.dart"
Cohesion: 0.12
Nodes (16): clarify_operation.dart, epistemic_service.dart, AiResponse, AiService, _clarify, _epistemic, _getProvider, intent (+8 more)

### Community 33 - "_"
Cohesion: 0.15
Nodes (14): double?, epistemic_node.dart, _, confidenceDelta, content, deeperContent, disambiguate, EpistemicOperation (+6 more)

### Community 34 - "llm_provider.dart"
Cohesion: 0.33
Nodes (8): AnthropicProvider, GeminiProvider, generate, LlmProvider, LocalProvider, OpenAiProvider, package:http/http.dart, settings_service.dart

## Knowledge Gaps
- **338 isolated node(s):** `path`, `fs`, `DB_PATH`, `name`, `version` (+333 more)
  These have ≤1 connection - possible missing edges or undocumented components.
- **3 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `EpistemicService` connect `ai_service.dart` to `clarify_operation.dart`, `epistemic_service.dart`?**
  _High betweenness centrality (0.031) - this node is a cross-community bridge._
- **Why does `CognitiveIntent` connect `intent_button.dart` to `ai_service.dart`, `home_screen.dart`?**
  _High betweenness centrality (0.015) - this node is a cross-community bridge._
- **What connects `path`, `fs`, `DB_PATH` to the rest of the system?**
  _338 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `intent_button.dart` be split into smaller, more focused modules?**
  _Cohesion score 0.053426248548199766 - nodes in this community are weakly interconnected._
- **Should `history_screen.dart` be split into smaller, more focused modules?**
  _Cohesion score 0.10526315789473684 - nodes in this community are weakly interconnected._
- **Should `GeneratedPluginRegistrant.swift` be split into smaller, more focused modules?**
  _Cohesion score 0.05807200929152149 - nodes in this community are weakly interconnected._
- **Should `home_screen.dart` be split into smaller, more focused modules?**
  _Cohesion score 0.08 - nodes in this community are weakly interconnected._
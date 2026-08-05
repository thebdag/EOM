# Graph Report - EOM  (2026-08-02)

## Corpus Check
- 47 files · ~17,152 words
- Verdict: corpus is large enough that graph structure adds value.

## Summary
- 341 nodes · 365 edges · 32 communities (26 shown, 6 thin omitted)
- Extraction: 100% EXTRACTED · 0% INFERRED · 0% AMBIGUOUS · INFERRED: 1 edges (avg confidence: 0.8)
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `1fead9a0`
- Run `git rev-parse HEAD` and compare to check if the graph is stale.
- Run `graphify update .` after code changes (no API cost).

## Community Hubs (Navigation)
- intent_button.dart
- ai_service.dart
- GeneratedPluginRegistrant.swift
- home_screen.dart
- settings_service.dart
- settings_screen.dart
- eom_colors.dart
- AppDelegate
- main.dart
- manifest.json
- Unreleased
- response_card.dart
- options
- history_service.dart
- thought_node.dart
- AGENTS.md
- EOM Development Workflow & Standards
- widget_test.dart
- [Unreleased] - 2026-05-11
- EOM - AI Agent Design Specification (`design_spec.md`)
- Learnings
- dependencies
- MainActivity
- eom
- REPOMAP.md
- LaunchImage.imageset/README.md
- EOM
- 0001-local-means-litellm-gateway.md

## God Nodes (most connected - your core abstractions)
1. `EOM Development Workflow & Standards` - 7 edges
2. `AppDelegate` - 5 edges
3. `LlmProvider` - 5 edges
4. `Unreleased` - 5 edges
5. `EOM - AI Agent Design Specification (`design_spec.md`)` - 5 edges
6. `CognitiveIntent` - 4 edges
7. `_ResponseCardState` - 4 edges
8. `FlutterMacOS` - 4 edges
9. `AppDelegate` - 4 edges
10. `lmstudio` - 4 edges

## Surprising Connections (you probably didn't know these)
- `HomeScreen` --inherits--> `StatefulWidget`  [EXTRACTED]
  lib/screens/home_screen.dart → None  _Bridges community 5 → community 3_
- `ResponseCard` --inherits--> `StatefulWidget`  [EXTRACTED]
  lib/widgets/response_card.dart → None  _Bridges community 5 → community 11_

## Import Cycles
- None detected.

## Communities (32 total, 6 thin omitted)

### Community 0 - "intent_button.dart"
Cohesion: 0.10
Nodes (18): Color, eom_colors.dart, IconData, CognitiveIntent, color, description, icon, label (+10 more)

### Community 1 - "ai_service.dart"
Cohesion: 0.09
Nodes (24): dart:convert, AiResponse, AiService, _getProvider, intent, _parseNode, process, text (+16 more)

### Community 2 - "GeneratedPluginRegistrant.swift"
Cohesion: 0.09
Nodes (17): Cocoa, Flutter, FlutterMacOS, FlutterPluginRegistry, FlutterSceneDelegate, Foundation, SceneDelegate, RunnerTests (+9 more)

### Community 3 - "home_screen.dart"
Cohesion: 0.08
Nodes (26): history_screen.dart, _activeIntent, _aiService, build, _buildInputArea, _buildIntentBar, _buildProcessingIndicator, _buildTopBar (+18 more)

### Community 4 - "settings_service.dart"
Cohesion: 0.07
Nodes (27): anthropicKey, defaultGatewayOrigin, defaultModelAlias, geminiKey, init, _kAnthropicKey, _kGeminiKey, _kLocalApiKey (+19 more)

### Community 5 - "settings_screen.dart"
Cohesion: 0.07
Nodes (28): build, _conversations, createState, _formatDate, HistoryScreen, _HistoryScreenState, _historyService, initState (+20 more)

### Community 6 - "eom_colors.dart"
Cohesion: 0.10
Nodes (19): accent, accentMuted, accentSubtle, background, divider, EomColors, error, intentHover (+11 more)

### Community 7 - "AppDelegate"
Cohesion: 0.16
Nodes (10): Any, FlutterAppDelegate, FlutterImplicitEngineBridge, FlutterImplicitEngineDelegate, AppDelegate, Bool, AppDelegate, Bool (+2 more)

### Community 8 - "main.dart"
Cohesion: 0.15
Nodes (12): build, EomApp, init, main, IntentButton, ThoughtTreeView, package:flutter/services.dart, screens/home_screen.dart (+4 more)

### Community 9 - "manifest.json"
Cohesion: 0.18
Nodes (10): background_color, description, display, icons, name, orientation, prefer_related_applications, short_name (+2 more)

### Community 10 - "Unreleased"
Cohesion: 0.18
Nodes (10): [1.0.0+1] — 2026-05-11, Added, Added, Added / Changed / Fixed / Removed, Changed, Changelog (Dev Log), Added, Changed (+2 more)

### Community 11 - "response_card.dart"
Cohesion: 0.12
Nodes (16): Animation, AnimationController, accentColor, build, _buildRichText, _controller, createState, dispose (+8 more)

### Community 12 - "options"
Cohesion: 0.20
Nodes (9): name, npm, options, baseURL, chunkTimeout, timeout, provider, lmstudio (+1 more)

### Community 13 - "history_service.dart"
Cohesion: 0.22
Nodes (8): _boxName, clearHistory, getConversations, HistoryService, init, saveConversation, package:hive_flutter/hive_flutter.dart, static const String

### Community 14 - "thought_node.dart"
Cohesion: 0.20
Nodes (9): bool get, children, fromJson, isExpanded, isLeaf, label, ThoughtNode, toJson (+1 more)

### Community 15 - "AGENTS.md"
Cohesion: 0.25
Nodes (6): 1. Orient yourself first, 2. Use the repomap (`docs/REPOMAP.md`), 3. Check the graphify graph content, 4. Coding standards (summary — full version in CODING-STANDARDS.md), 5. Pre-PR checklist (do this LAST, every time), 6. Commit & PR conventions

### Community 16 - "EOM Development Workflow & Standards"
Cohesion: 0.25
Nodes (7): Directory Overview, EOM Development Workflow & Standards, Step 1: Context & Navigation, Step 2: Architecture & Service Layer, Step 3: UI Development & Design System, Step 4: Stability & Error Handling, Step 5: Quality & Formatting

### Community 17 - "widget_test.dart"
Cohesion: 0.20
Nodes (7): package:eom/main.dart, package:eom/models/thought_node.dart, package:eom/services/settings_service.dart, package:flutter_test/flutter_test.dart, main, main, main

### Community 18 - "[Unreleased] - 2026-05-11"
Cohesion: 0.33
Nodes (5): Changelog, Added, Changed, Fixed, [Unreleased] - 2026-05-11

### Community 19 - "EOM - AI Agent Design Specification (`design_spec.md`)"
Cohesion: 0.33
Nodes (5): 1. Core Design Philosophy, 2. Visual Identity & Styling (Flutter / Material 3 / Cupertino), 3. Component Guidelines, 4. Animation & Motion, EOM - AI Agent Design Specification (`design_spec.md`)

### Community 20 - "Learnings"
Cohesion: 0.40
Nodes (4): Best Practices, Bugs To Avoid, Gotchas, Learnings

### Community 21 - "dependencies"
Cohesion: 0.50
Nodes (3): opencode-auto-resume, dependencies, opencode-auto-resume

## Knowledge Gaps
- **184 isolated node(s):** `main`, `init`, `build`, `label`, `icon` (+179 more)
  These have ≤1 connection - possible missing edges or undocumented components.
- **6 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `CognitiveIntent` connect `intent_button.dart` to `ai_service.dart`, `home_screen.dart`?**
  _High betweenness centrality (0.014) - this node is a cross-community bridge._
- **Why does `ThoughtNode` connect `thought_node.dart` to `ai_service.dart`?**
  _High betweenness centrality (0.011) - this node is a cross-community bridge._
- **Why does `AppDelegate` connect `AppDelegate` to `GeneratedPluginRegistrant.swift`?**
  _High betweenness centrality (0.005) - this node is a cross-community bridge._
- **What connects `main`, `init`, `build` to the rest of the system?**
  _184 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `intent_button.dart` be split into smaller, more focused modules?**
  _Cohesion score 0.10476190476190476 - nodes in this community are weakly interconnected._
- **Should `ai_service.dart` be split into smaller, more focused modules?**
  _Cohesion score 0.09116809116809117 - nodes in this community are weakly interconnected._
- **Should `GeneratedPluginRegistrant.swift` be split into smaller, more focused modules?**
  _Cohesion score 0.09116809116809117 - nodes in this community are weakly interconnected._
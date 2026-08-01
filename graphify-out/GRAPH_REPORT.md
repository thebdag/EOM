# Graph Report - workspace  (2026-08-01)

## Corpus Check
- 39 files · ~13,446 words
- Verdict: corpus is large enough that graph structure adds value.

## Summary
- 295 nodes · 324 edges · 27 communities (23 shown, 4 thin omitted)
- Extraction: 100% EXTRACTED · 0% INFERRED · 0% AMBIGUOUS · INFERRED: 1 edges (avg confidence: 0.8)
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `c8840e15`
- Run `git rev-parse HEAD` and compare to check if the graph is stale.
- Run `graphify update .` after code changes (no API cost).

## Community Hubs (Navigation)
- ai_service.dart
- settings_service.dart
- GeneratedPluginRegistrant.swift
- home_screen.dart
- response_card.dart
- intent_button.dart
- eom_colors.dart
- settings_screen.dart
- AppDelegate
- main.dart
- history_screen.dart
- options
- history_service.dart
- llm_provider.dart
- EOM Development Workflow & Standards
- [Unreleased] - 2026-05-11
- EOM - AI Agent Design Specification (`design_spec.md`)
- dependencies
- thought_node_test.dart
- MainActivity
- eom
- REPOMAP.md
- LaunchImage.imageset/README.md

## God Nodes (most connected - your core abstractions)
1. `EOM Development Workflow & Standards` - 7 edges
2. `AppDelegate` - 5 edges
3. `LlmProvider` - 5 edges
4. `EOM - AI Agent Design Specification (`design_spec.md`)` - 5 edges
5. `CognitiveIntent` - 4 edges
6. `_ResponseCardState` - 4 edges
7. `FlutterMacOS` - 4 edges
8. `AppDelegate` - 4 edges
9. `lmstudio` - 4 edges
10. `options` - 4 edges

## Surprising Connections (you probably didn't know these)
- `HistoryScreen` --inherits--> `StatefulWidget`  [EXTRACTED]
  lib/screens/history_screen.dart → None  _Bridges community 10 → community 4_
- `SettingsScreen` --inherits--> `StatefulWidget`  [EXTRACTED]
  lib/screens/settings_screen.dart → None  _Bridges community 4 → community 7_

## Import Cycles
- None detected.

## Communities (27 total, 4 thin omitted)

### Community 0 - "ai_service.dart"
Cohesion: 0.08
Nodes (25): bool get, dart:convert, children, fromJson, isExpanded, isLeaf, label, ThoughtNode (+17 more)

### Community 1 - "settings_service.dart"
Cohesion: 0.07
Nodes (27): activeProvider, anthropicKey, geminiKey, init, _kAnthropicKey, _kGeminiKey, _kOllamaApiKey, _kOllamaHost (+19 more)

### Community 2 - "GeneratedPluginRegistrant.swift"
Cohesion: 0.09
Nodes (17): Cocoa, Flutter, FlutterMacOS, FlutterPluginRegistry, FlutterSceneDelegate, Foundation, SceneDelegate, RunnerTests (+9 more)

### Community 3 - "home_screen.dart"
Cohesion: 0.08
Nodes (24): history_screen.dart, _activeIntent, _aiService, build, _buildInputArea, _buildIntentBar, _buildProcessingIndicator, _buildTopBar (+16 more)

### Community 4 - "response_card.dart"
Cohesion: 0.10
Nodes (20): Animation, AnimationController, HomeScreen, _HomeScreenState, accentColor, build, _buildRichText, _controller (+12 more)

### Community 5 - "intent_button.dart"
Cohesion: 0.10
Nodes (18): Color, eom_colors.dart, IconData, CognitiveIntent, color, description, icon, label (+10 more)

### Community 6 - "eom_colors.dart"
Cohesion: 0.10
Nodes (19): accent, accentMuted, accentSubtle, background, divider, EomColors, error, intentHover (+11 more)

### Community 7 - "settings_screen.dart"
Cohesion: 0.12
Nodes (17): _activeProvider, _anthropicController, build, _buildDropdown, _buildSectionTitle, _buildTextField, createState, dispose (+9 more)

### Community 8 - "AppDelegate"
Cohesion: 0.16
Nodes (10): Any, FlutterAppDelegate, FlutterImplicitEngineBridge, FlutterImplicitEngineDelegate, AppDelegate, Bool, AppDelegate, Bool (+2 more)

### Community 9 - "main.dart"
Cohesion: 0.15
Nodes (12): build, EomApp, init, main, IntentButton, ThoughtTreeView, package:flutter/services.dart, screens/home_screen.dart (+4 more)

### Community 10 - "history_screen.dart"
Cohesion: 0.22
Nodes (9): build, _conversations, createState, _formatDate, HistoryScreen, _HistoryScreenState, _historyService, initState (+1 more)

### Community 11 - "options"
Cohesion: 0.20
Nodes (9): name, npm, options, baseURL, chunkTimeout, timeout, provider, lmstudio (+1 more)

### Community 12 - "history_service.dart"
Cohesion: 0.22
Nodes (8): _boxName, clearHistory, getConversations, HistoryService, init, saveConversation, package:hive_flutter/hive_flutter.dart, static const String

### Community 13 - "llm_provider.dart"
Cohesion: 0.33
Nodes (8): AnthropicProvider, GeminiProvider, generate, LlmProvider, OllamaProvider, OpenAiProvider, package:http/http.dart, settings_service.dart

### Community 14 - "EOM Development Workflow & Standards"
Cohesion: 0.25
Nodes (7): Directory Overview, EOM Development Workflow & Standards, Step 1: Context & Navigation, Step 2: Architecture & Service Layer, Step 3: UI Development & Design System, Step 4: Stability & Error Handling, Step 5: Quality & Formatting

### Community 15 - "[Unreleased] - 2026-05-11"
Cohesion: 0.33
Nodes (5): Added, Changed, Changelog, Fixed, [Unreleased] - 2026-05-11

### Community 16 - "EOM - AI Agent Design Specification (`design_spec.md`)"
Cohesion: 0.33
Nodes (5): 1. Core Design Philosophy, 2. Visual Identity & Styling (Flutter / Material 3 / Cupertino), 3. Component Guidelines, 4. Animation & Motion, EOM - AI Agent Design Specification (`design_spec.md`)

### Community 17 - "dependencies"
Cohesion: 0.50
Nodes (3): opencode-auto-resume, dependencies, opencode-auto-resume

### Community 18 - "thought_node_test.dart"
Cohesion: 0.50
Nodes (3): package:eom/models/thought_node.dart, package:flutter_test/flutter_test.dart, main

## Knowledge Gaps
- **154 isolated node(s):** `main`, `init`, `build`, `label`, `icon` (+149 more)
  These have ≤1 connection - possible missing edges or undocumented components.
- **4 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `CognitiveIntent` connect `intent_button.dart` to `ai_service.dart`, `home_screen.dart`?**
  _High betweenness centrality (0.018) - this node is a cross-community bridge._
- **Why does `AppDelegate` connect `AppDelegate` to `GeneratedPluginRegistrant.swift`?**
  _High betweenness centrality (0.007) - this node is a cross-community bridge._
- **What connects `main`, `init`, `build` to the rest of the system?**
  _154 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `ai_service.dart` be split into smaller, more focused modules?**
  _Cohesion score 0.07671957671957672 - nodes in this community are weakly interconnected._
- **Should `settings_service.dart` be split into smaller, more focused modules?**
  _Cohesion score 0.07142857142857142 - nodes in this community are weakly interconnected._
- **Should `GeneratedPluginRegistrant.swift` be split into smaller, more focused modules?**
  _Cohesion score 0.09116809116809117 - nodes in this community are weakly interconnected._
- **Should `home_screen.dart` be split into smaller, more focused modules?**
  _Cohesion score 0.08 - nodes in this community are weakly interconnected._
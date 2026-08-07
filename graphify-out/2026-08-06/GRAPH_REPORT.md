# Graph Report - EOM  (2026-08-06)

## Corpus Check
- 124 files · ~64,443 words
- Verdict: corpus is large enough that graph structure adds value.

## Summary
- 1267 nodes · 1568 edges · 85 communities (82 shown, 3 thin omitted)
- Extraction: 100% EXTRACTED · 0% INFERRED · 0% AMBIGUOUS · INFERRED: 6 edges (avg confidence: 0.55)
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `bd8988ba`
- Run `git rev-parse HEAD` and compare to check if the graph is stale.
- Run `graphify update .` after code changes (no API cost).

## Community Hubs (Navigation)
- epistemic_export_service.dart
- ux_eom_s23_returning_user_test.dart
- GeneratedPluginRegistrant.swift
- home_screen.dart
- settings_service.dart
- settings_screen.dart
- eom_colors.dart
- ui.js
- response_card.dart
- manifest.json
- Unreleased
- Tables
- options
- tracker/package.json
- epistemic_node.dart
- AGENTS.md
- EOM Development Workflow & Standards
- epistemic_intent_service_test.dart
- [Unreleased] - 2026-05-11
- EOM — A Quiet Vault for the Mind
- Learnings
- scripts
- MainActivity
- sqlite_epistemic_graph_store.dart
- EOM Tracker
- LaunchImage.imageset/README.md
- EOM Tracker — TUI Keybindings Reference
- 0001-local-means-litellm-gateway.md
- ai_service.dart
- epistemic_operation.dart
- epistemic_maturity.dart
- install-hooks.js
- epistemic_relationship.dart
- intent.dart
- beta_scorer.dart
- Delta updates refine, never overwrite (EOM-T12)
- EOM Beta Pressure Tests
- confidence_event.dart
- epistemic_intent_service.dart
- UX Heuristics
- epistemic_query_result.dart
- epistemic_gap.dart
- in_memory_epistemic_store.dart
- package:eom/models/epistemic_node.dart
- epistemic_gap_test.dart
- sqlite_epistemic_graph_store_test.dart
- helpers/in_memory_epistemic_store.dart
- List
- package:flutter_test/flutter_test.dart
- llm_provider.dart
- epistemic_export_test.dart
- epistemic_graph_view.dart
- conversation.dart
- ux_eom_s21_first_run_test.dart
- package:flutter/material.dart
- beta_runner.dart
- beta_reporter.dart
- beta_loader.dart
- scorer_test.dart
- beta_provider.dart
- package:eom/models/intent.dart
- epistemic_gap_service.dart
- analyze_test.dart
- intent_config.dart
- Epistemic Alignment Scoring Rubric (EOM-T63)
- intent_error.dart
- UX Tester
- EOM Beta — Epistemic Alignment Pressure Tests (EOM-E5)
- ux_eom_e4_quick_wins_test.dart
- thought_tree_view.dart
- intent_button.dart
- history_screen.dart
- dart:io
- ux_eom_s22_session_ux_test.dart
- package:eom/services/settings_service.dart
- home_screen_test.dart
- main.dart
- _ResponseCardState
- ux_eom_s21_live_provider_test.dart
- ux_eom_s22_live_provider_test.dart
- InMemoryStore

## God Nodes (most connected - your core abstractions)
1. `Unreleased` - 15 edges
2. `LlmProvider` - 13 edges
3. `EOM Tracker` - 11 edges
4. `initDb()` - 10 edges
5. `Stories` - 10 edges
6. `EOM — A Quiet Vault for the Mind` - 10 edges
7. `InMemoryStore` - 9 edges
8. `UX Heuristics` - 9 edges
9. `Subtasks` - 8 edges
10. `scripts` - 8 edges

## Surprising Connections (you probably didn't know these)
- `_FakeHistory` --inherits--> `HistoryService`  [EXTRACTED]
  test/ux_eom_e4_quick_wins_test.dart → lib/services/history_service.dart
- `_NoopHistory` --inherits--> `HistoryService`  [EXTRACTED]
  test/ux_eom_s22_session_ux_test.dart → lib/services/history_service.dart
- `_FakeHistory` --inherits--> `HistoryService`  [EXTRACTED]
  test/ux_eom_s23_returning_user_test.dart → lib/services/history_service.dart
- `_FakeProvider` --implements--> `LlmProvider`  [EXTRACTED]
  test/ai_service_test.dart → lib/services/llm_provider.dart
- `_MissingKeyProvider` --implements--> `LlmProvider`  [EXTRACTED]
  test/ai_service_test.dart → lib/services/llm_provider.dart

## Import Cycles
- None detected.

## Communities (85 total, 3 thin omitted)

### Community 0 - "epistemic_export_service.dart"
Cohesion: 0.17
Nodes (12): EpistemicExporter, EpistemicExportService, exportVersion, _snippet, _store, toJson, toJsonGraph, toMarkdown (+4 more)

### Community 1 - "ux_eom_s23_returning_user_test.dart"
Cohesion: 0.14
Nodes (13): calls, clearCalls, clearHistory, generate, getConversations, historyLens, items, live (+5 more)

### Community 2 - "GeneratedPluginRegistrant.swift"
Cohesion: 0.06
Nodes (28): Any, Cocoa, Flutter, FlutterAppDelegate, FlutterImplicitEngineBridge, FlutterImplicitEngineDelegate, FlutterMacOS, FlutterPluginRegistry (+20 more)

### Community 3 - "home_screen.dart"
Cohesion: 0.05
Nodes (38): Future, history_screen.dart, _activeIntent, aiService, build, _buildInputArea, _buildIntentBar, _buildProcessingIndicator (+30 more)

### Community 4 - "settings_service.dart"
Cohesion: 0.06
Nodes (33): _boxName, clearHistory, getConversations, init, saveConversation, anthropicKey, defaultGatewayOrigin, defaultModelAlias (+25 more)

### Community 5 - "settings_screen.dart"
Cohesion: 0.11
Nodes (18): _activeProvider, _allowPop, _anthropicController, build, _buildDropdown, _buildSectionTitle, _buildTextField, createState (+10 more)

### Community 6 - "eom_colors.dart"
Cohesion: 0.10
Nodes (19): accent, accentMuted, accentSubtle, background, divider, EomColors, error, intentHover (+11 more)

### Community 7 - "ui.js"
Cohesion: 0.06
Nodes (53): findSubtask(), { initDb, Epics, Stories, Subtasks, Comments }, main(), Comments, DB_PATH, Epics, fs, get() (+45 more)

### Community 8 - "response_card.dart"
Cohesion: 0.12
Nodes (15): Animation, AnimationController, accentColor, build, _buildRichText, _controller, createState, dispose (+7 more)

### Community 9 - "manifest.json"
Cohesion: 0.18
Nodes (10): background_color, description, display, icons, name, orientation, prefer_related_applications, short_name (+2 more)

### Community 10 - "Unreleased"
Cohesion: 0.10
Nodes (20): [1.0.0+1] — 2026-05-11, Added, Added, Added, Added, Added, Added / Changed / Fixed / Removed, Changed (+12 more)

### Community 11 - "Tables"
Cohesion: 0.13
Nodes (14): Comments (subtask comments), EOM Tracker — Database Schema Reference, `epics`, Epics, JS Helper API (`db.js`), Key formats, `meta`, Resolving a key to an id (+6 more)

### Community 12 - "options"
Cohesion: 0.20
Nodes (9): name, npm, options, baseURL, chunkTimeout, timeout, provider, lmstudio (+1 more)

### Community 13 - "tracker/package.json"
Cohesion: 0.14
Nodes (13): blessed, dependencies, blessed, sql.js, description, main, name, scripts (+5 more)

### Community 14 - "epistemic_node.dart"
Cohesion: 0.08
Nodes (25): category, confidence, content, copyWith, createdAt, epistemicCategoryFromString, EpistemicNode, EpistemicNodeType (+17 more)

### Community 15 - "AGENTS.md"
Cohesion: 0.15
Nodes (11): 1. Orient yourself first, 2. Use the repomap (`docs/REPOMAP.md`), 3. Check the graphify graph content, 4. Coding standards (summary — full version in CODING-STANDARDS.md), 5. Update the issue tracker (`dev/tracker/`), 6. Pre-PR checklist (do this LAST, every time), 7. Commit & PR conventions, Path 1 — commit message (automatic) (+3 more)

### Community 16 - "EOM Development Workflow & Standards"
Cohesion: 0.25
Nodes (7): Directory Overview, EOM Development Workflow & Standards, Step 1: Context & Navigation, Step 2: Architecture & Service Layer, Step 3: UI Development & Design System, Step 4: Stability & Error Handling, Step 5: Quality & Formatting

### Community 17 - "epistemic_intent_service_test.dart"
Cohesion: 0.20
Nodes (8): EpistemicIntentService, package:eom/models/epistemic_operation.dart, package:eom/services/epistemic_intent_service.dart, main, seedNode, service, store, main

### Community 18 - "[Unreleased] - 2026-05-11"
Cohesion: 0.22
Nodes (8): Added, Changed, Changed, Changelog, Added, Changed, Fixed, [Unreleased] - 2026-05-11

### Community 19 - "EOM — A Quiet Vault for the Mind"
Cohesion: 0.05
Nodes (33): EOM, Language, 1. Core Design Philosophy, 2. Visual Identity & Styling (Flutter / Material 3 / Cupertino), 3. Component Guidelines, 4. Animation & Motion, EOM - AI Agent Design Specification (`design_spec.md`), Repository Map (+25 more)

### Community 20 - "Learnings"
Cohesion: 0.40
Nodes (4): Best Practices, Bugs To Avoid, Gotchas, Learnings

### Community 21 - "scripts"
Cohesion: 0.15
Nodes (12): opencode-auto-resume, dependencies, opencode-auto-resume, name, scripts, comment, done, install-hooks (+4 more)

### Community 23 - "sqlite_epistemic_graph_store.dart"
Cohesion: 0.05
Nodes (37): dart:async, Database?, addRelationship, all, allRelationships, byCategory, byType, cleaned (+29 more)

### Community 24 - "EOM Tracker"
Cohesion: 0.17
Nodes (11): Decision tree: which update path to use, EOM Tracker, Step 1: Launch the TUI, Step 2: Navigate the TUI, Step 3: Create items, Step 4: Update item status, Step 4b: Leave a comment on a subtask, Step 5: Link a git branch to a story (+3 more)

### Community 30 - "EOM Tracker — TUI Keybindings Reference"
Cohesion: 0.22
Nodes (8): App, Comments (subtasks only), CRUD, EOM Tracker — TUI Keybindings Reference, Navigation, Pane layout, Status & Linking, Status & priority colour codes

### Community 32 - "ai_service.dart"
Cohesion: 0.08
Nodes (24): intent_config.dart, intent_error.dart, AiResponse, AiService, defaultContext, depth, epistemicMarker, escape (+16 more)

### Community 33 - "epistemic_operation.dart"
Cohesion: 0.06
Nodes (37): actionable, ActOperation, category, clarified, ClarifyOperation, CompressOperation, confidence, conflictsWith (+29 more)

### Community 34 - "epistemic_maturity.dart"
Cohesion: 0.11
Nodes (17): computeMaturityByDomain, domain, EpistemicMaturity, highConfidence, highs, highThreshold, kMaturityHighThreshold, kMaturityUncertainThreshold (+9 more)

### Community 35 - "install-hooks.js"
Cohesion: 0.29
Nodes (6): fs, hooks, hooksDest, hooksSource, path, repoRoot

### Community 36 - "epistemic_relationship.dart"
Cohesion: 0.10
Nodes (19): camel, copyWith, createdAt, EpistemicRelationship, EpistemicRelationshipType, epistemicRelationshipTypeFromString, epistemicRelationshipTypeTryParse, fromJson (+11 more)

### Community 37 - "intent.dart"
Cohesion: 0.25
Nodes (7): Color, IconData, color, description, icon, label, ../theme/eom_colors.dart

### Community 38 - "beta_scorer.dart"
Cohesion: 0.04
Nodes (52): 0, 1, 2, c, cat, confidence, criterion, excerpt (+44 more)

### Community 39 - "Delta updates refine, never overwrite (EOM-T12)"
Cohesion: 0.50
Nodes (3): Consequences, Decision, Delta updates refine, never overwrite (EOM-T12)

### Community 40 - "EOM Beta Pressure Tests"
Cohesion: 0.20
Nodes (9): Decision tree, EOM Beta Pressure Tests, Guards and drift safety, Provider config (env vars), Step 1: Capture a run, Step 2: Score the run and emit the report, Step 3: Read the report, Step 4: Add or edit prompts (+1 more)

### Community 41 - "confidence_event.dart"
Cohesion: 0.10
Nodes (19): double get, absDelta, confidence, ConfidenceDrift, ConfidenceEvent, delta, eventCount, firstRecordedAt (+11 more)

### Community 42 - "epistemic_intent_service.dart"
Cohesion: 0.11
Nodes (17): epistemic_gap_service.dart, _detectGaps, _gapDetector, _hasOverlap, lastDetectedGaps, _lastGaps, _linkKeywords, _parseCategory (+9 more)

### Community 43 - "UX Heuristics"
Cohesion: 0.20
Nodes (9): Affordances, Cognitive load, Empty states, Error states, Flow continuity, Navigation, Tone, UX Heuristics (+1 more)

### Community 44 - "epistemic_query_result.dart"
Cohesion: 0.22
Nodes (8): epistemic_node.dart, epistemic_relationship.dart, edges, EpistemicQueryResult, isEmpty, nodes, rootId, toString

### Community 45 - "epistemic_gap.dart"
Cohesion: 0.18
Nodes (10): int get, concept, EpistemicGap, EpistemicGapKind, hashCode, kind, nodeId, operator (+2 more)

### Community 46 - "in_memory_epistemic_store.dart"
Cohesion: 0.14
Nodes (13): package:eom/models/confidence_event.dart, addRelationship, all, allRelationships, byType, confidenceEvents, confidenceHistory, create (+5 more)

### Community 47 - "package:eom/models/epistemic_node.dart"
Cohesion: 0.33
Nodes (4): ArgumentError, package:eom/models/epistemic_node.dart, main, main

### Community 48 - "epistemic_gap_test.dart"
Cohesion: 0.29
Nodes (6): package:eom/models/epistemic_gap.dart, package:eom/services/epistemic_gap_service.dart, main, node, service, store

### Community 49 - "sqlite_epistemic_graph_store_test.dart"
Cohesion: 0.17
Nodes (10): package:eom/models/epistemic_relationship.dart, package:eom/services/sqlite_epistemic_graph_store.dart, package:sqflite_common_ffi/sqflite_ffi.dart, edge, main, node, main, main (+2 more)

### Community 50 - "helpers/in_memory_epistemic_store.dart"
Cohesion: 0.40
Nodes (4): helpers/in_memory_epistemic_store.dart, package:eom/models/epistemic_maturity.dart, main, node

### Community 51 - "List"
Cohesion: 0.20
Nodes (9): bool get, List, children, fromJson, isExpanded, isLeaf, label, toJson (+1 more)

### Community 52 - "package:flutter_test/flutter_test.dart"
Cohesion: 0.29
Nodes (5): package:eom/main.dart, package:eom/services/intent_error.dart, package:flutter_test/flutter_test.dart, main, main

### Community 53 - "llm_provider.dart"
Cohesion: 0.06
Nodes (40): Exception, fallback, fromString, id, label, LlmProviderKind, AnthropicProvider, assistant (+32 more)

### Community 54 - "epistemic_export_test.dart"
Cohesion: 0.29
Nodes (6): dart:convert, package:eom/services/epistemic_export_service.dart, exporter, main, node, store

### Community 55 - "epistemic_graph_view.dart"
Cohesion: 0.11
Nodes (17): CustomPainter, dart:math, build, c, confidenceColor, _depths, _EpistemicGraphPainter, graph (+9 more)

### Community 56 - "conversation.dart"
Cohesion: 0.22
Nodes (8): DateTime, Conversation, fromMap, initialInput, intent, response, timestamp, toMap

### Community 57 - "ux_eom_s21_first_run_test.dart"
Cohesion: 0.17
Nodes (11): package:eom/models/llm_provider_kind.dart, package:eom/theme/eom_theme.dart, package:shared_preferences/shared_preferences.dart, main, fieldByHint, host, live, main (+3 more)

### Community 58 - "package:flutter/material.dart"
Cohesion: 0.17
Nodes (10): eom_colors.dart, EomTheme, Opacity, package:eom/models/epistemic_query_result.dart, package:eom/theme/eom_colors.dart, package:eom/widgets/epistemic_graph_view.dart, package:flutter/material.dart, graphOf (+2 more)

### Community 59 - "beta_runner.dart"
Cohesion: 0.05
Nodes (38): package:eom/models/thought_node.dart, CapturedResponse, depth, error, escape, _extractFirstJsonObject, inString, intent (+30 more)

### Community 60 - "beta_reporter.dart"
Cohesion: 0.06
Nodes (30): aligned, buf, buildReport, byCrit, bySev, dir, fail, failCount (+22 more)

### Community 61 - "beta_loader.dart"
Cohesion: 0.09
Nodes (21): all, allowsEmptyRelationships, category, complexity, confidenceRange, edgeType, fromJson, id (+13 more)

### Community 62 - "scorer_test.dart"
Cohesion: 0.11
Nodes (18): String? edgeType,
  String, Expected, edgeType, error, expected, id, input, intent (+10 more)

### Community 63 - "beta_provider.dart"
Cohesion: 0.11
Nodes (17): package:http/http.dart, String get, apiKey, BetaConfig, betaEpistemicMarker, BetaProviderKind, buildSystemPrompt, callProvider (+9 more)

### Community 64 - "package:eom/models/intent.dart"
Cohesion: 0.40
Nodes (4): beta/beta_provider.dart, package:eom/models/intent.dart, package:eom/services/intent_config.dart, main

### Community 65 - "epistemic_gap_service.dart"
Cohesion: 0.22
Nodes (9): detectGaps, EpistemicGapDetector, EpistemicGapService, explicitGaps, _isCovered, _store, ../models/epistemic_gap.dart, ../models/epistemic_node.dart (+1 more)

### Community 66 - "analyze_test.dart"
Cohesion: 0.17
Nodes (11): beta_loader.dart, beta_reporter.dart, beta_scorer.dart, File, _capturedFromJson, derived, dirs, _latestRun (+3 more)

### Community 67 - "intent_config.dart"
Cohesion: 0.22
Nodes (8): CognitiveIntent, buildPrompt, _categoryValues, CognitiveIntentOps, parseOperation, producesTree, ../models/epistemic_operation.dart, static const

### Community 68 - "Epistemic Alignment Scoring Rubric (EOM-T63)"
Cohesion: 0.20
Nodes (9): 1. Criteria, 2. Scale, 3. Weights, 4. Pass / fail thresholds, 5. Finding severity (EOM-T70), 6. Intent-specific notes, 7. Roll-up, Epistemic Alignment Scoring Rubric (EOM-T63) (+1 more)

### Community 69 - "intent_error.dart"
Cohesion: 0.25
Nodes (7): from, IntentError, _isMissingCredential, _isProviderConfig, _isProviderFailure, message, offerSettings

### Community 70 - "UX Tester"
Cohesion: 0.29
Nodes (6): Decision tree, Step 1: Orient, Step 2: Walk, Step 3: Find, Step 4: Prioritize, UX Tester

### Community 71 - "EOM Beta — Epistemic Alignment Pressure Tests (EOM-E5)"
Cohesion: 0.22
Nodes (8): Adding prompts, Drift safety, EOM Beta — Epistemic Alignment Pressure Tests (EOM-E5), Guards, Layout, Prompt metadata schema (EOM-T66), Running a pressure test, Why the runner lives under `test/`

### Community 72 - "ux_eom_e4_quick_wins_test.dart"
Cohesion: 0.14
Nodes (12): HistoryService, package:eom/models/conversation.dart, package:eom/screens/history_screen.dart, package:eom/widgets/intent_button.dart, main, clearCalls, clearHistory, _FakeHistory (+4 more)

### Community 73 - "thought_tree_view.dart"
Cohesion: 0.15
Nodes (12): EomApp, ThoughtNode, EpistemicGraphView, IntentButton, build, _buildNode, _exportMap, root (+4 more)

### Community 74 - "intent_button.dart"
Cohesion: 0.25
Nodes (7): build, intent, isLoading, isSelected, onPressed, ../models/intent.dart, VoidCallback?

### Community 75 - "history_screen.dart"
Cohesion: 0.20
Nodes (10): build, _confirmClear, _conversations, createState, _formatDate, HistoryScreen, _HistoryScreenState, historyService (+2 more)

### Community 76 - "dart:io"
Cohesion: 0.18
Nodes (9): beta_provider.dart, beta_runner.dart, dart:io, Directory, package:eom/services/history_service.dart, package:hive_flutter/hive_flutter.dart, main, main (+1 more)

### Community 77 - "ux_eom_s22_session_ux_test.dart"
Cohesion: 0.18
Nodes (10): package:eom/widgets/response_card.dart, generate, live, main, payload, pumpHome, richTextContaining, saveConversation (+2 more)

### Community 78 - "package:eom/services/settings_service.dart"
Cohesion: 0.22
Nodes (9): _buildTopBar, _openSettings, MaterialPageRoute, package:eom/screens/settings_screen.dart, package:eom/services/settings_service.dart, fieldByHint, main, pushSettings (+1 more)

### Community 79 - "home_screen_test.dart"
Cohesion: 0.20
Nodes (9): package:eom/screens/home_screen.dart, package:eom/widgets/thought_tree_view.dart, generate, main, payload, pumpHome, richTextContaining, store (+1 more)

### Community 80 - "main.dart"
Cohesion: 0.22
Nodes (8): build, init, main, package:flutter/services.dart, screens/home_screen.dart, ../services/history_service.dart, ../services/settings_service.dart, theme/eom_theme.dart

### Community 81 - "_ResponseCardState"
Cohesion: 0.28
Nodes (9): HomeScreen, _HomeScreenState, SettingsScreen, _SettingsScreenState, ResponseCard, _ResponseCardState, SingleTickerProviderStateMixin, State (+1 more)

### Community 82 - "ux_eom_s21_live_provider_test.dart"
Cohesion: 0.29
Nodes (6): package:eom/services/ai_service.dart, host, live, main, masterKey, model

### Community 83 - "ux_eom_s22_live_provider_test.dart"
Cohesion: 0.29
Nodes (6): host, live, main, masterKey, model, prompt

### Community 84 - "InMemoryStore"
Cohesion: 0.40
Nodes (4): main, node, store, InMemoryStore

## Knowledge Gaps
- **854 isolated node(s):** `{ initDb, Epics, Stories, Subtasks, Comments }`, `path`, `fs`, `DB_PATH`, `fs` (+849 more)
  These have ≤1 connection - possible missing edges or undocumented components.
- **3 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `List` connect `List` to `epistemic_operation.dart`, `ux_eom_s23_returning_user_test.dart`, `home_screen.dart`, `beta_scorer.dart`, `ux_eom_e4_quick_wins_test.dart`, `epistemic_intent_service.dart`, `history_screen.dart`, `epistemic_query_result.dart`, `epistemic_node.dart`, `in_memory_epistemic_store.dart`, `beta_reporter.dart`, `beta_loader.dart`?**
  _High betweenness centrality (0.154) - this node is a cross-community bridge._
- **Why does `EpistemicGraphStore` connect `epistemic_export_service.dart` to `epistemic_gap_service.dart`, `epistemic_intent_service.dart`, `InMemoryStore`, `sqlite_epistemic_graph_store.dart`?**
  _High betweenness centrality (0.021) - this node is a cross-community bridge._
- **Why does `InMemoryStore` connect `InMemoryStore` to `epistemic_export_service.dart`, `ux_eom_s23_returning_user_test.dart`, `ux_eom_s22_session_ux_test.dart`, `in_memory_epistemic_store.dart`, `home_screen_test.dart`, `epistemic_gap_test.dart`, `epistemic_intent_service_test.dart`, `epistemic_export_test.dart`?**
  _High betweenness centrality (0.015) - this node is a cross-community bridge._
- **What connects `{ initDb, Epics, Stories, Subtasks, Comments }`, `path`, `fs` to the rest of the system?**
  _854 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `ux_eom_s23_returning_user_test.dart` be split into smaller, more focused modules?**
  _Cohesion score 0.14285714285714285 - nodes in this community are weakly interconnected._
- **Should `GeneratedPluginRegistrant.swift` be split into smaller, more focused modules?**
  _Cohesion score 0.05807200929152149 - nodes in this community are weakly interconnected._
- **Should `home_screen.dart` be split into smaller, more focused modules?**
  _Cohesion score 0.05128205128205128 - nodes in this community are weakly interconnected._
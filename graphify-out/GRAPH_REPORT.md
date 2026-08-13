# Graph Report - EOM  (2026-08-12)

## Corpus Check
- 134 files · ~73,103 words
- Verdict: corpus is large enough that graph structure adds value.

## Summary
- 1437 nodes · 1854 edges · 88 communities (85 shown, 3 thin omitted)
- Extraction: 100% EXTRACTED · 0% INFERRED · 0% AMBIGUOUS · INFERRED: 7 edges (avg confidence: 0.54)
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `4712a9bb`
- Run `git rev-parse HEAD` and compare to check if the graph is stale.
- Run `graphify update .` after code changes (no API cost).

## Community Hubs (Navigation)
- dart:io
- ux_eom_s23_returning_user_test.dart
- GeneratedPluginRegistrant.swift
- home_screen.dart
- settings_service.dart
- settings_screen.dart
- eom_colors.dart
- db.js
- response_card.dart
- manifest.json
- Unreleased
- JS Helper API (`db.js`)
- options
- tracker/package.json
- epistemic_node.dart
- AGENTS.md
- EOM Development Workflow & Standards
- in_memory_epistemic_store.dart
- UI/UX Spirit Enhancement Plan
- UX Findings — EOM-E4
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
- epistemic_graph_view.dart
- install-hooks.js
- epistemic_relationship.dart
- guide_fields.dart
- beta_scorer.dart
- Delta updates refine, never overwrite (EOM-T12)
- EOM Beta Pressure Tests
- confidence_event.dart
- epistemic_intent_service.dart
- UX Heuristics
- ux_eom_s24_structural_test.dart
- epistemic_gap.dart
- package:shared_preferences/shared_preferences.dart
- empty_vault_panel.dart
- soft_gate_sheet.dart
- ux_eom_s26_empty_state_test.dart
- List
- epistemic_maturity.dart
- ux_eom_e4_quick_wins_test.dart
- intent_config.dart
- EOM — A Quiet Vault for the Mind
- llm_provider_kind.dart
- conversation.dart
- ux_eom_s27_soft_gate_test.dart
- package:eom/models/intent.dart
- beta_runner.dart
- beta_reporter.dart
- beta_loader.dart
- scorer_test.dart
- llm_provider.dart
- 2. Visual Identity & Styling (Flutter / Material 3 / Cupertino)
- Prioritization
- analyze_test.dart
- ux_eom_s29_polish_test.dart
- Epistemic Alignment Scoring Rubric (EOM-T63)
- intent_error.dart
- UX Tester
- EOM Beta — Epistemic Alignment Pressure Tests (EOM-E5)
- [Unreleased]
- thought_tree_view.dart
- intent.dart
- history_screen.dart
- thought_node.dart
- ux_eom_s22_session_ux_test.dart
- package:flutter_test/flutter_test.dart
- beta_provider.dart
- main.dart
- epistemic_gap_service.dart
- thought_node_test.dart
- README.md
- epistemic_intent_service_test.dart
- sqlite_epistemic_graph_store_test.dart
- epistemic_gap_test.dart
- package:eom/models/epistemic_node.dart

## God Nodes (most connected - your core abstractions)
1. `LlmProvider` - 18 edges
2. `Unreleased` - 15 edges
3. `InMemoryStore` - 13 edges
4. `UI/UX Spirit Enhancement Plan` - 12 edges
5. `initDb()` - 11 edges
6. `EOM Tracker` - 11 edges
7. `Stories` - 10 edges
8. `EOM — A Quiet Vault for the Mind` - 10 edges
9. `UX Heuristics` - 9 edges
10. `Subtasks` - 8 edges

## Surprising Connections (you probably didn't know these)
- `_FakeHistory` --inherits--> `HistoryService`  [EXTRACTED]
  test/ux_eom_e4_quick_wins_test.dart → lib/services/history_service.dart
- `_NoopHistory` --inherits--> `HistoryService`  [EXTRACTED]
  test/ux_eom_s22_session_ux_test.dart → lib/services/history_service.dart
- `_FakeHistory` --inherits--> `HistoryService`  [EXTRACTED]
  test/ux_eom_s23_returning_user_test.dart → lib/services/history_service.dart
- `_FakeHistory` --inherits--> `HistoryService`  [EXTRACTED]
  test/ux_eom_s24_structural_test.dart → lib/services/history_service.dart
- `_FakeHistory` --inherits--> `HistoryService`  [EXTRACTED]
  test/ux_eom_s29_polish_test.dart → lib/services/history_service.dart

## Import Cycles
- None detected.

## Communities (88 total, 3 thin omitted)

### Community 0 - "dart:io"
Cohesion: 0.20
Nodes (8): beta_provider.dart, beta_runner.dart, dart:io, Directory, package:hive_flutter/hive_flutter.dart, main, main, tempDir

### Community 1 - "ux_eom_s23_returning_user_test.dart"
Cohesion: 0.14
Nodes (13): calls, clearCalls, clearHistory, generate, getConversations, historyLens, items, live (+5 more)

### Community 2 - "GeneratedPluginRegistrant.swift"
Cohesion: 0.06
Nodes (28): Any, Cocoa, Flutter, FlutterAppDelegate, FlutterImplicitEngineBridge, FlutterImplicitEngineDelegate, FlutterMacOS, FlutterPluginRegistry (+20 more)

### Community 3 - "home_screen.dart"
Cohesion: 0.04
Nodes (53): Future, history_screen.dart, _activeIntent, aiService, _blankHint, build, _buildConnectionsSection, _buildInputArea (+45 more)

### Community 4 - "settings_service.dart"
Cohesion: 0.06
Nodes (33): _boxName, clearHistory, getConversations, init, saveConversation, anthropicKey, defaultGatewayOrigin, defaultModelAlias (+25 more)

### Community 5 - "settings_screen.dart"
Cohesion: 0.10
Nodes (21): _activeProvider, _advancedExpanded, _allowPop, _anthropicController, build, _buildAdvanced, createState, dispose (+13 more)

### Community 6 - "eom_colors.dart"
Cohesion: 0.09
Nodes (22): accent, accentMuted, accentSubtle, background, divider, EomColors, error, gold (+14 more)

### Community 7 - "db.js"
Cohesion: 0.05
Nodes (56): findSubtask(), { initDb, Epics, Stories, Subtasks, Comments }, main(), Comments, DB_PATH, Epics, fs, get() (+48 more)

### Community 8 - "response_card.dart"
Cohesion: 0.09
Nodes (22): Animation, AnimationController, HomeScreen, _HomeScreenState, accentColor, build, _buildRichText, _controller (+14 more)

### Community 9 - "manifest.json"
Cohesion: 0.18
Nodes (10): background_color, description, display, icons, name, orientation, prefer_related_applications, short_name (+2 more)

### Community 10 - "Unreleased"
Cohesion: 0.10
Nodes (20): [1.0.0+1] — 2026-05-11, Added, Added, Added, Added, Added, Added / Changed / Fixed / Removed, Changed (+12 more)

### Community 11 - "JS Helper API (`db.js`)"
Cohesion: 0.12
Nodes (15): Comments (subtask comments), EOM Tracker — Database Schema Reference, `epics`, Epics, JS Helper API (`db.js`), Key formats, Lifecycle, `meta` (+7 more)

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

### Community 17 - "in_memory_epistemic_store.dart"
Cohesion: 0.14
Nodes (13): package:eom/models/confidence_event.dart, addRelationship, all, allRelationships, byType, confidenceEvents, confidenceHistory, create (+5 more)

### Community 18 - "UI/UX Spirit Enhancement Plan"
Cohesion: 0.15
Nodes (12): Decisions (locked), Definition of done, Implementation map (likely touchpoints), North star, Out of scope (this plan), Phase 0 — Spec & tokens, Phase 1 — Empty-state presence, Phase 2 — Soft gate (F1 / F5) (+4 more)

### Community 19 - "UX Findings — EOM-E4"
Cohesion: 0.20
Nodes (10): Findings, Live beta — EOM-S22 (five intents), Live beta — EOM-S23 (returning user), Live session notes, Orient, Returning-user notes, Spirit walk — EOM-S29 / EOM-E6 (2026-08-12), Subtask coverage (+2 more)

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

### Community 34 - "epistemic_graph_view.dart"
Cohesion: 0.05
Nodes (40): CustomClipper, CustomPainter, dart:math, eom_colors.dart, EomLeafClipper, EomShapes, getClip, leaf (+32 more)

### Community 35 - "install-hooks.js"
Cohesion: 0.29
Nodes (6): fs, hooks, hooksDest, hooksSource, path, repoRoot

### Community 36 - "epistemic_relationship.dart"
Cohesion: 0.10
Nodes (19): camel, copyWith, createdAt, EpistemicRelationship, EpistemicRelationshipType, epistemicRelationshipTypeFromString, epistemicRelationshipTypeTryParse, fromJson (+11 more)

### Community 37 - "guide_fields.dart"
Cohesion: 0.12
Nodes (18): EomApp, EpistemicGraphView, build, controller, EomSurfaceField, GuideKeyField, hint, obscure (+10 more)

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

### Community 44 - "ux_eom_s24_structural_test.dart"
Cohesion: 0.09
Nodes (24): helpers/in_memory_epistemic_store.dart, package:eom/widgets/epistemic_graph_view.dart, package:eom/widgets/thought_tree_view.dart, main, node, store, InMemoryStore, generate (+16 more)

### Community 45 - "epistemic_gap.dart"
Cohesion: 0.18
Nodes (10): int get, concept, EpistemicGap, EpistemicGapKind, hashCode, kind, nodeId, operator (+2 more)

### Community 46 - "package:shared_preferences/shared_preferences.dart"
Cohesion: 0.12
Nodes (20): _openSettings, MaterialPageRoute, package:eom/main.dart, package:eom/models/llm_provider_kind.dart, package:eom/screens/settings_screen.dart, package:eom/services/settings_service.dart, package:eom/theme/eom_theme.dart, package:eom/widgets/guide_fields.dart (+12 more)

### Community 47 - "empty_vault_panel.dart"
Cohesion: 0.13
Nodes (14): build, child, EmptyVaultPanel, onConnect, showConnectCta, build, intent, isLoading (+6 more)

### Community 48 - "soft_gate_sheet.dart"
Cohesion: 0.15
Nodes (13): guide_fields.dart, build, _canConnect, _connect, createState, dispose, initState, _keyController (+5 more)

### Community 49 - "ux_eom_s26_empty_state_test.dart"
Cohesion: 0.17
Nodes (11): Container, IconButton, package:eom/theme/eom_shapes.dart, generate, main, pumpHome, richTextContaining, store (+3 more)

### Community 50 - "List"
Cohesion: 0.20
Nodes (9): epistemic_node.dart, epistemic_relationship.dart, List, edges, EpistemicQueryResult, isEmpty, nodes, rootId (+1 more)

### Community 51 - "epistemic_maturity.dart"
Cohesion: 0.11
Nodes (17): computeMaturityByDomain, domain, EpistemicMaturity, highConfidence, highs, highThreshold, kMaturityHighThreshold, kMaturityUncertainThreshold (+9 more)

### Community 52 - "ux_eom_e4_quick_wins_test.dart"
Cohesion: 0.14
Nodes (13): HistoryService, package:eom/screens/history_screen.dart, package:eom/services/history_service.dart, package:eom/widgets/intent_button.dart, clearCalls, clearHistory, _FakeHistory, getConversations (+5 more)

### Community 53 - "intent_config.dart"
Cohesion: 0.20
Nodes (9): CognitiveIntent, buildPrompt, _categoryValues, CognitiveIntentOps, parseOperation, producesTree, ../models/epistemic_operation.dart, ../models/intent.dart (+1 more)

### Community 54 - "EOM — A Quiet Vault for the Mind"
Cohesion: 0.17
Nodes (12): AI Providers — Your Choice, EOM — A Quiet Vault for the Mind, Getting Started, License, Privacy First, Project Documentation, Run the App, Session History (+4 more)

### Community 55 - "llm_provider_kind.dart"
Cohesion: 0.25
Nodes (7): fallback, fromString, id, label, LlmProviderKind, LlmProviderKindFactory, static const LlmProviderKind

### Community 56 - "conversation.dart"
Cohesion: 0.22
Nodes (8): DateTime, Conversation, fromMap, initialInput, intent, response, timestamp, toMap

### Community 57 - "ux_eom_s27_soft_gate_test.dart"
Cohesion: 0.11
Nodes (17): package:eom/screens/home_screen.dart, package:eom/services/llm_provider.dart, package:eom/widgets/empty_vault_panel.dart, package:eom/widgets/soft_gate_sheet.dart, fieldByHint, host, live, main (+9 more)

### Community 58 - "package:eom/models/intent.dart"
Cohesion: 0.12
Nodes (16): beta/beta_provider.dart, package:eom/models/intent.dart, package:eom/services/ai_service.dart, package:eom/services/intent_config.dart, main, host, live, main (+8 more)

### Community 59 - "beta_runner.dart"
Cohesion: 0.06
Nodes (35): CapturedResponse, depth, error, escape, _extractFirstJsonObject, inString, intent, markerIndex (+27 more)

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

### Community 63 - "llm_provider.dart"
Cohesion: 0.06
Nodes (37): Exception, AnthropicProvider, assistant, ChatMessage, content, createProvider, extraBody, _extractChatContent (+29 more)

### Community 64 - "2. Visual Identity & Styling (Flutter / Material 3 / Cupertino)"
Cohesion: 0.20
Nodes (10): 1. Core Design Philosophy, 2. Visual Identity & Styling (Flutter / Material 3 / Cupertino), 3. Component Guidelines, 4. Animation & Motion, Color palette (dark vault — single mode), Density ("vault room"), EOM - AI Agent Design Specification (`design_spec.md`), Family kinship (Epiture cue → product) (+2 more)

### Community 65 - "Prioritization"
Cohesion: 0.33
Nodes (6): Prioritization, Still open (next iteration), Structural fixes — resolved (EOM-S24, 2026-08-06), Structural fixes — resolved (EOM-S28, 2026-08-12), Structural fixes — resolved (EOM-S29, 2026-08-12), Top 3 quick wins — resolved (2026-08-06)

### Community 66 - "analyze_test.dart"
Cohesion: 0.17
Nodes (11): beta_loader.dart, beta_reporter.dart, beta_scorer.dart, File, _capturedFromJson, derived, dirs, _latestRun (+3 more)

### Community 67 - "ux_eom_s29_polish_test.dart"
Cohesion: 0.12
Nodes (16): clearHistory, contrastRatio, generate, getConversations, hi, items, l1, l2 (+8 more)

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

### Community 72 - "[Unreleased]"
Cohesion: 0.18
Nodes (9): Added, Added, Changed, Changed, Changelog, Added, Changed, Fixed (+1 more)

### Community 73 - "thought_tree_view.dart"
Cohesion: 0.25
Nodes (7): ThoughtNode, build, _buildNode, _exportMap, root, ../models/thought_node.dart, package:share_plus/share_plus.dart

### Community 74 - "intent.dart"
Cohesion: 0.25
Nodes (7): Color, IconData, color, description, displayName, icon, label

### Community 75 - "history_screen.dart"
Cohesion: 0.14
Nodes (14): build, _confirmClear, _conversations, createState, _expanded, _formatDate, HistoryScreen, _HistoryScreenState (+6 more)

### Community 76 - "thought_node.dart"
Cohesion: 0.22
Nodes (8): bool get, children, fromJson, isExpanded, isLeaf, label, toJson, tryParseRaw

### Community 77 - "ux_eom_s22_session_ux_test.dart"
Cohesion: 0.11
Nodes (17): Opacity, package:eom/models/epistemic_query_result.dart, package:eom/theme/eom_colors.dart, package:eom/widgets/response_card.dart, package:flutter/material.dart, graphOf, main, node (+9 more)

### Community 78 - "package:flutter_test/flutter_test.dart"
Cohesion: 0.29
Nodes (5): package:eom/models/conversation.dart, package:eom/services/intent_error.dart, package:flutter_test/flutter_test.dart, main, main

### Community 79 - "beta_provider.dart"
Cohesion: 0.06
Nodes (33): dart:convert, EpistemicExporter, EpistemicExportService, exportVersion, _snippet, _store, toJson, toJsonGraph (+25 more)

### Community 80 - "main.dart"
Cohesion: 0.22
Nodes (8): build, init, main, package:flutter/services.dart, screens/home_screen.dart, ../services/history_service.dart, ../services/settings_service.dart, ../theme/eom_theme.dart

### Community 81 - "epistemic_gap_service.dart"
Cohesion: 0.18
Nodes (11): detectGaps, EpistemicGapDetector, EpistemicGapService, explicitGaps, _isCovered, _store, EpistemicGraphStore, SqliteEpistemicGraphStore (+3 more)

### Community 82 - "thought_node_test.dart"
Cohesion: 0.50
Nodes (3): package:eom/models/thought_node.dart, main, TypeError

### Community 83 - "README.md"
Cohesion: 0.29
Nodes (3): EOM, Language, Repository Map

### Community 84 - "epistemic_intent_service_test.dart"
Cohesion: 0.20
Nodes (8): EpistemicIntentService, package:eom/models/epistemic_operation.dart, package:eom/services/epistemic_intent_service.dart, main, seedNode, service, store, main

### Community 88 - "sqlite_epistemic_graph_store_test.dart"
Cohesion: 0.17
Nodes (10): package:eom/models/epistemic_relationship.dart, package:eom/services/sqlite_epistemic_graph_store.dart, package:sqflite_common_ffi/sqflite_ffi.dart, edge, main, node, main, main (+2 more)

### Community 89 - "epistemic_gap_test.dart"
Cohesion: 0.29
Nodes (6): package:eom/models/epistemic_gap.dart, package:eom/services/epistemic_gap_service.dart, main, node, service, store

### Community 90 - "package:eom/models/epistemic_node.dart"
Cohesion: 0.20
Nodes (7): ArgumentError, package:eom/models/epistemic_maturity.dart, package:eom/models/epistemic_node.dart, main, main, node, main

## Knowledge Gaps
- **971 isolated node(s):** `{ initDb, Epics, Stories, Subtasks, Comments }`, `path`, `fs`, `DB_PATH`, `fs` (+966 more)
  These have ≤1 connection - possible missing edges or undocumented components.
- **3 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `List` connect `List` to `epistemic_operation.dart`, `ux_eom_s23_returning_user_test.dart`, `home_screen.dart`, `ux_eom_s29_polish_test.dart`, `beta_scorer.dart`, `epistemic_intent_service.dart`, `history_screen.dart`, `thought_node.dart`, `ux_eom_s24_structural_test.dart`, `epistemic_node.dart`, `in_memory_epistemic_store.dart`, `ux_eom_e4_quick_wins_test.dart`, `beta_reporter.dart`, `beta_loader.dart`?**
  _High betweenness centrality (0.146) - this node is a cross-community bridge._
- **Why does `InMemoryStore` connect `ux_eom_s24_structural_test.dart` to `ux_eom_s23_returning_user_test.dart`, `ux_eom_s29_polish_test.dart`, `ux_eom_s22_session_ux_test.dart`, `beta_provider.dart`, `epistemic_gap_service.dart`, `in_memory_epistemic_store.dart`, `ux_eom_s26_empty_state_test.dart`, `epistemic_intent_service_test.dart`, `epistemic_gap_test.dart`, `ux_eom_s27_soft_gate_test.dart`?**
  _High betweenness centrality (0.022) - this node is a cross-community bridge._
- **Why does `EpistemicGraphStore` connect `epistemic_gap_service.dart` to `epistemic_intent_service.dart`, `sqlite_epistemic_graph_store.dart`, `ux_eom_s24_structural_test.dart`, `beta_provider.dart`?**
  _High betweenness centrality (0.020) - this node is a cross-community bridge._
- **What connects `{ initDb, Epics, Stories, Subtasks, Comments }`, `path`, `fs` to the rest of the system?**
  _971 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `ux_eom_s23_returning_user_test.dart` be split into smaller, more focused modules?**
  _Cohesion score 0.14285714285714285 - nodes in this community are weakly interconnected._
- **Should `GeneratedPluginRegistrant.swift` be split into smaller, more focused modules?**
  _Cohesion score 0.05807200929152149 - nodes in this community are weakly interconnected._
- **Should `home_screen.dart` be split into smaller, more focused modules?**
  _Cohesion score 0.037037037037037035 - nodes in this community are weakly interconnected._
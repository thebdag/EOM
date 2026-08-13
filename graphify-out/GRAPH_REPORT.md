# Graph Report - EOM  (2026-08-13)

## Corpus Check
- 136 files · ~75,369 words
- Verdict: corpus is large enough that graph structure adds value.

## Summary
- 1519 nodes · 1989 edges · 98 communities (95 shown, 3 thin omitted)
- Extraction: 100% EXTRACTED · 0% INFERRED · 0% AMBIGUOUS · INFERRED: 8 edges (avg confidence: 0.54)
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `853183b1`
- Run `git rev-parse HEAD` and compare to check if the graph is stale.
- Run `graphify update .` after code changes (no API cost).

## Community Hubs (Navigation)
- ux_harness.dart
- ux_eom_s23_returning_user_test.dart
- AppDelegate
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
- initDb
- epistemic_gap.dart
- package:flutter/material.dart
- orientation_chrome.dart
- soft_gate_sheet.dart
- ux_eom_s26_empty_state_test.dart
- epistemic_query_result.dart
- epistemic_maturity.dart
- ux_eom_s24_structural_test.dart
- ui.js
- EOM — A Quiet Vault for the Mind
- llm_provider_kind.dart
- conversation.dart
- ux_eom_s21_first_run_test.dart
- package:flutter_test/flutter_test.dart
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
- State
- LlmProvider
- history_screen.dart
- ux_eom_e4_quick_wins_test.dart
- ux_eom_s22_session_ux_test.dart
- ../theme/eom_colors.dart
- beta_provider.dart
- main.dart
- epistemic_gap_service.dart
- thought_node_test.dart
- README.md
- epistemic_intent_service_test.dart
- history_service.dart
- home_screen_test.dart
- sqlite_epistemic_graph_store_test.dart
- epistemic_export_service.dart
- post-commit
- ai_service_test.dart
- epistemic_export_test.dart
- tracker.js
- InMemoryStore
- epistemic_gap_test.dart
- package:eom/models/epistemic_node.dart
- package:eom/models/intent.dart
- helpers/in_memory_epistemic_store.dart

## God Nodes (most connected - your core abstractions)
1. `Unreleased` - 19 edges
2. `LlmProvider` - 18 edges
3. `InMemoryStore` - 13 edges
4. `UI/UX Spirit Enhancement Plan` - 12 edges
5. `initDb()` - 11 edges
6. `EOM Tracker` - 11 edges
7. `EOM — A Quiet Vault for the Mind` - 10 edges
8. `HistoryService` - 9 edges
9. `UX Heuristics` - 9 edges
10. `Stories` - 8 edges

## Surprising Connections (you probably didn't know these)
- `_FakeProvider` --implements--> `LlmProvider`  [EXTRACTED]
  test/ai_service_test.dart → lib/services/llm_provider.dart
- `_MissingKeyProvider` --implements--> `LlmProvider`  [EXTRACTED]
  test/ai_service_test.dart → lib/services/llm_provider.dart
- `_ThrowingProvider` --implements--> `LlmProvider`  [EXTRACTED]
  test/ai_service_test.dart → lib/services/llm_provider.dart
- `FakeHistoryService` --inherits--> `HistoryService`  [EXTRACTED]
  test/helpers/ux_harness.dart → lib/services/history_service.dart
- `_FakeHistory` --inherits--> `HistoryService`  [EXTRACTED]
  test/ux_eom_e4_quick_wins_test.dart → lib/services/history_service.dart

## Import Cycles
- None detected.

## Communities (98 total, 3 thin omitted)

### Community 0 - "ux_harness.dart"
Cohesion: 0.13
Nodes (14): in_memory_epistemic_store.dart, clearCalls, clearHistory, fieldByHint, generate, getConversations, hasConversations, items (+6 more)

### Community 1 - "ux_eom_s23_returning_user_test.dart"
Cohesion: 0.13
Nodes (14): calls, clearCalls, clearHistory, generate, getConversations, hasConversations, historyLens, items (+6 more)

### Community 2 - "AppDelegate"
Cohesion: 0.06
Nodes (28): Any, Cocoa, Flutter, FlutterAppDelegate, FlutterImplicitEngineBridge, FlutterImplicitEngineDelegate, FlutterMacOS, FlutterPluginRegistry (+20 more)

### Community 3 - "home_screen.dart"
Cohesion: 0.04
Nodes (56): Future, history_screen.dart, _activeIntent, aiService, _blankHint, build, _buildConnectionsSection, _buildInputArea (+48 more)

### Community 4 - "settings_service.dart"
Cohesion: 0.06
Nodes (33): anthropicKey, defaultGatewayOrigin, defaultModelAlias, geminiKey, hasUsableGuide, init, _kAnthropicKey, keyFor (+25 more)

### Community 5 - "settings_screen.dart"
Cohesion: 0.09
Nodes (23): _activeProvider, _advancedExpanded, _allowPop, build, createState, dispose, _hostError, _initialKeys (+15 more)

### Community 6 - "eom_colors.dart"
Cohesion: 0.09
Nodes (22): accent, accentMuted, accentSubtle, background, divider, EomColors, error, gold (+14 more)

### Community 7 - "db.js"
Cohesion: 0.13
Nodes (28): all(), allFrom(), DB_PATH, _diskChanged(), fs, get(), getFrom(), lastInsertId() (+20 more)

### Community 8 - "response_card.dart"
Cohesion: 0.12
Nodes (15): Animation, AnimationController, accentColor, build, _buildRichText, _controller, createState, dispose (+7 more)

### Community 9 - "manifest.json"
Cohesion: 0.18
Nodes (10): background_color, description, display, icons, name, orientation, prefer_related_applications, short_name (+2 more)

### Community 10 - "Unreleased"
Cohesion: 0.08
Nodes (24): [1.0.0+1] — 2026-05-11, Added, Added, Added, Added, Added, Added, Added / Changed / Fixed / Removed (+16 more)

### Community 11 - "JS Helper API (`db.js`)"
Cohesion: 0.12
Nodes (15): Comments (subtask comments), EOM Tracker — Database Schema Reference, `epics`, Epics, JS Helper API (`db.js`), Key formats, Lifecycle, `meta` (+7 more)

### Community 12 - "options"
Cohesion: 0.20
Nodes (9): name, npm, options, baseURL, chunkTimeout, timeout, provider, lmstudio (+1 more)

### Community 13 - "tracker/package.json"
Cohesion: 0.12
Nodes (15): blessed, dependencies, blessed, proper-lockfile, sql.js, description, main, name (+7 more)

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
Cohesion: 0.18
Nodes (11): Findings, Live beta — EOM-S22 (five intents), Live beta — EOM-S23 (returning user), Live session notes, Orient, Returning-user notes, Review follow-up — 2026-08-13, Spirit walk — EOM-S29 / EOM-E6 (2026-08-12) (+3 more)

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
Cohesion: 0.05
Nodes (37): intent_config.dart, intent_error.dart, ThoughtNode, afterMarker, AiResponse, AiService, data, defaultContext (+29 more)

### Community 33 - "epistemic_operation.dart"
Cohesion: 0.06
Nodes (39): actionable, ActOperation, category, clarified, ClarifyOperation, CompressOperation, confidence, conflictsWith (+31 more)

### Community 34 - "epistemic_graph_view.dart"
Cohesion: 0.05
Nodes (39): CustomPainter, dart:math, eom_colors.dart, eom_shapes.dart, EomShapes, leafRadius, radiusMd, radiusSm (+31 more)

### Community 35 - "install-hooks.js"
Cohesion: 0.29
Nodes (6): fs, hooks, hooksDest, hooksSource, path, repoRoot

### Community 36 - "epistemic_relationship.dart"
Cohesion: 0.10
Nodes (19): camel, copyWith, createdAt, EpistemicRelationship, EpistemicRelationshipType, epistemicRelationshipTypeFromString, epistemicRelationshipTypeTryParse, fromJson (+11 more)

### Community 37 - "guide_fields.dart"
Cohesion: 0.11
Nodes (19): EmptyVaultPanel, EpistemicGraphView, build, controller, eomSurfaceDecoration, EomSurfaceField, GuideKeyField, hint (+11 more)

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

### Community 44 - "initDb"
Cohesion: 0.22
Nodes (14): findSubtask(), { initDb, Epics, Stories, Subtasks, Comments }, main(), Comments, Epics, getDb(), initDb(), Stories (+6 more)

### Community 45 - "epistemic_gap.dart"
Cohesion: 0.18
Nodes (10): int get, concept, EpistemicGap, EpistemicGapKind, hashCode, kind, nodeId, operator (+2 more)

### Community 46 - "package:flutter/material.dart"
Cohesion: 0.15
Nodes (15): _openSettings, MaterialPageRoute, package:eom/screens/settings_screen.dart, package:eom/theme/eom_theme.dart, package:eom/widgets/guide_fields.dart, package:flutter/material.dart, fieldByHint, main (+7 more)

### Community 47 - "orientation_chrome.dart"
Cohesion: 0.12
Nodes (18): Key?, build, child, onConnect, showConnectCta, build, buttonKey, child (+10 more)

### Community 48 - "soft_gate_sheet.dart"
Cohesion: 0.11
Nodes (17): guide_fields.dart, build, _connect, createState, _defaultPersist, dispose, _error, initState (+9 more)

### Community 49 - "ux_eom_s26_empty_state_test.dart"
Cohesion: 0.14
Nodes (15): Container, helpers/ux_harness.dart, IconButton, package:eom/theme/eom_shapes.dart, package:eom/widgets/empty_vault_panel.dart, package:eom/widgets/soft_gate_sheet.dart, main, pumpHome (+7 more)

### Community 50 - "epistemic_query_result.dart"
Cohesion: 0.22
Nodes (8): epistemic_node.dart, epistemic_relationship.dart, edges, EpistemicQueryResult, isEmpty, nodes, rootId, toString

### Community 51 - "epistemic_maturity.dart"
Cohesion: 0.11
Nodes (17): computeMaturityByDomain, domain, EpistemicMaturity, highConfidence, highs, highThreshold, kMaturityHighThreshold, kMaturityUncertainThreshold (+9 more)

### Community 52 - "ux_eom_s24_structural_test.dart"
Cohesion: 0.13
Nodes (13): package:eom/models/conversation.dart, main, calls, clearHistory, generate, getConversations, hasConversations, items (+5 more)

### Community 53 - "ui.js"
Cohesion: 0.14
Nodes (13): blessed, COLORS, colorTag(), epicProgress(), { Epics, Stories, Subtasks, Comments, reloadDb }, PRIORITY_COLOR, PRIORITY_LABEL, priorityTag() (+5 more)

### Community 54 - "EOM — A Quiet Vault for the Mind"
Cohesion: 0.17
Nodes (12): AI Providers — Your Choice, EOM — A Quiet Vault for the Mind, Getting Started, License, Privacy First, Project Documentation, Run the App, Session History (+4 more)

### Community 55 - "llm_provider_kind.dart"
Cohesion: 0.22
Nodes (8): fallback, fromString, id, keyHint, label, LlmProviderKind, LlmProviderKindFactory, static const LlmProviderKind

### Community 56 - "conversation.dart"
Cohesion: 0.22
Nodes (8): DateTime, Conversation, fromMap, initialInput, intent, response, timestamp, toMap

### Community 57 - "ux_eom_s21_first_run_test.dart"
Cohesion: 0.14
Nodes (14): package:eom/main.dart, package:eom/models/llm_provider_kind.dart, package:eom/screens/home_screen.dart, package:eom/services/settings_service.dart, package:shared_preferences/shared_preferences.dart, main, fieldByHint, host (+6 more)

### Community 58 - "package:flutter_test/flutter_test.dart"
Cohesion: 0.12
Nodes (15): package:eom/services/ai_service.dart, package:eom/services/intent_error.dart, package:flutter_test/flutter_test.dart, main, host, live, main, masterKey (+7 more)

### Community 59 - "beta_runner.dart"
Cohesion: 0.07
Nodes (29): CapturedResponse, error, intent, model, ok, operationJson, operationType, opJson (+21 more)

### Community 60 - "beta_reporter.dart"
Cohesion: 0.04
Nodes (44): bool get, List, children, fromJson, isExpanded, isLeaf, label, toJson (+36 more)

### Community 61 - "beta_loader.dart"
Cohesion: 0.09
Nodes (21): all, allowsEmptyRelationships, category, complexity, confidenceRange, edgeType, fromJson, id (+13 more)

### Community 62 - "scorer_test.dart"
Cohesion: 0.10
Nodes (19): FormatException, String? edgeType,
  String, Expected, edgeType, error, expected, id, input (+11 more)

### Community 63 - "llm_provider.dart"
Cohesion: 0.11
Nodes (17): assistant, ChatMessage, content, createProvider, extraBody, _extractChatContent, extractContent, generate (+9 more)

### Community 64 - "2. Visual Identity & Styling (Flutter / Material 3 / Cupertino)"
Cohesion: 0.20
Nodes (10): 1. Core Design Philosophy, 2. Visual Identity & Styling (Flutter / Material 3 / Cupertino), 3. Component Guidelines, 4. Animation & Motion, Color palette (dark vault — single mode), Density ("vault room"), EOM - AI Agent Design Specification (`design_spec.md`), Family kinship (Epiture cue → product) (+2 more)

### Community 65 - "Prioritization"
Cohesion: 0.33
Nodes (6): Prioritization, Still open (next iteration), Structural fixes — resolved (EOM-S24, 2026-08-06), Structural fixes — resolved (EOM-S28, 2026-08-12), Structural fixes — resolved (EOM-S29, 2026-08-12), Top 3 quick wins — resolved (2026-08-06)

### Community 66 - "analyze_test.dart"
Cohesion: 0.12
Nodes (15): beta_loader.dart, beta_provider.dart, beta_reporter.dart, beta_runner.dart, beta_scorer.dart, dart:io, File, _capturedFromJson (+7 more)

### Community 67 - "ux_eom_s29_polish_test.dart"
Cohesion: 0.10
Nodes (19): clearHistory, contrastRatio, generate, getConversations, hasConversations, hi, history, items (+11 more)

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

### Community 73 - "State"
Cohesion: 0.21
Nodes (13): _HistoryEntry, _HistoryEntryState, HistoryScreen, _HistoryScreenState, HomeScreen, _HomeScreenState, ResponseCard, _ResponseCardState (+5 more)

### Community 74 - "LlmProvider"
Cohesion: 0.15
Nodes (15): AnthropicProvider, GeminiProvider, LlmProvider, LocalProvider, OpenAiProvider, SilentLlmProvider, _FakeProvider, _MissingKeyProvider (+7 more)

### Community 75 - "history_screen.dart"
Cohesion: 0.11
Nodes (17): build, _collapsedLines, _confirmClear, _conversations, createState, _expanded, _formatDate, historyService (+9 more)

### Community 76 - "ux_eom_e4_quick_wins_test.dart"
Cohesion: 0.13
Nodes (14): HistoryService, package:eom/screens/history_screen.dart, package:eom/widgets/intent_button.dart, FakeHistoryService, clearCalls, clearHistory, _FakeHistory, getConversations (+6 more)

### Community 77 - "ux_eom_s22_session_ux_test.dart"
Cohesion: 0.11
Nodes (18): Opacity, package:eom/models/epistemic_query_result.dart, package:eom/theme/eom_colors.dart, package:eom/widgets/epistemic_graph_view.dart, package:eom/widgets/response_card.dart, graphOf, main, node (+10 more)

### Community 78 - "../theme/eom_colors.dart"
Cohesion: 0.11
Nodes (17): Color, IconData, CognitiveIntent, color, description, displayName, icon, label (+9 more)

### Community 79 - "beta_provider.dart"
Cohesion: 0.11
Nodes (17): package:http/http.dart, String get, apiKey, BetaConfig, betaEpistemicMarker, BetaProviderKind, buildSystemPrompt, callProvider (+9 more)

### Community 80 - "main.dart"
Cohesion: 0.22
Nodes (8): build, EomApp, init, main, package:flutter/services.dart, screens/home_screen.dart, ../services/history_service.dart, ../services/settings_service.dart

### Community 81 - "epistemic_gap_service.dart"
Cohesion: 0.22
Nodes (9): detectGaps, EpistemicGapDetector, EpistemicGapService, explicitGaps, _isCovered, _store, ../models/epistemic_gap.dart, ../models/epistemic_node.dart (+1 more)

### Community 82 - "thought_node_test.dart"
Cohesion: 0.50
Nodes (3): package:eom/models/thought_node.dart, main, TypeError

### Community 83 - "README.md"
Cohesion: 0.29
Nodes (3): EOM, Language, Repository Map

### Community 84 - "epistemic_intent_service_test.dart"
Cohesion: 0.29
Nodes (6): EpistemicIntentService, package:eom/services/epistemic_intent_service.dart, main, seedNode, service, store

### Community 85 - "history_service.dart"
Cohesion: 0.22
Nodes (8): _boxName, clearHistory, getConversations, init, saveConversation, ../models/conversation.dart, package:hive_flutter/hive_flutter.dart, static const String

### Community 86 - "home_screen_test.dart"
Cohesion: 0.14
Nodes (12): Directory, package:eom/services/history_service.dart, package:eom/widgets/thought_tree_view.dart, main, tempDir, generate, main, payload (+4 more)

### Community 87 - "sqlite_epistemic_graph_store_test.dart"
Cohesion: 0.17
Nodes (10): package:eom/models/epistemic_relationship.dart, package:eom/services/sqlite_epistemic_graph_store.dart, package:sqflite_common_ffi/sqflite_ffi.dart, edge, main, node, main, main (+2 more)

### Community 88 - "epistemic_export_service.dart"
Cohesion: 0.18
Nodes (11): EpistemicExporter, EpistemicExportService, exportVersion, _snippet, _store, toJson, toJsonGraph, toMarkdown (+3 more)

### Community 89 - "post-commit"
Cohesion: 0.18
Nodes (10): commentMatches, dbPath, { execSync }, fs, { initDb, Epics, Stories, Subtasks, Comments }, matches, path, repoRoot (+2 more)

### Community 90 - "ai_service_test.dart"
Cohesion: 0.22
Nodes (8): Exception, package:eom/services/llm_provider.dart, _FakeProvider, generate, main, _MissingKeyProvider, payload, _ThrowingProvider

### Community 91 - "epistemic_export_test.dart"
Cohesion: 0.29
Nodes (6): dart:convert, package:eom/services/epistemic_export_service.dart, exporter, main, node, store

### Community 92 - "tracker.js"
Cohesion: 0.38
Nodes (6): currentBranch(), { execSync }, { initDb }, { launchTUI }, main(), launchTUI()

### Community 93 - "InMemoryStore"
Cohesion: 0.29
Nodes (6): EpistemicGraphStore, SqliteEpistemicGraphStore, main, node, store, InMemoryStore

### Community 94 - "epistemic_gap_test.dart"
Cohesion: 0.29
Nodes (6): package:eom/models/epistemic_gap.dart, package:eom/services/epistemic_gap_service.dart, main, node, service, store

### Community 95 - "package:eom/models/epistemic_node.dart"
Cohesion: 0.33
Nodes (4): ArgumentError, package:eom/models/epistemic_node.dart, main, main

### Community 96 - "package:eom/models/intent.dart"
Cohesion: 0.40
Nodes (4): beta/beta_provider.dart, package:eom/models/intent.dart, package:eom/services/intent_config.dart, main

### Community 97 - "helpers/in_memory_epistemic_store.dart"
Cohesion: 0.40
Nodes (4): helpers/in_memory_epistemic_store.dart, package:eom/models/epistemic_maturity.dart, main, node

## Knowledge Gaps
- **1024 isolated node(s):** `{ initDb, Epics, Stories, Subtasks, Comments }`, `path`, `fs`, `{ Worker }`, `properLockfile` (+1019 more)
  These have ≤1 connection - possible missing edges or undocumented components.
- **3 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `List` connect `beta_reporter.dart` to `ux_harness.dart`, `epistemic_operation.dart`, `ux_eom_s23_returning_user_test.dart`, `home_screen.dart`, `ux_eom_s29_polish_test.dart`, `beta_scorer.dart`, `epistemic_intent_service.dart`, `history_screen.dart`, `ux_eom_e4_quick_wins_test.dart`, `epistemic_node.dart`, `in_memory_epistemic_store.dart`, `epistemic_query_result.dart`, `ux_eom_s24_structural_test.dart`, `beta_loader.dart`?**
  _High betweenness centrality (0.104) - this node is a cross-community bridge._
- **Why does `LlmProvider` connect `LlmProvider` to `ai_service.dart`, `ai_service_test.dart`, `llm_provider.dart`?**
  _High betweenness centrality (0.013) - this node is a cross-community bridge._
- **Why does `InMemoryStore` connect `InMemoryStore` to `ux_eom_s23_returning_user_test.dart`, `ux_eom_s29_polish_test.dart`, `ux_eom_s22_session_ux_test.dart`, `in_memory_epistemic_store.dart`, `ux_eom_s26_empty_state_test.dart`, `epistemic_intent_service_test.dart`, `ux_eom_s24_structural_test.dart`, `home_screen_test.dart`, `epistemic_export_test.dart`, `epistemic_gap_test.dart`?**
  _High betweenness centrality (0.011) - this node is a cross-community bridge._
- **What connects `{ initDb, Epics, Stories, Subtasks, Comments }`, `path`, `fs` to the rest of the system?**
  _1024 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `ux_harness.dart` be split into smaller, more focused modules?**
  _Cohesion score 0.13333333333333333 - nodes in this community are weakly interconnected._
- **Should `ux_eom_s23_returning_user_test.dart` be split into smaller, more focused modules?**
  _Cohesion score 0.13333333333333333 - nodes in this community are weakly interconnected._
- **Should `AppDelegate` be split into smaller, more focused modules?**
  _Cohesion score 0.05758582502768549 - nodes in this community are weakly interconnected._
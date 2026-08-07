import 'dart:async';

import 'package:flutter/material.dart';
import '../models/conversation.dart';
import '../models/epistemic_operation.dart';
import '../models/epistemic_query_result.dart';
import '../models/intent.dart';
import '../services/ai_service.dart';
import '../services/intent_error.dart';
import '../theme/eom_colors.dart';
import '../widgets/epistemic_graph_view.dart';
import '../widgets/intent_button.dart';
import '../widgets/response_card.dart';
import '../widgets/thought_tree_view.dart';
import 'settings_screen.dart';
import 'history_screen.dart';
import '../services/epistemic_gap_service.dart';
import '../services/epistemic_intent_service.dart';
import '../services/sqlite_epistemic_graph_store.dart';
import '../services/history_service.dart';
import '../services/llm_provider.dart';

/// Main screen — the "vault" where thoughts are processed.
///
/// Services are constructor-injected (EOM-S12) instead of hand-rolled in
/// the state: [aiService] and [historyService] default to production
/// instances, and [epistemicStoreFactory] defaults to opening the SQLite
/// store. Tests inject fakes through the same seams.
class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    this.aiService,
    this.historyService,
    this.epistemicStoreFactory,
  });

  final AiService? aiService;
  final HistoryService? historyService;

  /// Builds an initialized [EpistemicGraphStore]. Typed as the interface so
  /// the screen never depends on the SQLite implementation (EOM-S12).
  final Future<EpistemicGraphStore> Function()? epistemicStoreFactory;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  final _focusNode = FocusNode();
  late final AiService _aiService = widget.aiService ?? AiService();
  late final HistoryService _historyService =
      widget.historyService ?? HistoryService();

  CognitiveIntent? _activeIntent;
  AiResponse? _response;
  bool _isProcessing = false;
  final List<ChatMessage> _history = [];
  Future<EpistemicGraphStore>? _epistemicStoreFuture;
  EpistemicIntentService? _epistemicIntents;
  EpistemicQueryResult? _mapOverlay;

  /// F11 — graph starts collapsed so the tree keeps visual primacy.
  bool _connectionsExpanded = false;

  /// Caches the initialization *future*, not the instance (EOM-S8) —
  /// concurrent callers otherwise both pass the null check, init two
  /// stores, and leak a Database.
  Future<EpistemicGraphStore> _getEpistemicStore() {
    return _epistemicStoreFuture ??= _initEpistemicStore();
  }

  Future<EpistemicGraphStore> _initEpistemicStore() async {
    try {
      final factory = widget.epistemicStoreFactory;
      if (factory != null) return await factory();
      final store = SqliteEpistemicGraphStore();
      await store.init();
      return store;
    } catch (_) {
      // Do not cache a failed init — the next call retries.
      _epistemicStoreFuture = null;
      rethrow;
    }
  }

  Future<EpistemicIntentService> _getEpistemicIntents() async {
    final existing = _epistemicIntents;
    if (existing != null) return existing;
    final store = await _getEpistemicStore();
    return _epistemicIntents = EpistemicIntentService(
      store,
      gapDetector: EpistemicGapService(store),
    );
  }

  /// Persists epistemic operations to the graph without blocking the UI —
  /// failures stay silent so the prose UX is never affected. All five
  /// intent operations are applied (EOM-T11).
  void _persistOperation(AiResponse response) {
    final operation = response.operation;
    if (operation == null) return;
    unawaited(() async {
      try {
        final service = await _getEpistemicIntents();
        switch (operation) {
          case ClarifyOperation():
            await service.processClarify(operation);
          case CompressOperation():
            await service.processCompress(operation);
          case MapOperation():
            await service.processMap(operation);
            await _loadMapOverlay(operation);
          case ReflectOperation():
            await service.processReflect(operation);
          case ActOperation():
            await service.processAct(operation);
        }
      } catch (e, st) {
        // Non-blocking by design — a graph failure must never break the UX,
        // but it must not be silent either (EOM-S2).
        debugPrint('EOM: graph persistence failed: $e\n$st');
      }
    }());
  }

  /// Loads the epistemic subgraph around a Map session's root concept and
  /// renders it as the confidence-coloured overlay (EOM-T18).
  Future<void> _loadMapOverlay(MapOperation operation) async {
    final store = await _getEpistemicStore();
    final label = operation.rootLabel.trim().toLowerCase();
    final hits = await store.search(operation.rootLabel);
    String? rootId;
    for (final hit in hits) {
      if (hit.content.toLowerCase() == label) {
        rootId = hit.id;
        break;
      }
    }
    rootId ??= hits.isNotEmpty ? hits.first.id : null;
    if (rootId == null || !mounted) return;
    final graph = await store.traverse(rootId, depth: 2);
    if (mounted) setState(() => _mapOverlay = graph);
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _processIntent(CognitiveIntent intent) async {
    final input = _controller.text.trim();
    if (input.isEmpty) return;

    setState(() {
      _activeIntent = intent;
      _isProcessing = true;
      _response = null;
    });

    try {
      final response = await _aiService.process(
        input,
        intent,
        history: _history,
      );
      if (mounted) {
        setState(() {
          _response = response;
          _isProcessing = false;
          // Error responses are shown but never enter history (EOM-S5) —
          // they would pollute future prompts and the history library.
          if (!response.isError) {
            _history.add(ChatMessage.user(input));
            _history.add(ChatMessage.assistant(response.text));
          }
        });

        if (!response.isError) {
          // History save and graph persist fail independently (EOM-S8) —
          // a Hive failure must not abort graph persistence, and neither
          // may clear the intent as if the LLM itself had failed.
          try {
            await _historyService.saveConversation(
              initialInput: input,
              intent: intent.name,
              response: response.text,
            );
          } catch (e, st) {
            debugPrint('EOM: history save failed: $e\n$st');
          }

          _persistOperation(response);
        }

        // Scroll to show response
        await Future.delayed(const Duration(milliseconds: 100));
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      }
    } catch (e) {
      // Never fail silently (EOM-S18 / UX F3) — surface calm copy.
      if (mounted) {
        final mapped = IntentError.from(e);
        setState(() {
          _isProcessing = false;
          _response = AiResponse(
            text: mapped.message,
            intent: intent,
            isError: true,
            offerSettings: mapped.offerSettings,
          );
        });
      }
    }
  }

  void _openSettings() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SettingsScreen()),
    );
  }

  Future<void> _openHistory() async {
    final selected = await Navigator.push<Conversation>(
      context,
      MaterialPageRoute(
        builder: (_) => HistoryScreen(historyService: _historyService),
      ),
    );
    if (selected == null || !mounted) return;
    _restoreConversation(selected);
  }

  /// F8 — reopen a History row into the Home canvas.
  void _restoreConversation(Conversation item) {
    CognitiveIntent? intent;
    try {
      intent = CognitiveIntent.values.byName(item.intent);
    } catch (_) {
      intent = null;
    }
    setState(() {
      _controller.text = item.initialInput;
      _activeIntent = intent;
      _mapOverlay = null;
      _connectionsExpanded = false;
      _isProcessing = false;
      _history
        ..clear()
        ..add(ChatMessage.user(item.initialInput))
        ..add(ChatMessage.assistant(item.response));
      _response = AiResponse(
        text: item.response,
        intent: intent ?? CognitiveIntent.clarify,
      );
    });
  }

  Future<void> _confirmNewThought() async {
    // F16 — protect multi-turn context the same way Clear History does.
    final hasSession = _response != null || _history.isNotEmpty;
    if (!hasSession) {
      _clearSession();
      return;
    }
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: EomColors.surface,
        title: const Text(
          'Start a new thought?',
          style: TextStyle(
            color: EomColors.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        content: const Text(
          'This clears the current session on screen. Saved history is kept.',
          style: TextStyle(color: EomColors.textSecondary, fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('New thought'),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) _clearSession();
  }

  void _clearSession() {
    setState(() {
      _controller.clear();
      _activeIntent = null;
      _response = null;
      _isProcessing = false;
      _history.clear();
      _mapOverlay = null;
      _connectionsExpanded = false;
    });
    _focusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final hasInput = _controller.text.trim().isNotEmpty;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Top bar
            _buildTopBar(),
            const Divider(),

            // Scrollable content
            Expanded(
              child: SingleChildScrollView(
                controller: _scrollController,
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Input area — borderless, expansive
                    _buildInputArea(),

                    // Intent buttons
                    if (hasInput || _response != null) ...[
                      const SizedBox(height: 20),
                      _buildIntentBar(),
                    ],

                    // F10 — prior turns stay visible above the latest card
                    if (_priorTurns.isNotEmpty) ...[
                      const SizedBox(height: 24),
                      _buildPriorTurns(),
                    ],

                    // Response
                    if (_response != null) ...[
                      const SizedBox(height: 24),
                      ResponseCard(
                        text: _response!.text,
                        accentColor: _response!.intent.color,
                        isError: _response!.isError,
                        onOpenSettings: _response!.offerSettings
                            ? _openSettings
                            : null,
                      ),
                    ],

                    // Tree view (for Map intent) — F11 framing
                    if (_response?.tree != null) ...[
                      const SizedBox(height: 20),
                      const Text(
                        'Your map',
                        style: TextStyle(
                          color: EomColors.textTertiary,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 10),
                      ThoughtTreeView(root: _response!.tree!),
                    ],

                    // Epistemic graph overlay — F11 collapsed by default
                    if (_mapOverlay != null) ...[
                      const SizedBox(height: 12),
                      _buildConnectionsSection(),
                    ],

                    // Processing indicator
                    if (_isProcessing) ...[
                      const SizedBox(height: 24),
                      _buildProcessingIndicator(),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: EomColors.accent.withValues(alpha: 0.6),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 10),
          const Text(
            'EOM',
            style: TextStyle(
              color: EomColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w500,
              letterSpacing: 1.5,
            ),
          ),
          const Spacer(),
          if (_response != null)
            IconButton(
              onPressed: _confirmNewThought,
              icon: const Icon(Icons.refresh_outlined, size: 20),
              color: EomColors.textTertiary,
              tooltip: 'New thought',
            ),
          IconButton(
            onPressed: _openHistory,
            icon: const Icon(Icons.history_outlined, size: 20),
            color: EomColors.textTertiary,
            tooltip: 'History',
          ),
          IconButton(
            onPressed: _openSettings,
            icon: const Icon(Icons.settings_outlined, size: 20),
            color: EomColors.textTertiary,
            tooltip: 'Settings',
          ),
        ],
      ),
    );
  }

  Widget _buildInputArea() {
    return TextField(
      controller: _controller,
      focusNode: _focusNode,
      autofocus: true,
      maxLines: null,
      minLines: 6,
      style: const TextStyle(
        color: EomColors.textPrimary,
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 1.6,
      ),
      decoration: const InputDecoration(
        hintText: 'What\'s on your mind?',
        border: InputBorder.none,
        contentPadding: EdgeInsets.zero,
      ),
      onChanged: (_) => setState(() {}),
    );
  }

  Widget _buildIntentBar() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: CognitiveIntent.values.map((intent) {
        return IntentButton(
          intent: intent,
          isSelected: _activeIntent == intent,
          isLoading: _isProcessing,
          onPressed: () => _processIntent(intent),
        );
      }).toList(),
    );
  }

  Widget _buildProcessingIndicator() {
    return Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 14,
            height: 14,
            child: CircularProgressIndicator(
              strokeWidth: 1.5,
              color: _activeIntent?.color ?? EomColors.accent,
            ),
          ),
          const SizedBox(width: 10),
          Text(
            '${_activeIntent?.description ?? 'Processing'}…',
            style: const TextStyle(color: EomColors.textTertiary, fontSize: 13),
          ),
        ],
      ),
    );
  }

  /// Prior user/assistant pairs excluding the current turn (F10).
  List<ChatMessage> get _priorTurns {
    if (_history.length <= 2) return const [];
    if (_response != null && !_response!.isError) {
      return _history.sublist(0, _history.length - 2);
    }
    return List<ChatMessage>.from(_history);
  }

  Widget _buildPriorTurns() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Earlier in this session',
          style: TextStyle(
            color: EomColors.textTertiary,
            fontSize: 12,
            fontWeight: FontWeight.w500,
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: 12),
        for (var i = 0; i < _priorTurns.length; i++) ...[
          if (i > 0) const SizedBox(height: 10),
          Text(
            _priorTurns[i].role == 'user' ? 'You' : 'EOM',
            style: const TextStyle(
              color: EomColors.textTertiary,
              fontSize: 11,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _priorTurns[i].content,
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: _priorTurns[i].role == 'user'
                  ? EomColors.textSecondary
                  : EomColors.textTertiary,
              fontSize: 13,
              height: 1.45,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildConnectionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () =>
              setState(() => _connectionsExpanded = !_connectionsExpanded),
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                const Text(
                  'Connections',
                  style: TextStyle(
                    color: EomColors.textTertiary,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 1.2,
                  ),
                ),
                const Spacer(),
                Icon(
                  _connectionsExpanded ? Icons.expand_less : Icons.expand_more,
                  size: 18,
                  color: EomColors.textTertiary,
                ),
              ],
            ),
          ),
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
          alignment: Alignment.topCenter,
          child: _connectionsExpanded
              ? Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: EpistemicGraphView(graph: _mapOverlay!),
                )
              : const SizedBox(width: double.infinity),
        ),
      ],
    );
  }
}

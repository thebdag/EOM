import 'package:flutter/material.dart';
import '../models/intent.dart';
import '../services/ai_service.dart';
import '../theme/eom_colors.dart';
import '../widgets/intent_button.dart';
import '../widgets/response_card.dart';
import '../widgets/thought_tree_view.dart';
import 'settings_screen.dart';
import 'history_screen.dart';
import '../services/history_service.dart';

/// Main screen — the "vault" where thoughts are processed.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  final _aiService = AiService();
  final _focusNode = FocusNode();

  CognitiveIntent? _activeIntent;
  AiResponse? _response;
  bool _isProcessing = false;
  final List<Map<String, String>> _history = [];

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
      final response = await _aiService.process(input, intent, history: _history);
      if (mounted) {
        setState(() {
          _response = response;
          _isProcessing = false;
          _history.add({'role': 'user', 'content': input});
          _history.add({'role': 'assistant', 'content': response.text});
        });
        
        await HistoryService().saveConversation(
          initialInput: input,
          intent: intent.name,
          response: response.text,
        );

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
      if (mounted) {
        setState(() {
          _isProcessing = false;
          _activeIntent = null;
        });
      }
    }
  }

  void _clearSession() {
    setState(() {
      _controller.clear();
      _activeIntent = null;
      _response = null;
      _isProcessing = false;
      _history.clear();
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

                    // Response
                    if (_response != null) ...[
                      const SizedBox(height: 24),
                      ResponseCard(
                        text: _response!.text,
                        accentColor: _response!.intent.color,
                      ),
                    ],

                    // Tree view (for Map intent)
                    if (_response?.tree != null) ...[
                      const SizedBox(height: 16),
                      ThoughtTreeView(root: _response!.tree!),
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
              onPressed: _clearSession,
              icon: const Icon(Icons.refresh_outlined, size: 20),
              color: EomColors.textTertiary,
              tooltip: 'New thought',
            ),
          IconButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const HistoryScreen()),
            ),
            icon: const Icon(Icons.history_outlined, size: 20),
            color: EomColors.textTertiary,
            tooltip: 'History',
          ),
          IconButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            ),
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
            style: const TextStyle(
              color: EomColors.textTertiary,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

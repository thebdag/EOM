import 'package:flutter/material.dart';
import '../models/conversation.dart';
import '../models/intent.dart';
import '../services/history_service.dart';
import '../theme/eom_colors.dart';
import '../theme/eom_motion.dart';
import '../theme/eom_theme.dart';
import '../widgets/empty_vault_panel.dart';
import '../widgets/orientation_chrome.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key, this.historyService});

  /// Optional inject for tests (EOM-S19). Defaults to a live [HistoryService].
  final HistoryService? historyService;

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  late final HistoryService _historyService =
      widget.historyService ?? HistoryService();
  List<Conversation> _conversations = [];

  @override
  void initState() {
    super.initState();
    _loadConversations();
  }

  void _loadConversations() {
    setState(() {
      _conversations = _historyService.getConversations();
    });
  }

  Future<void> _confirmClear() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: EomColors.surface,
        title: const Text(
          'Clear history?',
          style: TextStyle(
            color: EomColors.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        content: const Text(
          'This removes every saved thought from this device.',
          style: TextStyle(color: EomColors.textSecondary, fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              'Clear',
              style: TextStyle(color: EomColors.error),
            ),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    await _historyService.clearHistory();
    if (!mounted) return;
    _loadConversations();
  }

  void _openConversation(Conversation item) {
    // F8 — return the row to Home so the session can continue.
    Navigator.pop(context, item);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('History'),
        actions: [
          if (_conversations.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_outline, size: 20),
              onPressed: _confirmClear,
              tooltip: 'Clear History',
            ),
        ],
      ),
      body: _conversations.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: EomSpacing.xl),
                child: EmptyVaultPanel(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'No conversations yet.',
                        style: EomTheme.orientationLabel(
                          fontSize: 15,
                        ).copyWith(color: EomColors.textSecondary),
                      ),
                      const SizedBox(height: EomSpacing.xs),
                      const Text(
                        'Capture a thought on Home to start your vault.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: EomColors.textTertiary,
                          fontSize: 13,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: EomSpacing.lg),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: OrientationCta(
                          label: 'Capture a thought',
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(EomSpacing.lg),
              itemCount: _conversations.length,
              separatorBuilder: (context, index) =>
                  const Divider(height: EomSpacing.xl),
              itemBuilder: (context, index) {
                return _HistoryEntry(
                  item: _conversations[index],
                  onOpen: () => _openConversation(_conversations[index]),
                );
              },
            ),
    );
  }
}

class _HistoryEntry extends StatefulWidget {
  const _HistoryEntry({required this.item, required this.onOpen});

  final Conversation item;
  final VoidCallback onOpen;

  @override
  State<_HistoryEntry> createState() => _HistoryEntryState();
}

class _HistoryEntryState extends State<_HistoryEntry> {
  bool _expanded = false;

  static const int _collapsedLines = 4;

  bool _needsReadMore(String response) =>
      response.length > 180 || response.split('\n').length > _collapsedLines;

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final showToggle = _needsReadMore(item.response);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Material(
          color: EomColors.transparent,
          child: Tooltip(
            message: 'Continue this thought',
            child: InkWell(
              onTap: widget.onOpen,
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          CognitiveIntent.displayName(item.intent),
                          style: const TextStyle(
                            color: EomColors.accent,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          _formatDate(item.timestamp),
                          style: const TextStyle(
                            color: EomColors.textTertiary,
                            fontSize: 12,
                          ),
                        ),
                        const Icon(
                          Icons.chevron_right,
                          size: 16,
                          color: EomColors.textTertiary,
                        ),
                      ],
                    ),
                    const SizedBox(height: EomSpacing.xs),
                    Text(
                      item.initialInput,
                      style: const TextStyle(
                        color: EomColors.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: EomSpacing.xs),
        AnimatedSize(
          duration: EomMotion.of(context, EomMotion.medium),
          curve: EomMotion.curve,
          alignment: Alignment.topCenter,
          child: Text(
            item.response,
            style: const TextStyle(
              color: EomColors.textSecondary,
              fontSize: 14,
              height: 1.5,
            ),
            maxLines: _expanded ? null : _collapsedLines,
            overflow: _expanded ? TextOverflow.visible : TextOverflow.ellipsis,
          ),
        ),
        if (showToggle)
          TextButton(
            onPressed: () => setState(() => _expanded = !_expanded),
            style: TextButton.styleFrom(
              foregroundColor: EomColors.textTertiary,
              padding: const EdgeInsets.symmetric(vertical: 8),
              minimumSize: const Size(0, 44),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              alignment: Alignment.centerLeft,
            ),
            child: Text(_expanded ? 'Show less' : 'Read more'),
          ),
      ],
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}

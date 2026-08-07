import 'package:flutter/material.dart';
import '../models/conversation.dart';
import '../services/history_service.dart';
import '../theme/eom_colors.dart';

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
        title: const Text(
          'History',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            letterSpacing: 1.5,
          ),
        ),
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
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'No conversations yet.',
                      style: TextStyle(
                        color: EomColors.textSecondary,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Capture a thought on Home to start your vault.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: EomColors.textTertiary,
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        foregroundColor: EomColors.accent,
                      ),
                      child: const Text(
                        'Capture a thought',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: _conversations.length,
              separatorBuilder: (context, index) => const Divider(height: 32),
              itemBuilder: (context, index) {
                final item = _conversations[index];
                return Material(
                  color: EomColors.transparent,
                  child: InkWell(
                    onTap: () => _openConversation(item),
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                item.intent,
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
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            item.initialInput,
                            style: const TextStyle(
                              color: EomColors.textPrimary,
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            item.response,
                            style: const TextStyle(
                              color: EomColors.textSecondary,
                              fontSize: 14,
                              height: 1.5,
                            ),
                            maxLines: 4,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }

  String _formatDate(DateTime? date) {
    // Malformed timestamps arrive null (EOM-S9) and render as no date
    // rather than crashing the build.
    if (date == null) return '';
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}

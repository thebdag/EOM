import 'package:flutter/material.dart';
import '../services/history_service.dart';
import '../theme/eom_colors.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final _historyService = HistoryService();
  List<Map<String, dynamic>> _conversations = [];

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'History',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, letterSpacing: 1.5),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline, size: 20),
            onPressed: () async {
              await _historyService.clearHistory();
              _loadConversations();
            },
            tooltip: 'Clear History',
          ),
        ],
      ),
      body: _conversations.isEmpty
          ? const Center(
              child: Text(
                'No conversations yet.',
                style: TextStyle(color: EomColors.textTertiary),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: _conversations.length,
              separatorBuilder: (context, index) => const Divider(height: 32),
              itemBuilder: (context, index) {
                final item = _conversations[index];
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          item['intent'],
                          style: const TextStyle(
                            color: EomColors.accent,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          _formatDate(item['timestamp']),
                          style: const TextStyle(
                            color: EomColors.textTertiary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      item['initialInput'],
                      style: const TextStyle(
                        color: EomColors.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      item['response'],
                      style: const TextStyle(
                        color: EomColors.textSecondary,
                        fontSize: 14,
                        height: 1.5,
                      ),
                      maxLines: 4,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                );
              },
            ),
    );
  }

  String _formatDate(String isoString) {
    final date = DateTime.parse(isoString);
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}

import 'package:hive_flutter/hive_flutter.dart';
import '../models/conversation.dart';

class HistoryService {
  static const String _boxName = 'conversations';

  Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox<Map<dynamic, dynamic>>(_boxName);
  }

  Future<void> saveConversation({
    required String initialInput,
    required String intent,
    required String response,
  }) async {
    final box = Hive.box<Map<dynamic, dynamic>>(_boxName);
    final conversation = Conversation(
      timestamp: DateTime.now(),
      initialInput: initialInput,
      intent: intent,
      response: response,
    );
    await box.add(conversation.toMap());
  }

  List<Conversation> getConversations() {
    final box = Hive.box<Map<dynamic, dynamic>>(_boxName);
    return box.values.map(Conversation.fromMap).toList().reversed.toList();
  }

  /// Presence check without parsing every stored transcript (History pip).
  bool get hasConversations {
    final box = Hive.box<Map<dynamic, dynamic>>(_boxName);
    return box.isNotEmpty;
  }

  Future<void> clearHistory() async {
    final box = Hive.box<Map<dynamic, dynamic>>(_boxName);
    await box.clear();
  }
}

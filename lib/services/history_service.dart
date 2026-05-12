import 'package:hive_flutter/hive_flutter.dart';

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
    final conversation = {
      'timestamp': DateTime.now().toIso8601String(),
      'initialInput': initialInput,
      'intent': intent,
      'response': response,
    };
    await box.add(conversation);
  }

  List<Map<String, dynamic>> getConversations() {
    final box = Hive.box<Map<dynamic, dynamic>>(_boxName);
    return box.values.map((e) {
      return {
        'timestamp': e['timestamp'] as String,
        'initialInput': e['initialInput'] as String,
        'intent': e['intent'] as String,
        'response': e['response'] as String,
      };
    }).toList().reversed.toList();
  }

  Future<void> clearHistory() async {
    final box = Hive.box<Map<dynamic, dynamic>>(_boxName);
    await box.clear();
  }
}

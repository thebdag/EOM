import 'dart:io';

import 'package:eom/services/history_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() {
  late Directory tempDir;

  setUp(() async {
    tempDir = Directory.systemTemp.createTempSync('eom_history_test');
    Hive.init(tempDir.path);
    await Hive.openBox<Map<dynamic, dynamic>>('conversations');
  });

  tearDown(() async {
    await Hive.close();
    tempDir.deleteSync(recursive: true);
  });

  group('HistoryService (EOM-S11)', () {
    test('saves and reads conversations back as typed models', () async {
      final service = HistoryService();
      await service.saveConversation(
        initialInput: 'a thought',
        intent: 'clarify',
        response: 'a clearer thought',
      );

      final conversations = service.getConversations();
      expect(conversations, hasLength(1));
      final saved = conversations.single;
      expect(saved.initialInput, 'a thought');
      expect(saved.intent, 'clarify');
      expect(saved.response, 'a clearer thought');
      expect(saved.timestamp, isNotNull);
    });

    test('returns newest first', () async {
      final service = HistoryService();
      await service.saveConversation(
        initialInput: 'first',
        intent: 'clarify',
        response: 'r1',
      );
      await service.saveConversation(
        initialInput: 'second',
        intent: 'act',
        response: 'r2',
      );

      final conversations = service.getConversations();
      expect(conversations.map((c) => c.initialInput), ['second', 'first']);
    });

    test('clearHistory empties the box', () async {
      final service = HistoryService();
      await service.saveConversation(
        initialInput: 'x',
        intent: 'map',
        response: 'y',
      );
      await service.clearHistory();
      expect(service.getConversations(), isEmpty);
    });

    test('tolerates corrupt entries (EOM-S9)', () async {
      final box = Hive.box<Map<dynamic, dynamic>>('conversations');
      await box.add({'timestamp': 'garbage', 'intent': null});

      final conversations = HistoryService().getConversations();
      expect(conversations, hasLength(1));
      expect(conversations.single.timestamp, isNull);
    });

    test('hasConversations is true without parsing transcripts', () async {
      final service = HistoryService();
      expect(service.hasConversations, isFalse);
      await service.saveConversation(
        initialInput: 'a thought',
        intent: 'clarify',
        response: 'clearer',
      );
      expect(service.hasConversations, isTrue);
    });
  });
}

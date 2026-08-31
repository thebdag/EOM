import 'package:eom/models/intent.dart';
import 'package:eom/services/ai_service.dart';
import 'package:eom/services/llm_provider.dart';
import 'package:eom/services/on_device_llm.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/fake_on_device_llm.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('OnDeviceAvailability', () {
    test('parses channel maps and status copy', () {
      expect(
        OnDeviceAvailability.fromMap({'status': 'available'}).kind,
        OnDeviceAvailabilityKind.available,
      );
      expect(
        OnDeviceAvailability.fromMap({'status': 'downloadable'}).statusCopy,
        'Preparing…',
      );
      expect(
        OnDeviceAvailability.fromMap({
          'status': 'unavailable',
          'reason': 'no aicore',
        }).statusCopy,
        'Not available here — choose another Guide',
      );
    });
  });

  group('MethodChannelOnDeviceLlm', () {
    late MethodChannel channel;
    late MethodChannelOnDeviceLlm client;
    Map<String, dynamic>? availabilityPayload;
    String? generateText;
    Object? generateError;

    setUp(() {
      channel = const MethodChannel(onDeviceLlmChannelName);
      client = MethodChannelOnDeviceLlm(channel: channel);
      availabilityPayload = {'status': 'available'};
      generateText = 'nano';
      generateError = null;
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (call) async {
            switch (call.method) {
              case 'availability':
                return availabilityPayload;
              case 'prepare':
                availabilityPayload = {'status': 'available'};
                return null;
              case 'generate':
                final err = generateError;
                if (err != null) throw err;
                return generateText;
              default:
                return null;
            }
          });
    });

    tearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, null);
    });

    test('availability maps a ready device', () async {
      final status = await client.availability();
      expect(status.isReady, isTrue);
    });

    test('generate returns channel text', () async {
      expect(
        await client.generate(systemPrompt: 's', userMessage: 'u'),
        'nano',
      );
    });

    test('MissingPluginException becomes unavailable', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, null);
      final status = await client.availability();
      expect(status.kind, OnDeviceAvailabilityKind.unavailable);
    });

    test('generate wraps PlatformException', () async {
      generateError = PlatformException(code: 'on_device', message: 'AICore');
      expect(
        () => client.generate(systemPrompt: 's', userMessage: 'u'),
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('On-device Error'),
          ),
        ),
      );
    });
  });

  group('OnDeviceProvider', () {
    test('generate when available does not prepare', () async {
      final fake = FakeOnDeviceLlm();
      final text = await OnDeviceProvider(client: fake).generate('sys', 'hi');
      expect(text, 'on-device prose');
      expect(fake.prepareCalls, 0);
      expect(fake.generateCalls, 1);
    });

    test('downloadable prepares then generates', () async {
      final fake = FakeOnDeviceLlm(
        availabilityResult: const OnDeviceAvailability(
          kind: OnDeviceAvailabilityKind.downloadable,
        ),
        prepareTo: OnDeviceAvailabilityKind.available,
      );
      await OnDeviceProvider(client: fake).generate('sys', 'hi');
      expect(fake.prepareCalls, 1);
      expect(fake.generateCalls, 1);
    });

    test('unavailable throws an On-device Error', () async {
      final fake = FakeOnDeviceLlm(
        availabilityResult: const OnDeviceAvailability(
          kind: OnDeviceAvailabilityKind.unavailable,
          reason: 'no AICore',
        ),
      );
      expect(
        () => OnDeviceProvider(client: fake).generate('sys', 'hi'),
        throwsA(
          isA<Exception>().having(
            (e) => e.toString().toLowerCase(),
            'message',
            contains('on-device'),
          ),
        ),
      );
      expect(fake.generateCalls, 0);
    });

    test('truncates history to the last two turns', () {
      final history = [for (var i = 0; i < 6; i++) ChatMessage.user('m$i')];
      final trimmed = OnDeviceProvider.truncateHistory(history);
      expect(trimmed, hasLength(4));
      expect(trimmed.first.content, 'm2');
      expect(trimmed.last.content, 'm5');
    });
  });

  group('AiService compact prompts', () {
    test(
      'OnDeviceProvider receives compactContext, not defaultContext',
      () async {
        final fake = FakeOnDeviceLlm();
        final service = AiService(provider: OnDeviceProvider(client: fake));
        await service.process('a thought', CognitiveIntent.clarify);
        expect(fake.lastSystem, contains(AiService.compactContext));
        expect(fake.lastSystem, isNot(contains(AiService.defaultContext)));
        expect(fake.lastSystem, contains(AiService.epistemicMarker));
        expect(fake.lastSystem, contains('"clarified"'));
      },
    );
  });
}

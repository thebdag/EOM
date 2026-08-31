import 'package:eom/services/on_device_llm.dart';

/// In-memory [OnDeviceLlmClient] for unit and widget tests.
class FakeOnDeviceLlm implements OnDeviceLlmClient {
  FakeOnDeviceLlm({
    this.availabilityResult = const OnDeviceAvailability(
      kind: OnDeviceAvailabilityKind.available,
    ),
    this.generateResult = 'on-device prose',
    this.prepareTo,
    this.generateError,
  });

  OnDeviceAvailability availabilityResult;
  String generateResult;
  OnDeviceAvailabilityKind? prepareTo;
  Object? generateError;

  int prepareCalls = 0;
  int generateCalls = 0;
  String? lastSystem;
  String? lastUser;
  List<Map<String, String>> lastHistory = const [];

  @override
  Future<OnDeviceAvailability> availability() async => availabilityResult;

  @override
  Future<void> prepare() async {
    prepareCalls++;
    final next = prepareTo;
    if (next != null) {
      availabilityResult = OnDeviceAvailability(kind: next);
    }
  }

  @override
  Future<String> generate({
    required String systemPrompt,
    required String userMessage,
    List<Map<String, String>> history = const [],
  }) async {
    generateCalls++;
    lastSystem = systemPrompt;
    lastUser = userMessage;
    lastHistory = history;
    final error = generateError;
    if (error != null) throw error;
    return generateResult;
  }
}

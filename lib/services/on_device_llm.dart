import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Method-channel name for OS on-device inference (Android AICore / iOS FM).
const onDeviceLlmChannelName = 'com.eom.eom/on_device_llm';

/// Feature status of the OS-managed on-device model.
enum OnDeviceAvailabilityKind {
  unavailable,
  downloadable,
  downloading,
  available,
}

/// Snapshot returned by [OnDeviceLlmClient.availability].
class OnDeviceAvailability {
  const OnDeviceAvailability({required this.kind, this.reason});

  final OnDeviceAvailabilityKind kind;
  final String? reason;

  factory OnDeviceAvailability.fromMap(Map<Object?, Object?> map) {
    final raw = (map['status'] as String? ?? 'unavailable').toLowerCase();
    final kind = OnDeviceAvailabilityKind.values.firstWhere(
      (k) => k.name == raw,
      orElse: () => OnDeviceAvailabilityKind.unavailable,
    );
    final reason = map['reason'] as String?;
    return OnDeviceAvailability(
      kind: kind,
      reason: (reason == null || reason.isEmpty) ? null : reason,
    );
  }

  /// Quiet Settings copy (Epistemic Calm — no vendor names).
  String get statusCopy {
    switch (kind) {
      case OnDeviceAvailabilityKind.available:
        return 'Ready on this device';
      case OnDeviceAvailabilityKind.downloadable:
      case OnDeviceAvailabilityKind.downloading:
        return 'Preparing…';
      case OnDeviceAvailabilityKind.unavailable:
        return 'Not available here — choose another Guide';
    }
  }

  bool get isReady => kind == OnDeviceAvailabilityKind.available;

  bool get needsPrepare =>
      kind == OnDeviceAvailabilityKind.downloadable ||
      kind == OnDeviceAvailabilityKind.downloading;
}

/// Platform client for OS-managed on-device generation.
abstract class OnDeviceLlmClient {
  Future<OnDeviceAvailability> availability();

  Future<void> prepare();

  Future<String> generate({
    required String systemPrompt,
    required String userMessage,
    List<Map<String, String>> history = const [],
  });
}

/// Default [OnDeviceLlmClient] used by [OnDeviceProvider] and Settings.
class OnDeviceLlm {
  OnDeviceLlm._();

  static OnDeviceLlmClient instance = MethodChannelOnDeviceLlm();

  @visibleForTesting
  static void debugReset() {
    instance = MethodChannelOnDeviceLlm();
  }
}

/// Invokes the in-app `com.eom.eom/on_device_llm` channel.
class MethodChannelOnDeviceLlm implements OnDeviceLlmClient {
  MethodChannelOnDeviceLlm({MethodChannel? channel})
    : _channel = channel ?? const MethodChannel(onDeviceLlmChannelName);

  final MethodChannel _channel;

  @override
  Future<OnDeviceAvailability> availability() async {
    try {
      final raw = await _channel.invokeMapMethod<Object?, Object?>(
        'availability',
      );
      return OnDeviceAvailability.fromMap(raw ?? const {});
    } on MissingPluginException {
      return const OnDeviceAvailability(
        kind: OnDeviceAvailabilityKind.unavailable,
        reason: 'On-device is not available on this platform',
      );
    } on PlatformException catch (e) {
      return OnDeviceAvailability(
        kind: OnDeviceAvailabilityKind.unavailable,
        reason: e.message,
      );
    }
  }

  @override
  Future<void> prepare() async {
    try {
      await _channel.invokeMethod<void>('prepare');
    } on MissingPluginException {
      throw Exception('On-device Error: not available on this platform');
    } on PlatformException catch (e) {
      throw Exception('On-device Error: ${e.message ?? 'prepare failed'}');
    }
  }

  @override
  Future<String> generate({
    required String systemPrompt,
    required String userMessage,
    List<Map<String, String>> history = const [],
  }) async {
    try {
      final text = await _channel.invokeMethod<String>('generate', {
        'systemPrompt': systemPrompt,
        'userMessage': userMessage,
        'history': history,
      });
      if (text == null || text.trim().isEmpty) {
        throw Exception('On-device Error: empty response');
      }
      return text;
    } on MissingPluginException {
      throw Exception('On-device Error: not available on this platform');
    } on PlatformException catch (e) {
      throw Exception('On-device Error: ${e.message ?? 'generate failed'}');
    }
  }
}

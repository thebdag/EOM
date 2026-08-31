import Flutter
import Foundation

#if canImport(FoundationModels)
  import FoundationModels
#endif

/// OS-managed on-device generation (Apple Foundation Models, iOS 26+).
///
/// Channel: `com.eom.eom/on_device_llm`
final class OnDeviceLlmPlugin: NSObject, FlutterPlugin {
  static let channelName = "com.eom.eom/on_device_llm"

  static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(
      name: channelName,
      binaryMessenger: registrar.messenger()
    )
    registrar.addMethodCallDelegate(OnDeviceLlmPlugin(), channel: channel)
  }

  func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "availability":
      availability(result: result)
    case "prepare":
      prepare(result: result)
    case "generate":
      generate(call: call, result: result)
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  private func availability(result: @escaping FlutterResult) {
    #if canImport(FoundationModels)
      if #available(iOS 26.0, *) {
        result(Self.foundationAvailability())
        return
      }
    #endif
    result([
      "status": "unavailable",
      "reason": "On-device requires iOS 26 and Apple Intelligence",
    ])
  }

  private func prepare(result: @escaping FlutterResult) {
    #if canImport(FoundationModels)
      if #available(iOS 26.0, *) {
        Task {
          await Self.foundationPrepare()
          DispatchQueue.main.async { result(nil) }
        }
        return
      }
    #endif
    result(nil)
  }

  private func generate(call: FlutterMethodCall, result: @escaping FlutterResult) {
    let args = call.arguments as? [String: Any] ?? [:]
    let system = args["systemPrompt"] as? String ?? ""
    let user = args["userMessage"] as? String ?? ""
    let history = args["history"] as? [[String: Any]] ?? []

    #if canImport(FoundationModels)
      if #available(iOS 26.0, *) {
        Task {
          do {
            let text = try await Self.foundationGenerate(
              system: system,
              user: user,
              history: history
            )
            DispatchQueue.main.async { result(text) }
          } catch {
            DispatchQueue.main.async {
              result(
                FlutterError(
                  code: "on_device",
                  message: error.localizedDescription,
                  details: nil
                )
              )
            }
          }
        }
        return
      }
    #endif
    result(
      FlutterError(
        code: "on_device",
        message: "On-device Error: not available on this platform",
        details: nil
      )
    )
  }

  #if canImport(FoundationModels)
    @available(iOS 26.0, *)
    static func foundationAvailability() -> [String: Any] {
      switch SystemLanguageModel.default.availability {
      case .available:
        return ["status": "available"]
      case .unavailable(.appleIntelligenceNotEnabled):
        return [
          "status": "unavailable",
          "reason": "Apple Intelligence is off",
        ]
      case .unavailable(.deviceNotEligible):
        return [
          "status": "unavailable",
          "reason": "This device does not support Apple Intelligence",
        ]
      case .unavailable(.modelNotReady):
        return [
          "status": "downloadable",
          "reason": "The on-device model is still preparing",
        ]
      @unknown default:
        return [
          "status": "unavailable",
          "reason": "On-device model unavailable",
        ]
      }
    }

    @available(iOS 26.0, *)
    static func foundationPrepare() async {
      for _ in 0..<15 {
        switch SystemLanguageModel.default.availability {
        case .available:
          return
        case .unavailable(.modelNotReady):
          try? await Task.sleep(nanoseconds: 1_000_000_000)
        default:
          return
        }
      }
    }

    @available(iOS 26.0, *)
    static func foundationGenerate(
      system: String,
      user: String,
      history: [[String: Any]]
    ) async throws -> String {
      switch SystemLanguageModel.default.availability {
      case .available:
        break
      default:
        throw OnDeviceLlmError.unavailable
      }

      let folded = foldHistory(user: user, history: history)
      let session = LanguageModelSession(instructions: Instructions(system))
      let response = try await session.respond(to: folded)
      let text = String(describing: response.content)
      if text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
        throw OnDeviceLlmError.empty
      }
      return text
    }
  #endif

  static func foldHistory(user: String, history: [[String: Any]]) -> String {
    if history.isEmpty { return user }
    let prior = history.map { turn in
      let role = turn["role"] as? String ?? "user"
      let content = turn["content"] as? String ?? ""
      return "\(role): \(content)"
    }.joined(separator: "\n")
    return "\(prior)\n\n\(user)"
  }
}

enum OnDeviceLlmError: LocalizedError {
  case unavailable
  case empty

  var errorDescription: String? {
    switch self {
    case .unavailable:
      return "On-device Error: model unavailable"
    case .empty:
      return "On-device Error: empty response"
    }
  }
}

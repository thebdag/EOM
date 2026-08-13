import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    excludePreferencesFromBackup()
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  /// Keep API keys in UserDefaults off iCloud / iTunes backup.
  private func excludePreferencesFromBackup() {
    guard let id = Bundle.main.bundleIdentifier else { return }
    var prefs = FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask)[0]
      .appendingPathComponent("Preferences")
      .appendingPathComponent("\(id).plist")
    var values = URLResourceValues()
    values.isExcludedFromBackup = true
    try? prefs.setResourceValues(values)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
  }
}

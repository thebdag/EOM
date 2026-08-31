package com.eom.eom

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        OnDeviceLlmPlugin.registerWith(flutterEngine.dartExecutor.binaryMessenger)
    }
}

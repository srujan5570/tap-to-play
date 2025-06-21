package com.example.my_time

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.castarsdk.flutter/castar"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "startCastarSdk" -> {
                    val clientId = call.argument<String>("clientId")
                    if (clientId != null) {
                        try {
                            MyApplication.startCastarSdk(application, clientId)
                            result.success("Castar SDK started successfully with client ID: $clientId")
                        } catch (e: Exception) {
                            result.error("SDK_START_ERROR", "Failed to start Castar SDK", e.message)
                        }
                    } else {
                        result.error("INVALID_ARGUMENTS", "Client ID is required", null)
                    }
                }
                "stopCastarSdk" -> {
                    try {
                        MyApplication.stopCastarSdk()
                        result.success("Castar SDK stopped successfully")
                    } catch (e: Exception) {
                        result.error("SDK_STOP_ERROR", "Failed to stop Castar SDK", e.message)
                    }
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }
}

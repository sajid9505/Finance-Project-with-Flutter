package com.example.finance_tracker_mobile_application

import android.content.Context
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import org.json.JSONArray

class MainActivity : FlutterActivity() {

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "sms/channel"
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "setEnabled" -> {
                    val enabled = call.arguments as? Boolean ?: false
                    val prefs = getSharedPreferences(
                        "FlutterSharedPreferences", Context.MODE_PRIVATE
                    )
                    prefs.edit().putBoolean("flutter.sms_monitoring_enabled", enabled).apply()
                    result.success(null)
                }
                "updateSenderAllowlist" -> {
                    @Suppress("UNCHECKED_CAST")
                    val ids = call.arguments as? List<String> ?: emptyList()
                    val prefs = getSharedPreferences(
                        "FlutterSharedPreferences", Context.MODE_PRIVATE
                    )
                    val arr = JSONArray(ids)
                    prefs.edit().putString("flutter.sms_senders", arr.toString()).apply()
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }
    }
}

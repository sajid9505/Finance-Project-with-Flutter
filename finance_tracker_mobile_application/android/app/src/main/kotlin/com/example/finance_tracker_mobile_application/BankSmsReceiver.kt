package com.example.finance_tracker_mobile_application

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.provider.Telephony
import android.util.Log
import org.json.JSONArray
import org.json.JSONObject

class BankSmsReceiver : BroadcastReceiver() {

    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action != Telephony.Sms.Intents.SMS_RECEIVED_ACTION) return

        val messages = Telephony.Sms.Intents.getMessagesFromIntent(intent)
        if (messages.isNullOrEmpty()) return

        // Combine multipart SMS
        val sender = messages[0].originatingAddress ?: return
        val body = messages.joinToString("") { it.messageBody ?: "" }

        if (body.isBlank()) return

        val prefs = context.getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)

        // Check if monitoring is enabled
        val enabled = prefs.getBoolean("flutter.sms_monitoring_enabled", false)
        if (!enabled) return

        // Check sender against allowlist
        val allowlistJson = prefs.getString("flutter.sms_senders", null)
        if (allowlistJson.isNullOrEmpty()) return

        val allowlist = mutableListOf<String>()
        try {
            val arr = JSONArray(allowlistJson)
            for (i in 0 until arr.length()) allowlist.add(arr.getString(i))
        } catch (e: Exception) {
            Log.w("BankSmsReceiver", "Failed to parse allowlist: ${e.message}")
            return
        }

        // Case-insensitive sender match
        val matched = allowlist.any { it.equals(sender, ignoreCase = true) }
        if (!matched) return

        Log.d("BankSmsReceiver", "Bank SMS from $sender — queuing")

        // Enqueue for Flutter to process on next launch
        val queueKey = "flutter.sms_queue"
        val existing = prefs.getString(queueKey, "[]") ?: "[]"
        val queue = try { JSONArray(existing) } catch (_: Exception) { JSONArray() }
        val item = JSONObject().apply {
            put("body", body)
            put("sender", sender)
        }
        queue.put(item)
        prefs.edit().putString(queueKey, queue.toString()).apply()
    }
}

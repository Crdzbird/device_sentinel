package com.example.verygoodcore

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent

/**
 * Manifest-registered BroadcastReceiver for shutdown/reboot events.
 *
 * These intents fire when the device is powering down — the app process may
 * be terminated immediately afterwards, so we persist the event to
 * device-protected SharedPreferences. The plugin reads and replays the event
 * on the next [startSecurityMonitoring] call.
 */
class DeviceSecurityReceiver : BroadcastReceiver() {

    override fun onReceive(context: Context, intent: Intent) {
        val event = when (intent.action) {
            Intent.ACTION_SHUTDOWN -> "shutdown_detected"
            "android.intent.action.REBOOT" -> "reboot_detected"
            else -> return
        }

        try {
            val prefs = context.createDeviceProtectedStorageContext()
                .getSharedPreferences("device_sentinel_security", Context.MODE_PRIVATE)
            prefs.edit()
                .putString("pending_event", event)
                .putLong("last_seen", System.currentTimeMillis())
                .putBoolean("clean_shutdown", true)
                .apply()
        } catch (_: Exception) {
            // Best-effort — device-protected storage may not be available.
        }
    }
}

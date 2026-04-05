package com.example.verygoodcore

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent

/**
 * Manifest-registered BroadcastReceiver for BOOT_COMPLETED.
 *
 * Checks device-protected SharedPreferences:
 * - If a "pending_event" exists (shutdown/reboot), leave it for the plugin.
 * - If "clean_shutdown" is false and no pending event exists, the previous
 *   session ended abnormally (crash, battery pull, force kill). Write an
 *   "unclean_shutdown" event with the last heartbeat timestamp.
 */
class BootReceiver : BroadcastReceiver() {

    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action != Intent.ACTION_BOOT_COMPLETED) return

        try {
            val prefs = context.createDeviceProtectedStorageContext()
                .getSharedPreferences("device_sentinel_security", Context.MODE_PRIVATE)

            val pendingEvent = prefs.getString("pending_event", null)
            val cleanShutdown = prefs.getBoolean("clean_shutdown", true)

            if (pendingEvent == null && !cleanShutdown) {
                val lastSeen = prefs.getLong("last_seen", 0L)
                prefs.edit()
                    .putString("pending_event", "unclean_shutdown:$lastSeen")
                    .apply()
            }
        } catch (_: Exception) {
            // Best-effort.
        }
    }
}

package com.example.verygoodcore

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter

class PowerButtonDetector(
    private val context: Context,
    private val onEvent: (Map<String, String>) -> Unit,
) {

    private var receiver: BroadcastReceiver? = null

    fun start() {
        stop()
        if (receiver != null) return
        receiver = object : BroadcastReceiver() {
            override fun onReceive(ctx: Context?, intent: Intent?) {
                if (intent?.action == Intent.ACTION_SCREEN_OFF) {
                    onEvent(mapOf("button" to "power", "action" to "pressed"))
                }
            }
        }
        val filter = IntentFilter(Intent.ACTION_SCREEN_OFF)
        context.registerReceiver(receiver, filter)
    }

    fun stop() {
        receiver?.let {
            context.unregisterReceiver(it)
            receiver = null
        }
    }
}

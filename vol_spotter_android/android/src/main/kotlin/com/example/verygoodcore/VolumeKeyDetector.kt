package com.example.verygoodcore

import android.app.Activity
import android.view.KeyEvent
import android.view.Window

class VolumeKeyDetector(
    private val activity: Activity,
    private val intercept: Boolean,
    private val onEvent: (Map<String, String>) -> Unit,
) {

    private var originalCallback: Window.Callback? = null
    private var isActive = false

    fun start() {
        if (isActive) return
        isActive = true
        val window = activity.window
        originalCallback = window.callback
        window.callback = ProxyCallback(originalCallback)
    }

    fun stop() {
        if (!isActive) return
        isActive = false
        originalCallback?.let { activity.window.callback = it }
        originalCallback = null
    }

    private inner class ProxyCallback(
        private val original: Window.Callback?,
    ) : Window.Callback by (original ?: activity.window.callback) {

        override fun dispatchKeyEvent(event: KeyEvent): Boolean {
            val button = when (event.keyCode) {
                KeyEvent.KEYCODE_VOLUME_UP -> "volumeUp"
                KeyEvent.KEYCODE_VOLUME_DOWN -> "volumeDown"
                else -> null
            }
            if (button != null) {
                val action = when (event.action) {
                    KeyEvent.ACTION_DOWN -> "pressed"
                    KeyEvent.ACTION_UP -> "released"
                    else -> null
                }
                if (action != null) {
                    try {
                        onEvent(mapOf("button" to button, "action" to action))
                    } catch (_: Exception) {
                        // Prevent callback failures from crashing event dispatch.
                    }
                }
                if (intercept) return true
            }
            return original?.dispatchKeyEvent(event) ?: false
        }
    }
}

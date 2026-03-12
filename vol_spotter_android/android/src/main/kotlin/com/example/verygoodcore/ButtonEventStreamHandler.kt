package com.example.verygoodcore

import android.os.Handler
import android.os.Looper
import io.flutter.plugin.common.EventChannel

class ButtonEventStreamHandler : EventChannel.StreamHandler {

    @Volatile
    private var eventSink: EventChannel.EventSink? = null
    private val mainHandler = Handler(Looper.getMainLooper())

    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        eventSink = events
    }

    override fun onCancel(arguments: Any?) {
        eventSink = null
    }

    fun send(event: Map<String, String>) {
        mainHandler.post {
            eventSink?.success(event)
        }
    }
}

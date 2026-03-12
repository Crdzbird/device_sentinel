package com.example.verygoodcore

import android.app.Activity
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

class VolSpotterPlugin : FlutterPlugin, MethodCallHandler, ActivityAware {

    private lateinit var methodChannel: MethodChannel
    private lateinit var eventChannel: EventChannel
    private val streamHandler = ButtonEventStreamHandler()
    private var volumeKeyDetector: VolumeKeyDetector? = null
    private var powerButtonDetector: PowerButtonDetector? = null
    private var activity: Activity? = null
    private var interceptVolume = false

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        methodChannel = MethodChannel(binding.binaryMessenger, "vol_spotter_android")
        methodChannel.setMethodCallHandler(this)
        eventChannel = EventChannel(binding.binaryMessenger, "vol_spotter_android/events")
        eventChannel.setStreamHandler(streamHandler)
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            "getPlatformName" -> {
                result.success("Android ${android.os.Build.VERSION.RELEASE}")
            }
            "startListening" -> {
                interceptVolume = call.argument<Boolean>("interceptVolumeEvents") ?: false
                startDetection()
                result.success(null)
            }
            "stopListening" -> {
                stopDetection()
                result.success(null)
            }
            else -> result.notImplemented()
        }
    }

    private fun startDetection() {
        activity?.let { act ->
            volumeKeyDetector?.stop()
            volumeKeyDetector = VolumeKeyDetector(act, interceptVolume) { event ->
                streamHandler.send(event)
            }
            volumeKeyDetector?.start()
        }
        activity?.applicationContext?.let { ctx ->
            powerButtonDetector?.stop()
            powerButtonDetector = PowerButtonDetector(ctx) { event ->
                streamHandler.send(event)
            }
            powerButtonDetector?.start()
        }
    }

    private fun stopDetection() {
        volumeKeyDetector?.stop()
        volumeKeyDetector = null
        powerButtonDetector?.stop()
        powerButtonDetector = null
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        stopDetection()
        methodChannel.setMethodCallHandler(null)
        eventChannel.setStreamHandler(null)
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.activity
    }

    override fun onDetachedFromActivityForConfigChanges() {
        stopDetection()
        activity = null
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        activity = binding.activity
    }

    override fun onDetachedFromActivity() {
        stopDetection()
        activity = null
    }
}

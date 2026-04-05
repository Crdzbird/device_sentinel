package com.example.verygoodcore

import android.app.Activity
import android.content.Context
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

class DeviceSentinelPlugin : FlutterPlugin, MethodCallHandler, ActivityAware {

    private lateinit var methodChannel: MethodChannel
    private lateinit var eventChannel: EventChannel
    private lateinit var securityEventChannel: EventChannel
    private val streamHandler = ButtonEventStreamHandler()
    private val securityStreamHandler = SecurityEventStreamHandler()
    private var volumeKeyDetector: VolumeKeyDetector? = null
    private var powerButtonDetector: PowerButtonDetector? = null
    private var securityMonitor: DeviceSecurityMonitor? = null
    private var activity: Activity? = null
    private var appContext: Context? = null
    private var interceptVolumeUp = false
    private var interceptVolumeDown = false

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        appContext = binding.applicationContext

        methodChannel = MethodChannel(binding.binaryMessenger, "device_sentinel_android")
        methodChannel.setMethodCallHandler(this)

        eventChannel = EventChannel(binding.binaryMessenger, "device_sentinel_android/events")
        eventChannel.setStreamHandler(streamHandler)

        securityEventChannel = EventChannel(
            binding.binaryMessenger,
            "device_sentinel_android/security_events"
        )
        securityEventChannel.setStreamHandler(securityStreamHandler)
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            "getPlatformName" -> {
                result.success("Android ${android.os.Build.VERSION.RELEASE}")
            }
            "startListening" -> {
                interceptVolumeUp = call.argument<Boolean>("interceptVolumeUp") ?: false
                interceptVolumeDown = call.argument<Boolean>("interceptVolumeDown") ?: false
                startDetection()
                result.success(null)
            }
            "stopListening" -> {
                stopDetection()
                result.success(null)
            }
            "startSecurityMonitoring" -> {
                val config = mutableMapOf<String, Boolean>()
                call.argument<Boolean>("monitorShutdown")?.let { config["monitorShutdown"] = it }
                call.argument<Boolean>("monitorConnectivity")?.let { config["monitorConnectivity"] = it }
                call.argument<Boolean>("monitorScreenLock")?.let { config["monitorScreenLock"] = it }
                call.argument<Boolean>("monitorPowerUsb")?.let { config["monitorPowerUsb"] = it }
                call.argument<Boolean>("monitorSecurityPosture")?.let { config["monitorSecurityPosture"] = it }
                startSecurityMonitoring(config)
                result.success(null)
            }
            "stopSecurityMonitoring" -> {
                stopSecurityMonitoring()
                result.success(null)
            }
            else -> result.notImplemented()
        }
    }

    // -----------------------------------------------------------------------
    // Button Detection
    // -----------------------------------------------------------------------

    private fun startDetection() {
        activity?.let { act ->
            volumeKeyDetector?.stop()
            volumeKeyDetector = VolumeKeyDetector(act, interceptVolumeUp, interceptVolumeDown) { event ->
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

    // -----------------------------------------------------------------------
    // Security Monitoring
    // -----------------------------------------------------------------------

    private fun startSecurityMonitoring(config: Map<String, Boolean>) {
        val ctx = appContext ?: return

        // Replay any pending events from shutdown/reboot/unclean shutdown
        replayPendingEvents(ctx)

        securityMonitor?.stop()
        securityMonitor = DeviceSecurityMonitor(
            context = ctx,
            activity = activity,
            handler = securityStreamHandler,
            config = config
        )
        securityMonitor?.start()
    }

    private fun stopSecurityMonitoring() {
        securityMonitor?.stop()
        securityMonitor = null

        // Mark clean shutdown
        appContext?.let { ctx ->
            try {
                val prefs = ctx.createDeviceProtectedStorageContext()
                    .getSharedPreferences("device_sentinel_security", Context.MODE_PRIVATE)
                prefs.edit().putBoolean("clean_shutdown", true).apply()
            } catch (_: Exception) {}
        }
    }

    private fun replayPendingEvents(ctx: Context) {
        try {
            val prefs = ctx.createDeviceProtectedStorageContext()
                .getSharedPreferences("device_sentinel_security", Context.MODE_PRIVATE)
            val pendingEvent = prefs.getString("pending_event", null)
            if (pendingEvent != null) {
                securityStreamHandler.send(pendingEvent)
                prefs.edit().remove("pending_event").apply()
            }
        } catch (_: Exception) {}
    }

    // -----------------------------------------------------------------------
    // Lifecycle
    // -----------------------------------------------------------------------

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        stopDetection()
        stopSecurityMonitoring()
        methodChannel.setMethodCallHandler(null)
        eventChannel.setStreamHandler(null)
        securityEventChannel.setStreamHandler(null)
        appContext = null
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

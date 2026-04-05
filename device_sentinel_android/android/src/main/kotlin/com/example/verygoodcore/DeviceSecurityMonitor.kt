package com.example.verygoodcore

import android.app.Activity
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.database.ContentObserver
import android.net.ConnectivityManager
import android.net.Network
import android.net.NetworkCapabilities
import android.net.NetworkRequest
import android.os.BatteryManager
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.provider.Settings

class DeviceSecurityMonitor(
    private val context: Context,
    private val activity: Activity?,
    private val handler: SecurityEventStreamHandler,
    private val config: Map<String, Boolean>
) {
    private var dynamicReceiver: BroadcastReceiver? = null
    private var batteryReceiver: BroadcastReceiver? = null
    private var networkCallback: ConnectivityManager.NetworkCallback? = null
    private var adbObserver: ContentObserver? = null
    private var devModeObserver: ContentObserver? = null
    private var screenCaptureCallback: Any? = null
    private var lastBatteryLowEmitted = false
    private var lastBatteryCriticalEmitted = false
    private var lastVpnState: Boolean? = null

    fun start() {
        if (config["monitorScreenLock"] != false) registerScreenLockReceiver()
        if (config["monitorConnectivity"] != false) registerNetworkCallback()
        if (config["monitorPowerUsb"] != false) {
            registerPowerReceiver()
            registerBatteryReceiver()
            registerAdbObserver()
        }
        if (config["monitorSecurityPosture"] != false) {
            registerDevModeObserver()
            registerScreenCaptureCallback()
        }
        if (config["monitorShutdown"] != false) writeHeartbeat()
    }

    fun stop() {
        unregisterScreenLockReceiver()
        unregisterNetworkCallback()
        unregisterPowerReceiver()
        unregisterBatteryReceiver()
        unregisterAdbObserver()
        unregisterDevModeObserver()
        unregisterScreenCaptureCallback()
    }

    // -----------------------------------------------------------------------
    // Screen Lock / Unlock
    // -----------------------------------------------------------------------

    private fun registerScreenLockReceiver() {
        dynamicReceiver = object : BroadcastReceiver() {
            override fun onReceive(ctx: Context, intent: Intent) {
                when (intent.action) {
                    Intent.ACTION_SCREEN_OFF -> handler.send("screen_off")
                    Intent.ACTION_SCREEN_ON -> handler.send("screen_on")
                    Intent.ACTION_USER_PRESENT -> handler.send("user_present")
                }
            }
        }
        val filter = IntentFilter().apply {
            addAction(Intent.ACTION_SCREEN_OFF)
            addAction(Intent.ACTION_SCREEN_ON)
            addAction(Intent.ACTION_USER_PRESENT)
        }
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            context.registerReceiver(dynamicReceiver, filter, Context.RECEIVER_NOT_EXPORTED)
        } else {
            context.registerReceiver(dynamicReceiver, filter)
        }
    }

    private fun unregisterScreenLockReceiver() {
        dynamicReceiver?.let {
            try { context.unregisterReceiver(it) } catch (_: Exception) {}
        }
        dynamicReceiver = null
    }

    // -----------------------------------------------------------------------
    // Connectivity (Network + VPN)
    // -----------------------------------------------------------------------

    private fun registerNetworkCallback() {
        val cm = context.getSystemService(Context.CONNECTIVITY_SERVICE) as? ConnectivityManager
            ?: return

        networkCallback = object : ConnectivityManager.NetworkCallback() {
            override fun onAvailable(network: Network) {
                handler.send("network_connected")
            }

            override fun onLost(network: Network) {
                handler.send("network_disconnected")
            }

            override fun onCapabilitiesChanged(network: Network, caps: NetworkCapabilities) {
                val hasWifi = caps.hasTransport(NetworkCapabilities.TRANSPORT_WIFI)
                val hasMobile = caps.hasTransport(NetworkCapabilities.TRANSPORT_CELLULAR)
                handler.send("network_caps:$hasWifi:$hasMobile")

                val hasVpn = caps.hasTransport(NetworkCapabilities.TRANSPORT_VPN)
                if (hasVpn != lastVpnState) {
                    lastVpnState = hasVpn
                    handler.send(if (hasVpn) "vpn_established" else "vpn_disconnected")
                }
            }
        }

        val request = NetworkRequest.Builder()
            .addCapability(NetworkCapabilities.NET_CAPABILITY_INTERNET)
            .build()
        cm.registerNetworkCallback(request, networkCallback!!)

        // Airplane mode via broadcast
        val airplaneReceiver = object : BroadcastReceiver() {
            override fun onReceive(ctx: Context, intent: Intent) {
                if (intent.action == Intent.ACTION_AIRPLANE_MODE_CHANGED) {
                    val isOn = intent.getBooleanExtra("state", false)
                    handler.send(if (isOn) "airplane_mode_on" else "airplane_mode_off")
                }
            }
        }
        val airplaneFilter = IntentFilter(Intent.ACTION_AIRPLANE_MODE_CHANGED)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            context.registerReceiver(airplaneReceiver, airplaneFilter, Context.RECEIVER_NOT_EXPORTED)
        } else {
            context.registerReceiver(airplaneReceiver, airplaneFilter)
        }
    }

    private fun unregisterNetworkCallback() {
        networkCallback?.let {
            val cm = context.getSystemService(Context.CONNECTIVITY_SERVICE) as? ConnectivityManager
            try { cm?.unregisterNetworkCallback(it) } catch (_: Exception) {}
        }
        networkCallback = null
    }

    // -----------------------------------------------------------------------
    // Power Connected / Disconnected
    // -----------------------------------------------------------------------

    private var powerReceiver: BroadcastReceiver? = null

    private fun registerPowerReceiver() {
        powerReceiver = object : BroadcastReceiver() {
            override fun onReceive(ctx: Context, intent: Intent) {
                when (intent.action) {
                    Intent.ACTION_POWER_CONNECTED -> handler.send("power_connected")
                    Intent.ACTION_POWER_DISCONNECTED -> handler.send("power_disconnected")
                }
            }
        }
        val filter = IntentFilter().apply {
            addAction(Intent.ACTION_POWER_CONNECTED)
            addAction(Intent.ACTION_POWER_DISCONNECTED)
        }
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            context.registerReceiver(powerReceiver, filter, Context.RECEIVER_NOT_EXPORTED)
        } else {
            context.registerReceiver(powerReceiver, filter)
        }
    }

    private fun unregisterPowerReceiver() {
        powerReceiver?.let {
            try { context.unregisterReceiver(it) } catch (_: Exception) {}
        }
        powerReceiver = null
    }

    // -----------------------------------------------------------------------
    // Battery Level
    // -----------------------------------------------------------------------

    private fun registerBatteryReceiver() {
        batteryReceiver = object : BroadcastReceiver() {
            override fun onReceive(ctx: Context, intent: Intent) {
                val level = intent.getIntExtra(BatteryManager.EXTRA_LEVEL, -1)
                val scale = intent.getIntExtra(BatteryManager.EXTRA_SCALE, -1)
                if (level < 0 || scale <= 0) return
                val pct = (level * 100) / scale

                if (pct <= 5) {
                    if (!lastBatteryCriticalEmitted) {
                        lastBatteryCriticalEmitted = true
                        handler.send("battery_critical:$pct")
                    }
                } else {
                    lastBatteryCriticalEmitted = false
                }

                if (pct <= 20) {
                    if (!lastBatteryLowEmitted) {
                        lastBatteryLowEmitted = true
                        handler.send("battery_low:$pct")
                    }
                } else {
                    lastBatteryLowEmitted = false
                }
            }
        }
        val filter = IntentFilter(Intent.ACTION_BATTERY_CHANGED)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            context.registerReceiver(batteryReceiver, filter, Context.RECEIVER_NOT_EXPORTED)
        } else {
            context.registerReceiver(batteryReceiver, filter)
        }
    }

    private fun unregisterBatteryReceiver() {
        batteryReceiver?.let {
            try { context.unregisterReceiver(it) } catch (_: Exception) {}
        }
        batteryReceiver = null
    }

    // -----------------------------------------------------------------------
    // ADB / USB Debugging
    // -----------------------------------------------------------------------

    private var lastAdbState: Boolean? = null

    private fun registerAdbObserver() {
        val mainHandler = Handler(Looper.getMainLooper())
        adbObserver = object : ContentObserver(mainHandler) {
            override fun onChange(selfChange: Boolean) {
                val enabled = Settings.Global.getInt(
                    context.contentResolver,
                    Settings.Global.ADB_ENABLED,
                    0
                ) == 1
                if (enabled != lastAdbState) {
                    lastAdbState = enabled
                    handler.send(
                        if (enabled) "usb_debugging_enabled" else "usb_debugging_disabled"
                    )
                }
            }
        }
        context.contentResolver.registerContentObserver(
            Settings.Global.getUriFor(Settings.Global.ADB_ENABLED),
            false,
            adbObserver!!
        )
    }

    private fun unregisterAdbObserver() {
        adbObserver?.let {
            context.contentResolver.unregisterContentObserver(it)
        }
        adbObserver = null
    }

    // -----------------------------------------------------------------------
    // Developer Mode
    // -----------------------------------------------------------------------

    private var lastDevModeState: Boolean? = null

    private fun registerDevModeObserver() {
        val mainHandler = Handler(Looper.getMainLooper())
        devModeObserver = object : ContentObserver(mainHandler) {
            override fun onChange(selfChange: Boolean) {
                val enabled = Settings.Global.getInt(
                    context.contentResolver,
                    Settings.Global.DEVELOPMENT_SETTINGS_ENABLED,
                    0
                ) == 1
                if (enabled != lastDevModeState) {
                    lastDevModeState = enabled
                    handler.send(
                        if (enabled) "dev_mode_enabled" else "dev_mode_disabled"
                    )
                }
            }
        }
        context.contentResolver.registerContentObserver(
            Settings.Global.getUriFor(Settings.Global.DEVELOPMENT_SETTINGS_ENABLED),
            false,
            devModeObserver!!
        )
    }

    private fun unregisterDevModeObserver() {
        devModeObserver?.let {
            context.contentResolver.unregisterContentObserver(it)
        }
        devModeObserver = null
    }

    // -----------------------------------------------------------------------
    // Screen Capture (API 34+)
    // -----------------------------------------------------------------------

    private fun registerScreenCaptureCallback() {
        if (Build.VERSION.SDK_INT < 34) return
        val act = activity ?: return

        try {
            val callback = Activity.ScreenCaptureCallback {
                handler.send("screen_capture_started")
            }
            act.registerScreenCaptureCallback(
                act.mainExecutor,
                callback
            )
            screenCaptureCallback = callback
        } catch (_: Exception) {
            // API not available or permission issue
        }
    }

    private fun unregisterScreenCaptureCallback() {
        if (Build.VERSION.SDK_INT < 34) return
        val act = activity ?: return
        val callback = screenCaptureCallback as? Activity.ScreenCaptureCallback ?: return

        try {
            act.unregisterScreenCaptureCallback(callback)
        } catch (_: Exception) {}
        screenCaptureCallback = null
    }

    // -----------------------------------------------------------------------
    // Heartbeat (for unclean shutdown detection)
    // -----------------------------------------------------------------------

    private fun writeHeartbeat() {
        try {
            val prefs = context.createDeviceProtectedStorageContext()
                .getSharedPreferences("device_sentinel_security", Context.MODE_PRIVATE)
            prefs.edit()
                .putLong("last_seen", System.currentTimeMillis())
                .putBoolean("clean_shutdown", false)
                .apply()
        } catch (_: Exception) {
            // Device-protected storage not available on all devices
        }
    }
}

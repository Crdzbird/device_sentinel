import Foundation
import Network
import UIKit

/// Monitors device security events on iOS:
/// - Network connectivity & VPN (NWPathMonitor)
/// - Screen lock/unlock (Darwin notifications)
/// - Battery level & charging state (UIDevice)
/// - Screen capture detection (iOS 11+)
/// - Unclean shutdown detection (UserDefaults heartbeat)
class DeviceSecurityMonitor {

    private let sink: (String) -> Void
    private let config: [String: Bool]

    private var nwMonitor: NWPathMonitor?
    private var monitorQueue: DispatchQueue?
    private var heartbeatTimer: Timer?
    private var lastVpnState: Bool?
    private var lastBatteryLowEmitted = false
    private var lastBatteryCriticalEmitted = false

    init(sink: @escaping (String) -> Void, config: [String: Bool]) {
        self.sink = sink
        self.config = config
    }

    func start() {
        if config["monitorShutdown"] != false { startShutdownDetection() }
        if config["monitorConnectivity"] != false { startNetworkMonitoring() }
        if config["monitorScreenLock"] != false { startScreenLockMonitoring() }
        if config["monitorPowerUsb"] != false { startBatteryMonitoring() }
        if config["monitorSecurityPosture"] != false { startScreenCaptureMonitoring() }
    }

    func stop() {
        stopNetworkMonitoring()
        stopScreenLockMonitoring()
        stopBatteryMonitoring()
        stopScreenCaptureMonitoring()
        stopHeartbeat()
        markCleanShutdown()
    }

    // MARK: - Unclean Shutdown Detection

    private func startShutdownDetection() {
        let defaults = UserDefaults.standard
        let cleanShutdown = defaults.bool(forKey: "device_sentinel_clean_shutdown")
        let lastSeen = defaults.integer(forKey: "device_sentinel_last_seen")

        // Check for unclean shutdown from previous session
        if !cleanShutdown && lastSeen > 0 {
            sink("unclean_shutdown:\(lastSeen)")
        }

        // Reset flags and start heartbeat
        defaults.set(false, forKey: "device_sentinel_clean_shutdown")
        writeHeartbeat()
        startHeartbeatTimer()
    }

    private func startHeartbeatTimer() {
        heartbeatTimer = Timer.scheduledTimer(
            withTimeInterval: 30.0,
            repeats: true
        ) { [weak self] _ in
            self?.writeHeartbeat()
        }
    }

    private func writeHeartbeat() {
        let ts = Int(Date().timeIntervalSince1970 * 1000)
        UserDefaults.standard.set(ts, forKey: "device_sentinel_last_seen")
    }

    private func stopHeartbeat() {
        heartbeatTimer?.invalidate()
        heartbeatTimer = nil
    }

    private func markCleanShutdown() {
        UserDefaults.standard.set(true, forKey: "device_sentinel_clean_shutdown")
    }

    // MARK: - Network Monitoring

    private func startNetworkMonitoring() {
        let monitor = NWPathMonitor()
        let queue = DispatchQueue(label: "dev.crdzbird.device_sentinel.network")
        monitorQueue = queue

        var wasConnected: Bool?

        monitor.pathUpdateHandler = { [weak self] path in
            guard let self = self else { return }

            let connected = path.status == .satisfied
            if connected != wasConnected {
                wasConnected = connected
                self.sendOnMain(connected ? "network_connected" : "network_disconnected")
            }

            if connected {
                let hasWifi = path.usesInterfaceType(.wifi)
                let hasMobile = path.usesInterfaceType(.cellular)
                self.sendOnMain("network_caps:\(hasWifi):\(hasMobile)")

                // VPN heuristic: "other" interface type without wifi/cellular
                let hasVpn = path.usesInterfaceType(.other) && !hasWifi && !hasMobile
                if hasVpn != self.lastVpnState {
                    self.lastVpnState = hasVpn
                    self.sendOnMain(hasVpn ? "vpn_established" : "vpn_disconnected")
                }
            }
        }

        monitor.start(queue: queue)
        nwMonitor = monitor
    }

    private func stopNetworkMonitoring() {
        nwMonitor?.cancel()
        nwMonitor = nil
        monitorQueue = nil
    }

    // MARK: - Screen Lock / Unlock

    private func startScreenLockMonitoring() {
        // com.apple.springboard.lockcomplete — device locked
        let lockComplete = "com.apple.springboard.lockcomplete" as CFString
        CFNotificationCenterAddObserver(
            CFNotificationCenterGetDarwinNotifyCenter(),
            Unmanaged.passUnretained(self).toOpaque(),
            { _, observer, name, _, _ in
                guard let observer = observer else { return }
                let monitor = Unmanaged<DeviceSecurityMonitor>
                    .fromOpaque(observer)
                    .takeUnretainedValue()
                monitor.sendOnMain("device_locked")
            },
            lockComplete,
            nil,
            .deliverImmediately
        )

        // com.apple.springboard.lockstate — lock state changed (0 = unlocked)
        let lockState = "com.apple.springboard.lockstate" as CFString
        CFNotificationCenterAddObserver(
            CFNotificationCenterGetDarwinNotifyCenter(),
            Unmanaged.passUnretained(self).toOpaque(),
            { _, observer, name, _, _ in
                guard let observer = observer else { return }
                let monitor = Unmanaged<DeviceSecurityMonitor>
                    .fromOpaque(observer)
                    .takeUnretainedValue()
                // lockstate fires for both lock and unlock; lockcomplete
                // fires only on lock. We use a brief delay to check the
                // display state — if still on after lockstate, it's an unlock.
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    if UIScreen.main.brightness > 0 {
                        monitor.sink("device_unlocked")
                        monitor.sink("screen_on")
                    } else {
                        monitor.sink("screen_off")
                    }
                }
            },
            lockState,
            nil,
            .deliverImmediately
        )
    }

    private func stopScreenLockMonitoring() {
        CFNotificationCenterRemoveEveryObserver(
            CFNotificationCenterGetDarwinNotifyCenter(),
            Unmanaged.passUnretained(self).toOpaque()
        )
    }

    // MARK: - Battery & Charging

    private func startBatteryMonitoring() {
        UIDevice.current.isBatteryMonitoringEnabled = true

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(batteryLevelChanged),
            name: UIDevice.batteryLevelDidChangeNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(batteryStateChanged),
            name: UIDevice.batteryStateDidChangeNotification,
            object: nil
        )
    }

    private func stopBatteryMonitoring() {
        NotificationCenter.default.removeObserver(
            self,
            name: UIDevice.batteryLevelDidChangeNotification,
            object: nil
        )
        NotificationCenter.default.removeObserver(
            self,
            name: UIDevice.batteryStateDidChangeNotification,
            object: nil
        )
    }

    @objc private func batteryLevelChanged() {
        let level = Int(UIDevice.current.batteryLevel * 100)
        if level <= 5 {
            if !lastBatteryCriticalEmitted {
                lastBatteryCriticalEmitted = true
                sink("battery_critical:\(level)")
            }
        } else {
            lastBatteryCriticalEmitted = false
        }

        if level <= 20 {
            if !lastBatteryLowEmitted {
                lastBatteryLowEmitted = true
                sink("battery_low:\(level)")
            }
        } else {
            lastBatteryLowEmitted = false
        }
    }

    @objc private func batteryStateChanged() {
        switch UIDevice.current.batteryState {
        case .charging, .full:
            sink("power_connected")
        case .unplugged:
            sink("power_disconnected")
        default:
            break
        }
    }

    // MARK: - Screen Capture

    private func startScreenCaptureMonitoring() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(screenCaptureChanged),
            name: UIScreen.capturedDidChangeNotification,
            object: nil
        )
    }

    private func stopScreenCaptureMonitoring() {
        NotificationCenter.default.removeObserver(
            self,
            name: UIScreen.capturedDidChangeNotification,
            object: nil
        )
    }

    @objc private func screenCaptureChanged() {
        if UIScreen.main.isCaptured {
            sink("screen_capture_started")
        } else {
            sink("screen_capture_stopped")
        }
    }

    // MARK: - Helpers

    private func sendOnMain(_ event: String) {
        DispatchQueue.main.async { [weak self] in
            self?.sink(event)
        }
    }
}

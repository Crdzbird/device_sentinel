import Flutter
import UIKit

public class DeviceSentinelPlugin: NSObject, FlutterPlugin, FlutterStreamHandler {

    private var eventSink: FlutterEventSink?
    private var securityEventSink: FlutterEventSink?
    private var volumeDetector: VolumeButtonDetector?
    private var powerDetector: PowerButtonDetector?
    private var securityMonitor: DeviceSecurityMonitor?

    /// Secondary stream handler for security events.
    private lazy var securityStreamHandler = SecurityStreamHandler()

    public static func register(with registrar: FlutterPluginRegistrar) {
        let methodChannel = FlutterMethodChannel(
            name: "device_sentinel_ios",
            binaryMessenger: registrar.messenger()
        )
        let eventChannel = FlutterEventChannel(
            name: "device_sentinel_ios/events",
            binaryMessenger: registrar.messenger()
        )
        let securityEventChannel = FlutterEventChannel(
            name: "device_sentinel_ios/security_events",
            binaryMessenger: registrar.messenger()
        )
        let instance = DeviceSentinelPlugin()
        registrar.addMethodCallDelegate(instance, channel: methodChannel)
        eventChannel.setStreamHandler(instance)
        securityEventChannel.setStreamHandler(instance.securityStreamHandler)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "getPlatformName":
            result("iOS \(UIDevice.current.systemVersion)")
        case "startListening":
            let args = call.arguments as? [String: Any] ?? [:]
            let interceptVolumeUp = args["interceptVolumeUp"] as? Bool ?? false
            let interceptVolumeDown = args["interceptVolumeDown"] as? Bool ?? false
            startDetection(
                interceptVolumeUp: interceptVolumeUp,
                interceptVolumeDown: interceptVolumeDown
            )
            result(nil)
        case "stopListening":
            stopDetection()
            result(nil)
        case "startSecurityMonitoring":
            let args = call.arguments as? [String: Any] ?? [:]
            var config: [String: Bool] = [:]
            if let v = args["monitorShutdown"] as? Bool { config["monitorShutdown"] = v }
            if let v = args["monitorConnectivity"] as? Bool { config["monitorConnectivity"] = v }
            if let v = args["monitorScreenLock"] as? Bool { config["monitorScreenLock"] = v }
            if let v = args["monitorPowerUsb"] as? Bool { config["monitorPowerUsb"] = v }
            if let v = args["monitorSecurityPosture"] as? Bool { config["monitorSecurityPosture"] = v }
            startSecurityMonitoring(config: config)
            result(nil)
        case "stopSecurityMonitoring":
            stopSecurityMonitoring()
            result(nil)
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    // MARK: - Button Event Stream Handler

    public func onListen(
        withArguments arguments: Any?,
        eventSink events: @escaping FlutterEventSink
    ) -> FlutterError? {
        eventSink = events
        return nil
    }

    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        eventSink = nil
        return nil
    }

    // MARK: - Button Detection

    private func startDetection(
        interceptVolumeUp: Bool,
        interceptVolumeDown: Bool
    ) {
        stopDetection()
        volumeDetector = VolumeButtonDetector(
            interceptVolumeUp: interceptVolumeUp,
            interceptVolumeDown: interceptVolumeDown
        ) { [weak self] event in
            self?.sendEvent(event)
        }
        volumeDetector?.start()

        powerDetector = PowerButtonDetector { [weak self] event in
            self?.sendEvent(event)
        }
        powerDetector?.start()
    }

    private func stopDetection() {
        volumeDetector?.stop()
        volumeDetector = nil
        powerDetector?.stop()
        powerDetector = nil
    }

    private func sendEvent(_ event: [String: String]) {
        DispatchQueue.main.async { [weak self] in
            self?.eventSink?(event)
        }
    }

    // MARK: - Security Monitoring

    private func startSecurityMonitoring(config: [String: Bool]) {
        stopSecurityMonitoring()
        securityMonitor = DeviceSecurityMonitor(
            sink: { [weak self] event in
                DispatchQueue.main.async {
                    self?.securityStreamHandler.send(event)
                }
            },
            config: config
        )
        securityMonitor?.start()
    }

    private func stopSecurityMonitoring() {
        securityMonitor?.stop()
        securityMonitor = nil
    }
}

// MARK: - Security Stream Handler

/// A separate FlutterStreamHandler for the security event channel.
private class SecurityStreamHandler: NSObject, FlutterStreamHandler {
    private var eventSink: FlutterEventSink?

    func onListen(
        withArguments arguments: Any?,
        eventSink events: @escaping FlutterEventSink
    ) -> FlutterError? {
        self.eventSink = events
        return nil
    }

    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        eventSink = nil
        return nil
    }

    func send(_ event: String) {
        eventSink?(event)
    }
}

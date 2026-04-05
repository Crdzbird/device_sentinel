import FlutterMacOS
import Foundation

public class DeviceSentinelPlugin: NSObject, FlutterPlugin, FlutterStreamHandler {

    private var eventSink: FlutterEventSink?
    private var volumeDetector: VolumeKeyDetector?
    private var powerDetector: PowerButtonDetector?

    public static func register(with registrar: FlutterPluginRegistrar) {
        let methodChannel = FlutterMethodChannel(
            name: "device_sentinel_macos",
            binaryMessenger: registrar.messenger
        )
        let eventChannel = FlutterEventChannel(
            name: "device_sentinel_macos/events",
            binaryMessenger: registrar.messenger
        )
        let instance = DeviceSentinelPlugin()
        registrar.addMethodCallDelegate(instance, channel: methodChannel)
        eventChannel.setStreamHandler(instance)
    }

    public func handle(
        _ call: FlutterMethodCall,
        result: @escaping FlutterResult
    ) {
        switch call.method {
        case "getPlatformName":
            result(
                "macOS \(ProcessInfo.processInfo.operatingSystemVersionString)"
            )
        case "startListening":
            let args = call.arguments as? [String: Any] ?? [:]
            let interceptVolume =
                args["interceptVolumeEvents"] as? Bool ?? false
            startDetection(interceptVolume: interceptVolume)
            result(nil)
        case "stopListening":
            stopDetection()
            result(nil)
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    // MARK: - FlutterStreamHandler

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

    // MARK: - Detection Lifecycle

    private func startDetection(interceptVolume: Bool) {
        stopDetection()
        volumeDetector = VolumeKeyDetector(
            intercept: interceptVolume
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
}

import Flutter
import UIKit

public class VolSpotterPlugin: NSObject, FlutterPlugin, FlutterStreamHandler {

    private var eventSink: FlutterEventSink?
    private var volumeDetector: VolumeButtonDetector?
    private var powerDetector: PowerButtonDetector?

    public static func register(with registrar: FlutterPluginRegistrar) {
        let methodChannel = FlutterMethodChannel(
            name: "vol_spotter_ios",
            binaryMessenger: registrar.messenger()
        )
        let eventChannel = FlutterEventChannel(
            name: "vol_spotter_ios/events",
            binaryMessenger: registrar.messenger()
        )
        let instance = VolSpotterPlugin()
        registrar.addMethodCallDelegate(instance, channel: methodChannel)
        eventChannel.setStreamHandler(instance)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "getPlatformName":
            result("iOS \(UIDevice.current.systemVersion)")
        case "startListening":
            let args = call.arguments as? [String: Any] ?? [:]
            let interceptVolume = args["interceptVolumeEvents"] as? Bool ?? false
            startDetection(interceptVolume: interceptVolume)
            result(nil)
        case "stopListening":
            stopDetection()
            result(nil)
        default:
            result(FlutterMethodNotImplemented)
        }
    }

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

    private func startDetection(interceptVolume: Bool) {
        stopDetection()
        volumeDetector = VolumeButtonDetector(
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

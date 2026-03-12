import FlutterMacOS
import Foundation

public class VolSpotterPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "vol_spotter_macos", binaryMessenger: registrar.messenger)
    let instance = VolSpotterPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    result("macOS")
  }
}

import 'package:device_sentinel_platform_interface/device_sentinel_platform_interface.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// The macOS implementation of [DeviceSentinelPlatform].
///
/// Supports button detection only. Security monitoring is not available.
class DeviceSentinelMacOS extends DeviceSentinelPlatform
    with ButtonOnlyEventChannelMixin {
  /// The primary method channel for button lifecycle calls.
  @override
  @visibleForTesting
  final methodChannel = const MethodChannel('device_sentinel_macos');

  /// The event channel used to receive button events from native.
  @override
  @visibleForTesting
  final buttonEventChannel =
      const EventChannel('device_sentinel_macos/events');

  /// Registers this class as the default instance of [DeviceSentinelPlatform].
  static void registerWith() {
    DeviceSentinelPlatform.instance = DeviceSentinelMacOS();
  }
}

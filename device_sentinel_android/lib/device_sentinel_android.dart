import 'package:device_sentinel_platform_interface/device_sentinel_platform_interface.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// The Android implementation of [DeviceSentinelPlatform].
class DeviceSentinelAndroid extends DeviceSentinelPlatform
    with EventChannelMixin {
  /// The primary method channel (button lifecycle + getPlatformName).
  @override
  @visibleForTesting
  final methodChannel = const MethodChannel('device_sentinel_android');

  /// The event channel used to receive button events from native.
  @override
  @visibleForTesting
  final buttonEventChannel =
      const EventChannel('device_sentinel_android/events');

  /// The method channel used for security monitoring lifecycle calls.
  @override
  @visibleForTesting
  final securityMethodChannel =
      const MethodChannel('device_sentinel_android');

  /// The event channel used to receive security event strings from native.
  @override
  @visibleForTesting
  final securityEventChannel =
      const EventChannel('device_sentinel_android/security_events');

  /// Registers this class as the default instance of [DeviceSentinelPlatform].
  static void registerWith() {
    DeviceSentinelPlatform.instance = DeviceSentinelAndroid();
  }
}

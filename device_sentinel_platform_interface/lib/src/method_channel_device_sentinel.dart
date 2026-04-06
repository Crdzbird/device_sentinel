import 'package:device_sentinel_platform_interface/device_sentinel_platform_interface.dart';
import 'package:flutter/foundation.dart' show visibleForTesting;
import 'package:flutter/services.dart';

/// An implementation of [DeviceSentinelPlatform] that uses method channels.
class MethodChannelDeviceSentinel extends DeviceSentinelPlatform
    with EventChannelMixin {
  /// The primary method channel for button lifecycle calls.
  @override
  @visibleForTesting
  final methodChannel = const MethodChannel('device_sentinel');

  /// The event channel used to receive button events from native.
  @override
  @visibleForTesting
  final buttonEventChannel = const EventChannel('device_sentinel/events');

  /// The method channel used for security monitoring lifecycle calls.
  @override
  @visibleForTesting
  final securityMethodChannel = const MethodChannel('device_sentinel');

  /// The event channel used to receive security event strings from native.
  @override
  @visibleForTesting
  final securityEventChannel =
      const EventChannel('device_sentinel/security_events');
}

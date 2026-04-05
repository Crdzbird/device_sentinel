import 'package:device_sentinel_platform_interface/device_sentinel_platform_interface.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// The Linux implementation of [DeviceSentinelPlatform].
///
/// Neither button detection nor security monitoring is supported on Linux.
class DeviceSentinelLinux extends DeviceSentinelPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('device_sentinel_linux');

  /// Registers this class as the default instance of [DeviceSentinelPlatform].
  static void registerWith() {
    DeviceSentinelPlatform.instance = DeviceSentinelLinux();
  }

  @override
  Stream<DeviceEvent> get events => const Stream.empty();

  @override
  Future<void> start({SentinelConfig config = const SentinelConfig()}) {
    throw UnsupportedError('start is not supported on Linux.');
  }

  @override
  Future<void> stop() {
    throw UnsupportedError('stop is not supported on Linux.');
  }

  @override
  Future<String?> getPlatformName() {
    return methodChannel.invokeMethod<String>('getPlatformName');
  }
}

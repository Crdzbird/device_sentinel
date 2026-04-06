import 'package:device_sentinel_platform_interface/device_sentinel_platform_interface.dart';

/// {@template device_sentinel_linux}
/// The Linux implementation of [DeviceSentinelPlatform].
///
/// Neither button detection nor security monitoring is supported on Linux.
/// Calling [start] or [stop] throws [PlatformUnsupportedException].
/// {@endtemplate}
class DeviceSentinelLinux extends DeviceSentinelPlatform {
  /// {@macro device_sentinel_linux}

  /// Registers this class as the default instance of
  /// [DeviceSentinelPlatform].
  static void registerWith() {
    DeviceSentinelPlatform.instance = DeviceSentinelLinux();
  }

  @override
  Stream<DeviceEvent> get events => const Stream.empty();

  @override
  Future<void> start({SentinelConfig config = const SentinelConfig()}) {
    throw const PlatformUnsupportedException(
      platform: 'Linux',
      operation: 'start',
    );
  }

  @override
  Future<void> stop() {
    throw const PlatformUnsupportedException(
      platform: 'Linux',
      operation: 'stop',
    );
  }
}

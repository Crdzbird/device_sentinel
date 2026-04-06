import 'package:device_sentinel_platform_interface/device_sentinel_platform_interface.dart';

/// {@template device_sentinel_web}
/// The Web implementation of [DeviceSentinelPlatform].
///
/// Neither button detection nor security monitoring is supported on Web.
/// Calling [start] or [stop] throws [PlatformUnsupportedException].
/// {@endtemplate}
class DeviceSentinelWeb extends DeviceSentinelPlatform {
  /// {@macro device_sentinel_web}

  /// Registers this class as the default instance of
  /// [DeviceSentinelPlatform].
  static void registerWith([Object? registrar]) {
    DeviceSentinelPlatform.instance = DeviceSentinelWeb();
  }

  @override
  Stream<DeviceEvent> get events => const Stream.empty();

  @override
  Future<void> start({SentinelConfig config = const SentinelConfig()}) {
    throw const PlatformUnsupportedException(
      platform: 'Web',
      operation: 'start',
    );
  }

  @override
  Future<void> stop() {
    throw const PlatformUnsupportedException(
      platform: 'Web',
      operation: 'stop',
    );
  }
}

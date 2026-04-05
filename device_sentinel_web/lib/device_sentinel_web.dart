import 'package:device_sentinel_platform_interface/device_sentinel_platform_interface.dart';

/// The Web implementation of [DeviceSentinelPlatform].
///
/// Neither button detection nor security monitoring is supported on Web.
class DeviceSentinelWeb extends DeviceSentinelPlatform {
  /// Registers this class as the default instance of [DeviceSentinelPlatform].
  static void registerWith([Object? registrar]) {
    DeviceSentinelPlatform.instance = DeviceSentinelWeb();
  }

  @override
  Stream<DeviceEvent> get events => const Stream.empty();

  @override
  Future<void> start({SentinelConfig config = const SentinelConfig()}) {
    throw UnsupportedError('start is not supported on Web.');
  }

  @override
  Future<void> stop() {
    throw UnsupportedError('stop is not supported on Web.');
  }

  @override
  Future<String?> getPlatformName() async => 'Web';
}

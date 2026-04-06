import 'package:device_sentinel_platform_interface/src/method_channel_device_sentinel.dart';
import 'package:device_sentinel_platform_interface/src/models/models.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

export 'package:device_sentinel_platform_interface/src/button_only_event_channel_mixin.dart';
export 'package:device_sentinel_platform_interface/src/event_channel_mixin.dart';
export 'package:device_sentinel_platform_interface/src/models/models.dart';

/// {@template device_sentinel_platform}
/// The interface that implementations of device_sentinel must implement.
///
/// Platform implementations should extend this class
/// rather than implement it as `DeviceSentinel`.
///
/// Extending this class (using `extends`) ensures that the subclass will get
/// the default implementation, while platform implementations that `implements`
/// this interface will be broken by newly added [DeviceSentinelPlatform]
/// methods.
/// {@endtemplate}
abstract class DeviceSentinelPlatform extends PlatformInterface {
  /// {@macro device_sentinel_platform}
  DeviceSentinelPlatform() : super(token: _token);

  static final Object _token = Object();

  static DeviceSentinelPlatform _instance = MethodChannelDeviceSentinel();

  /// The default instance of [DeviceSentinelPlatform] to use.
  ///
  /// Defaults to [MethodChannelDeviceSentinel].
  static DeviceSentinelPlatform get instance => _instance;

  /// Platform-specific plugins should set this with their own
  /// platform-specific class that extends [DeviceSentinelPlatform] when they
  /// register themselves.
  static set instance(DeviceSentinelPlatform instance) {
    PlatformInterface.verify(instance, _token);
    _instance = instance;
  }

  /// A unified broadcast stream of all device events — both physical
  /// button events and security events.
  ///
  /// Use `whereType<ButtonEvent>()` or `whereType<DeviceSecurityEvent>()`
  /// to filter for a specific category.
  Stream<DeviceEvent> get events;

  /// Starts monitoring with the given [config].
  ///
  /// The [SentinelConfig] controls both per-button interception (e.g.
  /// [SentinelConfig.interceptVolumeUp]) and security event categories.
  Future<void> start({SentinelConfig config = const SentinelConfig()});

  /// Stops all monitoring and releases native resources.
  Future<void> stop();
}

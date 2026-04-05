import 'package:device_sentinel_platform_interface/device_sentinel_platform_interface.dart';

export 'package:device_sentinel_platform_interface/device_sentinel_platform_interface.dart'
    show
        AirplaneModeOff,
        AirplaneModeOn,
        BatteryCritical,
        BatteryLow,
        ButtonAction,
        ButtonEvent,
        ButtonPressed,
        ButtonReleased,
        DevModeDisabled,
        DevModeEnabled,
        DeviceEvent,
        DeviceLocked,
        DeviceSecurityEvent,
        DeviceUnlocked,
        NetworkCapsChanged,
        NetworkConnected,
        NetworkDisconnected,
        PhysicalButton,
        PowerButton,
        PowerConnected,
        PowerDisconnected,
        RebootDetected,
        ScreenCaptureStarted,
        ScreenCaptureStopped,
        ScreenOff,
        ScreenOn,
        SentinelConfig,
        ShutdownDetected,
        UncleanShutdownDetected,
        UsbDebuggingDisabled,
        UsbDebuggingEnabled,
        UserPresent,
        VolumeDownButton,
        VolumeUpButton,
        VpnDisconnected,
        VpnEstablished;

DeviceSentinelPlatform get _platform => DeviceSentinelPlatform.instance;

/// {@template device_sentinel}
/// A plugin for detecting physical hardware events and device security events.
///
/// Provides a single unified [events] stream that delivers both
/// [ButtonEvent]s and [DeviceSecurityEvent]s. Use [SentinelConfig] to
/// control per-button interception and security monitoring categories.
///
/// ```dart
/// final sentinel = const DeviceSentinel();
///
/// sentinel.events.listen((event) {
///   switch (event) {
///     case ButtonEvent(:final button, :final action):
///       print('Button: $button $action');
///     case DeviceSecurityEvent():
///       print('Security: $event');
///   }
/// });
///
/// await sentinel.start(
///   config: SentinelConfig(interceptVolumeUp: true),
/// );
/// ```
/// {@endtemplate}
class DeviceSentinel {
  /// {@macro device_sentinel}
  const DeviceSentinel();

  /// A unified broadcast stream of all device events.
  ///
  /// Emits both [ButtonEvent]s and [DeviceSecurityEvent]s.
  /// Use `whereType<T>()` to filter for a specific event category.
  Stream<DeviceEvent> get events => _platform.events;

  /// Starts monitoring with the given [config].
  ///
  /// [SentinelConfig] controls:
  /// - **Per-button interception**: [SentinelConfig.interceptVolumeUp],
  ///   [SentinelConfig.interceptVolumeDown], [SentinelConfig.interceptPower]
  /// - **Security categories**: [SentinelConfig.monitorShutdown],
  ///   [SentinelConfig.monitorConnectivity], etc.
  Future<void> start({SentinelConfig config = const SentinelConfig()}) =>
      _platform.start(config: config);

  /// Stops all monitoring and releases native resources.
  Future<void> stop() => _platform.stop();
}

/// Returns the name of the current platform.
@Deprecated('Use DeviceSentinel instead.')
Future<String> getPlatformName() async {
  final platformName = await _platform.getPlatformName();
  if (platformName == null) throw Exception('Unable to get platform name.');
  return platformName;
}

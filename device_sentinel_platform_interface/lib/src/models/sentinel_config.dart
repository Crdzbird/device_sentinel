import 'package:meta/meta.dart';

/// Unified configuration for the device sentinel plugin.
///
/// Controls per-button interception and security monitoring categories
/// in a single configuration object passed to the sentinel's `start` method.
///
/// **Button interception** — when enabled, the native platform consumes the
/// button event and prevents its default behaviour (e.g. volume change).
/// Power button interception is observe-only on both Android and iOS.
///
/// **Security categories** — each flag controls an entire category of
/// security events. All categories are enabled by default.
@immutable
final class SentinelConfig {
  /// Creates a [SentinelConfig] with optional per-button interception
  /// and security monitoring toggles.
  const SentinelConfig({
    // Button interception
    this.interceptVolumeUp = false,
    this.interceptVolumeDown = false,
    this.interceptPower = false,
    // Security monitoring categories
    this.monitorShutdown = true,
    this.monitorConnectivity = true,
    this.monitorScreenLock = true,
    this.monitorPowerUsb = true,
    this.monitorSecurityPosture = true,
  });

  /// Creates a [SentinelConfig] from a map (e.g. from a method-channel call).
  factory SentinelConfig.fromMap(Map<String, dynamic> map) {
    return SentinelConfig(
      interceptVolumeUp: map['interceptVolumeUp'] as bool? ?? false,
      interceptVolumeDown: map['interceptVolumeDown'] as bool? ?? false,
      interceptPower: map['interceptPower'] as bool? ?? false,
      monitorShutdown: map['monitorShutdown'] as bool? ?? true,
      monitorConnectivity: map['monitorConnectivity'] as bool? ?? true,
      monitorScreenLock: map['monitorScreenLock'] as bool? ?? true,
      monitorPowerUsb: map['monitorPowerUsb'] as bool? ?? true,
      monitorSecurityPosture: map['monitorSecurityPosture'] as bool? ?? true,
    );
  }

  // ---- Button interception ------------------------------------------------

  /// When `true`, volume-up events are consumed; the system volume will not
  /// increase. When `false`, events are observed without side effects.
  final bool interceptVolumeUp;

  /// When `true`, volume-down events are consumed; the system volume will not
  /// decrease. When `false`, events are observed without side effects.
  final bool interceptVolumeDown;

  /// When `true`, the plugin attempts to intercept power button events.
  ///
  /// Note: Neither Android nor iOS can truly prevent the power button
  /// from triggering its system behaviour (screen off/lock). This flag
  /// is effectively observe-only on both platforms.
  final bool interceptPower;

  // ---- Security monitoring ------------------------------------------------

  /// Whether to monitor shutdown, reboot, and unclean-shutdown events.
  final bool monitorShutdown;

  /// Whether to monitor network, airplane-mode, and VPN events.
  final bool monitorConnectivity;

  /// Whether to monitor screen on/off and device lock/unlock events.
  final bool monitorScreenLock;

  /// Whether to monitor power/charger, battery level, and USB debugging events.
  final bool monitorPowerUsb;

  /// Whether to monitor screen capture and developer-mode events.
  final bool monitorSecurityPosture;

  /// Serializes the button-interception portion of this config.
  Map<String, dynamic> toButtonMap() => {
        'interceptVolumeUp': interceptVolumeUp,
        'interceptVolumeDown': interceptVolumeDown,
        'interceptPower': interceptPower,
      };

  /// Serializes the security-monitoring portion of this config.
  Map<String, dynamic> toSecurityMap() => {
        'monitorShutdown': monitorShutdown,
        'monitorConnectivity': monitorConnectivity,
        'monitorScreenLock': monitorScreenLock,
        'monitorPowerUsb': monitorPowerUsb,
        'monitorSecurityPosture': monitorSecurityPosture,
      };

  /// Serializes this entire config to a single map.
  Map<String, dynamic> toMap() => {
        ...toButtonMap(),
        ...toSecurityMap(),
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SentinelConfig &&
          other.interceptVolumeUp == interceptVolumeUp &&
          other.interceptVolumeDown == interceptVolumeDown &&
          other.interceptPower == interceptPower &&
          other.monitorShutdown == monitorShutdown &&
          other.monitorConnectivity == monitorConnectivity &&
          other.monitorScreenLock == monitorScreenLock &&
          other.monitorPowerUsb == monitorPowerUsb &&
          other.monitorSecurityPosture == monitorSecurityPosture;

  @override
  int get hashCode => Object.hash(
        interceptVolumeUp,
        interceptVolumeDown,
        interceptPower,
        monitorShutdown,
        monitorConnectivity,
        monitorScreenLock,
        monitorPowerUsb,
        monitorSecurityPosture,
      );

  @override
  String toString() => 'SentinelConfig('
      'interceptVolumeUp: $interceptVolumeUp, '
      'interceptVolumeDown: $interceptVolumeDown, '
      'interceptPower: $interceptPower, '
      'monitorShutdown: $monitorShutdown, '
      'monitorConnectivity: $monitorConnectivity, '
      'monitorScreenLock: $monitorScreenLock, '
      'monitorPowerUsb: $monitorPowerUsb, '
      'monitorSecurityPosture: $monitorSecurityPosture)';
}

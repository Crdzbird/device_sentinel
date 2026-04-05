import 'package:meta/meta.dart';

/// Configuration for the security event monitoring system.
///
/// Each flag controls an entire category of events. All categories are
/// enabled by default.
@immutable
final class SecurityConfig {
  /// Creates a [SecurityConfig] with optional category toggles.
  const SecurityConfig({
    this.monitorShutdown = true,
    this.monitorConnectivity = true,
    this.monitorScreenLock = true,
    this.monitorPowerUsb = true,
    this.monitorSecurityPosture = true,
  });

  /// Creates a [SecurityConfig] from a map (e.g. from a method-channel call).
  factory SecurityConfig.fromMap(Map<String, dynamic> map) {
    return SecurityConfig(
      monitorShutdown: map['monitorShutdown'] as bool? ?? true,
      monitorConnectivity: map['monitorConnectivity'] as bool? ?? true,
      monitorScreenLock: map['monitorScreenLock'] as bool? ?? true,
      monitorPowerUsb: map['monitorPowerUsb'] as bool? ?? true,
      monitorSecurityPosture: map['monitorSecurityPosture'] as bool? ?? true,
    );
  }

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

  /// Serializes this config to a map suitable for a method-channel call.
  Map<String, dynamic> toMap() {
    return {
      'monitorShutdown': monitorShutdown,
      'monitorConnectivity': monitorConnectivity,
      'monitorScreenLock': monitorScreenLock,
      'monitorPowerUsb': monitorPowerUsb,
      'monitorSecurityPosture': monitorSecurityPosture,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SecurityConfig &&
          other.monitorShutdown == monitorShutdown &&
          other.monitorConnectivity == monitorConnectivity &&
          other.monitorScreenLock == monitorScreenLock &&
          other.monitorPowerUsb == monitorPowerUsb &&
          other.monitorSecurityPosture == monitorSecurityPosture;

  @override
  int get hashCode => Object.hash(
        monitorShutdown,
        monitorConnectivity,
        monitorScreenLock,
        monitorPowerUsb,
        monitorSecurityPosture,
      );

  @override
  String toString() => 'SecurityConfig('
      'shutdown=$monitorShutdown, '
      'connectivity=$monitorConnectivity, '
      'screenLock=$monitorScreenLock, '
      'powerUsb=$monitorPowerUsb, '
      'securityPosture=$monitorSecurityPosture)';
}

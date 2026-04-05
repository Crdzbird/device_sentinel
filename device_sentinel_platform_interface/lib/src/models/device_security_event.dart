import 'package:device_sentinel_platform_interface/src/models/device_event.dart';
import 'package:meta/meta.dart';

/// Represents a device security event detected by the native platform.
///
/// Events are transmitted over the EventChannel as plain strings for simplicity
/// and forward compatibility. The [parse] factory returns `null` for unknown
/// strings, allowing old Dart code to gracefully handle events from newer
/// native versions.
@immutable
sealed class DeviceSecurityEvent extends DeviceEvent {
  const DeviceSecurityEvent();

  /// Parses a wire-format string into a [DeviceSecurityEvent].
  ///
  /// Returns `null` for unrecognised strings (forward compatibility).
  static DeviceSecurityEvent? parse(String raw) {
    // Handle parameterised events first.
    if (raw.startsWith('unclean_shutdown:')) {
      final ts = int.tryParse(raw.substring('unclean_shutdown:'.length));
      if (ts == null) return null;
      return UncleanShutdownDetected(lastSeenTimestamp: ts);
    }
    if (raw.startsWith('network_caps:')) {
      final parts = raw.split(':');
      if (parts.length != 3) return null;
      final hasWifi = parts[1] == 'true';
      final hasMobile = parts[2] == 'true';
      return NetworkCapsChanged(hasWifi: hasWifi, hasMobile: hasMobile);
    }
    if (raw.startsWith('battery_low:')) {
      final level = int.tryParse(raw.substring('battery_low:'.length));
      if (level == null) return null;
      return BatteryLow(level: level);
    }
    if (raw.startsWith('battery_critical:')) {
      final level = int.tryParse(raw.substring('battery_critical:'.length));
      if (level == null) return null;
      return BatteryCritical(level: level);
    }

    // Simple (non-parameterised) events.
    return switch (raw) {
      'shutdown_detected' => const ShutdownDetected(),
      'reboot_detected' => const RebootDetected(),
      'airplane_mode_on' => const AirplaneModeOn(),
      'airplane_mode_off' => const AirplaneModeOff(),
      'network_connected' => const NetworkConnected(),
      'network_disconnected' => const NetworkDisconnected(),
      'vpn_established' => const VpnEstablished(),
      'vpn_disconnected' => const VpnDisconnected(),
      'screen_off' => const ScreenOff(),
      'screen_on' => const ScreenOn(),
      'device_locked' => const DeviceLocked(),
      'device_unlocked' => const DeviceUnlocked(),
      'user_present' => const UserPresent(),
      'power_connected' => const PowerConnected(),
      'power_disconnected' => const PowerDisconnected(),
      'usb_debugging_enabled' => const UsbDebuggingEnabled(),
      'usb_debugging_disabled' => const UsbDebuggingDisabled(),
      'screen_capture_started' => const ScreenCaptureStarted(),
      'screen_capture_stopped' => const ScreenCaptureStopped(),
      'dev_mode_enabled' => const DevModeEnabled(),
      'dev_mode_disabled' => const DevModeDisabled(),
      _ => null,
    };
  }

  /// The string representation sent over the EventChannel wire.
  String get wireValue;
}

// ---------------------------------------------------------------------------
// Shutdown / Reboot
// ---------------------------------------------------------------------------

/// The device is shutting down (Android `ACTION_SHUTDOWN`).
@immutable
final class ShutdownDetected extends DeviceSecurityEvent {
  /// Creates a [ShutdownDetected] event.
  const ShutdownDetected();

  @override
  String get wireValue => 'shutdown_detected';

  @override
  bool operator ==(Object other) => other is ShutdownDetected;

  @override
  int get hashCode => wireValue.hashCode;

  @override
  String toString() => 'DeviceSecurityEvent.shutdownDetected';
}

/// The device is rebooting (Android `ACTION_REBOOT`).
@immutable
final class RebootDetected extends DeviceSecurityEvent {
  /// Creates a [RebootDetected] event.
  const RebootDetected();

  @override
  String get wireValue => 'reboot_detected';

  @override
  bool operator ==(Object other) => other is RebootDetected;

  @override
  int get hashCode => wireValue.hashCode;

  @override
  String toString() => 'DeviceSecurityEvent.rebootDetected';
}

/// An unclean shutdown was detected on boot (e.g. crash, force-kill, battery
/// pull). [lastSeenTimestamp] is the epoch-millis heartbeat written before the
/// crash.
@immutable
final class UncleanShutdownDetected extends DeviceSecurityEvent {
  /// Creates an [UncleanShutdownDetected] event.
  const UncleanShutdownDetected({required this.lastSeenTimestamp});

  /// Epoch-millisecond timestamp of the last recorded heartbeat.
  final int lastSeenTimestamp;

  @override
  String get wireValue => 'unclean_shutdown:$lastSeenTimestamp';

  @override
  bool operator ==(Object other) =>
      other is UncleanShutdownDetected &&
      other.lastSeenTimestamp == lastSeenTimestamp;

  @override
  int get hashCode => Object.hash(wireValue, lastSeenTimestamp);

  @override
  String toString() =>
      'DeviceSecurityEvent.uncleanShutdownDetected($lastSeenTimestamp)';
}

// ---------------------------------------------------------------------------
// Connectivity
// ---------------------------------------------------------------------------

/// Airplane mode was enabled.
@immutable
final class AirplaneModeOn extends DeviceSecurityEvent {
  /// Creates an [AirplaneModeOn] event.
  const AirplaneModeOn();

  @override
  String get wireValue => 'airplane_mode_on';

  @override
  bool operator ==(Object other) => other is AirplaneModeOn;

  @override
  int get hashCode => wireValue.hashCode;

  @override
  String toString() => 'DeviceSecurityEvent.airplaneModeOn';
}

/// Airplane mode was disabled.
@immutable
final class AirplaneModeOff extends DeviceSecurityEvent {
  /// Creates an [AirplaneModeOff] event.
  const AirplaneModeOff();

  @override
  String get wireValue => 'airplane_mode_off';

  @override
  bool operator ==(Object other) => other is AirplaneModeOff;

  @override
  int get hashCode => wireValue.hashCode;

  @override
  String toString() => 'DeviceSecurityEvent.airplaneModeOff';
}

/// A network connection became available.
@immutable
final class NetworkConnected extends DeviceSecurityEvent {
  /// Creates a [NetworkConnected] event.
  const NetworkConnected();

  @override
  String get wireValue => 'network_connected';

  @override
  bool operator ==(Object other) => other is NetworkConnected;

  @override
  int get hashCode => wireValue.hashCode;

  @override
  String toString() => 'DeviceSecurityEvent.networkConnected';
}

/// All network connections were lost.
@immutable
final class NetworkDisconnected extends DeviceSecurityEvent {
  /// Creates a [NetworkDisconnected] event.
  const NetworkDisconnected();

  @override
  String get wireValue => 'network_disconnected';

  @override
  bool operator ==(Object other) => other is NetworkDisconnected;

  @override
  int get hashCode => wireValue.hashCode;

  @override
  String toString() => 'DeviceSecurityEvent.networkDisconnected';
}

/// Network capabilities changed — reports which transports are active.
@immutable
final class NetworkCapsChanged extends DeviceSecurityEvent {
  /// Creates a [NetworkCapsChanged] event.
  const NetworkCapsChanged({
    required this.hasWifi,
    required this.hasMobile,
  });

  /// Whether Wi-Fi transport is available.
  final bool hasWifi;

  /// Whether cellular/mobile transport is available.
  final bool hasMobile;

  @override
  String get wireValue => 'network_caps:$hasWifi:$hasMobile';

  @override
  bool operator ==(Object other) =>
      other is NetworkCapsChanged &&
      other.hasWifi == hasWifi &&
      other.hasMobile == hasMobile;

  @override
  int get hashCode => Object.hash(wireValue, hasWifi, hasMobile);

  @override
  String toString() =>
      'DeviceSecurityEvent.networkCapsChanged('
      'wifi=$hasWifi, mobile=$hasMobile)';
}

/// A VPN connection was established.
@immutable
final class VpnEstablished extends DeviceSecurityEvent {
  /// Creates a [VpnEstablished] event.
  const VpnEstablished();

  @override
  String get wireValue => 'vpn_established';

  @override
  bool operator ==(Object other) => other is VpnEstablished;

  @override
  int get hashCode => wireValue.hashCode;

  @override
  String toString() => 'DeviceSecurityEvent.vpnEstablished';
}

/// The VPN connection was lost.
@immutable
final class VpnDisconnected extends DeviceSecurityEvent {
  /// Creates a [VpnDisconnected] event.
  const VpnDisconnected();

  @override
  String get wireValue => 'vpn_disconnected';

  @override
  bool operator ==(Object other) => other is VpnDisconnected;

  @override
  int get hashCode => wireValue.hashCode;

  @override
  String toString() => 'DeviceSecurityEvent.vpnDisconnected';
}

// ---------------------------------------------------------------------------
// Screen / Lock
// ---------------------------------------------------------------------------

/// The device screen was turned off.
@immutable
final class ScreenOff extends DeviceSecurityEvent {
  /// Creates a [ScreenOff] event.
  const ScreenOff();

  @override
  String get wireValue => 'screen_off';

  @override
  bool operator ==(Object other) => other is ScreenOff;

  @override
  int get hashCode => wireValue.hashCode;

  @override
  String toString() => 'DeviceSecurityEvent.screenOff';
}

/// The device screen was turned on.
@immutable
final class ScreenOn extends DeviceSecurityEvent {
  /// Creates a [ScreenOn] event.
  const ScreenOn();

  @override
  String get wireValue => 'screen_on';

  @override
  bool operator ==(Object other) => other is ScreenOn;

  @override
  int get hashCode => wireValue.hashCode;

  @override
  String toString() => 'DeviceSecurityEvent.screenOn';
}

/// The device was locked.
@immutable
final class DeviceLocked extends DeviceSecurityEvent {
  /// Creates a [DeviceLocked] event.
  const DeviceLocked();

  @override
  String get wireValue => 'device_locked';

  @override
  bool operator ==(Object other) => other is DeviceLocked;

  @override
  int get hashCode => wireValue.hashCode;

  @override
  String toString() => 'DeviceSecurityEvent.deviceLocked';
}

/// The device was unlocked.
@immutable
final class DeviceUnlocked extends DeviceSecurityEvent {
  /// Creates a [DeviceUnlocked] event.
  const DeviceUnlocked();

  @override
  String get wireValue => 'device_unlocked';

  @override
  bool operator ==(Object other) => other is DeviceUnlocked;

  @override
  int get hashCode => wireValue.hashCode;

  @override
  String toString() => 'DeviceSecurityEvent.deviceUnlocked';
}

/// The user completed the unlock + dismissed the keyguard (Android only).
@immutable
final class UserPresent extends DeviceSecurityEvent {
  /// Creates a [UserPresent] event.
  const UserPresent();

  @override
  String get wireValue => 'user_present';

  @override
  bool operator ==(Object other) => other is UserPresent;

  @override
  int get hashCode => wireValue.hashCode;

  @override
  String toString() => 'DeviceSecurityEvent.userPresent';
}

// ---------------------------------------------------------------------------
// Power / USB
// ---------------------------------------------------------------------------

/// A power source (charger) was connected.
@immutable
final class PowerConnected extends DeviceSecurityEvent {
  /// Creates a [PowerConnected] event.
  const PowerConnected();

  @override
  String get wireValue => 'power_connected';

  @override
  bool operator ==(Object other) => other is PowerConnected;

  @override
  int get hashCode => wireValue.hashCode;

  @override
  String toString() => 'DeviceSecurityEvent.powerConnected';
}

/// The power source (charger) was disconnected.
@immutable
final class PowerDisconnected extends DeviceSecurityEvent {
  /// Creates a [PowerDisconnected] event.
  const PowerDisconnected();

  @override
  String get wireValue => 'power_disconnected';

  @override
  bool operator ==(Object other) => other is PowerDisconnected;

  @override
  int get hashCode => wireValue.hashCode;

  @override
  String toString() => 'DeviceSecurityEvent.powerDisconnected';
}

/// Battery level dropped to or below 20%.
@immutable
final class BatteryLow extends DeviceSecurityEvent {
  /// Creates a [BatteryLow] event.
  const BatteryLow({required this.level});

  /// Current battery level (0–100).
  final int level;

  @override
  String get wireValue => 'battery_low:$level';

  @override
  bool operator ==(Object other) =>
      other is BatteryLow && other.level == level;

  @override
  int get hashCode => Object.hash(wireValue, level);

  @override
  String toString() => 'DeviceSecurityEvent.batteryLow($level)';
}

/// Battery level dropped to or below 5%.
@immutable
final class BatteryCritical extends DeviceSecurityEvent {
  /// Creates a [BatteryCritical] event.
  const BatteryCritical({required this.level});

  /// Current battery level (0–100).
  final int level;

  @override
  String get wireValue => 'battery_critical:$level';

  @override
  bool operator ==(Object other) =>
      other is BatteryCritical && other.level == level;

  @override
  int get hashCode => Object.hash(wireValue, level);

  @override
  String toString() => 'DeviceSecurityEvent.batteryCritical($level)';
}

/// USB debugging (ADB) was enabled on the device (Android only).
@immutable
final class UsbDebuggingEnabled extends DeviceSecurityEvent {
  /// Creates a [UsbDebuggingEnabled] event.
  const UsbDebuggingEnabled();

  @override
  String get wireValue => 'usb_debugging_enabled';

  @override
  bool operator ==(Object other) => other is UsbDebuggingEnabled;

  @override
  int get hashCode => wireValue.hashCode;

  @override
  String toString() => 'DeviceSecurityEvent.usbDebuggingEnabled';
}

/// USB debugging (ADB) was disabled on the device (Android only).
@immutable
final class UsbDebuggingDisabled extends DeviceSecurityEvent {
  /// Creates a [UsbDebuggingDisabled] event.
  const UsbDebuggingDisabled();

  @override
  String get wireValue => 'usb_debugging_disabled';

  @override
  bool operator ==(Object other) => other is UsbDebuggingDisabled;

  @override
  int get hashCode => wireValue.hashCode;

  @override
  String toString() => 'DeviceSecurityEvent.usbDebuggingDisabled';
}

// ---------------------------------------------------------------------------
// Security Posture
// ---------------------------------------------------------------------------

/// Screen capture / screen recording started.
///
/// Android: API 34+ `Activity.ScreenCaptureCallback`.
/// iOS: `UIScreen.capturedDidChangeNotification` (iOS 17+).
@immutable
final class ScreenCaptureStarted extends DeviceSecurityEvent {
  /// Creates a [ScreenCaptureStarted] event.
  const ScreenCaptureStarted();

  @override
  String get wireValue => 'screen_capture_started';

  @override
  bool operator ==(Object other) => other is ScreenCaptureStarted;

  @override
  int get hashCode => wireValue.hashCode;

  @override
  String toString() => 'DeviceSecurityEvent.screenCaptureStarted';
}

/// Screen capture / screen recording stopped.
@immutable
final class ScreenCaptureStopped extends DeviceSecurityEvent {
  /// Creates a [ScreenCaptureStopped] event.
  const ScreenCaptureStopped();

  @override
  String get wireValue => 'screen_capture_stopped';

  @override
  bool operator ==(Object other) => other is ScreenCaptureStopped;

  @override
  int get hashCode => wireValue.hashCode;

  @override
  String toString() => 'DeviceSecurityEvent.screenCaptureStopped';
}

/// Developer mode / developer options were enabled (Android only).
@immutable
final class DevModeEnabled extends DeviceSecurityEvent {
  /// Creates a [DevModeEnabled] event.
  const DevModeEnabled();

  @override
  String get wireValue => 'dev_mode_enabled';

  @override
  bool operator ==(Object other) => other is DevModeEnabled;

  @override
  int get hashCode => wireValue.hashCode;

  @override
  String toString() => 'DeviceSecurityEvent.devModeEnabled';
}

/// Developer mode / developer options were disabled (Android only).
@immutable
final class DevModeDisabled extends DeviceSecurityEvent {
  /// Creates a [DevModeDisabled] event.
  const DevModeDisabled();

  @override
  String get wireValue => 'dev_mode_disabled';

  @override
  bool operator ==(Object other) => other is DevModeDisabled;

  @override
  int get hashCode => wireValue.hashCode;

  @override
  String toString() => 'DeviceSecurityEvent.devModeDisabled';
}

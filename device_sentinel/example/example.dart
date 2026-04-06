// ignore_for_file: unused_import, this is an example showing the import
import 'package:device_sentinel/device_sentinel.dart';

/// ## Observe Buttons (no interception)
///
/// Detect presses without blocking the default OS behaviour:
///
/// ```dart
/// const sentinel = DeviceSentinel();
///
/// sentinel.events.whereType<ButtonEvent>().listen((event) {
///   print('${event.button} ${event.action}');
/// });
///
/// await sentinel.start(); // default config -- observe only
/// ```
///
/// ## Intercept Volume Buttons
///
/// Consume a press so the OS does **not** change the system volume:
///
/// ```dart
/// await sentinel.start(
///   config: SentinelConfig(
///     interceptVolumeUp: true,   // consume -- volume won't change
///     interceptVolumeDown: false, // observe -- volume still changes
///   ),
/// );
/// ```
///
/// ## Monitor Security Events
///
/// ```dart
/// sentinel.events.whereType<DeviceSecurityEvent>().listen((event) {
///   switch (event) {
///     case NetworkConnected():
///       print('Back online');
///     case DeviceLocked():
///       print('Device locked');
///     case BatteryLow(:final level):
///       print('Battery: $level%');
///     case _:
///       print('Event: $event');
///   }
/// });
///
/// await sentinel.start(
///   config: SentinelConfig(
///     monitorConnectivity: true,
///     monitorScreenLock: true,
///     monitorShutdown: false,
///     monitorPowerUsb: false,
///     monitorSecurityPosture: false,
///   ),
/// );
/// ```
///
/// ## Stop
///
/// ```dart
/// await sentinel.stop();
/// ```
///
/// See the full example app in `example/lib/main.dart` for a runnable demo.
void main() {}

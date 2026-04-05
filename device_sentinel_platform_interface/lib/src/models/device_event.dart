import 'package:meta/meta.dart';

/// Base class for all device events detected by the sentinel.
///
/// This is the parent type for both physical button events and
/// device security events, enabling a single unified [Stream] to deliver
/// every event the plugin detects.
///
/// Use `switch` with subtypes or `whereType<T>()` to filter:
///
/// ```dart
/// sentinel.events.listen((event) {
///   switch (event) {
///     case ButtonEvent(:final button, :final action):
///       // handle button press/release
///     case DeviceSecurityEvent():
///       // handle security event
///   }
/// });
/// ```
@immutable
abstract class DeviceEvent {
  /// Creates a [DeviceEvent].
  const DeviceEvent();
}

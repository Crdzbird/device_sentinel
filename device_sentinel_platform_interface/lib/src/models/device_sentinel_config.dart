import 'package:meta/meta.dart';

/// {@template device_sentinel_config}
/// Configuration for the device_sentinel plugin.
///
/// Controls whether button events are intercepted (consumed) or just observed.
/// {@endtemplate}
@immutable
final class DeviceSentinelConfig {
  /// {@macro device_sentinel_config}
  const DeviceSentinelConfig({
    this.interceptVolumeEvents = false,
    this.interceptPowerEvents = false,
  });

  /// Deserializes a [DeviceSentinelConfig] from a platform channel [map].
  factory DeviceSentinelConfig.fromMap(Map<String, dynamic> map) {
    return DeviceSentinelConfig(
      interceptVolumeEvents:
          map['interceptVolumeEvents'] as bool? ?? false,
      interceptPowerEvents:
          map['interceptPowerEvents'] as bool? ?? false,
    );
  }

  /// When `true`, volume button events are consumed and the system volume
  /// will not change. When `false`, events are observed without side effects.
  final bool interceptVolumeEvents;

  /// When `true`, the plugin attempts to intercept power button events.
  ///
  /// Note: Neither Android nor iOS can truly prevent the power button
  /// from triggering its system behavior (screen off/lock). This flag
  /// is effectively observe-only on both platforms.
  final bool interceptPowerEvents;

  /// Serializes this config to a platform channel map.
  Map<String, dynamic> toMap() => {
        'interceptVolumeEvents': interceptVolumeEvents,
        'interceptPowerEvents': interceptPowerEvents,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DeviceSentinelConfig &&
          other.interceptVolumeEvents == interceptVolumeEvents &&
          other.interceptPowerEvents == interceptPowerEvents;

  @override
  int get hashCode =>
      Object.hash(interceptVolumeEvents, interceptPowerEvents);

  @override
  String toString() => 'DeviceSentinelConfig('
      'interceptVolumeEvents: $interceptVolumeEvents, '
      'interceptPowerEvents: $interceptPowerEvents)';
}

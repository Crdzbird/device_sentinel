import 'package:device_sentinel_platform_interface/device_sentinel_platform_interface.dart';
import 'package:flutter/services.dart';

/// Mixin for platforms that support button detection via [EventChannel]
/// but do **not** support security monitoring.
///
/// The [events] stream emits only [ButtonEvent]s.
/// [start] starts button listening; security config keys are ignored.
/// [stop] stops button listening.
mixin ButtonOnlyEventChannelMixin on DeviceSentinelPlatform {
  /// The primary method channel (button lifecycle + getPlatformName).
  MethodChannel get methodChannel;

  /// The event channel that receives button events from native.
  EventChannel get buttonEventChannel;

  Stream<DeviceEvent>? _eventsStream;

  @override
  Stream<DeviceEvent> get events {
    _eventsStream ??= buttonEventChannel
        .receiveBroadcastStream()
        .map(
          (event) => ButtonEvent.fromMap(
            Map<String, dynamic>.from(event as Map),
          ),
        )
        .cast<DeviceEvent>()
        .asBroadcastStream();
    return _eventsStream!;
  }

  @override
  Future<void> start({SentinelConfig config = const SentinelConfig()}) {
    return methodChannel.invokeMethod<void>(
      'startListening',
      config.toButtonMap(),
    );
  }

  @override
  Future<void> stop() {
    return methodChannel.invokeMethod<void>('stopListening');
  }

  @override
  Future<String?> getPlatformName() {
    return methodChannel.invokeMethod<String>('getPlatformName');
  }
}

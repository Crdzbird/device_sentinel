import 'dart:async';

import 'package:device_sentinel_platform_interface/device_sentinel_platform_interface.dart';
import 'package:flutter/services.dart';

/// Mixin that provides the unified [DeviceEvent] stream implementation
/// by merging button and security [EventChannel]s, plus common
/// [MethodChannel] delegation for `start`, `stop`, and `getPlatformName`.
///
/// Platform implementations should mix this in and override the four
/// channel getters.
mixin EventChannelMixin on DeviceSentinelPlatform {
  /// The primary method channel (button lifecycle + getPlatformName).
  MethodChannel get methodChannel;

  /// The event channel that receives button events from native.
  EventChannel get buttonEventChannel;

  /// The method channel used for security monitoring lifecycle calls.
  MethodChannel get securityMethodChannel;

  /// The event channel that receives security event strings from native.
  EventChannel get securityEventChannel;

  Stream<ButtonEvent>? _buttonStream;
  Stream<DeviceSecurityEvent>? _securityStream;
  Stream<DeviceEvent>? _eventsStream;

  /// Internal broadcast stream of button events from the native platform.
  Stream<ButtonEvent> get buttonStream {
    _buttonStream ??= buttonEventChannel
        .receiveBroadcastStream()
        .map(
          (event) => ButtonEvent.fromMap(
            Map<String, dynamic>.from(event as Map),
          ),
        )
        .asBroadcastStream();
    return _buttonStream!;
  }

  /// Internal broadcast stream of security events from the native platform.
  Stream<DeviceSecurityEvent> get securityStream {
    _securityStream ??= securityEventChannel
        .receiveBroadcastStream()
        .map((event) => DeviceSecurityEvent.parse(event as String))
        .where((e) => e != null)
        .cast<DeviceSecurityEvent>()
        .asBroadcastStream();
    return _securityStream!;
  }

  @override
  Stream<DeviceEvent> get events {
    if (_eventsStream != null) return _eventsStream!;

    late final StreamController<DeviceEvent> controller;
    StreamSubscription<ButtonEvent>? buttonSub;
    StreamSubscription<DeviceSecurityEvent>? securitySub;

    controller = StreamController<DeviceEvent>.broadcast(
      onListen: () {
        buttonSub = buttonStream.listen(
          controller.add,
          onError: controller.addError,
        );
        securitySub = securityStream.listen(
          controller.add,
          onError: controller.addError,
        );
      },
      onCancel: () async {
        await buttonSub?.cancel();
        await securitySub?.cancel();
      },
    );

    _eventsStream = controller.stream;
    return _eventsStream!;
  }

  @override
  Future<void> start({SentinelConfig config = const SentinelConfig()}) async {
    await methodChannel.invokeMethod<void>(
      'startListening',
      config.toButtonMap(),
    );
    await securityMethodChannel.invokeMethod<void>(
      'startSecurityMonitoring',
      config.toSecurityMap(),
    );
  }

  @override
  Future<void> stop() async {
    await methodChannel.invokeMethod<void>('stopListening');
    await securityMethodChannel.invokeMethod<void>('stopSecurityMonitoring');
  }

  @override
  Future<String?> getPlatformName() {
    return methodChannel.invokeMethod<String>('getPlatformName');
  }
}

import 'package:flutter/services.dart';
import 'package:vol_spotter_platform_interface/vol_spotter_platform_interface.dart';

/// Mixin that provides the standard [ButtonEvent] stream implementation
/// from an [EventChannel], plus common [MethodChannel] delegation for
/// `startListening`, `stopListening`, and `getPlatformName`.
///
/// Platform implementations should mix this in and override
/// [eventChannel] and [methodChannel].
mixin ButtonEventChannelMixin on VolSpotterPlatform {
  /// The method channel used to interact with the native platform.
  MethodChannel get methodChannel;

  /// The event channel used to receive button events from native.
  EventChannel get eventChannel;

  Stream<ButtonEvent>? _buttonEvents;

  @override
  Stream<ButtonEvent> get buttonEvents {
    _buttonEvents ??= eventChannel
        .receiveBroadcastStream()
        .map(
          (event) => ButtonEvent.fromMap(
            Map<String, dynamic>.from(event as Map),
          ),
        )
        .asBroadcastStream();
    return _buttonEvents!;
  }

  @override
  Future<void> startListening({
    VolSpotterConfig config = const VolSpotterConfig(),
  }) {
    return methodChannel.invokeMethod<void>(
      'startListening',
      config.toMap(),
    );
  }

  @override
  Future<void> stopListening() {
    return methodChannel.invokeMethod<void>('stopListening');
  }

  @override
  Future<String?> getPlatformName() {
    return methodChannel.invokeMethod<String>('getPlatformName');
  }
}

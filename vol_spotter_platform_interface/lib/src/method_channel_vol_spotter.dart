import 'package:flutter/foundation.dart' show visibleForTesting;
import 'package:flutter/services.dart';
import 'package:vol_spotter_platform_interface/vol_spotter_platform_interface.dart';

/// An implementation of [VolSpotterPlatform] that uses method channels.
class MethodChannelVolSpotter extends VolSpotterPlatform
    with ButtonEventChannelMixin {
  /// The method channel used to interact with the native platform.
  @override
  @visibleForTesting
  final methodChannel = const MethodChannel('vol_spotter');

  /// The event channel used to receive button events from native.
  @override
  @visibleForTesting
  final eventChannel = const EventChannel('vol_spotter/events');
}

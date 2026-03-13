import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:vol_spotter_platform_interface/vol_spotter_platform_interface.dart';

/// The Windows implementation of [VolSpotterPlatform].
class VolSpotterWindows extends VolSpotterPlatform
    with ButtonEventChannelMixin {
  /// The method channel used to interact with the native platform.
  @override
  @visibleForTesting
  final methodChannel = const MethodChannel('vol_spotter_windows');

  /// The event channel used to receive button events from native.
  @override
  @visibleForTesting
  final eventChannel = const EventChannel('vol_spotter_windows/events');

  /// Registers this class as the default instance of [VolSpotterPlatform].
  static void registerWith() {
    VolSpotterPlatform.instance = VolSpotterWindows();
  }
}

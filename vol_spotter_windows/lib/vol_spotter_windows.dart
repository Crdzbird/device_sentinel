import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:vol_spotter_platform_interface/vol_spotter_platform_interface.dart';

/// The Windows implementation of [VolSpotterPlatform].
class VolSpotterWindows extends VolSpotterPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('vol_spotter_windows');

  /// Registers this class as the default instance of [VolSpotterPlatform].
  static void registerWith() {
    VolSpotterPlatform.instance = VolSpotterWindows();
  }

  @override
  Stream<ButtonEvent> get buttonEvents => const Stream.empty();

  @override
  Future<void> startListening({
    VolSpotterConfig config = const VolSpotterConfig(),
  }) {
    throw UnsupportedError(
      'startListening is not supported on Windows.',
    );
  }

  @override
  Future<void> stopListening() {
    throw UnsupportedError(
      'stopListening is not supported on Windows.',
    );
  }

  @override
  Future<String?> getPlatformName() {
    return methodChannel.invokeMethod<String>('getPlatformName');
  }
}

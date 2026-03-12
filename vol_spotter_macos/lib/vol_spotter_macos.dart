import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:vol_spotter_platform_interface/vol_spotter_platform_interface.dart';

/// The MacOS implementation of [VolSpotterPlatform].
class VolSpotterMacOS extends VolSpotterPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('vol_spotter_macos');

  /// Registers this class as the default instance of [VolSpotterPlatform].
  static void registerWith() {
    VolSpotterPlatform.instance = VolSpotterMacOS();
  }

  @override
  Stream<ButtonEvent> get buttonEvents => const Stream.empty();

  @override
  Future<void> startListening({
    VolSpotterConfig config = const VolSpotterConfig(),
  }) {
    throw UnsupportedError(
      'startListening is not supported on macOS.',
    );
  }

  @override
  Future<void> stopListening() {
    throw UnsupportedError(
      'stopListening is not supported on macOS.',
    );
  }

  @override
  Future<String?> getPlatformName() {
    return methodChannel.invokeMethod<String>('getPlatformName');
  }
}

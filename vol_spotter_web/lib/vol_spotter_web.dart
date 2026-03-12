import 'package:vol_spotter_platform_interface/vol_spotter_platform_interface.dart';

/// The Web implementation of [VolSpotterPlatform].
class VolSpotterWeb extends VolSpotterPlatform {
  /// Registers this class as the default instance of [VolSpotterPlatform].
  static void registerWith([Object? registrar]) {
    VolSpotterPlatform.instance = VolSpotterWeb();
  }

  @override
  Stream<ButtonEvent> get buttonEvents => const Stream.empty();

  @override
  Future<void> startListening({
    VolSpotterConfig config = const VolSpotterConfig(),
  }) {
    throw UnsupportedError(
      'startListening is not supported on Web.',
    );
  }

  @override
  Future<void> stopListening() {
    throw UnsupportedError(
      'stopListening is not supported on Web.',
    );
  }

  @override
  Future<String?> getPlatformName() async => 'Web';
}

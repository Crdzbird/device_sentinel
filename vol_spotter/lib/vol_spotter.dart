import 'package:vol_spotter_platform_interface/vol_spotter_platform_interface.dart';

export 'package:vol_spotter_platform_interface/vol_spotter_platform_interface.dart'
    show
        ButtonAction,
        ButtonEvent,
        ButtonPressed,
        ButtonReleased,
        PhysicalButton,
        PowerButton,
        VolSpotterConfig,
        VolumeDownButton,
        VolumeUpButton;

VolSpotterPlatform get _platform => VolSpotterPlatform.instance;

/// {@template vol_spotter}
/// A plugin for detecting physical button presses (volume, power).
/// {@endtemplate}
class VolSpotter {
  /// {@macro vol_spotter}
  const VolSpotter();

  /// A broadcast stream of physical button events.
  Stream<ButtonEvent> get buttonEvents => _platform.buttonEvents;

  /// Starts listening for physical button events.
  ///
  /// Use [config] to control whether events are intercepted (consumed)
  /// or just observed.
  Future<void> startListening({
    VolSpotterConfig config = const VolSpotterConfig(),
  }) =>
      _platform.startListening(config: config);

  /// Stops listening for physical button events.
  Future<void> stopListening() => _platform.stopListening();
}

/// Returns the name of the current platform.
@Deprecated('Use VolSpotter instead.')
Future<String> getPlatformName() async {
  final platformName = await _platform.getPlatformName();
  if (platformName == null) throw Exception('Unable to get platform name.');
  return platformName;
}

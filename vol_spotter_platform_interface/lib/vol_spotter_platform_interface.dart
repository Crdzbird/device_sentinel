import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:vol_spotter_platform_interface/src/method_channel_vol_spotter.dart';
import 'package:vol_spotter_platform_interface/src/models/models.dart';

export 'package:vol_spotter_platform_interface/src/button_event_channel_mixin.dart';
export 'package:vol_spotter_platform_interface/src/models/models.dart';

/// {@template vol_spotter_platform}
/// The interface that implementations of vol_spotter must implement.
///
/// Platform implementations should extend this class
/// rather than implement it as `VolSpotter`.
///
/// Extending this class (using `extends`) ensures that the subclass will get
/// the default implementation, while platform implementations that `implements`
/// this interface will be broken by newly added [VolSpotterPlatform] methods.
/// {@endtemplate}
abstract class VolSpotterPlatform extends PlatformInterface {
  /// {@macro vol_spotter_platform}
  VolSpotterPlatform() : super(token: _token);

  static final Object _token = Object();

  static VolSpotterPlatform _instance = MethodChannelVolSpotter();

  /// The default instance of [VolSpotterPlatform] to use.
  ///
  /// Defaults to [MethodChannelVolSpotter].
  static VolSpotterPlatform get instance => _instance;

  /// Platform-specific plugins should set this with their own
  /// platform-specific class that extends [VolSpotterPlatform] when they
  /// register themselves.
  static set instance(VolSpotterPlatform instance) {
    PlatformInterface.verify(instance, _token);
    _instance = instance;
  }

  /// A broadcast stream of physical button events from the native platform.
  Stream<ButtonEvent> get buttonEvents;

  /// Starts listening for physical button events with the given [config].
  Future<void> startListening({
    VolSpotterConfig config = const VolSpotterConfig(),
  });

  /// Stops listening for physical button events and releases native resources.
  Future<void> stopListening();

  /// Returns the name of the current platform.
  Future<String?> getPlatformName();
}

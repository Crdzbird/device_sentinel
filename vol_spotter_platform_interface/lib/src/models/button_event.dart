import 'package:meta/meta.dart';
import 'package:vol_spotter_platform_interface/src/models/button_action.dart';
import 'package:vol_spotter_platform_interface/src/models/physical_button.dart';

/// {@template button_event}
/// An event representing a physical button press or release.
/// {@endtemplate}
@immutable
final class ButtonEvent {
  /// {@macro button_event}
  const ButtonEvent({required this.button, required this.action});

  /// Deserializes a [ButtonEvent] from a platform channel [map].
  ///
  /// Expected format:
  /// ```json
  /// {"button": "volumeUp", "action": "pressed"}
  /// ```
  factory ButtonEvent.fromMap(Map<String, dynamic> map) {
    final button = map['button'];
    final action = map['action'];
    if (button is! String || action is! String) {
      throw ArgumentError('Invalid ButtonEvent map: $map');
    }
    return ButtonEvent(
      button: PhysicalButton.fromString(button),
      action: ButtonAction.fromString(action),
    );
  }

  /// The physical button involved.
  final PhysicalButton button;

  /// Whether the button was pressed or released.
  final ButtonAction action;

  /// Serializes this event to a platform channel map.
  Map<String, String> toMap() => {
        'button': button.name,
        'action': action.name,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ButtonEvent &&
          other.button == button &&
          other.action == action;

  @override
  int get hashCode => Object.hash(button, action);

  @override
  String toString() => 'ButtonEvent(button: $button, action: $action)';
}

import 'package:device_sentinel_platform_interface/src/models/device_sentinel_exception.dart';
import 'package:meta/meta.dart';

/// {@template button_action}
/// Represents the action performed on a physical button.
///
/// Use [ButtonAction.fromString] to deserialize from a platform channel value,
/// or pattern-match on the sealed subtypes:
///
/// ```dart
/// switch (action) {
///   case ButtonPressed(): // ...
///   case ButtonReleased(): // ...
/// }
/// ```
/// {@endtemplate}
@immutable
sealed class ButtonAction {
  /// {@macro button_action}
  const ButtonAction();

  /// Deserializes a [ButtonAction] from its string [value].
  ///
  /// Throws [UnknownButtonActionException] if [value] is not recognised.
  factory ButtonAction.fromString(String value) => switch (value) {
        'pressed' => const ButtonPressed(),
        'released' => const ButtonReleased(),
        _ => throw UnknownButtonActionException(value: value),
      };

  /// Serialization key for this action type.
  String get name;
}

/// {@template button_pressed}
/// The button was pressed down.
/// {@endtemplate}
@immutable
final class ButtonPressed extends ButtonAction {
  /// {@macro button_pressed}
  const ButtonPressed();

  @override
  String get name => 'pressed';

  @override
  bool operator ==(Object other) => other is ButtonPressed;

  @override
  int get hashCode => name.hashCode;

  @override
  String toString() => 'ButtonAction.pressed';
}

/// {@template button_released}
/// The button was released.
///
/// Note: Not all platforms emit release events. iOS volume buttons
/// only emit [ButtonPressed].
/// {@endtemplate}
@immutable
final class ButtonReleased extends ButtonAction {
  /// {@macro button_released}
  const ButtonReleased();

  @override
  String get name => 'released';

  @override
  bool operator ==(Object other) => other is ButtonReleased;

  @override
  int get hashCode => name.hashCode;

  @override
  String toString() => 'ButtonAction.released';
}

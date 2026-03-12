import 'package:meta/meta.dart';

/// Represents the action performed on a physical button.
@immutable
sealed class ButtonAction {
  const ButtonAction();

  /// Deserializes a [ButtonAction] from its string [value].
  factory ButtonAction.fromString(String value) => switch (value) {
        'pressed' => const ButtonPressed(),
        'released' => const ButtonReleased(),
        _ => throw ArgumentError.value(
          value,
          'value',
          'Unknown action type',
        ),
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

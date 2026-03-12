import 'package:meta/meta.dart';

/// Represents a physical hardware button on the device.
@immutable
sealed class PhysicalButton {
  const PhysicalButton();

  /// Deserializes a [PhysicalButton] from its string [value].
  factory PhysicalButton.fromString(String value) => switch (value) {
        'volumeUp' => const VolumeUpButton(),
        'volumeDown' => const VolumeDownButton(),
        'power' => const PowerButton(),
        _ => throw ArgumentError.value(
          value,
          'value',
          'Unknown button type',
        ),
      };

  /// Serialization key for this button type.
  String get name;
}

/// {@template volume_up_button}
/// The physical volume up button.
/// {@endtemplate}
@immutable
final class VolumeUpButton extends PhysicalButton {
  /// {@macro volume_up_button}
  const VolumeUpButton();

  @override
  String get name => 'volumeUp';

  @override
  bool operator ==(Object other) => other is VolumeUpButton;

  @override
  int get hashCode => name.hashCode;

  @override
  String toString() => 'PhysicalButton.volumeUp';
}

/// {@template volume_down_button}
/// The physical volume down button.
/// {@endtemplate}
@immutable
final class VolumeDownButton extends PhysicalButton {
  /// {@macro volume_down_button}
  const VolumeDownButton();

  @override
  String get name => 'volumeDown';

  @override
  bool operator ==(Object other) => other is VolumeDownButton;

  @override
  int get hashCode => name.hashCode;

  @override
  String toString() => 'PhysicalButton.volumeDown';
}

/// {@template power_button}
/// The physical power/lock button.
/// {@endtemplate}
@immutable
final class PowerButton extends PhysicalButton {
  /// {@macro power_button}
  const PowerButton();

  @override
  String get name => 'power';

  @override
  bool operator ==(Object other) => other is PowerButton;

  @override
  int get hashCode => name.hashCode;

  @override
  String toString() => 'PhysicalButton.power';
}

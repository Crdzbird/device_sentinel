/// {@template device_sentinel_exception}
/// Base exception for all device sentinel errors.
///
/// All exceptions thrown by the device sentinel plugin extend this class,
/// allowing consumers to catch [DeviceSentinelException] as a single
/// catch-all for every error the plugin can produce.
/// {@endtemplate}
sealed class DeviceSentinelException implements Exception {
  /// {@macro device_sentinel_exception}
  const DeviceSentinelException(this.message);

  /// A human-readable description of the error.
  final String message;

  @override
  String toString() => 'DeviceSentinelException: $message';
}

/// {@template platform_unsupported_exception}
/// Thrown when an operation is invoked on a platform that does not support it.
///
/// Linux and Web stubs throw this for `start` and `stop` because neither
/// button detection nor security monitoring is implemented.
/// {@endtemplate}
final class PlatformUnsupportedException extends DeviceSentinelException {
  /// {@macro platform_unsupported_exception}
  const PlatformUnsupportedException({
    required this.platform,
    required this.operation,
  }) : super('$operation is not supported on $platform.');

  /// The name of the unsupported platform (e.g. `Linux`, `Web`).
  final String platform;

  /// The operation that was attempted (e.g. `start`, `stop`).
  final String operation;
}

/// {@template invalid_event_data_exception}
/// Thrown when event data received from the platform channel is malformed.
///
/// For example, a `ButtonEvent.fromMap` call with a map that lacks the
/// required `button` or `action` keys.
/// {@endtemplate}
final class InvalidEventDataException extends DeviceSentinelException {
  /// {@macro invalid_event_data_exception}
  const InvalidEventDataException({required String details}) : super(details);
}

/// {@template unknown_button_exception}
/// Thrown when a `PhysicalButton.fromString` call receives an unrecognised
/// button name.
/// {@endtemplate}
final class UnknownButtonException extends DeviceSentinelException {
  /// {@macro unknown_button_exception}
  const UnknownButtonException({required this.value})
      : super('Unknown button type: $value');

  /// The unrecognised button name that was received.
  final String value;
}

/// {@template unknown_button_action_exception}
/// Thrown when a `ButtonAction.fromString` call receives an unrecognised
/// action name.
/// {@endtemplate}
final class UnknownButtonActionException extends DeviceSentinelException {
  /// {@macro unknown_button_action_exception}
  const UnknownButtonActionException({required this.value})
      : super('Unknown action type: $value');

  /// The unrecognised action name that was received.
  final String value;
}

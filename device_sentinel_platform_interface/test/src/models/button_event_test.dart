import 'package:device_sentinel_platform_interface/device_sentinel_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ButtonEvent', () {
    const event = ButtonEvent(
      button: VolumeUpButton(),
      action: ButtonPressed(),
    );

    group('fromMap', () {
      test('deserializes correctly', () {
        final result = ButtonEvent.fromMap(
          const <String, dynamic>{'button': 'volumeUp', 'action': 'pressed'},
        );
        expect(result, equals(event));
      });

      test('throws InvalidEventDataException on missing button key', () {
        expect(
          () => ButtonEvent.fromMap(
            const <String, dynamic>{'action': 'pressed'},
          ),
          throwsA(isA<InvalidEventDataException>()),
        );
      });

      test('throws InvalidEventDataException on missing action key', () {
        expect(
          () => ButtonEvent.fromMap(
            const <String, dynamic>{'button': 'volumeUp'},
          ),
          throwsA(isA<InvalidEventDataException>()),
        );
      });

      test('throws UnknownButtonException on invalid button value', () {
        expect(
          () => ButtonEvent.fromMap(
            const <String, dynamic>{
              'button': 'invalid',
              'action': 'pressed',
            },
          ),
          throwsA(isA<UnknownButtonException>()),
        );
      });

      test('throws UnknownButtonActionException on invalid action', () {
        expect(
          () => ButtonEvent.fromMap(
            const <String, dynamic>{
              'button': 'volumeUp',
              'action': 'invalid',
            },
          ),
          throwsA(isA<UnknownButtonActionException>()),
        );
      });

      test('throws InvalidEventDataException when values are not strings', () {
        expect(
          () => ButtonEvent.fromMap(
            const <String, dynamic>{'button': 123, 'action': 456},
          ),
          throwsA(isA<InvalidEventDataException>()),
        );
      });

      test('throws InvalidEventDataException on empty map', () {
        expect(
          () => ButtonEvent.fromMap(const <String, dynamic>{}),
          throwsA(isA<InvalidEventDataException>()),
        );
      });
    });

    group('toMap', () {
      test('serializes correctly', () {
        expect(
          event.toMap(),
          equals(<String, String>{'button': 'volumeUp', 'action': 'pressed'}),
        );
      });
    });

    group('roundtrip', () {
      test('fromMap(toMap()) returns equivalent event', () {
        final events = [
          const ButtonEvent(
            button: VolumeUpButton(),
            action: ButtonPressed(),
          ),
          const ButtonEvent(
            button: VolumeDownButton(),
            action: ButtonReleased(),
          ),
          const ButtonEvent(
            button: PowerButton(),
            action: ButtonPressed(),
          ),
        ];
        for (final e in events) {
          expect(ButtonEvent.fromMap(e.toMap()), equals(e));
        }
      });
    });

    group('equality', () {
      test('identical events are equal', () {
        const other = ButtonEvent(
          button: VolumeUpButton(),
          action: ButtonPressed(),
        );
        expect(event, equals(other));
        expect(event.hashCode, equals(other.hashCode));
      });

      test('different button events are not equal', () {
        const other = ButtonEvent(
          button: VolumeDownButton(),
          action: ButtonPressed(),
        );
        expect(event, isNot(equals(other)));
      });

      test('different action events are not equal', () {
        const other = ButtonEvent(
          button: VolumeUpButton(),
          action: ButtonReleased(),
        );
        expect(event, isNot(equals(other)));
      });
    });

    test('toString includes button and action', () {
      expect(event.toString(), contains('volumeUp'));
      expect(event.toString(), contains('pressed'));
    });
  });
}

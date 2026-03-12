import 'package:flutter_test/flutter_test.dart';
import 'package:vol_spotter_platform_interface/vol_spotter_platform_interface.dart';

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

      test('throws on missing button key', () {
        expect(
          () => ButtonEvent.fromMap(
            const <String, dynamic>{'action': 'pressed'},
          ),
          throwsArgumentError,
        );
      });

      test('throws on missing action key', () {
        expect(
          () => ButtonEvent.fromMap(
            const <String, dynamic>{'button': 'volumeUp'},
          ),
          throwsArgumentError,
        );
      });

      test('throws on invalid button value', () {
        expect(
          () => ButtonEvent.fromMap(
            const <String, dynamic>{
              'button': 'invalid',
              'action': 'pressed',
            },
          ),
          throwsArgumentError,
        );
      });

      test('throws on invalid action value', () {
        expect(
          () => ButtonEvent.fromMap(
            const <String, dynamic>{
              'button': 'volumeUp',
              'action': 'invalid',
            },
          ),
          throwsArgumentError,
        );
      });

      test('throws when values are not strings', () {
        expect(
          () => ButtonEvent.fromMap(
            const <String, dynamic>{'button': 123, 'action': 456},
          ),
          throwsArgumentError,
        );
      });

      test('throws on empty map', () {
        expect(
          () => ButtonEvent.fromMap(const <String, dynamic>{}),
          throwsArgumentError,
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

import 'package:device_sentinel_platform_interface/device_sentinel_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ButtonAction', () {
    group('fromString', () {
      test('parses pressed', () {
        expect(ButtonAction.fromString('pressed'), isA<ButtonPressed>());
      });

      test('parses released', () {
        expect(ButtonAction.fromString('released'), isA<ButtonReleased>());
      });

      test('throws on unknown value', () {
        expect(
          () => ButtonAction.fromString('unknown'),
          throwsArgumentError,
        );
      });
    });

    group('name', () {
      test('ButtonPressed returns pressed', () {
        expect(const ButtonPressed().name, 'pressed');
      });

      test('ButtonReleased returns released', () {
        expect(const ButtonReleased().name, 'released');
      });
    });

    group('equality', () {
      test('same types are equal', () {
        expect(const ButtonPressed(), equals(const ButtonPressed()));
        expect(const ButtonReleased(), equals(const ButtonReleased()));
      });

      test('different types are not equal', () {
        expect(
          const ButtonPressed(),
          isNot(equals(const ButtonReleased())),
        );
      });
    });

    group('toString', () {
      test('ButtonPressed', () {
        expect(
          const ButtonPressed().toString(),
          equals('ButtonAction.pressed'),
        );
      });

      test('ButtonReleased', () {
        expect(
          const ButtonReleased().toString(),
          equals('ButtonAction.released'),
        );
      });
    });

    group('roundtrip', () {
      test('fromString(name) returns equivalent instance', () {
        for (final action in [
          const ButtonPressed(),
          const ButtonReleased(),
        ]) {
          expect(ButtonAction.fromString(action.name), equals(action));
        }
      });
    });
  });
}

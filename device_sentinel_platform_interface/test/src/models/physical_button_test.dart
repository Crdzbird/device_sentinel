import 'package:flutter_test/flutter_test.dart';
import 'package:device_sentinel_platform_interface/device_sentinel_platform_interface.dart';

void main() {
  group('PhysicalButton', () {
    group('fromString', () {
      test('parses volumeUp', () {
        expect(
          PhysicalButton.fromString('volumeUp'),
          isA<VolumeUpButton>(),
        );
      });

      test('parses volumeDown', () {
        expect(
          PhysicalButton.fromString('volumeDown'),
          isA<VolumeDownButton>(),
        );
      });

      test('parses power', () {
        expect(
          PhysicalButton.fromString('power'),
          isA<PowerButton>(),
        );
      });

      test('throws on unknown value', () {
        expect(
          () => PhysicalButton.fromString('unknown'),
          throwsArgumentError,
        );
      });
    });

    group('name', () {
      test('VolumeUpButton returns volumeUp', () {
        expect(const VolumeUpButton().name, 'volumeUp');
      });

      test('VolumeDownButton returns volumeDown', () {
        expect(const VolumeDownButton().name, 'volumeDown');
      });

      test('PowerButton returns power', () {
        expect(const PowerButton().name, 'power');
      });
    });

    group('toString', () {
      test('VolumeUpButton', () {
        expect(
          const VolumeUpButton().toString(),
          equals('PhysicalButton.volumeUp'),
        );
      });

      test('VolumeDownButton', () {
        expect(
          const VolumeDownButton().toString(),
          equals('PhysicalButton.volumeDown'),
        );
      });

      test('PowerButton', () {
        expect(
          const PowerButton().toString(),
          equals('PhysicalButton.power'),
        );
      });
    });

    group('equality', () {
      test('same types are equal', () {
        expect(const VolumeUpButton(), equals(const VolumeUpButton()));
        expect(const VolumeDownButton(), equals(const VolumeDownButton()));
        expect(const PowerButton(), equals(const PowerButton()));
      });

      test('different types are not equal', () {
        expect(const VolumeUpButton(), isNot(equals(const PowerButton())));
      });
    });

    group('roundtrip', () {
      test('fromString(name) returns equivalent instance', () {
        for (final button in [
          const VolumeUpButton(),
          const VolumeDownButton(),
          const PowerButton(),
        ]) {
          expect(PhysicalButton.fromString(button.name), equals(button));
        }
      });
    });
  });
}

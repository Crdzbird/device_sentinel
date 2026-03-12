import 'package:flutter_test/flutter_test.dart';
import 'package:vol_spotter_platform_interface/vol_spotter_platform_interface.dart';

void main() {
  group('VolSpotterConfig', () {
    group('defaults', () {
      test('interceptVolumeEvents is false', () {
        expect(const VolSpotterConfig().interceptVolumeEvents, isFalse);
      });

      test('interceptPowerEvents is false', () {
        expect(const VolSpotterConfig().interceptPowerEvents, isFalse);
      });
    });

    group('toMap', () {
      test('serializes default config', () {
        expect(
          const VolSpotterConfig().toMap(),
          equals(<String, dynamic>{
            'interceptVolumeEvents': false,
            'interceptPowerEvents': false,
          }),
        );
      });

      test('serializes custom config', () {
        const config = VolSpotterConfig(
          interceptVolumeEvents: true,
          interceptPowerEvents: true,
        );
        expect(
          config.toMap(),
          equals(<String, dynamic>{
            'interceptVolumeEvents': true,
            'interceptPowerEvents': true,
          }),
        );
      });
    });

    group('fromMap', () {
      test('deserializes correctly', () {
        final config = VolSpotterConfig.fromMap(const <String, dynamic>{
          'interceptVolumeEvents': true,
          'interceptPowerEvents': false,
        });
        expect(config.interceptVolumeEvents, isTrue);
        expect(config.interceptPowerEvents, isFalse);
      });

      test('uses defaults for missing keys', () {
        final config = VolSpotterConfig.fromMap(const <String, dynamic>{});
        expect(config.interceptVolumeEvents, isFalse);
        expect(config.interceptPowerEvents, isFalse);
      });
    });

    group('toString', () {
      test('includes both fields', () {
        const config = VolSpotterConfig(interceptVolumeEvents: true);
        expect(
          config.toString(),
          equals(
            'VolSpotterConfig('
            'interceptVolumeEvents: true, '
            'interceptPowerEvents: false)',
          ),
        );
      });
    });

    group('roundtrip', () {
      test('fromMap(toMap()) returns equivalent config', () {
        const configs = [
          VolSpotterConfig(),
          VolSpotterConfig(interceptVolumeEvents: true),
          VolSpotterConfig(interceptPowerEvents: true),
          VolSpotterConfig(
            interceptVolumeEvents: true,
            interceptPowerEvents: true,
          ),
        ];
        for (final config in configs) {
          expect(
            VolSpotterConfig.fromMap(config.toMap()),
            equals(config),
          );
        }
      });
    });

    group('equality', () {
      test('identical configs are equal', () {
        const a = VolSpotterConfig(interceptVolumeEvents: true);
        const b = VolSpotterConfig(interceptVolumeEvents: true);
        expect(a, equals(b));
        expect(a.hashCode, equals(b.hashCode));
      });

      test('different configs are not equal', () {
        const a = VolSpotterConfig();
        const b = VolSpotterConfig(interceptVolumeEvents: true);
        expect(a, isNot(equals(b)));
      });
    });
  });
}

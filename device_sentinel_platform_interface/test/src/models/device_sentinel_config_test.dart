import 'package:flutter_test/flutter_test.dart';
import 'package:device_sentinel_platform_interface/device_sentinel_platform_interface.dart';

void main() {
  group('DeviceSentinelConfig', () {
    group('defaults', () {
      test('interceptVolumeEvents is false', () {
        expect(const DeviceSentinelConfig().interceptVolumeEvents, isFalse);
      });

      test('interceptPowerEvents is false', () {
        expect(const DeviceSentinelConfig().interceptPowerEvents, isFalse);
      });
    });

    group('toMap', () {
      test('serializes default config', () {
        expect(
          const DeviceSentinelConfig().toMap(),
          equals(<String, dynamic>{
            'interceptVolumeEvents': false,
            'interceptPowerEvents': false,
          }),
        );
      });

      test('serializes custom config', () {
        const config = DeviceSentinelConfig(
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
        final config = DeviceSentinelConfig.fromMap(const <String, dynamic>{
          'interceptVolumeEvents': true,
          'interceptPowerEvents': false,
        });
        expect(config.interceptVolumeEvents, isTrue);
        expect(config.interceptPowerEvents, isFalse);
      });

      test('uses defaults for missing keys', () {
        final config = DeviceSentinelConfig.fromMap(const <String, dynamic>{});
        expect(config.interceptVolumeEvents, isFalse);
        expect(config.interceptPowerEvents, isFalse);
      });
    });

    group('toString', () {
      test('includes both fields', () {
        const config = DeviceSentinelConfig(interceptVolumeEvents: true);
        expect(
          config.toString(),
          equals(
            'DeviceSentinelConfig('
            'interceptVolumeEvents: true, '
            'interceptPowerEvents: false)',
          ),
        );
      });
    });

    group('roundtrip', () {
      test('fromMap(toMap()) returns equivalent config', () {
        const configs = [
          DeviceSentinelConfig(),
          DeviceSentinelConfig(interceptVolumeEvents: true),
          DeviceSentinelConfig(interceptPowerEvents: true),
          DeviceSentinelConfig(
            interceptVolumeEvents: true,
            interceptPowerEvents: true,
          ),
        ];
        for (final config in configs) {
          expect(
            DeviceSentinelConfig.fromMap(config.toMap()),
            equals(config),
          );
        }
      });
    });

    group('equality', () {
      test('identical configs are equal', () {
        const a = DeviceSentinelConfig(interceptVolumeEvents: true);
        const b = DeviceSentinelConfig(interceptVolumeEvents: true);
        expect(a, equals(b));
        expect(a.hashCode, equals(b.hashCode));
      });

      test('different configs are not equal', () {
        const a = DeviceSentinelConfig();
        const b = DeviceSentinelConfig(interceptVolumeEvents: true);
        expect(a, isNot(equals(b)));
      });
    });
  });
}

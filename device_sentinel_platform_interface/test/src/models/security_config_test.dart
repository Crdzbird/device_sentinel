import 'package:device_sentinel_platform_interface/device_sentinel_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SecurityConfig', () {
    test('default values are all true', () {
      const config = SecurityConfig();
      expect(config.monitorShutdown, isTrue);
      expect(config.monitorConnectivity, isTrue);
      expect(config.monitorScreenLock, isTrue);
      expect(config.monitorPowerUsb, isTrue);
      expect(config.monitorSecurityPosture, isTrue);
    });

    test('toMap produces correct map', () {
      const config = SecurityConfig(
        monitorShutdown: false,
        monitorConnectivity: true,
        monitorScreenLock: false,
        monitorPowerUsb: true,
        monitorSecurityPosture: false,
      );
      expect(config.toMap(), {
        'monitorShutdown': false,
        'monitorConnectivity': true,
        'monitorScreenLock': false,
        'monitorPowerUsb': true,
        'monitorSecurityPosture': false,
      });
    });

    test('fromMap round-trips correctly', () {
      const original = SecurityConfig(
        monitorShutdown: false,
        monitorSecurityPosture: false,
      );
      final restored = SecurityConfig.fromMap(original.toMap());
      expect(restored, equals(original));
    });

    test('fromMap uses defaults for missing keys', () {
      final config = SecurityConfig.fromMap(<String, dynamic>{});
      expect(config, equals(const SecurityConfig()));
    });

    test('equality', () {
      expect(
        const SecurityConfig(),
        equals(const SecurityConfig()),
      );
      expect(
        const SecurityConfig(monitorShutdown: false),
        isNot(equals(const SecurityConfig())),
      );
    });

    test('toString', () {
      expect(
        const SecurityConfig().toString(),
        contains('shutdown=true'),
      );
    });
  });
}

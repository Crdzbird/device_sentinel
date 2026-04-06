import 'package:device_sentinel_platform_interface/device_sentinel_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SentinelConfig', () {
    test('default values', () {
      const config = SentinelConfig();
      expect(config.interceptVolumeUp, isFalse);
      expect(config.interceptVolumeDown, isFalse);
      expect(config.interceptPower, isFalse);
      expect(config.monitorShutdown, isTrue);
      expect(config.monitorConnectivity, isTrue);
      expect(config.monitorScreenLock, isTrue);
      expect(config.monitorPowerUsb, isTrue);
      expect(config.monitorSecurityPosture, isTrue);
    });

    test('toMap produces correct map', () {
      const config = SentinelConfig(
        interceptVolumeUp: true,
        interceptVolumeDown: true,
        interceptPower: true,
        monitorShutdown: false,
        monitorConnectivity: false,
        monitorScreenLock: false,
        monitorPowerUsb: false,
        monitorSecurityPosture: false,
      );
      expect(config.toMap(), {
        'interceptVolumeUp': true,
        'interceptVolumeDown': true,
        'interceptPower': true,
        'monitorShutdown': false,
        'monitorConnectivity': false,
        'monitorScreenLock': false,
        'monitorPowerUsb': false,
        'monitorSecurityPosture': false,
      });
    });

    test('toButtonMap produces correct map', () {
      const config = SentinelConfig(
        interceptVolumeUp: true,
        interceptPower: true,
      );
      expect(config.toButtonMap(), {
        'interceptVolumeUp': true,
        'interceptVolumeDown': false,
        'interceptPower': true,
      });
    });

    test('toSecurityMap produces correct map', () {
      const config = SentinelConfig(
        monitorShutdown: false,
      );
      expect(config.toSecurityMap(), {
        'monitorShutdown': false,
        'monitorConnectivity': true,
        'monitorScreenLock': true,
        'monitorPowerUsb': true,
        'monitorSecurityPosture': true,
      });
    });

    test('fromMap round-trips correctly', () {
      const original = SentinelConfig(
        interceptVolumeUp: true,
        interceptPower: true,
        monitorShutdown: false,
        monitorScreenLock: false,
        monitorSecurityPosture: false,
      );
      final map = original.toMap();
      final restored = SentinelConfig.fromMap(map);
      expect(restored, equals(original));
    });

    test('fromMap uses defaults for missing keys', () {
      final config = SentinelConfig.fromMap(const <String, dynamic>{});
      expect(config, equals(const SentinelConfig()));
    });

    test('equality', () {
      const a = SentinelConfig(interceptVolumeUp: true);
      const b = SentinelConfig(interceptVolumeUp: true);
      const c = SentinelConfig(interceptVolumeDown: true);
      expect(a, equals(b));
      expect(a, isNot(equals(c)));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('toString', () {
      const config = SentinelConfig();
      expect(config.toString(), contains('SentinelConfig'));
      expect(config.toString(), contains('interceptVolumeUp'));
    });
  });
}

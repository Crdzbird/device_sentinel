import 'package:device_sentinel_platform_interface/device_sentinel_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DeviceSecurityEvent.parse', () {
    // -------------------------------------------------------------------
    // Shutdown / Reboot
    // -------------------------------------------------------------------
    test('parses shutdown_detected', () {
      final event = DeviceSecurityEvent.parse('shutdown_detected');
      expect(event, isA<ShutdownDetected>());
      expect(event?.wireValue, 'shutdown_detected');
    });

    test('parses reboot_detected', () {
      final event = DeviceSecurityEvent.parse('reboot_detected');
      expect(event, isA<RebootDetected>());
    });

    test('parses unclean_shutdown with timestamp', () {
      final event = DeviceSecurityEvent.parse('unclean_shutdown:1712345678000');
      expect(event, isA<UncleanShutdownDetected>());
      expect(
        (event! as UncleanShutdownDetected).lastSeenTimestamp,
        1712345678000,
      );
      expect(event.wireValue, 'unclean_shutdown:1712345678000');
    });

    test('unclean_shutdown with invalid timestamp returns null', () {
      expect(DeviceSecurityEvent.parse('unclean_shutdown:abc'), isNull);
    });

    test('unclean_shutdown without timestamp returns null', () {
      expect(DeviceSecurityEvent.parse('unclean_shutdown:'), isNull);
    });

    // -------------------------------------------------------------------
    // Connectivity
    // -------------------------------------------------------------------
    test('parses airplane_mode_on', () {
      expect(
        DeviceSecurityEvent.parse('airplane_mode_on'),
        isA<AirplaneModeOn>(),
      );
    });

    test('parses airplane_mode_off', () {
      expect(
        DeviceSecurityEvent.parse('airplane_mode_off'),
        isA<AirplaneModeOff>(),
      );
    });

    test('parses network_connected', () {
      expect(
        DeviceSecurityEvent.parse('network_connected'),
        isA<NetworkConnected>(),
      );
    });

    test('parses network_disconnected', () {
      expect(
        DeviceSecurityEvent.parse('network_disconnected'),
        isA<NetworkDisconnected>(),
      );
    });

    test('parses network_caps with wifi and mobile', () {
      final event = DeviceSecurityEvent.parse('network_caps:true:false');
      expect(event, isA<NetworkCapsChanged>());
      final caps = event! as NetworkCapsChanged;
      expect(caps.hasWifi, isTrue);
      expect(caps.hasMobile, isFalse);
      expect(caps.wireValue, 'network_caps:true:false');
    });

    test('network_caps with wrong part count returns null', () {
      expect(DeviceSecurityEvent.parse('network_caps:true'), isNull);
    });

    test('parses vpn_established', () {
      expect(
        DeviceSecurityEvent.parse('vpn_established'),
        isA<VpnEstablished>(),
      );
    });

    test('parses vpn_disconnected', () {
      expect(
        DeviceSecurityEvent.parse('vpn_disconnected'),
        isA<VpnDisconnected>(),
      );
    });

    // -------------------------------------------------------------------
    // Screen / Lock
    // -------------------------------------------------------------------
    test('parses screen_off', () {
      expect(DeviceSecurityEvent.parse('screen_off'), isA<ScreenOff>());
    });

    test('parses screen_on', () {
      expect(DeviceSecurityEvent.parse('screen_on'), isA<ScreenOn>());
    });

    test('parses device_locked', () {
      expect(DeviceSecurityEvent.parse('device_locked'), isA<DeviceLocked>());
    });

    test('parses device_unlocked', () {
      expect(
        DeviceSecurityEvent.parse('device_unlocked'),
        isA<DeviceUnlocked>(),
      );
    });

    test('parses user_present', () {
      expect(DeviceSecurityEvent.parse('user_present'), isA<UserPresent>());
    });

    // -------------------------------------------------------------------
    // Power / USB
    // -------------------------------------------------------------------
    test('parses power_connected', () {
      expect(
        DeviceSecurityEvent.parse('power_connected'),
        isA<PowerConnected>(),
      );
    });

    test('parses power_disconnected', () {
      expect(
        DeviceSecurityEvent.parse('power_disconnected'),
        isA<PowerDisconnected>(),
      );
    });

    test('parses battery_low with level', () {
      final event = DeviceSecurityEvent.parse('battery_low:18');
      expect(event, isA<BatteryLow>());
      expect((event! as BatteryLow).level, 18);
      expect(event.wireValue, 'battery_low:18');
    });

    test('battery_low with invalid level returns null', () {
      expect(DeviceSecurityEvent.parse('battery_low:abc'), isNull);
    });

    test('parses battery_critical with level', () {
      final event = DeviceSecurityEvent.parse('battery_critical:3');
      expect(event, isA<BatteryCritical>());
      expect((event! as BatteryCritical).level, 3);
    });

    test('parses usb_debugging_enabled', () {
      expect(
        DeviceSecurityEvent.parse('usb_debugging_enabled'),
        isA<UsbDebuggingEnabled>(),
      );
    });

    test('parses usb_debugging_disabled', () {
      expect(
        DeviceSecurityEvent.parse('usb_debugging_disabled'),
        isA<UsbDebuggingDisabled>(),
      );
    });

    // -------------------------------------------------------------------
    // Security Posture
    // -------------------------------------------------------------------
    test('parses screen_capture_started', () {
      expect(
        DeviceSecurityEvent.parse('screen_capture_started'),
        isA<ScreenCaptureStarted>(),
      );
    });

    test('parses screen_capture_stopped', () {
      expect(
        DeviceSecurityEvent.parse('screen_capture_stopped'),
        isA<ScreenCaptureStopped>(),
      );
    });

    test('parses dev_mode_enabled', () {
      expect(
        DeviceSecurityEvent.parse('dev_mode_enabled'),
        isA<DevModeEnabled>(),
      );
    });

    test('parses dev_mode_disabled', () {
      expect(
        DeviceSecurityEvent.parse('dev_mode_disabled'),
        isA<DevModeDisabled>(),
      );
    });

    // -------------------------------------------------------------------
    // Unknown / Forward compatibility
    // -------------------------------------------------------------------
    test('unknown string returns null', () {
      expect(DeviceSecurityEvent.parse('some_future_event'), isNull);
    });

    test('empty string returns null', () {
      expect(DeviceSecurityEvent.parse(''), isNull);
    });
  });

  group('DeviceSecurityEvent equality', () {
    test('simple events are equal by type', () {
      expect(const ShutdownDetected(), equals(const ShutdownDetected()));
      expect(const ScreenOff(), equals(const ScreenOff()));
    });

    test('parameterised events require matching values', () {
      expect(
        const BatteryLow(level: 15),
        equals(const BatteryLow(level: 15)),
      );
      expect(
        const BatteryLow(level: 15),
        isNot(equals(const BatteryLow(level: 10))),
      );
    });

    test('UncleanShutdownDetected equality', () {
      expect(
        const UncleanShutdownDetected(lastSeenTimestamp: 100),
        equals(const UncleanShutdownDetected(lastSeenTimestamp: 100)),
      );
      expect(
        const UncleanShutdownDetected(lastSeenTimestamp: 100),
        isNot(equals(const UncleanShutdownDetected(lastSeenTimestamp: 200))),
      );
    });

    test('NetworkCapsChanged equality', () {
      expect(
        const NetworkCapsChanged(hasWifi: true, hasMobile: false),
        equals(const NetworkCapsChanged(hasWifi: true, hasMobile: false)),
      );
      expect(
        const NetworkCapsChanged(hasWifi: true, hasMobile: false),
        isNot(
          equals(const NetworkCapsChanged(hasWifi: false, hasMobile: false)),
        ),
      );
    });
  });

  group('DeviceSecurityEvent toString', () {
    test('simple events', () {
      expect(
        const ShutdownDetected().toString(),
        'DeviceSecurityEvent.shutdownDetected',
      );
    });

    test('parameterised events', () {
      expect(
        const BatteryLow(level: 18).toString(),
        'DeviceSecurityEvent.batteryLow(18)',
      );
    });
  });
}

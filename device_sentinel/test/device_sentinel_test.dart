import 'package:device_sentinel/device_sentinel.dart';
import 'package:device_sentinel_platform_interface/device_sentinel_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockDeviceSentinelPlatform extends Mock
    with MockPlatformInterfaceMixin
    implements DeviceSentinelPlatform {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    registerFallbackValue(const SentinelConfig());
  });

  group('DeviceSentinel', () {
    late DeviceSentinelPlatform platform;

    setUp(() {
      platform = MockDeviceSentinelPlatform();
      DeviceSentinelPlatform.instance = platform;
    });

    group('events', () {
      test('delegates to platform interface', () {
        final events = Stream<DeviceEvent>.fromIterable([
          const ButtonEvent(
            button: VolumeUpButton(),
            action: ButtonPressed(),
          ),
          const ScreenOff(),
          const DeviceLocked(),
        ]);
        when(() => platform.events).thenAnswer((_) => events);

        const sentinel = DeviceSentinel();
        expect(sentinel.events, equals(events));
        verify(() => platform.events).called(1);
      });
    });

    group('start', () {
      test('delegates with default config', () async {
        when(
          () => platform.start(config: any(named: 'config')),
        ).thenAnswer((_) async {});

        const sentinel = DeviceSentinel();
        await sentinel.start();

        verify(() => platform.start()).called(1);
      });

      test('delegates with custom config', () async {
        when(
          () => platform.start(config: any(named: 'config')),
        ).thenAnswer((_) async {});

        const sentinel = DeviceSentinel();
        const config = SentinelConfig(
          interceptVolumeUp: true,
          monitorShutdown: false,
        );
        await sentinel.start(config: config);

        verify(() => platform.start(config: config)).called(1);
      });
    });

    group('stop', () {
      test('delegates to platform interface', () async {
        when(() => platform.stop()).thenAnswer((_) async {});

        const sentinel = DeviceSentinel();
        await sentinel.stop();

        verify(() => platform.stop()).called(1);
      });
    });

    group('getPlatformName (deprecated)', () {
      test('returns correct name', () async {
        const platformName = '__test_platform__';
        when(
          () => platform.getPlatformName(),
        ).thenAnswer((_) async => platformName);

        // Calling deprecated API to verify backward compatibility.
        // ignore: deprecated_member_use_from_same_package
        final actualPlatformName = await getPlatformName();
        expect(actualPlatformName, equals(platformName));
      });

      test('throws when null', () async {
        when(
          () => platform.getPlatformName(),
        ).thenAnswer((_) async => null);

        // Calling deprecated API to verify backward compatibility.
        // ignore: deprecated_member_use_from_same_package
        expect(getPlatformName, throwsException);
      });
    });
  });
}

import 'package:device_sentinel_platform_interface/device_sentinel_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

class DeviceSentinelMock extends DeviceSentinelPlatform {
  static const mockPlatformName = 'Mock';

  @override
  Stream<DeviceEvent> get events => const Stream.empty();

  @override
  Future<void> start({SentinelConfig config = const SentinelConfig()}) async {}

  @override
  Future<void> stop() async {}

  @override
  Future<String?> getPlatformName() async => mockPlatformName;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  group('DeviceSentinelPlatformInterface', () {
    late DeviceSentinelPlatform platform;

    setUp(() {
      platform = DeviceSentinelMock();
      DeviceSentinelPlatform.instance = platform;
    });

    group('getPlatformName', () {
      test('returns correct name', () async {
        expect(
          await DeviceSentinelPlatform.instance.getPlatformName(),
          equals(DeviceSentinelMock.mockPlatformName),
        );
      });
    });

    group('events', () {
      test('returns a stream', () {
        expect(
          DeviceSentinelPlatform.instance.events,
          isA<Stream<DeviceEvent>>(),
        );
      });
    });

    group('start', () {
      test('completes without error', () async {
        await expectLater(
          DeviceSentinelPlatform.instance.start(),
          completes,
        );
      });

      test('accepts custom config', () async {
        await expectLater(
          DeviceSentinelPlatform.instance.start(
            config: const SentinelConfig(interceptVolumeUp: true),
          ),
          completes,
        );
      });
    });

    group('stop', () {
      test('completes without error', () async {
        await expectLater(
          DeviceSentinelPlatform.instance.stop(),
          completes,
        );
      });
    });
  });
}

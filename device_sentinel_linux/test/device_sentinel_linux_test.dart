import 'package:device_sentinel_linux/device_sentinel_linux.dart';
import 'package:device_sentinel_platform_interface/device_sentinel_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('DeviceSentinelLinux', () {
    late DeviceSentinelLinux plugin;

    setUp(() async {
      plugin = DeviceSentinelLinux();
    });

    test('can be registered', () {
      DeviceSentinelLinux.registerWith();
      expect(DeviceSentinelPlatform.instance, isA<DeviceSentinelLinux>());
    });

    test('events returns empty stream', () async {
      expect(await plugin.events.isEmpty, isTrue);
    });

    test('start throws PlatformUnsupportedException', () {
      expect(
        plugin.start,
        throwsA(isA<PlatformUnsupportedException>()),
      );
    });

    test('stop throws PlatformUnsupportedException', () {
      expect(
        plugin.stop,
        throwsA(isA<PlatformUnsupportedException>()),
      );
    });
  });
}

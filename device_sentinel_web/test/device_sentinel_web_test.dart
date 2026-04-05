import 'package:device_sentinel_platform_interface/device_sentinel_platform_interface.dart';
import 'package:device_sentinel_web/device_sentinel_web.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('DeviceSentinelWeb', () {
    late DeviceSentinelWeb plugin;

    setUp(() {
      plugin = DeviceSentinelWeb();
    });

    test('can be registered', () {
      DeviceSentinelWeb.registerWith();
      expect(DeviceSentinelPlatform.instance, isA<DeviceSentinelWeb>());
    });

    test('getPlatformName returns correct name', () async {
      final name = await plugin.getPlatformName();
      expect(name, equals('Web'));
    });

    test('events returns empty stream', () async {
      expect(await plugin.events.isEmpty, isTrue);
    });

    test('start throws UnsupportedError', () {
      expect(plugin.start, throwsUnsupportedError);
    });

    test('stop throws UnsupportedError', () {
      expect(plugin.stop, throwsUnsupportedError);
    });
  });
}

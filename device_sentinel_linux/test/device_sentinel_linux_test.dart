import 'package:device_sentinel_linux/device_sentinel_linux.dart';
import 'package:device_sentinel_platform_interface/device_sentinel_platform_interface.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('DeviceSentinelLinux', () {
    const kPlatformName = 'Linux';
    late DeviceSentinelLinux plugin;
    late List<MethodCall> log;

    setUp(() async {
      plugin = DeviceSentinelLinux();

      log = <MethodCall>[];
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        plugin.methodChannel,
        (methodCall) async {
          log.add(methodCall);
          switch (methodCall.method) {
            case 'getPlatformName':
              return kPlatformName;
            default:
              return null;
          }
        },
      );
    });

    test('can be registered', () {
      DeviceSentinelLinux.registerWith();
      expect(DeviceSentinelPlatform.instance, isA<DeviceSentinelLinux>());
    });

    test('getPlatformName returns correct name', () async {
      final name = await plugin.getPlatformName();
      expect(
        log,
        <Matcher>[isMethodCall('getPlatformName', arguments: null)],
      );
      expect(name, equals(kPlatformName));
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

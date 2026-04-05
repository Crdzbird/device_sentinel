import 'package:device_sentinel_macos/device_sentinel_macos.dart';
import 'package:device_sentinel_platform_interface/device_sentinel_platform_interface.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('DeviceSentinelMacOS', () {
    const kPlatformName = 'MacOS';
    late DeviceSentinelMacOS plugin;
    late List<MethodCall> log;

    setUp(() async {
      plugin = DeviceSentinelMacOS();

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
      DeviceSentinelMacOS.registerWith();
      expect(DeviceSentinelPlatform.instance, isA<DeviceSentinelMacOS>());
    });

    test('getPlatformName returns correct name', () async {
      final name = await plugin.getPlatformName();
      expect(
        log,
        <Matcher>[isMethodCall('getPlatformName', arguments: null)],
      );
      expect(name, equals(kPlatformName));
    });

    test('events returns a stream', () {
      expect(plugin.events, isA<Stream<DeviceEvent>>());
    });

    test('start sends button config via startListening', () async {
      await plugin.start();
      expect(
        log,
        <Matcher>[
          isMethodCall(
            'startListening',
            arguments: <String, dynamic>{
              'interceptVolumeUp': false,
              'interceptVolumeDown': false,
              'interceptPower': false,
            },
          ),
        ],
      );
    });

    test('stop sends stopListening', () async {
      await plugin.stop();
      expect(
        log,
        <Matcher>[isMethodCall('stopListening', arguments: null)],
      );
    });
  });
}

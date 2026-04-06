import 'package:device_sentinel_ios/device_sentinel_ios.dart';
import 'package:device_sentinel_platform_interface/device_sentinel_platform_interface.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('DeviceSentinelIOS', () {
    late DeviceSentinelIOS plugin;
    late List<MethodCall> log;

    setUp(() async {
      plugin = DeviceSentinelIOS();

      log = <MethodCall>[];
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        plugin.methodChannel,
        (methodCall) async {
          log.add(methodCall);
          return null;
        },
      );
    });

    test('can be registered', () {
      DeviceSentinelIOS.registerWith();
      expect(DeviceSentinelPlatform.instance, isA<DeviceSentinelIOS>());
    });

    test('events returns a stream', () {
      expect(plugin.events, isA<Stream<DeviceEvent>>());
    });

    test('start sends default config', () async {
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
          isMethodCall(
            'startSecurityMonitoring',
            arguments: <String, dynamic>{
              'monitorShutdown': true,
              'monitorConnectivity': true,
              'monitorScreenLock': true,
              'monitorPowerUsb': true,
              'monitorSecurityPosture': true,
            },
          ),
        ],
      );
    });

    test('start sends custom config', () async {
      await plugin.start(
        config: const SentinelConfig(
          interceptVolumeUp: true,
          monitorShutdown: false,
        ),
      );
      expect(
        log,
        <Matcher>[
          isMethodCall(
            'startListening',
            arguments: <String, dynamic>{
              'interceptVolumeUp': true,
              'interceptVolumeDown': false,
              'interceptPower': false,
            },
          ),
          isMethodCall(
            'startSecurityMonitoring',
            arguments: <String, dynamic>{
              'monitorShutdown': false,
              'monitorConnectivity': true,
              'monitorScreenLock': true,
              'monitorPowerUsb': true,
              'monitorSecurityPosture': true,
            },
          ),
        ],
      );
    });

    test('stop', () async {
      await plugin.stop();
      expect(
        log,
        <Matcher>[
          isMethodCall('stopListening', arguments: null),
          isMethodCall('stopSecurityMonitoring', arguments: null),
        ],
      );
    });
  });
}

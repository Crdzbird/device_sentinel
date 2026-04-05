import 'package:device_sentinel_android/device_sentinel_android.dart';
import 'package:device_sentinel_platform_interface/device_sentinel_platform_interface.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('DeviceSentinelAndroid', () {
    const kPlatformName = 'Android';
    late DeviceSentinelAndroid plugin;
    late List<MethodCall> log;

    setUp(() async {
      plugin = DeviceSentinelAndroid();

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
      DeviceSentinelAndroid.registerWith();
      expect(
        DeviceSentinelPlatform.instance,
        isA<DeviceSentinelAndroid>(),
      );
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
          interceptVolumeDown: true,
          monitorShutdown: false,
          monitorConnectivity: false,
        ),
      );
      expect(
        log,
        <Matcher>[
          isMethodCall(
            'startListening',
            arguments: <String, dynamic>{
              'interceptVolumeUp': true,
              'interceptVolumeDown': true,
              'interceptPower': false,
            },
          ),
          isMethodCall(
            'startSecurityMonitoring',
            arguments: <String, dynamic>{
              'monitorShutdown': false,
              'monitorConnectivity': false,
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

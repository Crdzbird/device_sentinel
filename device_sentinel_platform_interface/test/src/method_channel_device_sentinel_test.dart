import 'package:device_sentinel_platform_interface/device_sentinel_platform_interface.dart';
import 'package:device_sentinel_platform_interface/src/method_channel_device_sentinel.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('$MethodChannelDeviceSentinel', () {
    late MethodChannelDeviceSentinel methodChannelDeviceSentinel;
    final log = <MethodCall>[];

    setUp(() async {
      methodChannelDeviceSentinel = MethodChannelDeviceSentinel();
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        methodChannelDeviceSentinel.methodChannel,
        (methodCall) async {
          log.add(methodCall);
          return null;
        },
      );
    });

    tearDown(log.clear);

    test('start sends default config', () async {
      await methodChannelDeviceSentinel.start();
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
      await methodChannelDeviceSentinel.start(
        config: const SentinelConfig(
          interceptVolumeUp: true,
          interceptVolumeDown: true,
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
              'interceptVolumeDown': true,
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
      await methodChannelDeviceSentinel.stop();
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

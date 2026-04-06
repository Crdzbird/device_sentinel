import 'package:device_sentinel_platform_interface/device_sentinel_platform_interface.dart';
import 'package:device_sentinel_windows/device_sentinel_windows.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('DeviceSentinelWindows', () {
    late DeviceSentinelWindows plugin;
    late List<MethodCall> log;

    setUp(() async {
      plugin = DeviceSentinelWindows();

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
      DeviceSentinelWindows.registerWith();
      expect(
        DeviceSentinelPlatform.instance,
        isA<DeviceSentinelWindows>(),
      );
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

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vol_spotter_platform_interface/src/method_channel_vol_spotter.dart';
import 'package:vol_spotter_platform_interface/vol_spotter_platform_interface.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const kPlatformName = 'platformName';

  group('$MethodChannelVolSpotter', () {
    late MethodChannelVolSpotter methodChannelVolSpotter;
    final log = <MethodCall>[];

    setUp(() async {
      methodChannelVolSpotter = MethodChannelVolSpotter();
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        methodChannelVolSpotter.methodChannel,
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

    tearDown(log.clear);

    test('getPlatformName', () async {
      final platformName =
          await methodChannelVolSpotter.getPlatformName();
      expect(
        log,
        <Matcher>[isMethodCall('getPlatformName', arguments: null)],
      );
      expect(platformName, equals(kPlatformName));
    });

    test('startListening sends config', () async {
      await methodChannelVolSpotter.startListening();
      expect(
        log,
        <Matcher>[
          isMethodCall(
            'startListening',
            arguments: <String, dynamic>{
              'interceptVolumeEvents': false,
              'interceptPowerEvents': false,
            },
          ),
        ],
      );
    });

    test('startListening sends custom config', () async {
      await methodChannelVolSpotter.startListening(
        config: const VolSpotterConfig(interceptVolumeEvents: true),
      );
      expect(
        log,
        <Matcher>[
          isMethodCall(
            'startListening',
            arguments: <String, dynamic>{
              'interceptVolumeEvents': true,
              'interceptPowerEvents': false,
            },
          ),
        ],
      );
    });

    test('stopListening', () async {
      await methodChannelVolSpotter.stopListening();
      expect(
        log,
        <Matcher>[isMethodCall('stopListening', arguments: null)],
      );
    });
  });
}

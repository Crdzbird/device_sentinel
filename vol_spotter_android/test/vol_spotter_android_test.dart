import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vol_spotter_android/vol_spotter_android.dart';
import 'package:vol_spotter_platform_interface/vol_spotter_platform_interface.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('VolSpotterAndroid', () {
    const kPlatformName = 'Android';
    late VolSpotterAndroid volSpotter;
    late List<MethodCall> log;

    setUp(() async {
      volSpotter = VolSpotterAndroid();

      log = <MethodCall>[];
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        volSpotter.methodChannel,
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
      VolSpotterAndroid.registerWith();
      expect(VolSpotterPlatform.instance, isA<VolSpotterAndroid>());
    });

    test('getPlatformName returns correct name', () async {
      final name = await volSpotter.getPlatformName();
      expect(
        log,
        <Matcher>[isMethodCall('getPlatformName', arguments: null)],
      );
      expect(name, equals(kPlatformName));
    });

    test('startListening sends default config', () async {
      await volSpotter.startListening();
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
      await volSpotter.startListening(
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
      await volSpotter.stopListening();
      expect(
        log,
        <Matcher>[isMethodCall('stopListening', arguments: null)],
      );
    });

    test('buttonEvents returns a stream', () {
      expect(volSpotter.buttonEvents, isA<Stream<ButtonEvent>>());
    });
  });
}

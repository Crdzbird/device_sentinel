import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vol_spotter_ios/vol_spotter_ios.dart';
import 'package:vol_spotter_platform_interface/vol_spotter_platform_interface.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('VolSpotterIOS', () {
    const kPlatformName = 'iOS';
    late VolSpotterIOS volSpotter;
    late List<MethodCall> log;

    setUp(() async {
      volSpotter = VolSpotterIOS();

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
      VolSpotterIOS.registerWith();
      expect(VolSpotterPlatform.instance, isA<VolSpotterIOS>());
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

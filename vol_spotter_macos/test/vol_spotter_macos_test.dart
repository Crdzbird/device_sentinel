import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vol_spotter_macos/vol_spotter_macos.dart';
import 'package:vol_spotter_platform_interface/vol_spotter_platform_interface.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('VolSpotterMacOS', () {
    const kPlatformName = 'MacOS';
    late VolSpotterMacOS volSpotter;
    late List<MethodCall> log;

    setUp(() async {
      volSpotter = VolSpotterMacOS();

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
      });
    });

    test('can be registered', () {
      VolSpotterMacOS.registerWith();
      expect(VolSpotterPlatform.instance, isA<VolSpotterMacOS>());
    });

    test('getPlatformName returns correct name', () async {
      final name = await volSpotter.getPlatformName();
      expect(
        log,
        <Matcher>[isMethodCall('getPlatformName', arguments: null)],
      );
      expect(name, equals(kPlatformName));
    });

    test('buttonEvents returns empty stream', () async {
      expect(await volSpotter.buttonEvents.isEmpty, isTrue);
    });

    test('startListening throws UnsupportedError', () {
      expect(volSpotter.startListening, throwsUnsupportedError);
    });

    test('stopListening throws UnsupportedError', () {
      expect(volSpotter.stopListening, throwsUnsupportedError);
    });
  });
}

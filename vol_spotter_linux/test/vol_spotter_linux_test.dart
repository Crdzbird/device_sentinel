import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vol_spotter_linux/vol_spotter_linux.dart';
import 'package:vol_spotter_platform_interface/vol_spotter_platform_interface.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('VolSpotterLinux', () {
    const kPlatformName = 'Linux';
    late VolSpotterLinux volSpotter;
    late List<MethodCall> log;

    setUp(() async {
      volSpotter = VolSpotterLinux();

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
      VolSpotterLinux.registerWith();
      expect(VolSpotterPlatform.instance, isA<VolSpotterLinux>());
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

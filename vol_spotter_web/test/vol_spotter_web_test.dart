import 'package:flutter_test/flutter_test.dart';
import 'package:vol_spotter_platform_interface/vol_spotter_platform_interface.dart';
import 'package:vol_spotter_web/vol_spotter_web.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('VolSpotterWeb', () {
    const kPlatformName = 'Web';
    late VolSpotterWeb volSpotter;

    setUp(() async {
      volSpotter = VolSpotterWeb();
    });

    test('can be registered', () {
      VolSpotterWeb.registerWith();
      expect(VolSpotterPlatform.instance, isA<VolSpotterWeb>());
    });

    test('getPlatformName returns correct name', () async {
      final name = await volSpotter.getPlatformName();
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

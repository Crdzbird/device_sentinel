import 'package:flutter_test/flutter_test.dart';
import 'package:vol_spotter_platform_interface/vol_spotter_platform_interface.dart';

class VolSpotterMock extends VolSpotterPlatform {
  static const mockPlatformName = 'Mock';

  @override
  Stream<ButtonEvent> get buttonEvents => const Stream.empty();

  @override
  Future<void> startListening({
    VolSpotterConfig config = const VolSpotterConfig(),
  }) async {}

  @override
  Future<void> stopListening() async {}

  @override
  Future<String?> getPlatformName() async => mockPlatformName;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  group('VolSpotterPlatformInterface', () {
    late VolSpotterPlatform volSpotterPlatform;

    setUp(() {
      volSpotterPlatform = VolSpotterMock();
      VolSpotterPlatform.instance = volSpotterPlatform;
    });

    group('getPlatformName', () {
      test('returns correct name', () async {
        expect(
          await VolSpotterPlatform.instance.getPlatformName(),
          equals(VolSpotterMock.mockPlatformName),
        );
      });
    });

    group('buttonEvents', () {
      test('returns a stream', () {
        expect(
          VolSpotterPlatform.instance.buttonEvents,
          isA<Stream<ButtonEvent>>(),
        );
      });
    });

    group('startListening', () {
      test('completes without error', () async {
        await expectLater(
          VolSpotterPlatform.instance.startListening(),
          completes,
        );
      });

      test('accepts custom config', () async {
        await expectLater(
          VolSpotterPlatform.instance.startListening(
            config: const VolSpotterConfig(interceptVolumeEvents: true),
          ),
          completes,
        );
      });
    });

    group('stopListening', () {
      test('completes without error', () async {
        await expectLater(
          VolSpotterPlatform.instance.stopListening(),
          completes,
        );
      });
    });
  });
}

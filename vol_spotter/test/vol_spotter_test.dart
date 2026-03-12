import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:vol_spotter/vol_spotter.dart';
import 'package:vol_spotter_platform_interface/vol_spotter_platform_interface.dart';

class MockVolSpotterPlatform extends Mock
    with MockPlatformInterfaceMixin
    implements VolSpotterPlatform {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    registerFallbackValue(const VolSpotterConfig());
  });

  group('VolSpotter', () {
    late VolSpotterPlatform volSpotterPlatform;

    setUp(() {
      volSpotterPlatform = MockVolSpotterPlatform();
      VolSpotterPlatform.instance = volSpotterPlatform;
    });

    group('buttonEvents', () {
      test('delegates to platform interface', () {
        final events = Stream<ButtonEvent>.fromIterable([
          const ButtonEvent(
            button: VolumeUpButton(),
            action: ButtonPressed(),
          ),
        ]);
        when(() => volSpotterPlatform.buttonEvents).thenAnswer((_) => events);

        const volSpotter = VolSpotter();
        expect(volSpotter.buttonEvents, equals(events));
        verify(() => volSpotterPlatform.buttonEvents).called(1);
      });
    });

    group('startListening', () {
      test('delegates with default config', () async {
        when(
          () => volSpotterPlatform.startListening(
            config: any(named: 'config'),
          ),
        ).thenAnswer((_) async {});

        const volSpotter = VolSpotter();
        await volSpotter.startListening();

        verify(() => volSpotterPlatform.startListening()).called(1);
      });

      test('delegates with custom config', () async {
        when(
          () => volSpotterPlatform.startListening(
            config: any(named: 'config'),
          ),
        ).thenAnswer((_) async {});

        const volSpotter = VolSpotter();
        const config = VolSpotterConfig(interceptVolumeEvents: true);
        await volSpotter.startListening(config: config);

        verify(
          () => volSpotterPlatform.startListening(config: config),
        ).called(1);
      });
    });

    group('stopListening', () {
      test('delegates to platform interface', () async {
        when(() => volSpotterPlatform.stopListening())
            .thenAnswer((_) async {});

        const volSpotter = VolSpotter();
        await volSpotter.stopListening();

        verify(() => volSpotterPlatform.stopListening()).called(1);
      });
    });

    group('getPlatformName (deprecated)', () {
      test('returns correct name', () async {
        const platformName = '__test_platform__';
        when(
          () => volSpotterPlatform.getPlatformName(),
        ).thenAnswer((_) async => platformName);

        // Calling deprecated API to verify backward compatibility.
        // ignore: deprecated_member_use_from_same_package
        final actualPlatformName = await getPlatformName();
        expect(actualPlatformName, equals(platformName));
      });

      test('throws when null', () async {
        when(
          () => volSpotterPlatform.getPlatformName(),
        ).thenAnswer((_) async => null);

        // Calling deprecated API to verify backward compatibility.
        // ignore: deprecated_member_use_from_same_package
        expect(getPlatformName, throwsException);
      });
    });
  });
}

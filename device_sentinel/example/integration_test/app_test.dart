import 'package:device_sentinel_example/main.dart' as app;
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('E2E', () {
    testWidgets('renders app bar with Start chip', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // App bar title
      expect(find.text('Device Sentinel'), findsOneWidget);

      // Start/Stop ActionChip in app bar (initially "Start")
      expect(find.text('Start'), findsOneWidget);
    });

    testWidgets('renders button tab with interception toggles',
        (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // The Buttons tab is shown by default
      expect(
        find.text('Intercept (block default OS action)'),
        findsOneWidget,
      );

      // Interception toggle chips
      expect(find.text('Vol Up'), findsOneWidget);
      expect(find.text('Vol Down'), findsOneWidget);
      expect(find.text('Power'), findsOneWidget);
    });

    testWidgets('renders button tab empty state', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Empty state hint when not monitoring
      expect(find.text('Tap Start to begin.'), findsOneWidget);
    });

    testWidgets('can navigate to security tab', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Tap the Security tab
      await tester.tap(find.text('Security'));
      await tester.pumpAndSettle();

      // Verify security tab category toggles are visible
      expect(find.text('Monitor categories'), findsOneWidget);
      expect(find.text('Shutdown'), findsOneWidget);
      expect(find.text('Connectivity'), findsOneWidget);
      expect(find.text('Screen / Lock'), findsOneWidget);
      expect(find.text('Power / USB'), findsOneWidget);

      // Security posture toggle
      // (The chip label is "Security" which also matches the nav item,
      // so expect at least one.)
      expect(find.text('Security'), findsWidgets);

      // Empty state when not monitoring
      expect(
        find.text('Tap Start to begin monitoring'),
        findsOneWidget,
      );
    });

    testWidgets('can navigate back to buttons tab', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Navigate to Security tab
      await tester.tap(find.text('Security'));
      await tester.pumpAndSettle();

      // Navigate back to Buttons tab
      await tester.tap(find.text('Buttons'));
      await tester.pumpAndSettle();

      // Verify button tab content is shown
      expect(
        find.text('Intercept (block default OS action)'),
        findsOneWidget,
      );
      expect(find.text('Vol Up'), findsOneWidget);
    });
  });
}

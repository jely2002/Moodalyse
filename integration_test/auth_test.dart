import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:moodalyse/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('login', () {
    testWidgets('tap on the floating action button, verify counter',
            (WidgetTester tester) async {
          app.main();
          await tester.pumpAndSettle();

          // Verify we are at registration screen
          expect(find.text('Create a Moodalyse account'), findsOneWidget);

          // Finds the floating action button to tap on.
          final Finder login = find.textContaining('Log in');

          // Emulate a tap on the floating action button.
          await tester.tap(login);

          // Trigger a frame.
          await tester.pumpAndSettle();

          // Verify we are at registration screen
          expect(find.text('Login to Moodalyse'), findsOneWidget);

          final Finder email = find.text('E-mail');
          final Finder password = find.text('Password');

          await tester.enterText(email, 'test@moodalyse.com');

          await tester.pumpAndSettle();

          await tester.enterText(password, 'moodalyse');

          await tester.pumpAndSettle();

          final Finder loginButton = find.text('Log in');

          tester.tap(loginButton);

          await tester.pumpAndSettle();

          expect(find.text('Add a mood to your day'), findsOneWidget);

        });
  });

}

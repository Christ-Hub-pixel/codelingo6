import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:codelingo/main.dart';
import 'package:codelingo/fournisseurs/progression_fournisseur.dart';
import 'package:codelingo/fournisseurs/notification_fournisseur.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('App startup smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (context) => ProgressionFournisseur()),
          ChangeNotifierProvider(create: (context) => NotificationFournisseur()),
        ],
        child: const MyApp(),
      ),
    );

    // Verify that the splash screen is shown with the app name.
    expect(find.text('Codelingo'), findsOneWidget);
  });
}

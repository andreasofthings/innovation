import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:innovation/screens/login_screen.dart';
import 'package:provider/provider.dart';
import 'package:innovation/providers/auth_provider.dart';

void main() {
  testWidgets('LoginScreen shows the Innovation Card and Login button', (WidgetTester tester) async {
    final authProvider = AuthProvider();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: authProvider),
        ],
        child: const MaterialApp(
          home: LoginScreen(),
        ),
      ),
    );

    // Verify AppBar
    expect(find.text('Innovation Coach'), findsOneWidget);

    // Verify the card content
    expect(find.byIcon(Icons.lightbulb_outline), findsOneWidget);
    expect(find.text('Ready to Innovate?'), findsOneWidget);
    expect(find.text('Start planning your next innovation here.'), findsOneWidget);

    // Verify the Login button
    expect(find.widgetWithText(ElevatedButton, 'Login'), findsOneWidget);
  });

  testWidgets('LoginScreen shows footer text and link', (WidgetTester tester) async {
    final authProvider = AuthProvider();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: authProvider),
        ],
        child: const MaterialApp(
          home: LoginScreen(),
        ),
      ),
    );

    expect(find.textContaining('made with ❤️ in Munich by'), findsOneWidget);
    expect(find.text('https://neumeier.org'), findsOneWidget);
  });
}

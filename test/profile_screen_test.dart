import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:innovation/screens/profile_screen.dart';
import 'package:provider/provider.dart';
import 'package:innovation/providers/auth_provider.dart';
import 'package:innovation/providers/user_provider.dart';

class MockUserProvider extends UserProvider {
  bool _mockHasError = false;

  MockUserProvider() : super(null);

  @override
  bool get hasError => _mockHasError;

  void setHasError(bool value) {
    _mockHasError = value;
    notifyListeners();
  }

  @override
  bool get isLoading => false;
}

void main() {
  testWidgets('ProfileScreen shows default values and logout button when profile is null', (WidgetTester tester) async {
    final authProvider = AuthProvider();
    final userProvider = UserProvider(null);

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<AuthProvider>.value(value: authProvider),
          ChangeNotifierProvider<UserProvider>.value(value: userProvider),
        ],
        child: const MaterialApp(
          home: ProfileScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Verify default language is English
    expect(find.text('English'), findsOneWidget);

    // Verify logout button exists
    expect(find.byType(OutlinedButton), findsOneWidget);
    expect(find.text('Logout'), findsOneWidget);
  });

  testWidgets('ProfileScreen fields are disabled and snackbar shown when hasError is true', (WidgetTester tester) async {
    final authProvider = AuthProvider();
    final userProvider = MockUserProvider();
    userProvider.setHasError(true);

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<AuthProvider>.value(value: authProvider),
          ChangeNotifierProvider<UserProvider>.value(value: userProvider),
        ],
        child: const MaterialApp(
          home: ProfileScreen(),
        ),
      ),
    );

    await tester.pump(); // Start frame for snackbar
    await tester.pump(const Duration(seconds: 1)); // Advance for snackbar animation

    expect(find.text('Profile not available. Using offline settings.'), findsOneWidget);

    // Verify TextFormField (e.g., Country) is disabled
    final countryField = tester.widget<TextFormField>(find.widgetWithText(TextFormField, 'Country'));
    expect(countryField.enabled, false);

    // Verify Logout button is still enabled
    final logoutButton = tester.widget<OutlinedButton>(find.byType(OutlinedButton));
    expect(logoutButton.enabled, true);
  });
}

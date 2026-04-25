import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:coach/screens/home_screen.dart';
import 'package:coach/screens/library_screen.dart';
import 'package:coach/screens/workshop_screen.dart';
import 'package:coach/screens/favorites_screen.dart';
import 'package:coach/screens/profile_screen.dart';
import 'package:provider/provider.dart';
import 'package:coach/providers/auth_provider.dart';
import 'package:coach/providers/user_provider.dart';
import 'package:coach/providers/method_provider.dart';
import 'package:coach/providers/workshop_provider.dart';

void main() {
  testWidgets('HomePage navigation test', (WidgetTester tester) async {
    final authProvider = AuthProvider();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: authProvider),
          ChangeNotifierProvider(create: (context) => UserProvider(null)),
          ChangeNotifierProvider(create: (context) => MethodProvider()),
          ChangeNotifierProvider(create: (context) => WorkshopProvider()),
        ],
        child: const MaterialApp(
          home: HomePage(title: 'Coach'),
        ),
      ),
    );

    // Verify initial state (Home tab)
    expect(find.text('Home Screen'), findsOneWidget);

    // Navigate to Library
    await tester.tap(find.text('LIBRARY'));
    await tester.pumpAndSettle();
    expect(find.byType(LibraryScreen), findsOneWidget);

    // Navigate to Workshop
    await tester.tap(find.text('WORKSHOP'));
    await tester.pumpAndSettle();
    expect(find.byType(WorkshopScreen), findsOneWidget);

    // Navigate to Favorites
    await tester.tap(find.text('FAVORITES'));
    await tester.pumpAndSettle();
    expect(find.byType(FavoritesScreen), findsOneWidget);

    // Navigate to Profile
    await tester.tap(find.text('PROFILE'));
    await tester.pumpAndSettle();
    expect(find.byType(ProfileScreen), findsOneWidget);
  });
}

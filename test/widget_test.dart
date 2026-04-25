import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:coach/main.dart';
import 'package:coach/providers/auth_provider.dart';
import 'package:coach/providers/user_provider.dart';
import 'package:coach/providers/method_provider.dart';
import 'package:coach/providers/workshop_provider.dart';
import 'package:provider/provider.dart';

void main() {
  testWidgets('Coach app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (context) => AuthProvider()),
          ChangeNotifierProxyProvider<AuthProvider, UserProvider>(
            create: (context) => UserProvider(null),
            update: (context, auth, previous) {
              if (previous != null) {
                previous.updateAuth(auth);
                return previous;
              }
              return UserProvider(auth);
            },
          ),
          ChangeNotifierProvider(create: (context) => MethodProvider()),
          ChangeNotifierProvider(create: (context) => WorkshopProvider()),
        ],
        child: const Coach(),
      ),
    );

    expect(find.byType(MaterialApp), findsOneWidget);
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:innovation/main.dart';
import 'package:provider/provider.dart';
import 'package:innovation/providers/auth_provider.dart';

void main() {
  testWidgets('Login screen smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    // We need to provide the AuthProvider for the Innovation widget to work.
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (context) => AuthProvider(),
        child: const Innovation(),
      ),
    );

    // Verify that the login button is present.
    expect(find.text('Login'), findsOneWidget);
    expect(find.byType(ElevatedButton), findsOneWidget);
  });
}

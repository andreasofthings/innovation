import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:coach/screens/workshop_screen.dart';
import 'package:coach/providers/workshop_provider.dart';
import 'package:provider/provider.dart';

void main() {
  testWidgets('WorkshopScreen shows workshops and filter bar', (WidgetTester tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (context) => WorkshopProvider(),
        child: const MaterialApp(
          home: WorkshopScreen(),
        ),
      ),
    );

    // Check header
    expect(find.text('Workshop Planner'), findsOneWidget);

    // Check filter chips
    expect(find.text('All Status'), findsOneWidget);
    expect(find.text('Date: Newest'), findsOneWidget);
    expect(find.text('Session'), findsOneWidget);

    // Check initial workshops from provider
    expect(find.text('Advanced UX Strategy'), findsOneWidget);
    expect(find.text('Design Systems Workshop'), findsOneWidget);

    // Check FAB
    expect(find.byType(FloatingActionButton), findsOneWidget);
  });

  testWidgets('WorkshopScreen create workshop dialog', (WidgetTester tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (context) => WorkshopProvider(),
        child: const MaterialApp(
          home: WorkshopScreen(),
        ),
      ),
    );

    // Open create dialog
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    expect(find.text('Create Workshop'), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);

    // Enter title
    await tester.enterText(find.byType(TextField), 'New Test Workshop');
    await tester.tap(find.text('Create'));
    await tester.pumpAndSettle();

    // Verify it appeared in the list
    expect(find.text('New Test Workshop'), findsOneWidget);
  });
}

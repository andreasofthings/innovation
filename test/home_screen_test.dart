import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:coach/screens/home_screen.dart';

void main() {
  testWidgets('HomeContent shows only Ready to Innovate card', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: HomeContent(),
        ),
      ),
    );

    // Verify "Ready to Innovate?" is present
    expect(find.text('Ready to Innovate?'), findsOneWidget);
    expect(find.text('Access your creative workshops, templates, and facilitation guides to spark the next big idea.'), findsOneWidget);
    expect(find.text('Start a Session'), findsOneWidget);

    // Verify removed items are NOT present
    expect(find.text('Method Library'), findsNothing);
    expect(find.text('Active Groups'), findsNothing);
    expect(find.text('Browse 50+ proven facilitation frameworks.'), findsNothing);
    expect(find.text('Manage your current workshop participants.'), findsNothing);
  });
}

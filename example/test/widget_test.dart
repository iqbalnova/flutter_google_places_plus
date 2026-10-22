import 'package:flutter/material.dart';
import 'package:flutter_google_places_plus_example/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Renders Google Places Plus search UI', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const PlacesExampleApp());

    expect(find.text('Google Places Plus'), findsOneWidget);
    expect(find.byType(TextField), findsWidgets);
    expect(find.text('Initialize'), findsOneWidget);
    expect(find.text('Powered by Google'), findsOneWidget);
  });
}

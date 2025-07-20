// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// Import the main app file
import 'package:college_event_app/main.dart';

void main() {
  // A test group for all HomeScreen related tests
  group('HomeScreen Widget Tests', () {
    // Test case 1: Verify that the initial UI renders correctly
    testWidgets('Renders initial UI with all events', (
      WidgetTester tester,
    ) async {
      // Build our app and trigger a frame.
      await tester.pumpWidget(const CollegeEventApp());

      // Verify the app bar title is present.
      expect(find.text('Discover Campus Events'), findsOneWidget);

      // Verify the search bar is present.
      expect(find.byType(TextField), findsOneWidget);

      // Verify that the first event from the list is displayed.
      expect(find.text('Tech Talk: AI & ML'), findsOneWidget);
      // Verify that the last event from the list is also displayed.
      expect(find.text('Basketball Championship'), findsOneWidget);
    });

    // Test case 2: Verify that the search functionality works correctly
    testWidgets('Filters events when text is entered in search bar', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const CollegeEventApp());

      // Find the search bar.
      final searchBar = find.byType(TextField);
      expect(searchBar, findsOneWidget);

      // Enter 'Music' into the search bar.
      await tester.enterText(searchBar, 'Music');
      // Rebuild the widget with the new state.
      await tester.pump();

      // Verify that only the 'Music' event is visible.
      expect(find.text('Spring Music Festival'), findsOneWidget);

      // Verify that other events are not visible.
      expect(find.text('Tech Talk: AI & ML'), findsNothing);
      expect(find.text('Career Fair 2024'), findsNothing);
    });

    // Test case 3: Verify that the "No Events Found" message appears
    testWidgets('Shows "No Events Found" message for non-matching search', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const CollegeEventApp());

      // Find the search bar.
      final searchBar = find.byType(TextField);
      expect(searchBar, findsOneWidget);

      // Enter a query that won't match any event.
      await tester.enterText(searchBar, 'xyz-non-existent-event');
      await tester.pump();

      // Verify that the "No Events Found" message is displayed.
      expect(find.text('No Events Found'), findsOneWidget);
      expect(find.byIcon(Icons.search_off), findsOneWidget);

      // Verify that no event cards are being displayed.
      expect(find.byType(Card), findsNothing);
    });

    // Test case 4: Verify that clearing the search bar shows all events again
    testWidgets('Clearing search bar shows all events again', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const CollegeEventApp());

      // Find the search bar and enter text
      final searchBar = find.byType(TextField);
      await tester.enterText(searchBar, 'Music');
      await tester.pump();

      // Verify that only one event is visible
      expect(find.text('Spring Music Festival'), findsOneWidget);
      expect(find.text('Tech Talk: AI & ML'), findsNothing);

      // Find and tap the clear button
      final clearButton = find.byIcon(Icons.clear);
      expect(clearButton, findsOneWidget);
      await tester.tap(clearButton);
      await tester.pump();

      // Verify that all events are visible again
      expect(find.text('Tech Talk: AI & ML'), findsOneWidget);
      expect(find.text('Spring Music Festival'), findsOneWidget);
      expect(find.text('Basketball Championship'), findsOneWidget);
    });
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:expense_tracker/main.dart';

void main() {
  testWidgets('Expense Tracker smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ExpenseTrackerApp());

    // Verify that the app title is displayed
    expect(find.text('WiseSteward'), findsOneWidget);

    // Verify that the floating action button exists
    expect(find.byType(FloatingActionButton), findsOneWidget);

    // Verify the empty state message appears when no expenses
    await tester.pump();
    expect(find.text('No expenses found. Start adding some!'), findsOneWidget);
  });

  testWidgets('Add expense button opens modal', (WidgetTester tester) async {
    // Build our app
    await tester.pumpWidget(const ExpenseTrackerApp());
    await tester.pump();

    // Tap the floating action button
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    // Verify that the modal with form fields appears
    expect(find.text('Title'), findsOneWidget);
    expect(find.text('Amount'), findsOneWidget);
    expect(find.text('Save Expense'), findsOneWidget);
    expect(find.text('Cancel'), findsOneWidget);
  });
}

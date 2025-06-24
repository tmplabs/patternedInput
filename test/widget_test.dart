// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patternedinput/widgets/patterned_input.dart';

void main() {
  testWidgets('PatternedInput validation test', (WidgetTester tester) async {
    String? lastValidValue;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PatternedInput(
            length: 6,
            patterns: [
              r'[0-9]',
              r'[0-9]',
              r'[0-9]',
              r'[0-9]',
              r'[a-z]',
              r'[a-z]',
            ],
            hints: ['0', '1', '2', '3', 'a', 'b'],
            onValid: (value) {
              lastValidValue = value;
            },
          ),
        ),
      ),
    );

    // Test case 1: 'abc123' - should fail as it starts with letters
    await _enterText(tester, 'abc123');
    expect(lastValidValue, null);
    expect(find.text('Invalid value \'a\''), findsOneWidget);

    // Clear the error
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    // Test case 2: '1111ab' - should succeed
    await _enterText(tester, '1111ab');
    expect(lastValidValue, '1111ab');
    expect(find.text('Invalid value'), findsNothing);

    // Clear the input
    await _clearInput(tester);
    lastValidValue = null;

    // Test case 3: '11111111' - should fail as it's too long
    await _enterText(tester, '11111111');
    expect(lastValidValue, null);
    expect(find.text('Invalid value \'1\''), findsOneWidget);
  });
}

Future<void> _enterText(WidgetTester tester, String text) async {
  for (int i = 0; i < text.length; i++) {
    await tester.enterText(find.byType(TextField).at(i), text[i]);
    await tester.pump();
  }
}

Future<void> _clearInput(WidgetTester tester) async {
  for (int i = 0; i < 6; i++) {
    await tester.enterText(find.byType(TextField).at(i), '');
    await tester.pump();
  }
}

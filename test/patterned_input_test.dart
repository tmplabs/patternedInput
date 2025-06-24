import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import '../lib/patterned_input.dart';

void main() {
  group('PatternedInput Tests', () {
    testWidgets('should create correct number of input fields', (WidgetTester tester) async {
      final pattern = [
        InputType.alpha,
        InputType.alpha,
        InputType.alpha,
        InputType.digit,
        InputType.digit,
        InputType.digit,
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PatternedInput(pattern: pattern),
          ),
        ),
      );

      expect(find.byType(TextField), findsNWidgets(6));
    });

    testWidgets('should validate alpha input correctly', (WidgetTester tester) async {
      final pattern = [InputType.alpha];
      String? lastValue;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PatternedInput(
              pattern: pattern,
              onChanged: (value) => lastValue = value,
            ),
          ),
        ),
      );

      final textField = find.byType(TextField).first;
      
      // Test valid alpha input
      await tester.enterText(textField, 'A');
      await tester.pump();
      expect(lastValue, 'A');
      
      // Test invalid numeric input
      await tester.enterText(textField, '1');
      await tester.pump();
      expect(lastValue, 'A'); // Should remain unchanged
    });

    testWidgets('should validate digit input correctly', (WidgetTester tester) async {
      final pattern = [InputType.digit];
      String? lastValue;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PatternedInput(
              pattern: pattern,
              onChanged: (value) => lastValue = value,
            ),
          ),
        ),
      );

      final textField = find.byType(TextField).first;
      
      // Test valid digit input
      await tester.enterText(textField, '5');
      await tester.pump();
      expect(lastValue, '5');
      
      // Test invalid alpha input
      await tester.enterText(textField, 'X');
      await tester.pump();
      expect(lastValue, '5'); // Should remain unchanged
    });

    testWidgets('should validate alphanumeric input correctly', (WidgetTester tester) async {
      final pattern = [InputType.alphanumeric];
      String? lastValue;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PatternedInput(
              pattern: pattern,
              onChanged: (value) => lastValue = value,
            ),
          ),
        ),
      );

      final textField = find.byType(TextField).first;
      
      // Test valid alpha input
      await tester.enterText(textField, 'A');
      await tester.pump();
      expect(lastValue, 'A');
      
      // Clear and test valid digit input
      await tester.enterText(textField, '');
      await tester.pump();
      await tester.enterText(textField, '5');
      await tester.pump();
      expect(lastValue, '5');
    });

    testWidgets('should handle paste operation correctly', (WidgetTester tester) async {
      final pattern = [
        InputType.alpha,
        InputType.alpha,
        InputType.alpha,
        InputType.digit,
        InputType.digit,
        InputType.alpha,
      ];
      String? lastValue;
      String? completeValue;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PatternedInput(
              pattern: pattern,
              onChanged: (value) => lastValue = value,
              onComplete: (value) => completeValue = value,
            ),
          ),
        ),
      );

      // Paste valid mixed content
      final firstField = find.byType(TextField).first;
      await tester.tap(firstField);
      await tester.pump();
      await tester.enterText(firstField, 'ABC123');
      await tester.pump();

      expect(lastValue, 'ABC12');
      expect(completeValue, null); // Not complete due to pattern mismatch at position 5
    });

    testWidgets('should handle paste with pattern validation', (WidgetTester tester) async {
      final pattern = [
        InputType.digit,
        InputType.digit,
        InputType.digit,
        InputType.alpha,
        InputType.alpha,
      ];
      String? completeValue;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PatternedInput(
              pattern: pattern,
              onComplete: (value) => completeValue = value,
            ),
          ),
        ),
      );

      // Paste valid content that matches pattern
      final firstField = find.byType(TextField).first;
      await tester.tap(firstField);
      await tester.pump();
      await tester.enterText(firstField, '123AB');
      await tester.pump();

      expect(completeValue, '123AB');
    });

    testWidgets('should auto-focus next field after input', (WidgetTester tester) async {
      final pattern = [InputType.alpha, InputType.digit];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PatternedInput(pattern: pattern),
          ),
        ),
      );

      final firstField = find.byType(TextField).first;
      final secondField = find.byType(TextField).last;

      // Enter text in first field
      await tester.tap(firstField);
      await tester.pump();
      await tester.enterText(firstField, 'A');
      await tester.pump();

      // Check if second field is focused
      expect(tester.binding.focusManager.primaryFocus?.hasFocus, true);
    });

    testWidgets('controller should work correctly', (WidgetTester tester) async {
      final controller = PatternedInputController();
      final pattern = [InputType.alpha, InputType.digit, InputType.alpha];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PatternedInput(
              pattern: pattern,
              controller: controller,
            ),
          ),
        ),
      );

      // Test setValue
      controller.setValue('A1B');
      await tester.pump();
      expect(controller.value, 'A1B');
      expect(controller.isValid, true);

      // Test clear
      controller.clear();
      await tester.pump();
      expect(controller.value, '');
      expect(controller.isValid, false);
    });

    testWidgets('should handle backspace navigation', (WidgetTester tester) async {
      final pattern = [InputType.alpha, InputType.alpha];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PatternedInput(pattern: pattern),
          ),
        ),
      );

      final firstField = find.byType(TextField).first;
      final secondField = find.byType(TextField).last;

      // Fill first field and move to second
      await tester.tap(firstField);
      await tester.pump();
      await tester.enterText(firstField, 'A');
      await tester.pump();

      // Now focus should be on second field
      // Simulate backspace when second field is empty
      await tester.tap(secondField);
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.backspace);
      await tester.pump();

      // First field should be cleared and focused
      expect(find.text('A'), findsNothing);
    });

    testWidgets('should stop paste at pattern boundary', (WidgetTester tester) async {
      final pattern = [InputType.alpha, InputType.alpha];
      String? lastValue;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PatternedInput(
              pattern: pattern,
              onChanged: (value) => lastValue = value,
            ),
          ),
        ),
      );

      // Paste longer text than pattern allows
      final firstField = find.byType(TextField).first;
      await tester.tap(firstField);
      await tester.pump();
      await tester.enterText(firstField, 'ABCDEF');
      await tester.pump();

      expect(lastValue, 'AB'); // Should only take first 2 characters
    });

    testWidgets('should handle case conversion', (WidgetTester tester) async {
      final pattern = [InputType.alpha];
      String? lastValue;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PatternedInput(
              pattern: pattern,
              onChanged: (value) => lastValue = value,
            ),
          ),
        ),
      );

      final textField = find.byType(TextField).first;
      
      // Test lowercase input gets converted to uppercase
      await tester.enterText(textField, 'a');
      await tester.pump();
      expect(lastValue, 'A');
    });
  });
}
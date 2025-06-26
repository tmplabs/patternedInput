# Patterned Input

A customizable Flutter widget for creating pattern-driven input fields with intelligent paste handling, auto-navigation, and validation. Perfect for OTP codes, form numbers, license plates, and any structured data entry.

## Features

- 🎯 **Pattern-Driven Input**: Define input patterns using `InputType.alpha`, `InputType.digit`, or `InputType.alphanumeric`
- 🔄 **Intelligent Paste Handling**: Smart character distribution with validation
- 🎯 **Auto-Navigation**: Automatic focus management between fields
- ✅ **Real-time Validation**: Prevent invalid characters and provide instant feedback
- 🎨 **Customizable UI**: Full control over styling, spacing, and decoration
- 📱 **Controller Support**: Programmatic access to widget state and methods

Published on https://pub.dev/packages/patternedinput

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  patterned_input: ^1.0.0
```

Then run:

```bash
flutter pub get
```

## Usage

### Basic Example

```dart
import 'package:patterned_input/patterned_input.dart';

PatternedInput(
  pattern: [
    InputType.alpha,
    InputType.alpha,
    InputType.alpha,
    InputType.digit,
    InputType.digit,
    InputType.digit,
  ],
  onChanged: (value) => print('Current: $value'),
  onComplete: (value) => print('Complete: $value'),
)
```

### USCIS Case Number Example

```dart
PatternedInput(
  pattern: [
    InputType.alpha, InputType.alpha, InputType.alpha, // ABC
    InputType.digit, InputType.digit, InputType.digit, // 123
    InputType.digit, InputType.digit, InputType.digit, // 456
    InputType.digit, InputType.digit, InputType.digit, // 789
    InputType.digit, // 0
  ],
  onComplete: (value) {
    // Handle complete USCIS case number (e.g., "ABC1234567890")
    print('USCIS Case Number: $value');
  },
)
```

### With Controller

```dart
final controller = PatternedInputController();

PatternedInput(
  pattern: [InputType.digit, InputType.digit, InputType.digit, InputType.digit],
  controller: controller,
  onComplete: (value) => print('Complete: $value'),
)

// Programmatic control
controller.setValue('1234');
print('Current value: ${controller.value}');
print('Is valid: ${controller.isValid}');
controller.clear();
```

### Customization

```dart
PatternedInput(
  pattern: [InputType.alpha, InputType.digit, InputType.alpha],
  fieldWidth: 50.0,
  fieldHeight: 50.0,
  spacing: 12.0,
  textStyle: TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: Colors.blue,
  ),
  decoration: InputDecoration(
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    filled: true,
    fillColor: Colors.grey.shade100,
  ),
)
```

## Input Types

| InputType | Description | Valid Characters |
|-----------|-------------|------------------|
| `InputType.alpha` | Alphabetic only | A-Z (case insensitive, stored as uppercase) |
| `InputType.digit` | Numeric only | 0-9 |
| `InputType.alphanumeric` | Both letters and numbers | A-Z, 0-9 |

## Properties

| Property | Type | Description | Default |
|----------|------|-------------|---------|
| `pattern` | `List<InputType>` | Defines the input pattern | **Required** |
| `onChanged` | `ValueChanged<String>?` | Called when any field changes | `null` |
| `onComplete` | `ValueChanged<String>?` | Called when all fields are filled | `null` |
| `controller` | `PatternedInputController?` | Controller for programmatic access | `null` |
| `decoration` | `InputDecoration?` | Custom decoration for fields | Default styling |
| `textStyle` | `TextStyle?` | Text style for input fields | Default styling |
| `spacing` | `double` | Spacing between fields | `8.0` |
| `fieldWidth` | `double` | Width of each field | `45.0` |
| `fieldHeight` | `double` | Height of each field | `45.0` |
| `autoFocus` | `bool` | Auto-focus first field | `true` |

## Controller Methods

| Method | Description |
|--------|-------------|
| `String get value` | Get current input value |
| `bool get isValid` | Check if all fields are filled |
| `void clear()` | Clear all input fields |
| `void setValue(String value)` | Set value programmatically |
| `void focusField(int index)` | Focus specific field |

## Paste Handling

The widget intelligently handles paste operations:

1. **Smart Distribution**: Characters are distributed across fields based on the pattern
2. **Validation**: Only valid characters for each field type are accepted
3. **Boundary Respect**: Pasting stops at pattern boundaries or invalid characters
4. **Focus Management**: Automatically focuses the next appropriate field

Example: Pasting "ABC123XYZ" into a pattern `[alpha, alpha, alpha, digit, digit, digit]` will result in "ABC123" with focus on the next field.

## Use Cases

- **OTP Verification**: 4-6 digit verification codes
- **License Plates**: Letter-number combinations
- **Government Forms**: USCIS case numbers, SSN formatting
- **Product Codes**: Mixed alphanumeric identifiers
- **Credit Card Numbers**: Chunked numeric input
- **Postal Codes**: Regional format validation

## Example App

See the `example/` directory for a complete sample app demonstrating various use cases and customization options.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

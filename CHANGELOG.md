# Changelog

## [1.0.0+1] - 2024-03-19

### Added
- Initial release of the PatternedInput widget
- Support for custom patterns per character position
- Individual character validation
- Automatic focus management
- Error message display
- Custom keyboard types per position
- Custom input formatters per position

### Features
- Flexible pattern validation using regex
- Single error message display below input
- Automatic clearing of invalid input
- Support for hints per character position
- Callback for valid input completion
- Backspace navigation between fields

### Example Usage
```dart
PatternedInput(
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
    print('Valid input: $value');
  },
)
```

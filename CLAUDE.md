# Claude Configuration

## Code Style Preferences

- Place comments on the same line as code (inline comments) rather than above the code
- Use `// comment` format for single-line comments placed at the end of lines
- Prefer concise inline comments that explain the "why" rather than the "what"

## Example

Preferred:
```dart
final pattern = RegExp(r'^[0-9]{3}-[0-9]{2}-[0-9]{4}$'); // SSN format validation
```

Instead of:
```dart
// SSN format validation
final pattern = RegExp(r'^[0-9]{3}-[0-9]{2}-[0-9]{4}$');
```
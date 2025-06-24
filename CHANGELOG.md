# Changelog

## [1.0.1] - 2024-06-24

### Fixed
- Fixed paste handling logic to properly distribute characters to matching field types instead of stopping at first invalid character
- Removed unused `_currentFocusIndex` field to eliminate static analysis warnings
- Fixed test imports to use relative paths instead of package imports

## [1.0.0] - 2024-06-24

### Added
- Initial release of PatternedInput package
- `PatternedInput` widget with pattern-driven input validation
- Support for three input types: `alpha`, `digit`, and `alphanumeric`
- Intelligent paste handling with automatic character distribution
- Smart navigation between input fields with auto-focus
- Real-time validation preventing invalid character input
- `PatternedInputController` for programmatic widget control
- Comprehensive customization options for styling and layout
- Auto-conversion of lowercase letters to uppercase
- Backspace handling for seamless field navigation
- Complete test suite with comprehensive coverage
- Example app demonstrating various use cases
- Full documentation with API reference

### Features
- Pattern-based input validation
- Automatic focus management
- Intelligent paste operation handling
- Customizable field dimensions and spacing
- Flexible styling options
- Controller-based programmatic access
- Material Design integration
- Accessibility support
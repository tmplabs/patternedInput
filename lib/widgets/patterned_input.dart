import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Custom text input formatter that handles paste operations while maintaining single character fields
class _PasteAwareFormatter extends TextInputFormatter {
  final int fieldIndex;
  final Function(String, int) onPasteDetected;
  
  _PasteAwareFormatter({required this.fieldIndex, required this.onPasteDetected});
  
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    // If more than one character was entered, it's likely a paste operation
    if (newValue.text.length > 1) {
      onPasteDetected(newValue.text, fieldIndex);
      // Return the old value to prevent the multi-character text from being displayed
      return oldValue;
    }
    
    // For single characters, allow normal processing but limit to one character
    if (newValue.text.length <= 1) {
      return newValue;
    }
    
    // Fallback: take only the first character
    return TextEditingValue(
      text: newValue.text.isNotEmpty ? newValue.text[0] : '',
      selection: TextSelection.collapsed(offset: newValue.text.isNotEmpty ? 1 : 0),
    );
  }
}

enum InputType {
  // Types of input allowed in each field
  alpha, // Alphabetic characters only (A-Z, case-insensitive)
  digit, // Numeric characters only (0-9)
  alphanumeric, // Both alphabetic and numeric characters
}

class PatternedInput extends StatefulWidget {
  // Customizable pattern-driven input widget with intelligent validation
  final List<InputType>
      pattern; // Pattern defining the type of input for each field

  final ValueChanged<String>?
      onChanged; // Callback triggered when any field value changes

  final ValueChanged<String>?
      onComplete; // Callback triggered when all fields are filled

  final InputDecoration? decoration; // Custom decoration for input fields

  final TextStyle? textStyle; // Text style for input fields

  final double spacing; // Spacing between input fields

  final double fieldWidth; // Width of each input field

  final double fieldHeight; // Height of each input field

  final bool autoFocus; // Whether to auto-focus the first field

  final PatternedInputController?
      controller; // Controller to access the widget's state externally

  const PatternedInput({
    super.key,
    required this.pattern,
    this.onChanged,
    this.onComplete,
    this.decoration,
    this.textStyle,
    this.spacing = 8.0,
    this.fieldWidth = 45.0,
    this.fieldHeight = 45.0,
    this.autoFocus = true,
    this.controller,
  });

  @override
  State<PatternedInput> createState() => _PatternedInputState();
}

class _PatternedInputState extends State<PatternedInput> {
  late List<TextEditingController> _controllers;
  late List<FocusNode> _focusNodes;
  late List<String> _values;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    widget.controller?._attachState(this);
  }

  void _initializeControllers() {
    _controllers = List.generate(
      widget.pattern.length,
      (index) => TextEditingController(),
    );
    _focusNodes = List.generate(
      widget.pattern.length,
      (index) => FocusNode()..addListener(() {}),
    );
    _values = List.filled(widget.pattern.length, '');

    if (widget.autoFocus && widget.pattern.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _focusNodes[0].requestFocus();
      });
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  bool _isValidCharacter(String char, InputType type) {
    // Validates if a character is valid for the given input type
    switch (type) {
      case InputType.alpha:
        return RegExp(r'^[A-Za-z]$').hasMatch(char);
      case InputType.digit:
        return RegExp(r'^[0-9]$').hasMatch(char);
      case InputType.alphanumeric:
        return RegExp(r'^[A-Za-z0-9]$').hasMatch(char);
    }
  }

  void _handlePaste(String text, int startIndex) {
    // Handles paste operation with validation-first approach
    if (text.isEmpty) return;

    // Step 1: Validate if the string matches the expected pattern from startIndex
    List<String> validatedChars = [];
    int textIndex = 0;
    
    // Pre-validate the string against the pattern starting from startIndex
    for (int fieldIndex = startIndex; fieldIndex < widget.pattern.length && textIndex < text.length; fieldIndex++) {
      String? validChar;
      
      // Look for a valid character for this field type in the remaining text
      while (textIndex < text.length) {
        String char = text[textIndex];
        if (_isValidCharacter(char, widget.pattern[fieldIndex])) {
          validChar = char.toUpperCase();
          textIndex++;
          break;
        }
        textIndex++; // Skip invalid character
      }
      
      if (validChar != null) {
        validatedChars.add(validChar);
      } else {
        break; // No valid character found for this field, stop validation
      }
    }
    
    // Step 2: If validation successful, distribute characters to fields
    if (validatedChars.isNotEmpty) {
      List<String> newValues = List.from(_values);
      
      // Clear fields from start index onwards first
      for (int i = startIndex; i < widget.pattern.length; i++) {
        newValues[i] = '';
        _controllers[i].clear();
      }
      
      // Place validated characters in respective fields starting from focused field
      for (int i = 0; i < validatedChars.length; i++) {
        int fieldIndex = startIndex + i;
        if (fieldIndex < widget.pattern.length) {
          newValues[fieldIndex] = validatedChars[i];
          _controllers[fieldIndex].text = validatedChars[i];
        }
      }
      
      setState(() {
        _values = newValues;
      });
      
      // Find the next empty field to focus
      int nextFocusIndex = startIndex + validatedChars.length;
      if (nextFocusIndex < widget.pattern.length) {
        _focusNodes[nextFocusIndex].requestFocus();
      } else if (widget.pattern.isNotEmpty) {
        // All fields filled, focus on the last field
        _focusNodes[widget.pattern.length - 1].requestFocus();
      }
      
      _notifyCallbacks();
    }
  }

  void _onChanged(int index, String value) {
    // Handles individual character input
    if (value.length > 1) {
      _handlePaste(value, index); // Handle paste operation
      return;
    }

    if (value.isEmpty) {
      setState(() {
        // Handle deletion
        _values[index] = '';
      });
      _notifyCallbacks();
      return;
    }

    if (!_isValidCharacter(value, widget.pattern[index])) {
      // Validate single character input
      _controllers[index].text = _values[index]; // Reject invalid character
      _controllers[index].selection = TextSelection.fromPosition(
        TextPosition(offset: _values[index].length),
      );
      return;
    }

    String upperValue = value.toUpperCase(); // Accept valid character
    setState(() {
      _values[index] = upperValue;
    });

    _controllers[index].text = upperValue;
    _controllers[index].selection = TextSelection.fromPosition(
      TextPosition(offset: upperValue.length),
    );

    if (index < widget.pattern.length - 1) {
      // Auto-focus next field
      _focusNodes[index + 1].requestFocus();
    }

    _notifyCallbacks();
  }


  void _handleKeyEvent(int index, KeyEvent event) {
    // Handles special key presses
    if (event is KeyDownEvent) {
      // Handle paste operations (Ctrl+V or Cmd+V)
      if ((event.logicalKey == LogicalKeyboardKey.keyV) &&
          (HardwareKeyboard.instance.isControlPressed || 
           HardwareKeyboard.instance.isMetaPressed)) {
        _handlePasteFromClipboard(index);
        return;
      }
      
      // Handle backspace navigation
      if (event.logicalKey == LogicalKeyboardKey.backspace) {
        if (_values[index].isEmpty && index > 0) {
          _focusNodes[index - 1]
              .requestFocus(); // Move to previous field and clear it
          setState(() {
            _values[index - 1] = '';
          });
          _controllers[index - 1].clear();
          _notifyCallbacks();
        }
      }
    }
  }
  
  void _handlePasteFromClipboard(int index) async {
    // Handle paste operation from clipboard
    try {
      ClipboardData? data = await Clipboard.getData(Clipboard.kTextPlain);
      if (data != null && data.text != null && data.text!.isNotEmpty) {
        _handlePaste(data.text!, index);
      }
    } catch (e) {
      // Ignore clipboard access errors
    }
  }

  void _notifyCallbacks() {
    // Notifies callbacks about state changes
    String currentValue = _values.join();
    widget.onChanged?.call(currentValue);

    if (_values.every((v) => v.isNotEmpty)) {
      widget.onComplete?.call(currentValue);
    }
  }

  void _refreshUI() {
    // Refreshes the UI (for controller access)
    if (mounted) {
      setState(() {});
    }
  }

  TextInputType _getKeyboardType(InputType type) {
    // Gets keyboard type based on input type
    switch (type) {
      case InputType.alpha:
        return TextInputType.text;
      case InputType.digit:
        return TextInputType.number;
      case InputType.alphanumeric:
        return TextInputType.text;
    }
  }

  List<TextInputFormatter> _getInputFormatters(InputType type, int index) {
    // Gets input formatters based on input type
    switch (type) {
      case InputType.alpha:
        return [FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z]'))];
      case InputType.digit:
        return [FilteringTextInputFormatter.digitsOnly];
      case InputType.alphanumeric:
        return [FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9]'))];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: widget.spacing,
      children: List.generate(
        widget.pattern.length,
        (index) => SizedBox(
          width: widget.fieldWidth,
          height: widget.fieldHeight,
          child: KeyboardListener(
            focusNode: FocusNode(),
            onKeyEvent: (event) => _handleKeyEvent(index, event),
            child: TextField(
              controller: _controllers[index],
              focusNode: _focusNodes[index],
              textAlign: TextAlign.center,
              maxLength: 1,
              keyboardType: _getKeyboardType(widget.pattern[index]),
              inputFormatters: _getInputFormatters(widget.pattern[index], index),
              enableInteractiveSelection: true, // Enable text selection and clipboard operations
              textCapitalization: TextCapitalization.characters,
              style: widget.textStyle ??
                  const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
              decoration: widget.decoration ??
                  InputDecoration(
                    counterText: '',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.all(8),
                  ),
              onChanged: (value) => _onChanged(index, value),
            ),
          ),
        ),
      ),
    );
  }
}

class PatternedInputController {
  // Controller class to interact with PatternedInput widget externally
  _PatternedInputState? _state;

  void _attachState(_PatternedInputState state) {
    _state = state;
  }

  String get value {
    // Gets the current value as a concatenated string
    return _state?._values.join() ?? '';
  }

  bool get isValid {
    // Checks if all fields are filled with valid values
    return _state?._values.every((v) => v.isNotEmpty) ?? false;
  }

  void clear() {
    // Clears all input fields
    if (_state == null) return;

    for (int i = 0; i < _state!._controllers.length; i++) {
      _state!._controllers[i].clear();
      _state!._values[i] = '';
    }
    _state!._notifyCallbacks();
    _state!._refreshUI();
  }

  void setValue(String value) {
    // Sets the value programmatically
    if (_state == null) return;
    _state!._handlePaste(value, 0);
  }

  void focusField(int index) {
    // Focuses a specific field
    if (_state == null || index < 0 || index >= _state!._focusNodes.length) {
      return;
    }
    _state!._focusNodes[index].requestFocus();
  }
}

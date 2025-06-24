import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum InputType { // Types of input allowed in each field
  alpha, // Alphabetic characters only (A-Z, case-insensitive)
  digit, // Numeric characters only (0-9)
  alphanumeric, // Both alphabetic and numeric characters
}

class PatternedInput extends StatefulWidget { // Customizable pattern-driven input widget with intelligent validation
  final List<InputType> pattern; // Pattern defining the type of input for each field
  
  final ValueChanged<String>? onChanged; // Callback triggered when any field value changes
  
  final ValueChanged<String>? onComplete; // Callback triggered when all fields are filled
  
  final InputDecoration? decoration; // Custom decoration for input fields
  
  final TextStyle? textStyle; // Text style for input fields
  
  final double spacing; // Spacing between input fields
  
  final double fieldWidth; // Width of each input field
  
  final double fieldHeight; // Height of each input field
  
  final bool autoFocus; // Whether to auto-focus the first field
  
  final PatternedInputController? controller; // Controller to access the widget's state externally

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
      (index) => FocusNode()
..addListener(() {}),
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

  bool _isValidCharacter(String char, InputType type) { // Validates if a character is valid for the given input type
    switch (type) {
      case InputType.alpha:
        return RegExp(r'^[A-Za-z]$').hasMatch(char);
      case InputType.digit:
        return RegExp(r'^[0-9]$').hasMatch(char);
      case InputType.alphanumeric:
        return RegExp(r'^[A-Za-z0-9]$').hasMatch(char);
    }
  }

  void _handlePaste(String text, int startIndex) { // Handles paste operation with intelligent character distribution
    if (text.isEmpty) return;

    List<String> newValues = List.from(_values);
    int textIndex = 0;
    
    for (int i = startIndex; i < widget.pattern.length; i++) { // Clear fields from start index onwards first
      newValues[i] = '';
      _controllers[i].clear();
    }

    for (int fieldIndex = startIndex; // Distribute characters from the paste text 
         fieldIndex < widget.pattern.length && textIndex < text.length; 
         fieldIndex++) {
      
      // Find the next valid character for this field type
      while (textIndex < text.length) {
        String char = text[textIndex];
        
        if (_isValidCharacter(char, widget.pattern[fieldIndex])) { // Check if character is valid for current field type
          newValues[fieldIndex] = char.toUpperCase();
          _controllers[fieldIndex].text = char.toUpperCase();
          textIndex++;
          break; // Move to next field after finding valid character
        } else {
          textIndex++; // Skip invalid character and continue searching
        }
      }
    }

    setState(() {
      _values = newValues;
    });

    int nextFocusIndex = startIndex; // Focus next empty field or last field
    for (int i = startIndex; i < widget.pattern.length; i++) {
      if (_values[i].isEmpty) {
        nextFocusIndex = i;
        break;
      }
      nextFocusIndex = i + 1;
    }
    
    if (nextFocusIndex < widget.pattern.length) {
      _focusNodes[nextFocusIndex].requestFocus();
    } else if (widget.pattern.isNotEmpty) {
      _focusNodes[widget.pattern.length - 1].requestFocus();
    }

    _notifyCallbacks();
  }

  void _onChanged(int index, String value) { // Handles individual character input
    if (value.length > 1) {
      _handlePaste(value, index); // Handle paste operation
      return;
    }

    if (value.isEmpty) {
      setState(() { // Handle deletion
        _values[index] = '';
      });
      _notifyCallbacks();
      return;
    }

    if (!_isValidCharacter(value, widget.pattern[index])) { // Validate single character input
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

    if (index < widget.pattern.length - 1) { // Auto-focus next field
      _focusNodes[index + 1].requestFocus();
    }

    _notifyCallbacks();
  }

  void _handleKeyEvent(int index, KeyEvent event) { // Handles backspace key press
    if (event is KeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.backspace) {
        if (_values[index].isEmpty && index > 0) {
          _focusNodes[index - 1].requestFocus(); // Move to previous field and clear it
          setState(() {
            _values[index - 1] = '';
          });
          _controllers[index - 1].clear();
          _notifyCallbacks();
        }
      }
    }
  }

  void _notifyCallbacks() { // Notifies callbacks about state changes
    String currentValue = _values.join();
    widget.onChanged?.call(currentValue);
    
    if (_values.every((v) => v.isNotEmpty)) {
      widget.onComplete?.call(currentValue);
    }
  }

  void _refreshUI() { // Refreshes the UI (for controller access)
    if (mounted) {
      setState(() {});
    }
  }

  TextInputType _getKeyboardType(InputType type) { // Gets keyboard type based on input type
    switch (type) {
      case InputType.alpha:
        return TextInputType.text;
      case InputType.digit:
        return TextInputType.number;
      case InputType.alphanumeric:
        return TextInputType.text;
    }
  }

  List<TextInputFormatter> _getInputFormatters(InputType type) { // Gets input formatters based on input type
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
              inputFormatters: _getInputFormatters(widget.pattern[index]),
              textCapitalization: TextCapitalization.characters,
              style: widget.textStyle ?? const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              decoration: widget.decoration ?? InputDecoration(
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

class PatternedInputController { // Controller class to interact with PatternedInput widget externally
  _PatternedInputState? _state;

  void _attachState(_PatternedInputState state) {
    _state = state;
  }

  String get value { // Gets the current value as a concatenated string
    return _state?._values.join() ?? '';
  }

  bool get isValid { // Checks if all fields are filled with valid values
    return _state?._values.every((v) => v.isNotEmpty) ?? false;
  }

  void clear() { // Clears all input fields
    if (_state == null) return;
    
    for (int i = 0; i < _state!._controllers.length; i++) {
      _state!._controllers[i].clear();
      _state!._values[i] = '';
    }
    _state!._notifyCallbacks();
    _state!._refreshUI();
  }

  void setValue(String value) { // Sets the value programmatically
    if (_state == null) return;
    _state!._handlePaste(value, 0);
  }

  void focusField(int index) { // Focuses a specific field
    if (_state == null || index < 0 || index >= _state!._focusNodes.length) {
      return;
    }
    _state!._focusNodes[index].requestFocus();
  }
}
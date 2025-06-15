import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PatternedInput extends StatefulWidget {
  final int length;
  final List<String> patterns;
  final String? error;
  final List<String> hints;
  final Function(String) onValid;
  final TextEditingController? controller;
  final Map<int, TextInputType>? keyboardTypes;
  final Map<int, List<TextInputFormatter>>? inputFormatters;

  const PatternedInput({
    super.key,
    required this.length,
    required this.patterns,
    required this.hints,
    required this.onValid,
    this.error,
    this.controller,
    this.keyboardTypes,
    this.inputFormatters,
  }) : assert(
         patterns.length == length,
         'Patterns length must match input length',
       );

  @override
  State<PatternedInput> createState() => _PatternedInputState();
}

class _PatternedInputState extends State<PatternedInput> {
  late List<TextEditingController> _controllers;
  late List<FocusNode> _focusNodes;
  late List<String> _values;
  late List<RegExp> _patternRegexes;
  String? _currentError;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      widget.length,
      (index) => TextEditingController(),
    );
    _focusNodes = List.generate(widget.length, (index) => FocusNode());
    _values = List.filled(widget.length, '');
    _patternRegexes = widget.patterns
        .map((pattern) => RegExp('^$pattern\$'))
        .toList();
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

  bool _isValidPartialInput(String input, int index) {
    return _patternRegexes[index].hasMatch(input);
  }

  void _onChanged(int index, String value) {
    if (value.length > 1) {
      value = value[value.length - 1];
    }

    if (!_isValidPartialInput(value, index)) {
      setState(() {
        _currentError = 'Invalid value \'$value\'';
        _controllers[index].clear();
        _values[index] = '';
      });
      return;
    }

    setState(() {
      _values[index] = value;
      _currentError = null;
    });

    if (value.isNotEmpty && index < widget.length - 1) {
      _focusNodes[index + 1].requestFocus();
    }

    if (_values.every((v) => v.isNotEmpty)) {
      final result = _values.join();
      widget.onValid(result);
    }
  }

  void _handleKeyEvent(int index, RawKeyEvent event) {
    if (event is RawKeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.backspace) {
        if (_values[index].isEmpty && index > 0) {
          _focusNodes[index - 1].requestFocus();
          _controllers[index - 1].clear();
          setState(() {
            _values[index - 1] = '';
          });
        }
      }
    }
  }

  TextInputType _getKeyboardType(int index) {
    if (widget.keyboardTypes != null &&
        widget.keyboardTypes!.containsKey(index)) {
      return widget.keyboardTypes![index]!;
    }
    return TextInputType.text;
  }

  List<TextInputFormatter> _getInputFormatters(int index) {
    if (widget.inputFormatters != null &&
        widget.inputFormatters!.containsKey(index)) {
      return widget.inputFormatters![index]!;
    }
    return [];
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            widget.length,
            (index) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: SizedBox(
                width: 45,
                child: RawKeyboardListener(
                  focusNode: FocusNode(),
                  onKey: (event) => _handleKeyEvent(index, event),
                  child: TextField(
                    controller: _controllers[index],
                    focusNode: _focusNodes[index],
                    textAlign: TextAlign.center,
                    maxLength: 1,
                    keyboardType: _getKeyboardType(index),
                    inputFormatters: _getInputFormatters(index),
                    textCapitalization: TextCapitalization.none,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    decoration: InputDecoration(
                      counterText: '',
                      hintText: widget.hints.length > index
                          ? widget.hints[index]
                          : '',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onChanged: (value) => _onChanged(index, value),
                  ),
                ),
              ),
            ),
          ),
        ),
        if (_currentError != null || widget.error != null)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              _currentError ?? widget.error!,
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
                fontSize: 12,
              ),
            ),
          ),
      ],
    );
  }
}

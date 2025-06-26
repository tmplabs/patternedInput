import 'package:flutter/material.dart';
import 'widgets/patterned_input.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pattern Input Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String _result = '';
  String _currentValue = '';
  final PatternedInputController _controller = PatternedInputController();

  void _onComplete(String value) {
    setState(() {
      _result = value;
    });
  }

  void _onChanged(String value) {
    setState(() {
      _currentValue = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Pattern Input Demo'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Enter 4 digits + 2 letters',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              PatternedInput(
                pattern: const [
                  InputType.alpha,
                  InputType.alpha,
                  InputType.alpha,
                  InputType.digit,
                  InputType.digit,
                  InputType.digit,
                  InputType.digit,
                  InputType.digit,
                  InputType.digit,
                  InputType.digit,
                  InputType.digit,
                  InputType.digit,
                  InputType.digit,
                ],
                hints: const ['S', 'R', 'C', '1', '2', '3', '4', '5', '6', '7', '8', '9', '0'],
                controller: _controller,
                onChanged: _onChanged,
                onComplete: _onComplete,
                spacing: 3,
                fieldWidth: 25,
                fieldHeight: 40,
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
                decoration: InputDecoration(
                  counterText: '',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(9),
                    borderSide: const BorderSide(color: Colors.blue, width: 2),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(9),
                    borderSide: const BorderSide(color: Colors.blueAccent, width: 3),
                  ),
                  contentPadding: const EdgeInsets.all(6),
                ),
              ),
              const SizedBox(height: 30),
              if (_currentValue.isNotEmpty)
                Text(
                  'Current input: $_currentValue',
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                ),
              if (_result.isNotEmpty)
                Text(
                  'Completed value: $_result',
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      _controller.clear();
                      setState(() {
                        _result = '';
                        _currentValue = '';
                      });
                    },
                    child: const Text('Clear'),
                  ),
                  const SizedBox(width: 20),
                  ElevatedButton(
                    onPressed: () {
                      // Example of programmatically setting a value55
                      _controller.setValue('ABC1234567890');
                    },
                    child: const Text('Set Example'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
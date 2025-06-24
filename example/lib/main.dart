import 'package:flutter/material.dart';
import 'package:patterned_input/patterned_input.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Patterned Input Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const ExamplePage(),
    );
  }
}

class ExamplePage extends StatefulWidget {
  const ExamplePage({super.key});

  @override
  State<ExamplePage> createState() => _ExamplePageState();
}

class _ExamplePageState extends State<ExamplePage> {
  final PatternedInputController _controller = PatternedInputController();
  String _currentValue = '';
  String _completedValue = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Patterned Input Examples'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // USCIS Case Number Example (3 letters + 10 digits)
            _buildSection(
              'USCIS Case Number (ABC1234567890)',
              PatternedInput(
                pattern: [
                  InputType.alpha, InputType.alpha, InputType.alpha,
                  InputType.digit, InputType.digit, InputType.digit,
                  InputType.digit, InputType.digit, InputType.digit,
                  InputType.digit, InputType.digit, InputType.digit,
                  InputType.digit,
                ],
                onChanged: (value) => setState(() => _currentValue = value),
                onComplete: (value) => setState(() => _completedValue = value),
                controller: _controller,
              ),
            ),
            
            const SizedBox(height: 20),
            
            // License Plate Example (3 letters + 3 digits)
            _buildSection(
              'License Plate (ABC123)',
              PatternedInput(
                pattern: [
                  InputType.alpha, InputType.alpha, InputType.alpha,
                  InputType.digit, InputType.digit, InputType.digit,
                ],
                fieldWidth: 50,
                fieldHeight: 50,
                spacing: 10,
                textStyle: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.blue, width: 2),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.green, width: 2),
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // 6-Digit OTP Example
            _buildSection(
              '6-Digit OTP',
              PatternedInput(
                pattern: List.filled(6, InputType.digit),
                fieldWidth: 40,
                spacing: 8,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade100,
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Mixed Alphanumeric Example
            _buildSection(
              'Mixed Code (A1B2C3)',
              PatternedInput(
                pattern: [
                  InputType.alphanumeric, InputType.alphanumeric,
                  InputType.alphanumeric, InputType.alphanumeric,
                  InputType.alphanumeric, InputType.alphanumeric,
                ],
                fieldWidth: 45,
                spacing: 6,
              ),
            ),
            
            const SizedBox(height: 30),
            
            // Status Display
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Current Value: $_currentValue',
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Completed Value: $_completedValue',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Is Valid: ${_controller.isValid}',
                      style: TextStyle(
                        fontSize: 16,
                        color: _controller.isValid ? Colors.green : Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Control Buttons
            Row(
              children: [
                ElevatedButton(
                  onPressed: () => _controller.clear(),
                  child: const Text('Clear'),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: () => _controller.setValue('ABC1234567890'),
                  child: const Text('Set Sample Value'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, Widget child) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }
}
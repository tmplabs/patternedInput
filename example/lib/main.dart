import 'package:flutter/material.dart'; // Flutter UI framework
import 'package:patternedinput/patterned_input.dart'; // Custom patterned input widget

void main() {
  runApp(const MyApp()); // Entry point - launches the Flutter app
}

class MyApp extends StatelessWidget { // Root application widget
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Patterned Input Example', // App title shown in task switcher
      theme: ThemeData(
        primarySwatch: Colors.blue, // Primary color scheme
        useMaterial3: true, // Use Material Design 3
      ),
      home: const ExamplePage(), // Main page of the app
    );
  }
}

class ExamplePage extends StatefulWidget { // Main demo page with state
  const ExamplePage({super.key});

  @override
  State<ExamplePage> createState() => _ExamplePageState();
}

class _ExamplePageState extends State<ExamplePage> {
  final PatternedInputController _controller = PatternedInputController(); // Controls input state
  String _currentValue = ''; // Current input value (real-time)
  String _completedValue = ''; // Value when input is complete

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Patterned Input Examples'), // App bar title
        backgroundColor: Theme.of(context).colorScheme.inversePrimary, // Dynamic theme color
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection( // USCIS Case Number Example (3 letters + 10 digits)
              'USCIS Case Number (ABC1234567890)',
              PatternedInput(
                pattern: [ // Define input pattern: 3 letters followed by 10 digits
                  InputType.alpha, InputType.alpha, InputType.alpha,
                  InputType.digit, InputType.digit, InputType.digit,
                  InputType.digit, InputType.digit, InputType.digit,
                  InputType.digit, InputType.digit, InputType.digit,
                  InputType.digit,
                ],
                onChanged: (value) => setState(() => _currentValue = value), // Update UI on each keystroke
                onComplete: (value) => setState(() => _completedValue = value), // Triggered when pattern is complete
                controller: _controller, // Shared controller for programmatic control
              ),
            ),
            
            const SizedBox(height: 20),
            
            _buildSection( // License Plate Example (3 letters + 3 digits)
              'License Plate (ABC123)',
              PatternedInput(
                pattern: [ // 3 letters + 3 digits pattern
                  InputType.alpha, InputType.alpha, InputType.alpha,
                  InputType.digit, InputType.digit, InputType.digit,
                ],
                fieldWidth: 50, // Custom field dimensions
                fieldHeight: 50,
                spacing: 10, // Space between input fields
                textStyle: const TextStyle( // Custom text styling
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
                decoration: InputDecoration( // Custom border styling
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.blue, width: 2),
                  ),
                  focusedBorder: OutlineInputBorder( // Different style when focused
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.green, width: 2),
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            _buildSection( // 6-Digit OTP Example
              '6-Digit OTP',
              PatternedInput(
                pattern: List.filled(6, InputType.digit), // Create 6 digit-only fields
                fieldWidth: 40, // Smaller fields for OTP
                spacing: 8,
                decoration: InputDecoration( // OTP-style styling with background fill
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  filled: true, // Enable background fill
                  fillColor: Colors.grey.shade100, // Light gray background
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            _buildSection( // Mixed Alphanumeric Example
              'Mixed Code (A1B2C3)',
              PatternedInput(
                pattern: [ // 6 fields accepting both letters and numbers
                  InputType.alphanumeric, InputType.alphanumeric,
                  InputType.alphanumeric, InputType.alphanumeric,
                  InputType.alphanumeric, InputType.alphanumeric,
                ],
                fieldWidth: 45,
                spacing: 6,
              ),
            ),
            
            const SizedBox(height: 30),
            
            Card( // Status Display - shows current input state
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text( // Real-time value updates
                      'Current Value: $_currentValue',
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    Text( // Only updates when pattern is complete
                      'Completed Value: $_completedValue',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text( // Validation status with color coding
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
            
            Row( // Control Buttons for testing controller functionality
              children: [
                ElevatedButton(
                  onPressed: () => _controller.clear(), // Clear all input fields
                  child: const Text('Clear'),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: () => _controller.setValue('ABC1234567890'), // Set sample USCIS case number
                  child: const Text('Set Sample Value'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, Widget child) { // Helper method to create consistent section layout
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text( // Section title
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8), // Spacing between title and content
        child, // The actual input widget
      ],
    );
  }
}
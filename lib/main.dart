import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io' show Platform;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Castar SDK App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      home: const CastarSdkScreen(),
    );
  }
}

class CastarSdkScreen extends StatefulWidget {
  const CastarSdkScreen({super.key});

  @override
  State<CastarSdkScreen> createState() => _CastarSdkScreenState();
}

class _CastarSdkScreenState extends State<CastarSdkScreen> {
  final TextEditingController _clientIdController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _isSdkStarted = false;
  static const platform = MethodChannel('com.castarsdk.flutter/castar');

  @override
  void dispose() {
    _clientIdController.dispose();
    super.dispose();
  }

  Future<void> _startCastarSdk() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        // Call native Castar SDK (works for both iOS and Android)
        final result = await platform.invokeMethod('startCastarSdk', {
          'clientId': _clientIdController.text,
        });

        if (mounted) {
          setState(() {
            _isLoading = false;
            _isSdkStarted = true;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Castar SDK started successfully with Client ID: ${_clientIdController.text}',
              ),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to start Castar SDK: $e'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    }
  }

  Future<void> _stopCastarSdk() async {
    try {
      await platform.invokeMethod('stopCastarSdk');

      if (mounted) {
        setState(() {
          _isSdkStarted = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Castar SDK stopped successfully'),
            backgroundColor: Colors.orange,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to stop Castar SDK: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Castar SDK'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(
                context,
              ).colorScheme.inversePrimary.withValues(alpha: 0.3),
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Platform Indicator
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color:
                          Platform.isIOS
                              ? Colors.blue.withValues(alpha: 0.1)
                              : Colors.green.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color:
                            Platform.isIOS
                                ? Colors.blue.withValues(alpha: 0.3)
                                : Colors.green.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Text(
                      Platform.isIOS ? 'iOS Platform' : 'Android Platform',
                      style: TextStyle(
                        color:
                            Platform.isIOS
                                ? Colors.blue[700]
                                : Colors.green[700],
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // App Icon
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withValues(alpha: 0.2),
                          spreadRadius: 2,
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.play_circle_outline,
                      size: 60,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Title
                  Text(
                    'Castar SDK',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 8),

                  // Subtitle
                  Text(
                    'Enter your client ID to start the Castar SDK service',
                    style: Theme.of(
                      context,
                    ).textTheme.bodyLarge?.copyWith(color: Colors.grey[600]),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 40),

                  // Client ID Input Field
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withValues(alpha: 0.1),
                          spreadRadius: 1,
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: TextFormField(
                      controller: _clientIdController,
                      decoration: InputDecoration(
                        labelText: 'Client ID',
                        hintText:
                            'Enter your Castar client ID (e.g., CSK****FHQlUQZ)',
                        prefixIcon: Icon(
                          Icons.key,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                      ),
                      keyboardType: TextInputType.text,
                      textCapitalization: TextCapitalization.characters,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a client ID';
                        }
                        if (value.length < 3) {
                          return 'Client ID must be at least 3 characters';
                        }
                        return null;
                      },
                    ),
                  ),

                  const SizedBox(height: 32),

                  // SDK Status
                  if (_isSdkStarted)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.green.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.check_circle, color: Colors.green),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Castar SDK is running',
                              style: TextStyle(
                                color: Colors.green[700],
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(height: 24),

                  // Action Buttons
                  if (!_isSdkStarted) ...[
                    // Start SDK Button
                    SizedBox(
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _startCastarSdk,
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              Theme.of(context).colorScheme.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                        ),
                        child:
                            _isLoading
                                ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                )
                                : const Text(
                                  'Start Castar SDK',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                      ),
                    ),
                  ] else ...[
                    // Stop SDK Button
                    SizedBox(
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _stopCastarSdk,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                        ),
                        child: const Text(
                          'Stop Castar SDK',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 16),

                  // Help Text
                  Text(
                    'Make sure you have a valid Castar client ID',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

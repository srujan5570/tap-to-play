import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io' show Platform;
import 'dart:async';
import 'package:flutter/foundation.dart';

void main() {
  // Add error handling for the entire app
  runZonedGuarded(
    () {
      runApp(const MyApp());
    },
    (error, stack) {
      print('🚨 App Error: $error');
      print('Stack trace: $stack');
    },
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CastarSDK Demo',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      home: const CastarSDKPage(),
    );
  }
}

class CastarSDKPage extends StatefulWidget {
  const CastarSDKPage({super.key});

  @override
  State<CastarSDKPage> createState() => _CastarSDKPageState();
}

class _CastarSDKPageState extends State<CastarSDKPage> {
  static const platform = MethodChannel('com.castarsdk.flutter/castar');

  bool _isSdkRunning = false;
  bool _isLoading = false;
  String _statusMessage = 'Ready to start CastarSDK';
  String _lastError = '';
  Map<String, dynamic> _sdkStatus = {};
  Timer? _statusTimer;

  // Add crash protection
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  @override
  void dispose() {
    _statusTimer?.cancel();
    super.dispose();
  }

  // Initialize app with crash protection
  Future<void> _initializeApp() async {
    try {
      setState(() {
        _isLoading = true;
        _statusMessage = 'Initializing app...';
      });

      // Wait a bit to ensure app is fully loaded
      await Future.delayed(const Duration(seconds: 2));

      // Check SDK status
      await _getSdkStatus();

      setState(() {
        _isInitialized = true;
        _isLoading = false;
        _statusMessage = 'App initialized successfully';
      });

      // Start periodic status check
      _startStatusMonitoring();
    } catch (e) {
      setState(() {
        _isLoading = false;
        _statusMessage = 'App initialization failed: $e';
        _lastError = e.toString();
      });
      _logError('App initialization error: $e');
    }
  }

  // Start periodic status monitoring
  void _startStatusMonitoring() {
    _statusTimer?.cancel();
    _statusTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (mounted) {
        _getSdkStatus();
      }
    });
  }

  // Get SDK status with crash protection
  Future<void> _getSdkStatus() async {
    try {
      final result = await platform.invokeMethod('getCastarStatus');
      if (result is Map<String, dynamic>) {
        setState(() {
          _sdkStatus = result;
          _isSdkRunning = result['running'] ?? false;
        });
        _logMessage('SDK Status: $_sdkStatus');
      }
    } catch (e) {
      _logError('Failed to get SDK status: $e');
      // Don't update UI on status check failure to prevent crashes
    }
  }

  // Start CastarSDK with crash protection
  Future<void> _startCastarSdk() async {
    if (!_isInitialized) {
      _showError('App not initialized yet. Please wait...');
      return;
    }

    try {
      setState(() {
        _isLoading = true;
        _statusMessage = 'Starting CastarSDK...';
        _lastError = '';
      });

      _logMessage('Starting CastarSDK...');

      // Use a test client ID - replace with your actual client ID
      const clientId = 'test_client_id_12345';

      final result = await platform.invokeMethod('startCastarSdk', {
        'clientId': clientId,
      });

      setState(() {
        _isLoading = false;
        _statusMessage = result ?? 'CastarSDK started successfully';
        _isSdkRunning = true;
      });

      _logMessage('CastarSDK started: $result');

      // Update status immediately
      await _getSdkStatus();
    } catch (e) {
      setState(() {
        _isLoading = false;
        _statusMessage = 'Failed to start CastarSDK';
        _lastError = e.toString();
        _isSdkRunning = false;
      });
      _logError('Start CastarSDK error: $e');
      _showError('Failed to start CastarSDK: $e');
    }
  }

  // Stop CastarSDK with crash protection
  Future<void> _stopCastarSdk() async {
    try {
      setState(() {
        _isLoading = true;
        _statusMessage = 'Stopping CastarSDK...';
      });

      _logMessage('Stopping CastarSDK...');

      final result = await platform.invokeMethod('stopCastarSdk');

      setState(() {
        _isLoading = false;
        _statusMessage = result ?? 'CastarSDK stopped successfully';
        _isSdkRunning = false;
      });

      _logMessage('CastarSDK stopped: $result');

      // Update status immediately
      await _getSdkStatus();
    } catch (e) {
      setState(() {
        _isLoading = false;
        _statusMessage = 'Failed to stop CastarSDK';
        _lastError = e.toString();
      });
      _logError('Stop CastarSDK error: $e');
      _showError('Failed to stop CastarSDK: $e');
    }
  }

  // Retry mechanism
  Future<void> _retryCastarSdk() async {
    _logMessage('Retrying CastarSDK...');
    await _stopCastarSdk();
    await Future.delayed(const Duration(seconds: 2));
    await _startCastarSdk();
  }

  // Show error dialog
  void _showError(String message) {
    if (mounted) {
      showDialog(
        context: context,
        builder:
            (context) => AlertDialog(
              title: const Text('Error'),
              content: Text(message),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('OK'),
                ),
              ],
            ),
      );
    }
  }

  // Logging functions - KEEP IN RELEASE
  void _logMessage(String message) {
    print('[CastarSDK Flutter] $message');
    debugPrint('[CastarSDK Flutter] $message');
  }

  void _logError(String error) {
    print('[CastarSDK Flutter ERROR] $error');
    debugPrint('[CastarSDK Flutter ERROR] $error');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CastarSDK Demo'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isLoading ? null : _getSdkStatus,
            tooltip: 'Refresh Status',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Status Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          _isSdkRunning ? Icons.check_circle : Icons.error,
                          color: _isSdkRunning ? Colors.green : Colors.red,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'SDK Status: ${_isSdkRunning ? "Running" : "Stopped"}',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text('Status: $_statusMessage'),
                    if (_lastError.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        'Last Error: $_lastError',
                        style: const TextStyle(color: Colors.red),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // SDK Info Card
            if (_sdkStatus.isNotEmpty) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'SDK Information',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text('Running: ${_sdkStatus['running'] ?? 'Unknown'}'),
                      Text('Dev Key: ${_sdkStatus['devKey'] ?? 'Unknown'}'),
                      Text('Dev SN: ${_sdkStatus['devSn'] ?? 'Unknown'}'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Control Buttons
            if (_isLoading) ...[
              const Center(
                child: Column(
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Processing...'),
                  ],
                ),
              ),
            ] else ...[
              ElevatedButton.icon(
                onPressed: _isSdkRunning ? null : _startCastarSdk,
                icon: const Icon(Icons.play_arrow),
                label: const Text('Start CastarSDK'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.all(16),
                ),
              ),

              const SizedBox(height: 12),

              ElevatedButton.icon(
                onPressed: _isSdkRunning ? _stopCastarSdk : null,
                icon: const Icon(Icons.stop),
                label: const Text('Stop CastarSDK'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.all(16),
                ),
              ),

              const SizedBox(height: 12),

              OutlinedButton.icon(
                onPressed: _retryCastarSdk,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry CastarSDK'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                ),
              ),
            ],

            const Spacer(),

            // Debug Info
            Card(
              color: Colors.grey[100],
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Debug Information',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 8),
                    Text('App Initialized: $_isInitialized'),
                    Text('SDK Running: $_isSdkRunning'),
                    Text('Loading: $_isLoading'),
                    Text(
                      'Status Timer Active: ${_statusTimer?.isActive ?? false}',
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

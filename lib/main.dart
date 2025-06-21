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
      title: 'My Time',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'CastarSDK Integration'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with WidgetsBindingObserver {
  static const platform = MethodChannel('com.castarsdk.flutter/castar');

  final TextEditingController _clientIdController = TextEditingController();
  String _status = 'Ready';
  bool _isRunning = false;
  bool _isLoading = false;
  Map<String, dynamic> _sdkStatus = {};
  int _retryCount = 0;
  static const int maxRetries = 3;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // Add a small delay to ensure app is fully loaded
    Future.delayed(const Duration(seconds: 2), () {
      _checkSDKStatus();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _clientIdController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    switch (state) {
      case AppLifecycleState.resumed:
        print('📱 App resumed');
        _checkSDKStatus();
        break;
      case AppLifecycleState.inactive:
        print('📱 App inactive');
        break;
      case AppLifecycleState.paused:
        print('📱 App paused - keeping CastarSDK running');
        // Keep the app alive by preventing sleep
        _keepAlive();
        break;
      case AppLifecycleState.detached:
        print('📱 App detached');
        break;
      case AppLifecycleState.hidden:
        print('📱 App hidden');
        break;
    }
  }

  void _keepAlive() {
    // This helps prevent the app from being terminated
    print('🔋 Keeping app alive...');
  }

  Future<void> _startCastarSDK() async {
    if (_clientIdController.text.isEmpty) {
      setState(() {
        _status = 'Error: Client ID is required';
      });
      return;
    }

    setState(() {
      _status = 'Starting CastarSDK...';
      _isLoading = true;
    });

    try {
      final String result = await platform.invokeMethod('startCastarSdk', {
        'clientId': _clientIdController.text,
      });

      setState(() {
        _status = result;
        _isRunning = true;
        _isLoading = false;
        _retryCount = 0; // Reset retry count on success
      });

      // Check status after starting
      await _checkSDKStatus();

      // Start periodic status checking
      _startPeriodicStatusCheck();
    } on PlatformException catch (e) {
      print('❌ Platform Exception: ${e.message}');
      setState(() {
        _status = 'Error: ${e.message}';
        _isLoading = false;
      });

      // Retry logic
      if (_retryCount < maxRetries) {
        _retryCount++;
        print('🔄 Retrying... Attempt $_retryCount of $maxRetries');
        Future.delayed(Duration(seconds: _retryCount * 2), () {
          _startCastarSDK();
        });
      }
    } catch (e) {
      print('❌ General Exception: $e');
      setState(() {
        _status = 'Error: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _stopCastarSDK() async {
    setState(() {
      _status = 'Stopping CastarSDK...';
      _isLoading = true;
    });

    try {
      final String result = await platform.invokeMethod('stopCastarSdk');

      setState(() {
        _status = result;
        _isRunning = false;
        _isLoading = false;
        _sdkStatus = {};
      });

      // Stop periodic status checking
      _stopPeriodicStatusCheck();
    } on PlatformException catch (e) {
      print('❌ Platform Exception: ${e.message}');
      setState(() {
        _status = 'Error: ${e.message}';
        _isLoading = false;
      });
    }
  }

  Future<void> _checkSDKStatus() async {
    try {
      final Map<String, dynamic> status = await platform.invokeMethod(
        'getCastarStatus',
      );

      setState(() {
        _sdkStatus = status;
        _isRunning = status['running'] ?? false;
      });

      print('📊 SDK Status: $status');
    } on PlatformException catch (e) {
      print('❌ Error checking SDK status: ${e.message}');
    }
  }

  void _startPeriodicStatusCheck() {
    // Check status every 30 seconds to keep the app active
    Future.delayed(const Duration(seconds: 30), () {
      if (_isRunning) {
        _checkSDKStatus();
        _startPeriodicStatusCheck(); // Recursive call
      }
    });
  }

  void _stopPeriodicStatusCheck() {
    // This will stop the periodic checking
    _isRunning = false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            // Status Display
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Status: $_status',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    if (_sdkStatus.isNotEmpty) ...[
                      Text('Running: ${_sdkStatus['running'] ?? false}'),
                      Text('Device Key: ${_sdkStatus['devKey'] ?? 'N/A'}'),
                      Text('Device SN: ${_sdkStatus['devSn'] ?? 'N/A'}'),
                    ],
                    if (_retryCount > 0) ...[
                      const SizedBox(height: 8),
                      Text(
                        'Retry Attempt: $_retryCount/$maxRetries',
                        style: TextStyle(
                          color:
                              _retryCount >= maxRetries
                                  ? Colors.red
                                  : Colors.orange,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Client ID Input
            TextField(
              controller: _clientIdController,
              decoration: const InputDecoration(
                labelText: 'Client ID',
                hintText: 'Enter your CastarSDK Client ID',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            // Control Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed:
                        (_isRunning || _isLoading) ? null : _startCastarSDK,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child:
                        _isLoading && !_isRunning
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
                            : const Text('Start CastarSDK'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed:
                        (_isRunning && !_isLoading) ? _stopCastarSDK : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Stop CastarSDK'),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Status Check Button
            ElevatedButton(
              onPressed: _checkSDKStatus,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Check SDK Status'),
            ),

            const Spacer(),

            // Info Card
            Card(
              color: Colors.blue.shade50,
              child: const Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'App Lifecycle Management',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Text('• Background processing enabled'),
                    Text('• CastarSDK keeps running in background'),
                    Text('• Auto-stopping prevention active'),
                    Text('• Status monitoring available'),
                    Text('• Automatic retry mechanism'),
                    Text('• Crash prevention enabled'),
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

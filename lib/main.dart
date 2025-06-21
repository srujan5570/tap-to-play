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
  Map<String, dynamic> _sdkStatus = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkSDKStatus();
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
        break;
      case AppLifecycleState.detached:
        print('📱 App detached');
        break;
      case AppLifecycleState.hidden:
        print('📱 App hidden');
        break;
    }
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
    });

    try {
      final String result = await platform.invokeMethod('startCastarSdk', {
        'clientId': _clientIdController.text,
      });

      setState(() {
        _status = result;
        _isRunning = true;
      });

      // Check status after starting
      _checkSDKStatus();
    } on PlatformException catch (e) {
      setState(() {
        _status = 'Error: ${e.message}';
      });
    }
  }

  Future<void> _stopCastarSDK() async {
    setState(() {
      _status = 'Stopping CastarSDK...';
    });

    try {
      final String result = await platform.invokeMethod('stopCastarSdk');

      setState(() {
        _status = result;
        _isRunning = false;
        _sdkStatus = {};
      });
    } on PlatformException catch (e) {
      setState(() {
        _status = 'Error: ${e.message}';
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
    } on PlatformException catch (e) {
      print('Error checking SDK status: ${e.message}');
    }
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
                    onPressed: _isRunning ? null : _startCastarSDK,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Start CastarSDK'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isRunning ? _stopCastarSDK : null,
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

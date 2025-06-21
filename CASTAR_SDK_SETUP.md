# Castar SDK Integration Guide

This Flutter iOS app has been integrated with the Castar SDK to enable tap-to-play functionality.

## Features

- **Client ID Input**: Enter your Castar client ID (e.g., CSK****FHQlUQZ)
- **SDK Management**: Start and stop the Castar SDK service
- **Real-time Status**: Visual indicator showing SDK running status
- **Error Handling**: Proper error messages for failed operations

## Setup Instructions

### 1. iOS Configuration

The app is already configured with:
- Castar SDK dependency in `ios/Podfile`
- Method channel implementation in `ios/Runner/AppDelegate.swift`
- Internet permissions in `ios/Runner/Info.plist`

### 2. Install Dependencies

```bash
cd my_time
flutter pub get
cd ios
pod install
```

### 3. Castar SDK Setup

1. **Add Castar SDK to your project:**
   - Download `CastarSdk.framework` from Castar
   - Add it to your iOS project's `Frameworks` folder
   - Or use CocoaPods if available: `pod 'CastarSdk'`

2. **Update Podfile** (if using CocoaPods):
   ```ruby
   pod 'CastarSdk', '~> 1.0'
   ```

3. **Build and Run:**
   ```bash
   flutter run
   ```

## Usage

1. **Launch the app**
2. **Enter your Castar Client ID** (e.g., CSK****FHQlUQZ)
3. **Tap "Start Castar SDK"** to initialize the service
4. **Monitor the status** - green indicator shows SDK is running
5. **Tap "Stop Castar SDK"** to stop the service when needed

## Code Structure

### Flutter Side (`lib/main.dart`)
- `CastarSdkScreen`: Main UI for client ID input and SDK control
- `MethodChannel`: Communication bridge to native iOS code
- `_startCastarSdk()`: Starts the Castar SDK with provided client ID
- `_stopCastarSdk()`: Stops the Castar SDK service

### iOS Side (`ios/Runner/AppDelegate.swift`)
- Method channel handler for Flutter communication
- `CastarSdk.Start()`: Initializes SDK in background thread
- `CastarSdk.Stop()`: Stops the SDK service

## API Reference

### Start SDK
```dart
await platform.invokeMethod('startCastarSdk', {
  'clientId': 'YOUR_CLIENT_ID'
});
```

### Stop SDK
```dart
await platform.invokeMethod('stopCastarSdk');
```

## Troubleshooting

1. **SDK not starting**: Check your client ID format and internet connection
2. **Build errors**: Ensure Castar SDK framework is properly added to iOS project
3. **Permission issues**: Verify internet permissions in Info.plist

## Notes

- The Castar SDK runs in a background thread to avoid blocking the UI
- Internet permission is required for SDK functionality
- The app displays real-time status of the SDK service
- Error handling provides clear feedback for failed operations

## Support

For Castar SDK specific issues, refer to the official Castar documentation.
For app integration issues, check the Flutter and iOS setup guides. 
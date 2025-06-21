# Castar SDK Integration Guide

This Flutter app has been integrated with the Castar SDK to enable tap-to-play functionality on both iOS and Android platforms.

## Features

- **Cross-Platform Support**: Works on both iOS and Android
- **Client ID Input**: Enter your Castar client ID (e.g., CSK****FHQlUQZ)
- **SDK Management**: Start and stop the Castar SDK service
- **Real-time Status**: Visual indicator showing SDK running status
- **Error Handling**: Proper error messages for failed operations
- **Platform Detection**: Shows which platform (iOS/Android) is being used

## Setup Instructions

### 1. Android Configuration ✅ COMPLETE

The app is already configured with:
- Castar SDK AAR file in `android/app/libs/CastarSdk.aar`
- SDK dependency in `android/app/build.gradle.kts`
- Method channel implementation in `android/app/src/main/kotlin/com/example/my_time/MainActivity.kt`
- Application class in `android/app/src/main/kotlin/com/example/my_time/MyApplication.kt`
- Internet permissions in `android/app/src/main/AndroidManifest.xml`

### 2. iOS Configuration ✅ READY FOR INTEGRATION

The app is configured with:
- Castar SDK framework in `ios/Frameworks/CastarSdk.framework`
- Method channel implementation in `ios/Runner/AppDelegate.swift`
- Internet permissions in `ios/Runner/Info.plist`
- **Manual setup guide**: `ios/MANUAL_CASTAR_SETUP.md`

### 3. Install Dependencies

```bash
cd my_time
flutter pub get

# For Android
cd android
./gradlew clean

# For iOS
cd ios
pod install
```

### 4. iOS Framework Integration

**Follow the manual setup guide:**
```bash
cd ios
open Runner.xcworkspace
```

Then follow the steps in `ios/MANUAL_CASTAR_SETUP.md` to:
1. Add CastarSdk.framework to Xcode project
2. Configure build settings
3. Embed the framework

### 5. Build and Run

```bash
# For Android
flutter run -d android

# For iOS (after framework integration)
flutter run -d ios
```

## Usage

1. **Launch the app**
2. **Check platform indicator** - shows iOS or Android
3. **Enter your Castar Client ID** (e.g., CSK****FHQlUQZ)
4. **Tap "Start Castar SDK"** to initialize the service
5. **Monitor the status** - green indicator shows SDK is running
6. **Tap "Stop Castar SDK"** to stop the service when needed

## Code Structure

### Flutter Side (`lib/main.dart`)
- `CastarSdkScreen`: Main UI for client ID input and SDK control
- `MethodChannel`: Communication bridge to native code (iOS/Android)
- `_startCastarSdk()`: Starts the Castar SDK with provided client ID
- `_stopCastarSdk()`: Stops the Castar SDK service
- Platform detection for UI customization

### Android Side (`android/app/src/main/kotlin/com/example/my_time/`)
- `MainActivity.kt`: Method channel handler for Flutter communication
- `MyApplication.kt`: Application class with Castar SDK methods
- `CastarSdk.Start()`: Initializes SDK in background thread
- `CastarSdk.Stop()`: Stops the SDK service

### iOS Side (`ios/Runner/AppDelegate.swift`)
- Method channel handler for Flutter communication
- `CastarSdk.Start()`: Initializes SDK in background thread
- `CastarSdk.Stop()`: Stops the SDK service

## API Reference

### Start SDK (Cross-Platform)
```dart
await platform.invokeMethod('startCastarSdk', {
  'clientId': 'YOUR_CLIENT_ID'
});
```

### Stop SDK (Cross-Platform)
```dart
await platform.invokeMethod('stopCastarSdk');
```

## Android Implementation Details

### 1. AAR File Integration
- `CastarSdk.aar` is placed in `android/app/libs/`
- Dependency added: `implementation(files("libs/CastarSdk.aar"))`

### 2. Application Class
```kotlin
class MyApplication : Application() {
    companion object {
        fun startCastarSdk(application: Application, clientId: String) {
            GlobalScope.launch(Dispatchers.IO) {
                CastarSdk.Start(application, clientId)
            }
        }
        
        fun stopCastarSdk() {
            CastarSdk.Stop()
        }
    }
}
```

### 3. Method Channel in MainActivity
```kotlin
MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
    when (call.method) {
        "startCastarSdk" -> {
            val clientId = call.argument<String>("clientId")
            MyApplication.startCastarSdk(application, clientId)
            result.success("Castar SDK started successfully")
        }
        "stopCastarSdk" -> {
            MyApplication.stopCastarSdk()
            result.success("Castar SDK stopped successfully")
        }
    }
}
```

## iOS Implementation Details

### 1. Framework Integration
- `CastarSdk.framework` is placed in `ios/Frameworks/`
- Manual integration required via Xcode (see `ios/MANUAL_CASTAR_SETUP.md`)

### 2. AppDelegate Implementation
```swift
import CastarSdk

// Start SDK
DispatchQueue.global(qos: .background).async {
    CastarSdk.Start(application, clientId)
}

// Stop SDK
CastarSdk.Stop()
```

## Troubleshooting

### Android Issues:
1. **SDK not starting**: Check client ID format and internet connection
2. **Build errors**: Ensure CastarSdk.aar is in libs directory
3. **Permission issues**: Verify internet permissions in AndroidManifest.xml

### iOS Issues:
1. **SDK not starting**: Check client ID format and internet connection
2. **Build errors**: Follow `ios/MANUAL_CASTAR_SETUP.md` for framework integration
3. **Permission issues**: Verify internet permissions in Info.plist

## Current Status

### ✅ Complete:
- **Android**: Full Castar SDK integration with AAR file
- **iOS**: Framework provided, ready for Xcode integration
- **Flutter**: Cross-platform UI and method channels
- **Documentation**: Complete setup guides

### ⏳ Pending:
- **iOS**: Manual Xcode integration (follow `ios/MANUAL_CASTAR_SETUP.md`)

## Next Steps

1. **For iOS**: Follow the manual setup guide in `ios/MANUAL_CASTAR_SETUP.md`
2. **Test both platforms** with your client ID
3. **Build and deploy** the complete app

## Support

For Castar SDK specific issues:
- Contact Castar support for SDK documentation
- Check the manual setup guides for platform-specific issues
- Verify framework compatibility with your deployment targets 
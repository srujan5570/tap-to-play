# iOS Castar SDK Setup Guide

This guide explains how to add the Castar SDK to your iOS project to enable the full functionality.

## Current Status

The iOS build currently uses a **simulated Castar SDK** to allow the app to build and run without the actual SDK framework. The app will work but won't have real Castar SDK functionality until you add the framework.

## Adding Castar SDK to iOS

### Option 1: Using CocoaPods (Recommended)

1. **Get the Castar SDK Pod**
   - Contact Castar support to get the CocoaPods repository URL
   - Or download the SDK and create a local pod

2. **Update Podfile**
   ```ruby
   # In ios/Podfile, uncomment this line:
   pod 'CastarSdk', '~> 1.0'
   ```

3. **Install Pods**
   ```bash
   cd ios
   pod install
   ```

### Option 2: Manual Framework Integration

1. **Download CastarSdk.framework**
   - Get the `CastarSdk.framework` from Castar
   - This should be a complete iOS framework bundle

2. **Add to Xcode Project**
   - Open `ios/Runner.xcworkspace` in Xcode
   - Drag `CastarSdk.framework` into the project navigator
   - Make sure it's added to the "Runner" target
   - Place it in the "Frameworks" folder

3. **Update Build Settings**
   - In Xcode, select the Runner target
   - Go to "Build Settings"
   - Add `CastarSdk.framework` to "Framework Search Paths"
   - Ensure "Embed Frameworks" includes CastarSdk.framework

4. **Update AppDelegate.swift**
   ```swift
   import UIKit
   import Flutter
   import CastarSdk  // Uncomment this line
   
   @UIApplicationMain
   @objc class AppDelegate: FlutterAppDelegate {
     override func application(
       _ application: UIApplication,
       didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
     ) -> Bool {
       
       let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
       let castarChannel = FlutterMethodChannel(name: "com.castarsdk.flutter/castar",
                                                 binaryMessenger: controller.binaryMessenger)
       
       castarChannel.setMethodCallHandler({
         (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
         
         switch call.method {
         case "startCastarSdk":
           guard let args = call.arguments as? [String: Any],
                 let clientId = args["clientId"] as? String else {
             result(FlutterError(code: "INVALID_ARGUMENTS", message: "Client ID is required", details: nil))
             return
           }
           
           // Start Castar SDK in background thread
           DispatchQueue.global(qos: .background).async {
             CastarSdk.Start(application, clientId)  // Uncomment this line
             
             DispatchQueue.main.async {
               result("Castar SDK started successfully with client ID: \(clientId)")
             }
           }
           
         case "stopCastarSdk":
           // Stop Castar SDK
           CastarSdk.Stop()  // Uncomment this line
           result("Castar SDK stopped successfully")
           
         default:
           result(FlutterMethodNotImplemented)
         }
       })
       
       GeneratedPluginRegistrant.register(with: self)
       return super.application(application, didFinishLaunchingWithOptions: launchOptions)
     }
   }
   ```

## Testing the Integration

1. **Build the app**
   ```bash
   flutter build ios --release --no-codesign
   ```

2. **Run on device/simulator**
   ```bash
   flutter run -d ios
   ```

3. **Test Castar SDK**
   - Enter a valid client ID
   - Tap "Start Castar SDK"
   - Check console logs for SDK activity

## Troubleshooting

### Build Errors
- **"No such module 'CastarSdk'"**: Framework not properly added to project
- **"Framework not found"**: Check framework search paths in Xcode
- **"Symbol not found"**: Ensure framework is embedded in the app bundle

### Runtime Errors
- **SDK not starting**: Check client ID format and internet connection
- **Permission denied**: Verify internet permissions in Info.plist
- **Crash on startup**: Check framework compatibility with iOS version

## Current Implementation

The current implementation includes:
- ✅ Method channel setup for Flutter communication
- ✅ Internet permissions in Info.plist
- ✅ Simulated SDK calls for testing
- ✅ Error handling and user feedback
- ⏳ **Pending**: Actual CastarSdk.framework integration

## Next Steps

1. **Get Castar SDK**: Contact Castar to obtain the iOS SDK
2. **Follow setup guide**: Use either CocoaPods or manual integration
3. **Test thoroughly**: Verify SDK functionality on real devices
4. **Update code**: Uncomment the actual SDK calls in AppDelegate.swift

## Support

For Castar SDK specific issues:
- Contact Castar support for iOS SDK access
- Check Castar documentation for iOS integration
- Verify framework compatibility with your iOS deployment target 
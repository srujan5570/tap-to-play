# Manual Castar SDK Setup for iOS

The Castar SDK framework has been copied to `ios/Frameworks/CastarSdk.framework`. Follow these steps to integrate it into your Xcode project.

## Step 1: Open Xcode Project

```bash
cd ios
open Runner.xcworkspace
```

## Step 2: Add Framework to Project

1. **In Xcode Project Navigator:**
   - Right-click on the "Runner" project
   - Select "Add Files to 'Runner'"
   - Navigate to `ios/Frameworks/CastarSdk.framework`
   - Make sure "Add to target: Runner" is checked
   - Click "Add"

2. **Verify Framework Location:**
   - The framework should appear in the project navigator
   - It should be listed under "Frameworks" or at the root level

## Step 3: Configure Build Settings

1. **Select Runner Target:**
   - Click on "Runner" in the project navigator
   - Select the "Runner" target (not project)

2. **Add Framework Search Path:**
   - Go to "Build Settings" tab
   - Search for "Framework Search Paths"
   - Add: `$(SRCROOT)/Frameworks`

3. **Embed Framework:**
   - Go to "General" tab
   - Scroll to "Frameworks, Libraries, and Embedded Content"
   - Make sure "CastarSdk.framework" is listed
   - Set embedding to "Embed & Sign"

## Step 4: Verify Integration

1. **Check AppDelegate.swift:**
   - Open `ios/Runner/AppDelegate.swift`
   - Verify `import CastarSdk` is present
   - Verify `CastarSdk.Start()` and `CastarSdk.Stop()` calls are uncommented

2. **Build the Project:**
   - Press Cmd+B to build
   - Should compile without errors

## Step 5: Test the Integration

1. **Run the App:**
   ```bash
   flutter run -d ios
   ```

2. **Test Castar SDK:**
   - Enter your client ID
   - Tap "Start Castar SDK"
   - Check console for SDK activity

## Troubleshooting

### Build Errors:
- **"No such module 'CastarSdk'"**: Framework not properly added to project
- **"Framework not found"**: Check framework search paths
- **"Symbol not found"**: Ensure framework is embedded

### Solutions:
1. **Clean and Rebuild:**
   ```bash
   flutter clean
   cd ios
   pod install
   flutter run -d ios
   ```

2. **Check Framework Path:**
   - Ensure `CastarSdk.framework` is in `ios/Frameworks/`
   - Verify it's added to the Xcode project

3. **Verify Build Settings:**
   - Framework Search Paths should include `$(SRCROOT)/Frameworks`
   - Framework should be embedded in the app

## Current Status

✅ **CastarSdk.framework** copied to `ios/Frameworks/`
✅ **AppDelegate.swift** updated with real SDK calls
✅ **Manual setup guide** provided
⏳ **Pending**: Xcode project integration (follow steps above)

## Next Steps

1. **Follow manual setup** (steps 1-5 above)
2. **Test the integration** with your client ID
3. **Build and deploy** the iOS app

The Castar SDK is now ready to be integrated into your iOS app! 
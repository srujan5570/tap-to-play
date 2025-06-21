# Complete Castar SDK Setup Guide for iOS

## 🎯 Problem Solved: Module Name Mismatch

**Issue**: `No such module 'CastarSdk'`
**Root Cause**: Import statement didn't match framework module name
**Solution**: Changed `import CastarSdk` to `import CastarSDK`

## ✅ What's Fixed:

1. **Module Name**: `CastarSDK` (correct) instead of `CastarSdk` (incorrect)
2. **Import Statement**: `import CastarSDK` matches the framework
3. **SDK Calls**: `CastarSDK.Start()` and `CastarSDK.Stop()` now correct

## 📋 Complete Setup Steps:

### Step 1: Verify Framework Structure
```
ios/Frameworks/CastarSDK.framework/
├── CastarSDK (6.8MB binary)
├── Headers/
│   ├── CastarSDK.h
│   └── CSDK.h
├── Modules/
│   └── module.modulemap (contains: framework module CastarSDK)
└── Info.plist
```

### Step 2: Open Xcode Project
```bash
cd ios
open Runner.xcworkspace
```

### Step 3: Add Framework to Xcode Project

1. **In Xcode Project Navigator:**
   - Right-click on "Runner" project (blue icon)
   - Select "Add Files to 'Runner'..."
   - Navigate to: `ios/Frameworks/CastarSDK.framework`
   - ✅ **IMPORTANT**: Check "Add to target: Runner"
   - Click "Add"

2. **Verify Framework is Added:**
   - Framework should appear in project navigator
   - Should be listed under "Frameworks" or at root level

### Step 4: Configure Build Settings

1. **Select Runner Target:**
   - Click "Runner" in project navigator
   - Select "Runner" target (not project)

2. **Add Framework Search Path:**
   - Go to "Build Settings" tab
   - Search for "Framework Search Paths"
   - Add: `$(SRCROOT)/Frameworks`
   - Make sure it's set to "recursive"

3. **Embed Framework:**
   - Go to "General" tab
   - Scroll to "Frameworks, Libraries, and Embedded Content"
   - Find "CastarSDK.framework"
   - Set to "Embed & Sign"

### Step 5: Verify Code Changes

**AppDelegate.swift should have:**
```swift
import UIKit
import Flutter
import CastarSDK  // ✅ Correct module name

// ... in method channel handler:
CastarSDK.Start(application, clientId)  // ✅ Correct SDK call
CastarSDK.Stop()  // ✅ Correct SDK call
```

### Step 6: Clean and Build

```bash
# Clean everything
flutter clean

# Install pods
cd ios
pod install
cd ..

# Build iOS
flutter build ios --release --no-codesign
```

## 🔧 Troubleshooting:

### If Still Getting "No such module":

1. **Check Framework Search Paths:**
   - In Xcode: Runner target → Build Settings
   - Search: "Framework Search Paths"
   - Should include: `$(SRCROOT)/Frameworks`

2. **Check Framework Embedding:**
   - In Xcode: Runner target → General
   - "Frameworks, Libraries, and Embedded Content"
   - CastarSDK.framework should be "Embed & Sign"

3. **Clean Build Folder:**
   - In Xcode: Product → Clean Build Folder
   - Then rebuild

4. **Verify Framework File:**
   ```bash
   ls -la ios/Frameworks/CastarSDK.framework/
   # Should show: CastarSDK, Headers/, Modules/, Info.plist
   ```

### Common Issues:

1. **Framework not added to target**: Make sure "Add to target: Runner" was checked
2. **Wrong search path**: Use `$(SRCROOT)/Frameworks` not relative paths
3. **Case sensitivity**: Module name must match exactly (`CastarSDK` not `CastarSdk`)

## 🎉 Expected Result:

After following these steps:
- ✅ Build succeeds: `flutter build ios --release --no-codesign`
- ✅ No "No such module" errors
- ✅ Castar SDK fully functional
- ✅ Real SDK calls work: `CastarSDK.Start()` and `CastarSDK.Stop()`

## 📱 Test Your Integration:

1. **Build the app**: `flutter build ios --release --no-codesign`
2. **Run on device/simulator**: `flutter run -d ios`
3. **Test Castar SDK**:
   - Enter your client ID
   - Tap "Start Castar SDK"
   - Should show success message
   - Check console for SDK activity

Your Castar SDK integration should now work perfectly! 🚀 
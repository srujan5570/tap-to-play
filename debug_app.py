#!/usr/bin/env python3
"""
Debug script for CastarSDK Flutter app
Helps diagnose startup crashes and provides detailed logging
"""

import os
import sys
import subprocess
import time
import json
from pathlib import Path

def run_command(cmd, cwd=None):
    """Run a command and return the result"""
    try:
        result = subprocess.run(
            cmd, 
            shell=True, 
            cwd=cwd,
            capture_output=True, 
            text=True, 
            encoding='utf-8',
            errors='replace',
            timeout=60
        )
        return result.returncode, result.stdout, result.stderr
    except subprocess.TimeoutExpired:
        return -1, "", "Command timed out"
    except Exception as e:
        return -1, "", str(e)

def check_flutter_environment():
    """Check Flutter environment"""
    print("🔍 Checking Flutter environment...")
    
    # Check Flutter version
    code, stdout, stderr = run_command("flutter --version")
    if code == 0:
        print("✅ Flutter is available")
        # Get first line safely
        lines = stdout.split('\n')
        if lines:
            print(lines[0])
    else:
        print("❌ Flutter not found or error:", stderr)
        return False
    
    # Check Flutter doctor
    print("\n🔍 Running Flutter doctor...")
    code, stdout, stderr = run_command("flutter doctor -v")
    if code == 0:
        print("✅ Flutter doctor completed")
        # Look for iOS setup
        if "iOS toolchain" in stdout and "✓" in stdout:
            print("✅ iOS toolchain is properly configured")
        else:
            print("⚠️ iOS toolchain may have issues")
    else:
        print("❌ Flutter doctor failed:", stderr)
    
    return True

def check_ios_setup():
    """Check iOS-specific setup"""
    print("\n🔍 Checking iOS setup...")
    
    # Check if iOS folder exists
    ios_path = Path("ios")
    if not ios_path.exists():
        print("❌ iOS folder not found")
        return False
    
    # Check AppDelegate
    app_delegate_path = ios_path / "Runner" / "AppDelegate.swift"
    if app_delegate_path.exists():
        print("✅ AppDelegate.swift found")
        
        # Check for CastarSDK import
        try:
            with open(app_delegate_path, 'r', encoding='utf-8') as f:
                content = f.read()
                if "import CastarSDK" in content:
                    print("✅ CastarSDK import found")
                else:
                    print("❌ CastarSDK import not found")
        except Exception as e:
            print(f"❌ Error reading AppDelegate: {e}")
    else:
        print("❌ AppDelegate.swift not found")
    
    # Check Info.plist
    info_plist_path = ios_path / "Runner" / "Info.plist"
    if info_plist_path.exists():
        print("✅ Info.plist found")
        
        # Check for background modes
        try:
            with open(info_plist_path, 'r', encoding='utf-8') as f:
                content = f.read()
                if "UIBackgroundModes" in content:
                    print("✅ Background modes configured")
                else:
                    print("❌ Background modes not configured")
        except Exception as e:
            print(f"❌ Error reading Info.plist: {e}")
    else:
        print("❌ Info.plist not found")
    
    return True

def check_castar_sdk():
    """Check CastarSDK setup"""
    print("\n🔍 Checking CastarSDK setup...")
    
    # Check if framework exists
    framework_path = Path("ios/Frameworks/CastarSDK.framework")
    if framework_path.exists():
        print("✅ CastarSDK.framework found")
        
        # Check framework contents
        headers_path = framework_path / "Headers"
        if headers_path.exists():
            print("✅ Framework headers found")
            header_files = list(headers_path.glob("*.h"))
            if header_files:
                print(f"✅ Found {len(header_files)} header files")
                for header in header_files:
                    print(f"   - {header.name}")
            else:
                print("❌ No header files found")
        else:
            print("❌ Framework headers not found")
    else:
        print("❌ CastarSDK.framework not found")
        print("   Run the download script first")
    
    return True

def build_and_test():
    """Build and test the app"""
    print("\n🔧 Building and testing the app...")
    
    # Clean build
    print("🧹 Cleaning build...")
    code, stdout, stderr = run_command("flutter clean")
    if code != 0:
        print("❌ Clean failed:", stderr)
        return False
    
    # Get dependencies
    print("📦 Getting dependencies...")
    code, stdout, stderr = run_command("flutter pub get")
    if code != 0:
        print("❌ Pub get failed:", stderr)
        return False
    
    # Build for iOS (simulator)
    print("🔨 Building for iOS simulator...")
    code, stdout, stderr = run_command("flutter build ios --debug --simulator")
    if code == 0:
        print("✅ Build successful")
        return True
    else:
        print("❌ Build failed")
        print("STDOUT:", stdout)
        print("STDERR:", stderr)
        return False

def analyze_crash_logs():
    """Analyze crash logs if available"""
    print("\n📊 Analyzing crash logs...")
    
    # Check for crash logs in common locations
    crash_log_paths = [
        Path.home() / "Library" / "Logs" / "DiagnosticReports",
        Path.home() / "Library" / "Developer" / "Xcode" / "DerivedData",
    ]
    
    for crash_path in crash_log_paths:
        if crash_path.exists():
            print(f"🔍 Checking {crash_path}")
            # Look for recent crash logs
            crash_files = list(crash_path.glob("*Runner*.crash"))
            if crash_files:
                print(f"✅ Found {len(crash_files)} crash files")
                for crash_file in sorted(crash_files, key=lambda x: x.stat().st_mtime, reverse=True)[:3]:
                    print(f"   - {crash_file.name}")
                    # Show first few lines
                    try:
                        with open(crash_file, 'r', encoding='utf-8', errors='replace') as f:
                            lines = f.readlines()[:10]
                            for line in lines:
                                if "Exception" in line or "Crash" in line or "Castar" in line:
                                    print(f"     {line.strip()}")
                    except Exception as e:
                        print(f"     Error reading crash file: {e}")
            else:
                print("   No crash files found")

def generate_debug_report():
    """Generate a comprehensive debug report"""
    print("\n📋 Generating debug report...")
    
    report = {
        "timestamp": time.strftime("%Y-%m-%d %H:%M:%S"),
        "flutter_version": "",
        "ios_setup": {},
        "castar_sdk": {},
        "build_status": "",
        "recommendations": []
    }
    
    # Get Flutter version
    code, stdout, stderr = run_command("flutter --version")
    if code == 0:
        lines = stdout.split('\n')
        if lines:
            report["flutter_version"] = lines[0]
    
    # Check iOS setup
    ios_path = Path("ios")
    if ios_path.exists():
        report["ios_setup"]["folder_exists"] = True
        report["ios_setup"]["app_delegate_exists"] = (ios_path / "Runner" / "AppDelegate.swift").exists()
        report["ios_setup"]["info_plist_exists"] = (ios_path / "Runner" / "Info.plist").exists()
    else:
        report["ios_setup"]["folder_exists"] = False
    
    # Check CastarSDK
    framework_path = Path("ios/Frameworks/CastarSDK.framework")
    report["castar_sdk"]["framework_exists"] = framework_path.exists()
    if framework_path.exists():
        report["castar_sdk"]["headers_exist"] = (framework_path / "Headers").exists()
    
    # Save report
    try:
        with open("debug_report.json", 'w', encoding='utf-8') as f:
            json.dump(report, f, indent=2, ensure_ascii=False)
        print("✅ Debug report saved to debug_report.json")
    except Exception as e:
        print(f"❌ Error saving debug report: {e}")
    
    return report

def main():
    """Main debug function"""
    print("🚀 CastarSDK Flutter App Debug Tool")
    print("=" * 50)
    
    # Check if we're in the right directory
    if not Path("pubspec.yaml").exists():
        print("❌ pubspec.yaml not found. Please run this script from the Flutter project root.")
        return
    
    # Run all checks
    flutter_ok = check_flutter_environment()
    ios_ok = check_ios_setup()
    sdk_ok = check_castar_sdk()
    
    # Build test
    build_ok = build_and_test()
    
    # Analyze crashes
    analyze_crash_logs()
    
    # Generate report
    report = generate_debug_report()
    
    # Summary
    print("\n" + "=" * 50)
    print("📊 DEBUG SUMMARY")
    print("=" * 50)
    print(f"Flutter Environment: {'✅' if flutter_ok else '❌'}")
    print(f"iOS Setup: {'✅' if ios_ok else '❌'}")
    print(f"CastarSDK Setup: {'✅' if sdk_ok else '❌'}")
    print(f"Build Test: {'✅' if build_ok else '❌'}")
    
    # Recommendations
    print("\n💡 RECOMMENDATIONS:")
    if not flutter_ok:
        print("- Install or fix Flutter environment")
    if not ios_ok:
        print("- Check iOS project setup")
    if not sdk_ok:
        print("- Download and integrate CastarSDK framework")
    if not build_ok:
        print("- Fix build errors before testing")
    
    if all([flutter_ok, ios_ok, sdk_ok, build_ok]):
        print("- All checks passed! App should work correctly.")
        print("- If app still crashes, check device logs for specific errors.")
    
    print("\n📄 Full debug report saved to: debug_report.json")

if __name__ == "__main__":
    main() 
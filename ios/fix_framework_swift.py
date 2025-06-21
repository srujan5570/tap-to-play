#!/usr/bin/env python3
"""
Script to check and fix CastarSDK framework configuration for Swift compatibility
"""

import os
import re
from pathlib import Path

def check_and_fix_framework():
    """Check and fix CastarSDK framework for Swift compatibility"""
    
    print("🔧 Checking CastarSDK framework for Swift compatibility...")
    
    # Paths
    framework_dir = Path("Frameworks/CastarSDK.framework")
    headers_dir = framework_dir / "Headers"
    modules_dir = framework_dir / "Modules"
    
    if not framework_dir.exists():
        print(f"❌ Framework directory not found: {framework_dir}")
        return False
    
    print(f"✅ Found framework: {framework_dir}")
    
    # 1. Check umbrella header (CastarSDK.h)
    umbrella_header = headers_dir / "CastarSDK.h"
    if umbrella_header.exists():
        print(f"📄 Checking umbrella header: {umbrella_header}")
        with open(umbrella_header, 'r') as f:
            content = f.read()
        
        # Check if CSDK.h is imported
        if '#import "CSDK.h"' not in content and '#import <CastarSDK/CSDK.h>' not in content:
            print("⚠️ CSDK.h not imported in umbrella header")
            print("🔧 Adding CSDK.h import to umbrella header...")
            
            # Add import at the end of the file
            new_content = content.rstrip() + '\n\n#import "CSDK.h"\n'
            
            with open(umbrella_header, 'w') as f:
                f.write(new_content)
            print("✅ Added CSDK.h import to umbrella header")
        else:
            print("✅ CSDK.h already imported in umbrella header")
    else:
        print(f"❌ Umbrella header not found: {umbrella_header}")
        return False
    
    # 2. Check module map
    module_map = modules_dir / "module.modulemap"
    if module_map.exists():
        print(f"📄 Checking module map: {module_map}")
        with open(module_map, 'r') as f:
            content = f.read()
        
        # Check if it's properly configured
        if 'umbrella header "CastarSDK.h"' not in content:
            print("⚠️ Module map not using umbrella header")
            print("🔧 Fixing module map...")
            
            new_content = '''framework module CastarSDK {
    umbrella header "CastarSDK.h"
    export *
    module * { export * }
}'''
            
            with open(module_map, 'w') as f:
                f.write(new_content)
            print("✅ Fixed module map")
        else:
            print("✅ Module map properly configured")
    else:
        print(f"❌ Module map not found: {module_map}")
        return False
    
    # 3. Check CSDK.h header
    csdk_header = headers_dir / "CSDK.h"
    if csdk_header.exists():
        print(f"📄 Checking CSDK.h header: {csdk_header}")
        with open(csdk_header, 'r') as f:
            content = f.read()
        
        # Check if Castar class is properly declared (the class is named Castar, not CSDK)
        if '@interface Castar' in content:
            print("✅ Castar class found in header")
            
            # Check if it's marked as @objc or inherits from NSObject
            if 'NSObject' in content or '@objc' in content:
                print("✅ Castar class properly configured for Swift")
            else:
                print("⚠️ Castar class may not be properly exposed to Swift")
                print("📋 Consider adding @objc annotation or NSObject inheritance")
        else:
            print("❌ Castar class not found in header")
            return False
    else:
        print(f"❌ CSDK.h header not found: {csdk_header}")
        return False
    
    # 4. Check Info.plist for framework configuration
    info_plist = framework_dir / "Info.plist"
    if info_plist.exists():
        print(f"📄 Framework Info.plist exists: {info_plist}")
    else:
        print(f"⚠️ Framework Info.plist not found: {info_plist}")
    
    # 5. Check if framework is dynamic
    binary_path = framework_dir / "CastarSDK"
    if binary_path.exists():
        print(f"✅ Framework binary exists: {binary_path}")
        
        # Check if it's a dynamic library
        try:
            import subprocess
            result = subprocess.run(['file', str(binary_path)], capture_output=True, text=True)
            if 'dynamically linked' in result.stdout:
                print("✅ Framework is dynamic library")
            else:
                print("⚠️ Framework may not be dynamic library")
        except:
            print("⚠️ Could not check framework binary type")
    else:
        print(f"❌ Framework binary not found: {binary_path}")
        return False
    
    return True

def create_swift_bridge_header():
    """Create a Swift bridging header if needed"""
    
    print("\n🔧 Creating Swift bridging header...")
    
    bridge_header = Path("Runner/Runner-Bridging-Header.h")
    
    if not bridge_header.exists():
        bridge_content = '''//
//  Runner-Bridging-Header.h
//  Runner
//
//  Generated file. Do not edit.
//

#ifndef Runner_Bridging_Header_h
#define Runner_Bridging_Header_h

#import <CastarSDK/CastarSDK.h>

#endif /* Runner_Bridging_Header_h */
'''
        
        with open(bridge_header, 'w') as f:
            f.write(bridge_content)
        print(f"✅ Created bridging header: {bridge_header}")
    else:
        print(f"✅ Bridging header already exists: {bridge_header}")
    
    return True

def main():
    """Main function"""
    print("🚀 CastarSDK Framework Swift Compatibility Fixer")
    print("=" * 60)
    
    success = check_and_fix_framework()
    if success:
        create_swift_bridge_header()
        print("\n✅ Framework Swift compatibility check and fix complete!")
        print("📱 The framework should now be accessible from Swift")
    else:
        print("\n❌ Framework Swift compatibility check failed!")
        return False
    
    return True

if __name__ == "__main__":
    success = main()
    exit(0 if success else 1) 
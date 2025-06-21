#!/usr/bin/env python3
"""
Script to check CastarSDK API and find the correct method names
"""

import os
from pathlib import Path

def check_sdk_api():
    """Check the CastarSDK framework headers for available methods"""
    
    print("🔍 Checking CastarSDK API...")
    
    # Paths
    headers_dir = Path("Frameworks/CastarSDK.framework/Headers")
    
    if not headers_dir.exists():
        print(f"❌ Headers directory not found: {headers_dir}")
        return False
    
    print(f"✅ Found headers directory: {headers_dir}")
    
    # List header files
    header_files = list(headers_dir.glob("*.h"))
    print(f"📁 Header files found: {[f.name for f in header_files]}")
    
    # Check each header file
    for header_file in header_files:
        print(f"\n📄 Analyzing {header_file.name}:")
        print("=" * 50)
        
        try:
            with open(header_file, 'r') as f:
                content = f.read()
            
            # Look for method declarations
            lines = content.split('\n')
            for i, line in enumerate(lines):
                line = line.strip()
                # Look for method declarations
                if any(keyword in line for keyword in ['+', '-', 'void', 'int', 'NSString', 'BOOL']):
                    if '(' in line and ')' in line:
                        print(f"Line {i+1}: {line}")
                        
        except Exception as e:
            print(f"❌ Error reading {header_file}: {e}")
    
    return True

def main():
    """Main function"""
    print("🚀 CastarSDK API Checker")
    print("=" * 50)
    
    success = check_sdk_api()
    if success:
        print("\n✅ API check complete!")
    else:
        print("\n❌ API check failed!")
        return False
    
    return True

if __name__ == "__main__":
    success = main()
    exit(0 if success else 1) 
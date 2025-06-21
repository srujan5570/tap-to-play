#!/usr/bin/env python3
"""
Script to debug and examine CastarSDK header files
"""

import os
from pathlib import Path

def debug_headers():
    """Debug and examine CastarSDK header files"""
    
    print("🔍 Debugging CastarSDK header files...")
    
    # Paths
    headers_dir = Path("Frameworks/CastarSDK.framework/Headers")
    
    if not headers_dir.exists():
        print(f"❌ Headers directory not found: {headers_dir}")
        return False
    
    print(f"✅ Found headers directory: {headers_dir}")
    
    # List all header files
    header_files = list(headers_dir.glob("*.h"))
    print(f"📁 Header files found: {[f.name for f in header_files]}")
    
    # Examine each header file
    for header_file in header_files:
        print(f"\n📄 Examining {header_file.name}:")
        print("=" * 60)
        
        try:
            with open(header_file, 'r') as f:
                content = f.read()
            
            print(f"File size: {len(content)} characters")
            print(f"First 500 characters:")
            print("-" * 40)
            print(content[:500])
            print("-" * 40)
            
            # Look for class declarations
            lines = content.split('\n')
            class_lines = []
            interface_lines = []
            
            for i, line in enumerate(lines):
                line = line.strip()
                if '@interface' in line:
                    interface_lines.append(f"Line {i+1}: {line}")
                elif '@class' in line:
                    class_lines.append(f"Line {i+1}: {line}")
                elif 'class' in line and '(' in line and ')' in line:
                    class_lines.append(f"Line {i+1}: {line}")
            
            if interface_lines:
                print(f"\n🔍 @interface declarations found:")
                for line in interface_lines:
                    print(f"  {line}")
            
            if class_lines:
                print(f"\n🔍 Class declarations found:")
                for line in class_lines:
                    print(f"  {line}")
            
            # Look for method declarations
            method_lines = []
            for i, line in enumerate(lines):
                line = line.strip()
                if any(keyword in line for keyword in ['+', '-', 'void', 'int', 'NSString', 'BOOL']):
                    if '(' in line and ')' in line and not line.startswith('//'):
                        method_lines.append(f"Line {i+1}: {line}")
            
            if method_lines:
                print(f"\n🔍 Method declarations found:")
                for line in method_lines[:10]:  # Show first 10 methods
                    print(f"  {line}")
                if len(method_lines) > 10:
                    print(f"  ... and {len(method_lines) - 10} more methods")
            
            # Look for imports
            import_lines = []
            for i, line in enumerate(lines):
                line = line.strip()
                if line.startswith('#import') or line.startswith('#include'):
                    import_lines.append(f"Line {i+1}: {line}")
            
            if import_lines:
                print(f"\n🔍 Import statements found:")
                for line in import_lines:
                    print(f"  {line}")
            
        except Exception as e:
            print(f"❌ Error reading {header_file}: {e}")
    
    return True

def main():
    """Main function"""
    print("🚀 CastarSDK Header Debugger")
    print("=" * 50)
    
    success = debug_headers()
    if success:
        print("\n✅ Header debugging complete!")
    else:
        print("\n❌ Header debugging failed!")
        return False
    
    return True

if __name__ == "__main__":
    success = main()
    exit(0 if success else 1) 
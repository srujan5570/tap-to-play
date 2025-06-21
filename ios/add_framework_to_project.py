#!/usr/bin/env python3
"""
Script to programmatically add CastarSDK.framework to Xcode project
This fixes the "No such module 'CastarSDK'" error in CI builds
"""

import os
import re
import uuid
from pathlib import Path

def generate_uuid():
    """Generate a UUID for Xcode project references"""
    return str(uuid.uuid4()).upper()

def add_framework_to_project():
    """Add CastarSDK.framework to the Xcode project file"""
    
    print("🔧 Adding CastarSDK.framework to Xcode project...")
    
    # Paths - since we're running from ios directory
    project_file = Path("Runner.xcodeproj") / "project.pbxproj"
    framework_path = Path("Frameworks") / "CastarSDK.framework"
    
    # Check if files exist
    if not project_file.exists():
        print(f"❌ Project file not found: {project_file}")
        return False
    
    if not framework_path.exists():
        print(f"❌ Framework not found: {framework_path}")
        return False
    
    print(f"✅ Found project file: {project_file}")
    print(f"✅ Found framework: {framework_path}")
    
    # Read project file
    with open(project_file, 'r') as f:
        content = f.read()
    
    # Check if framework is already added
    if "CastarSDK.framework" in content:
        print("✅ Framework already in project file")
        return True
    
    # Generate UUIDs for the framework reference
    framework_uuid = generate_uuid()
    build_file_uuid = generate_uuid()
    
    # Create framework reference entry
    framework_ref = f'''		{framework_uuid} /* CastarSDK.framework */ = {{
			isa = PBXFileReference;
			lastKnownFileType = wrapper.framework;
			name = CastarSDK.framework;
			path = Frameworks/CastarSDK.framework;
			sourceTree = "<group>";
		}};'''
    
    # Create build file entry
    build_file = f'''		{build_file_uuid} /* CastarSDK.framework in Frameworks */ = {{
			isa = PBXBuildFile;
			fileRef = {framework_uuid} /* CastarSDK.framework */;
		}};'''
    
    # Find where to insert the framework reference
    # Look for the PBXFileReference section
    file_ref_pattern = r'(/\* Begin PBXFileReference section \*/.*?/\* End PBXFileReference section \*/)'
    match = re.search(file_ref_pattern, content, re.DOTALL)
    
    if not match:
        print("❌ Could not find PBXFileReference section")
        return False
    
    # Insert framework reference before the end of PBXFileReference section
    file_ref_section = match.group(1)
    new_file_ref_section = file_ref_section.replace(
        "/* End PBXFileReference section */",
        f"{framework_ref}\n\t\t/* End PBXFileReference section */"
    )
    
    # Find PBXBuildFile section
    build_file_pattern = r'(/\* Begin PBXBuildFile section \*/.*?/\* End PBXBuildFile section \*/)'
    build_match = re.search(build_file_pattern, content, re.DOTALL)
    
    if not build_match:
        print("❌ Could not find PBXBuildFile section")
        return False
    
    # Insert build file reference
    build_file_section = build_match.group(1)
    new_build_file_section = build_file_section.replace(
        "/* End PBXBuildFile section */",
        f"{build_file}\n\t\t/* End PBXBuildFile section */"
    )
    
    # Find the main group (usually the first PBXGroup)
    group_pattern = r'(/\* Begin PBXGroup section \*/.*?/\* End PBXGroup section \*/)'
    group_match = re.search(group_pattern, content, re.DOTALL)
    
    if not group_match:
        print("❌ Could not find PBXGroup section")
        return False
    
    # Add framework to the main group
    group_section = group_match.group(1)
    # Find the main group that contains the app files
    main_group_pattern = r'(\t\t[A-F0-9]{24} /\* Runner \*/ = \{.*?\n\t\t\};)'
    main_group_match = re.search(main_group_pattern, group_section, re.DOTALL)
    
    if main_group_match:
        main_group = main_group_match.group(1)
        # Add framework reference to the children list
        if "children = (" in main_group:
            new_main_group = main_group.replace(
                "children = (",
                f"children = (\n\t\t\t\t{framework_uuid} /* CastarSDK.framework */,"
            )
            new_group_section = group_section.replace(main_group, new_main_group)
        else:
            print("❌ Could not find children list in main group")
            return False
    else:
        print("❌ Could not find main group")
        return False
    
    # Find the target's frameworks build phase
    frameworks_phase_pattern = r'(/\* Frameworks \*/ = \{.*?\n\t\t\};)'
    frameworks_match = re.search(frameworks_phase_pattern, content, re.DOTALL)
    
    if frameworks_match:
        frameworks_phase = frameworks_match.group(1)
        # Add framework to the files list
        if "files = (" in frameworks_phase:
            new_frameworks_phase = frameworks_phase.replace(
                "files = (",
                f"files = (\n\t\t\t\t{build_file_uuid} /* CastarSDK.framework in Frameworks */,"
            )
        else:
            print("❌ Could not find files list in frameworks phase")
            return False
    else:
        print("❌ Could not find frameworks build phase")
        return False
    
    # Apply all changes
    new_content = content
    new_content = new_content.replace(file_ref_section, new_file_ref_section)
    new_content = new_content.replace(build_file_section, new_build_file_section)
    new_content = new_content.replace(group_section, new_group_section)
    new_content = new_content.replace(frameworks_phase, new_frameworks_phase)
    
    # Write updated project file
    with open(project_file, 'w') as f:
        f.write(new_content)
    
    print("✅ Successfully added CastarSDK.framework to Xcode project")
    print("📝 Framework UUID:", framework_uuid)
    print("📝 Build File UUID:", build_file_uuid)
    
    return True

def add_framework_search_path():
    """Add framework search path to build settings"""
    
    print("🔧 Adding framework search path...")
    
    project_file = Path("Runner.xcodeproj/project.pbxproj")
    
    with open(project_file, 'r') as f:
        content = f.read()
    
    # Look for build configuration sections
    # We need to find the build settings for both Debug and Release configurations
    build_config_pattern = r'(/\* Begin XCBuildConfiguration section \*/.*?/\* End XCBuildConfiguration section \*/)'
    build_config_match = re.search(build_config_pattern, content, re.DOTALL)
    
    if not build_config_match:
        print("❌ Could not find build configuration section")
        return False
    
    build_config_section = build_config_match.group(1)
    
    # Find all build configuration blocks
    config_blocks = re.findall(r'(\t\t[A-F0-9]{24} /\* .*? \*/ = \{.*?\n\t\t\};)', build_config_section, re.DOTALL)
    
    new_content = content
    modified = False
    
    for config_block in config_blocks:
        # Check if this is a build configuration (not a project configuration)
        if "buildSettings = {" in config_block and ("Debug" in config_block or "Release" in config_block):
            print(f"🔧 Processing build configuration: {config_block.split('/*')[1].split('*/')[0].strip()}")
            
            # Check if FRAMEWORK_SEARCH_PATHS already exists
            if "FRAMEWORK_SEARCH_PATHS" in config_block:
                # Update existing FRAMEWORK_SEARCH_PATHS
                if '"$(SRCROOT)/Frameworks"' not in config_block:
                    # Add our path to existing paths
                    new_config_block = re.sub(
                        r'(FRAMEWORK_SEARCH_PATHS = \()(.*?)(\);.*?;)',
                        r'\1\2, "$(SRCROOT)/Frameworks"\3',
                        config_block,
                        flags=re.DOTALL
                    )
                    new_content = new_content.replace(config_block, new_config_block)
                    modified = True
                    print(f"✅ Added framework search path to existing configuration")
            else:
                # Add new FRAMEWORK_SEARCH_PATHS
                new_config_block = config_block.replace(
                    "buildSettings = {",
                    '''buildSettings = {
				FRAMEWORK_SEARCH_PATHS = ("$(SRCROOT)/Frameworks");'''
                )
                new_content = new_content.replace(config_block, new_config_block)
                modified = True
                print(f"✅ Added new framework search path configuration")
    
    if modified:
        with open(project_file, 'w') as f:
            f.write(new_content)
        print("✅ Successfully updated framework search paths in build settings")
        return True
    else:
        print("⚠️ No build configurations were modified")
        print("📋 Framework search paths may need manual configuration")
        return True

def main():
    """Main function"""
    print("🚀 CastarSDK Framework Integration Script")
    print("=" * 50)
    
    success = add_framework_to_project()
    if success:
        add_framework_search_path()
        print("\n✅ Framework integration complete!")
        print("📱 You can now build the project with: flutter build ios --release --no-codesign")
    else:
        print("\n❌ Framework integration failed!")
        return False
    
    return True

if __name__ == "__main__":
    success = main()
    exit(0 if success else 1) 
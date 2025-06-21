#!/usr/bin/env ruby

require 'xcodeproj'

# Path to the Xcode project
project_path = 'Runner.xcodeproj'
project = Xcodeproj::Project.open(project_path)

# Get the main target
target = project.targets.find { |t| t.name == 'Runner' }

# Add the CastarSdk framework
framework_path = 'Frameworks/CastarSdk.framework'
framework_ref = project.new_file(framework_path)

# Add framework to target
target.frameworks_build_phase.add_file_reference(framework_ref)

# Add framework search path
target.build_configurations.each do |config|
  config.build_settings['FRAMEWORK_SEARCH_PATHS'] ||= ['$(inherited)']
  config.build_settings['FRAMEWORK_SEARCH_PATHS'] << '$(SRCROOT)/Frameworks'
end

# Save the project
project.save

puts "CastarSdk.framework has been added to the Xcode project!"
puts "Please open Runner.xcworkspace in Xcode to verify the integration." 
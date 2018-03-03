# Uncomment the next line to define a global platform for your project
platform :ios, '10.0'

target 'Impulse' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

  # Pods for Impulse

  # pod "ResearchSuiteResultsProcessor", :path => '~/Developer/Foundry/ResearchSuite/ios/ResearchSuiteResultsProcessor'
  # pod "sdlrkx", :path => '~/Developer/Foundry/ResearchSuite/ios/sdl-rkx'

  # pod "ResearchSuiteTaskBuilder", "0.4.0"
  # pod "ResearchSuiteResultsProcessor", "0.2.0"
  pod "ResearchSuiteTaskBuilder", :git => 'https://github.com/ResearchSuite/ResearchSuiteTaskBuilder-ios', :tag => '0.10.1'
  pod "ResearchSuiteResultsProcessor", :git => 'https://github.com/ResearchSuite/ResearchSuiteResultsProcessor-ios', :tag => '0.9.0'
  # pod "sdlrkx", "0.13.0"
  # pod "sdlrkx", :path => '~/Developer/ResearchSuite/iOS/sdl-rkx'
  pod "sdlrkx", :git => 'https://github.com/ResearchSuite/sdl-rkx', :tag => 'dmt-2.1'
  pod "ResearchKit", '~> 1.5'
  pod "ReSwift", '~> 3.0'
  pod "ResearchSuiteExtensions", :git => 'https://github.com/ResearchSuite/ResearchSuiteExtensions-iOS', :tag => '0.11.0'
  # pod "ResearchSuiteExtensions",:path => '~/Developer/ResearchSuite/iOS/ResearchSuiteExtensions'

  target 'ImpulseTests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'ImpulseUITests' do
    inherit! :search_paths
    # Pods for testing
  end

end

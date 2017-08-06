# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

workspace 'BluesnapSDKPod'

target 'DemoObjc' do
  # Uncomment the next line if you're using Swift or would like to use dynamic frameworks
  project 'DemoObjc/DemoObjc.xcodeproj'
  use_frameworks!

  # Pods for DemoObjc
  pod 'BluesnapSDK', :path => './BluesnapSDK.podspec'
  pod 'Alamofire', '~> 4.4'

  target 'DemoObjcTests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'DemoObjcUITests' do
    inherit! :search_paths
    # Pods for testing
  end

end

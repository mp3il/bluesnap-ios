Pod::Spec.new do |s|
  s.name         = "BluesnapSDK"
  s.version      = "0.0.1"
  s.summary      = "An iOS SDK for Bluesnap "
  s.description  = <<-DESC
  Integrate payment methods into your iOS native apps quickly and easily.
  Bluesnap iOS SDK supports credit card and apple pay, currency conversions and more.
                  DESC
  s.homepage     = "http://www.bluesnap.com"
  s.license      = { :type => "MIT", :file => "LICENSE.md" }
  s.author             = { "snpori" => "oribsnap@gmail.com" }
  s.platform     = :ios, "9.0"
  s.source       = { :git => "https://github.com/bluesnap/bluesnap-ios.git", :tag => "0.0.1" }
  s.source_files  = "BluesnapSDK/**/*.{h,m,swift}"
  s.resource_bundles = {
    'BluesnapUI' => [
        'BluesnapSDK/**/*.xib',
        'BluesnapSDK/**/*.storyboard',
        'BluesnapSDK/**/Media.xcassets',
    ]
  }
  s.exclude_files = "BluesnapSDK/BluesnapSDKTests/**/*.*"
  s.resources = "BluesnapSDK/**/Media.xcassets"
  s.frameworks                     = 'Foundation', 'Security', 'WebKit', 'PassKit', 'AddressBook', 'UIKit'
  s.weak_frameworks                = 'Contacts'
  s.requires_arc = true
end

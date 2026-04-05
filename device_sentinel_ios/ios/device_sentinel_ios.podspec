#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#
Pod::Spec.new do |s|
  s.name             = 'device_sentinel_ios'
  s.version          = '0.0.1'
  s.summary          = 'An iOS implementation of the device_sentinel plugin.'
  s.description      = <<-DESC
  An iOS implementation of the device_sentinel plugin.
                       DESC
  s.homepage         = 'http://example.com'
  s.license          = { :type => 'BSD', :file => '../LICENSE' }
  s.author           = { 'Com Example Verygoodcore' => 'email@example.com' }
  s.source           = { :path => '.' }  
  s.source_files = 'device_sentinel_ios/Sources/**/*.swift'
  s.dependency 'Flutter'
  s.platform = :ios, '13.0'
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES' }
  s.swift_version = '5.0'
end

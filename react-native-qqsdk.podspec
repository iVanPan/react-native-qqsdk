require 'json'

package = JSON.parse(File.read(File.join(__dir__, 'package.json')))

Pod::Spec.new do |s|
  s.name     = "react-native-qqsdk"
  s.version  = package['version']
  s.summary  = package['description']
  s.homepage = "https://github.com/UnPourTous/react-native-qqsdk.git"
  s.license  = package['license']
  s.author   = package['author']
  s.source   = { :git => "https://github.com/UnPourTous/react-native-qqsdk.git", :tag => "v#{s.version}" }

  s.platform = :ios, "8.0"

  s.preserve_paths = 'README.md', 'LICENSE', 'package.json', 'index.js'
  s.source_files   = "ios/RCTQQSDK/*.{h,m}"
  s.xcconfig = { 'FRAMEWORK_SEARCH_PATHS' => '$(SRCROOT)/../WebankApp/Classes/Lib/QQ' }
  
  s.dependency 'React'
end

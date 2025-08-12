#
# Be sure to run `pod lib lint BCryptSwift.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'WisetailBCryptSwift'
  s.version          = '2.0.0'
  s.summary          = 'A secure, modern Swift implementation of the bcrypt password hashing algorithm.'

  s.description      = <<-DESC
BCryptSwift is a Swift implementation of the bcrypt password hashing algorithm.

Version 2.0 brings major security improvements:
- Uses SecRandomCopyBytes for cryptographically secure random generation
- Implements secure memory cleanup for sensitive data
- Adds constant-time string comparison to prevent timing attacks
- Modern Swift 5+ API with proper error handling
- Async/await support for iOS 13+
- Swift Package Manager support
- Comprehensive test suite with security tests

Features:
- Generate salt with configurable rounds (4-31)
- Hash passwords with bcrypt
- Verify passwords against hashes
- Compatible with bcrypt hashes from other libraries
- Thread-safe implementation
- Full backward compatibility with 1.x API
                       DESC

  s.homepage         = 'https://github.com/wisetail/BCryptSwift'
  s.license          = { :type => 'Apache License, Version 2.0', :file => 'LICENSE' }
  s.author           = { 'Dave Friedel' => 'dave.friedel@wisetail.com' }
  s.source           = { :git => 'https://github.com/wisetail/BCryptSwift.git', :tag => "v#{s.version}" }
  
  s.ios.deployment_target = '12.0'
  # s.tvos.deployment_target = '12.0'  # Temporarily disabled due to simulator issues
  s.osx.deployment_target = '10.13'
  # s.watchos.deployment_target = '5.0'  # Temporarily disabled due to simulator issues

  s.source_files = 'BCryptSwift/Classes/**/*'
  
  s.swift_versions = ['5.0', '5.1', '5.2', '5.3', '5.4', '5.5', '5.6', '5.7', '5.8', '5.9']
  
  s.frameworks = 'Security'
  
  s.requires_arc = true
end

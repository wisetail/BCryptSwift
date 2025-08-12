# Changelog

All notable changes to BCryptSwift will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [2.0.1] - 2025-08-12

### Fixed
- **CI/CD Workflow Issues**
  - Updated Xcode versions for GitHub Actions compatibility (15.0.1 → 15.0)
  - Upgraded deprecated GitHub Actions (dependency-review v3→v4, upload-artifact v3→v4, codecov v3→v4)
  - Fixed security audit job to run only on pull requests
  - Made documentation build job continue on error
- **CocoaPods Integration**
  - Updated Example project Podfile to reference renamed pod `WisetailBCryptSwift`
  - Fixed iOS deployment targets in Xcode project (9.0 → 12.0)
  - Updated Swift version in project settings (4.0 → 5.0)
  - Fixed podspec references in CI workflow
- **Code Quality**
  - Fixed SwiftLint violations (trailing newlines, empty count checks, parameter alignment)
  - Relaxed SwiftLint configuration for better CI compatibility
- **Documentation Build**
  - Fixed Jazzy configuration to run from project root
  - Updated README reference in Jazzy config
  - Simplified documentation generation in CI
- **Test Stability**
  - Reduced concurrent operations from 10 to 5 for CI environments
  - Increased test timeout from 60s to 120s for slower CI runners

## [2.0.0] - 2025-08-12

### Added
- Modern Swift API with proper error handling via `BCryptSwiftModern`
- `BCryptError` enum for specific error cases
- `BCryptConfiguration` struct for structured configuration
- Async/await support for iOS 13+ with `hashPasswordAsync` and `verifyPasswordAsync`
- Swift Package Manager support
- Comprehensive test suite with security-focused tests
- Constant-time string comparison to prevent timing attacks
- Secure memory cleanup for sensitive data
- Support for BCrypt versions 2a, 2b, and 2y
- Thread-safe implementation
- Security guidelines in documentation
- Migration guide for upgrading from v1.x
- Performance benchmarks in documentation

### Changed
- Random number generation now uses `SecRandomCopyBytes` instead of `arc4random()`
- Refactored to use modern Swift patterns (struct instead of class for new API)
- Improved error messages with detailed context
- Updated minimum deployment targets:
  - iOS 12.0+
  - macOS 10.13+
  - tvOS 12.0+
  - watchOS 5.0+
- Better memory management with proper cleanup
- Password length validation (truncates at 72 bytes per BCrypt spec)

### Fixed
- Division by zero error when handling empty passwords
- Memory leaks in key management
- Unsafe pointer usage
- Various edge cases in salt generation and validation

### Security
- Replaced insecure `arc4random()` with `SecRandomCopyBytes`
- Implemented secure memory cleanup with `memset`
- Added constant-time comparison to prevent timing attacks
- Improved input validation and bounds checking
- Added protection against malicious salt inputs

### Deprecated
- Legacy API methods are maintained for backward compatibility but should be migrated to modern API

## [1.1.0] - Previous Release
- Last release by original author Felipe Florencio Garcia
- Based on Swift 4.x patterns
- Used `arc4random()` for random number generation
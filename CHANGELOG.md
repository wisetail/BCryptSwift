# Changelog

All notable changes to BCryptSwift will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [2.0.0] - 2025-01-XX

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
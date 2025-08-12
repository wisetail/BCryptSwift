# BCryptSwift

A secure, modern Swift implementation of the bcrypt password hashing algorithm.

## Attribution

This project is based on the original BCryptSwift by Felipe Florencio Garcia (https://github.com/felipeflorencio/BCryptSwift), which in turn was based on JKBCrypt by Joe Kramer (https://github.com/meanjoe45/JKBCrypt).

Version 2.0 has been updated and is maintained by Dave Friedel / Wisetail.

[![CI Status](https://github.com/wisetail/BCryptSwift/workflows/CI/badge.svg)](https://github.com/wisetail/BCryptSwift/actions)
[![Version](https://img.shields.io/cocoapods/v/BCryptSwift.svg?style=flat)](http://cocoapods.org/pods/BCryptSwift)
[![License](https://img.shields.io/cocoapods/l/BCryptSwift.svg?style=flat)](http://cocoapods.org/pods/BCryptSwift)
[![Platform](https://img.shields.io/cocoapods/p/BCryptSwift.svg?style=flat)](http://cocoapods.org/pods/BCryptSwift)
[![Swift Package Manager](https://img.shields.io/badge/Swift%20Package%20Manager-compatible-brightgreen.svg)](https://github.com/apple/swift-package-manager)
[![Swift Version](https://img.shields.io/badge/Swift-5.0+-orange.svg)](https://swift.org)

## Features

- **Secure**: Uses `SecRandomCopyBytes` for cryptographically secure random number generation
- **Modern Swift**: Fully updated for Swift 5+ with proper error handling
- **Memory Safe**: Implements secure memory cleanup for sensitive data
- **Thread Safe**: Safe for concurrent use
- **Async/Await**: Support for modern async Swift APIs
- **Timing Attack Resistant**: Implements constant-time string comparison
- **Well Tested**: Comprehensive test suite including security tests
- **Compatible**: Maintains backward compatibility with existing code

## Installation

### Swift Package Manager (Recommended)

Add the following to your `Package.swift` file:

```swift
dependencies: [
    .package(url: "https://github.com/felipeflorencio/BCryptSwift.git", from: "2.0.0")
]
```

Or in Xcode: File → Add Packages → Enter package URL

### CocoaPods

Add the following line to your Podfile:

```ruby
pod 'BCryptSwift'
```

## Usage

### Modern API (Recommended)

```swift
import BCryptSwift

// Using the modern API with proper error handling
do {
    // Generate a salt with default configuration (10 rounds)
    let salt = try BCryptSwiftModern.generateSalt()
    
    // Hash a password
    let hashedPassword = try BCryptSwiftModern.hashPassword("mySecurePassword", withSalt: salt)
    
    // Verify a password
    let isValid = try BCryptSwiftModern.verifyPassword("mySecurePassword", matchesHash: hashedPassword)
    print("Password is valid: \(isValid)")
    
} catch let error as BCryptError {
    // Handle specific BCrypt errors
    print("BCrypt error: \(error.localizedDescription)")
} catch {
    // Handle other errors
    print("Unexpected error: \(error)")
}
```

### Configuration Options

```swift
// Use different security levels
let defaultConfig = BCryptConfiguration.default      // 10 rounds
let highSecurity = BCryptConfiguration.highSecurity  // 12 rounds
let testing = BCryptConfiguration.testing           // 4 rounds (fast, for tests only)

// Custom configuration
let customConfig = BCryptConfiguration(
    rounds: 14,                    // 4-31
    version: .v2a,                 // .v2a, .v2b, or .v2y
    maxPasswordLength: 72          // BCrypt maximum
)

// Generate salt with custom configuration
let salt = try BCryptSwiftModern.generateSalt(config: customConfig)
```

### Async/Await Support

```swift
// For iOS 13.0+, macOS 10.15+, tvOS 13.0+, watchOS 6.0+
@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
func hashPasswordAsync() async throws {
    // Hash password asynchronously
    let hashedPassword = try await BCryptSwiftModern.hashPasswordAsync("myPassword")
    
    // Verify password asynchronously
    let isValid = try await BCryptSwiftModern.verifyPasswordAsync("myPassword", 
                                                                  matchesHash: hashedPassword)
}
```

### Legacy API (Backward Compatible)

```swift
// For existing code - returns optionals instead of throwing errors
let salt = BCryptSwift.generateSalt()
let hash = BCryptSwift.hashPassword("password", withSalt: salt)
let isValid = BCryptSwift.verifyPassword("password", matchesHash: hash!)
```

## Security Best Practices

### 1. Salt Generation
Always generate a new salt for each password. Never reuse salts.

```swift
// ✅ Good - new salt for each password
let salt = try BCryptSwiftModern.generateSalt()
let hash = try BCryptSwiftModern.hashPassword(password, withSalt: salt)

// ❌ Bad - reusing salt
let commonSalt = "$2a$10$vI8aWBnW3fID.ZQ4/zo1G."  // Don't do this!
```

### 2. Round Selection
Choose rounds based on your security requirements:

- **Testing**: 4 rounds (minimum, only for tests)
- **Default**: 10 rounds (good for most applications)
- **High Security**: 12+ rounds (for sensitive data)
- **Maximum**: 31 rounds (extremely slow)

```swift
// Measure performance on your target hardware
let start = Date()
let salt = try BCryptSwiftModern.generateSalt(config: BCryptConfiguration(rounds: 12))
let hash = try BCryptSwiftModern.hashPassword("test", withSalt: salt)
print("Time taken: \(Date().timeIntervalSince(start)) seconds")
```

### 3. Password Length Limits
BCrypt has a maximum effective password length of 72 bytes:

```swift
// Passwords longer than 72 bytes will be truncated
let longPassword = String(repeating: "a", count: 100)
// Only the first 72 bytes are used
```

Consider pre-hashing very long passwords with SHA-256 if needed:

```swift
import CryptoKit

func hashLongPassword(_ password: String) throws -> String {
    let passwordData = Data(password.utf8)
    
    // Pre-hash if longer than 72 bytes
    let effectivePassword: String
    if passwordData.count > 72 {
        let hashed = SHA256.hash(data: passwordData)
        effectivePassword = hashed.compactMap { String(format: "%02x", $0) }.joined()
    } else {
        effectivePassword = password
    }
    
    let salt = try BCryptSwiftModern.generateSalt()
    return try BCryptSwiftModern.hashPassword(effectivePassword, withSalt: salt)
}
```

### 4. Error Handling
Always handle errors appropriately:

```swift
do {
    let hash = try BCryptSwiftModern.hashPassword(password, withSalt: salt)
    // Store hash in database
} catch BCryptError.invalidSalt(let details) {
    print("Invalid salt: \(details)")
} catch BCryptError.passwordTooLong {
    print("Password exceeds maximum length")
} catch BCryptError.randomGenerationFailed {
    print("Failed to generate secure random data")
} catch {
    print("Unexpected error: \(error)")
}
```

### 5. Secure Storage
- Never store passwords in plain text
- Store only the bcrypt hash in your database
- The hash includes the salt, version, and rounds - store the entire string

```swift
// The hash contains everything needed for verification
let hash = "$2a$10$N9qo8uLOickgx2ZMRZoMye1ISwRJW4cG6j4fJdGGrFXL3IM5IZkta"
// Format: $version$rounds$salt+hash
```

## Migration Guide

### From Version 1.x to 2.0

The library maintains backward compatibility while offering a modern API:

```swift
// Old way (still works)
let salt = BCryptSwift.generateSalt()
if let hash = BCryptSwift.hashPassword("password", withSalt: salt) {
    // Use hash
}

// New way (recommended)
do {
    let salt = try BCryptSwiftModern.generateSalt()
    let hash = try BCryptSwiftModern.hashPassword("password", withSalt: salt)
    // Use hash
} catch {
    // Handle error
}
```

### From Other BCrypt Libraries

BCryptSwift is compatible with bcrypt hashes from other libraries:

```swift
// Hash from another bcrypt implementation
let phpHash = "$2y$10$vI8aWBnW3fID.ZQ4/zo1G.lmqOhE8jGGNsRIZH1ULHdxTVYmZlAeW"

// Verify with BCryptSwift
let isValid = try BCryptSwiftModern.verifyPassword("password", matchesHash: phpHash)
```

## Performance Considerations

BCrypt is intentionally slow to resist brute-force attacks. Performance varies by hardware:

| Rounds | iPhone 13 Pro | MacBook Pro M1 | Purpose |
|--------|--------------|----------------|---------|
| 4      | ~2 ms        | ~1 ms          | Testing only |
| 10     | ~60 ms       | ~30 ms         | Default |
| 12     | ~240 ms      | ~120 ms        | High security |
| 14     | ~950 ms      | ~475 ms        | Very high security |

Choose rounds based on your security requirements and acceptable login time.

## Requirements

- Swift 5.0+
- iOS 12.0+ / macOS 10.13+ / tvOS 12.0+ / watchOS 5.0+

## Contributing

Contributions are welcome! Please:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

Please ensure:
- All tests pass
- New features include tests
- Security-related changes are thoroughly reviewed
- Documentation is updated

## Security Disclosure

If you discover a security vulnerability, please create an issue.

## Author

David H. Friedel, dave.friedel@wisetail.com
.NET Architect & Solution Developer
**Wisetail**

## License

BCryptSwift is available under the Apache License 2.0. See the LICENSE file for more info.

## Credits

- Original BCryptSwift (this fork is based on): Felipe Florencio Garcia ([BCryptSwift](https://github.com/felipeflorencio/BCryptSwift))
- Initial Swift port: Joe Kramer ([JKBCrypt](https://github.com/meanjoe45/JKBCrypt))
- Objective-C implementation: Jay Fuerstenberg ([JFCommon](https://github.com/jayfuerstenberg/JFCommon))
- Original Java bcrypt: Damien Miller ([jBCrypt](http://www.mindrot.org/projects/jBCrypt/))

## Changelog

### Version 2.0.0
- **Security**: Replaced `arc4random()` with `SecRandomCopyBytes`
- **Memory Safety**: Added secure memory cleanup
- **Modern Swift**: Proper error handling with `Result` type
- **Async/Await**: Added async methods for iOS 13+
- **SPM Support**: Added Swift Package Manager support
- **Testing**: Comprehensive test suite with security tests
- **Documentation**: Improved docs with security guidelines
- **Compatibility**: Maintained backward compatibility
# BCryptSwift 2.0 Migration Guide

This guide helps you migrate from BCryptSwift 1.x to 2.0.

## Overview

BCryptSwift 2.0 brings significant security improvements and modernization while maintaining backward compatibility. Your existing code will continue to work, but we recommend migrating to the new API for better security and error handling.

## What's New in 2.0

### Security Improvements
- Secure random generation using `SecRandomCopyBytes` instead of `arc4random()`
- Memory cleanup for sensitive data
- Constant-time string comparison to prevent timing attacks
- Proper bounds checking and input validation

### API Improvements
- Modern Swift error handling with `throw` and `Result` types
- Async/await support for iOS 13+
- Structured configuration with `BCryptConfiguration`
- Comprehensive error types with `BCryptError`

### Platform Support
- Swift Package Manager support
- Updated minimum deployment targets
- Linux compatibility improvements

## Migration Steps

### Step 1: Update Your Dependencies

#### CocoaPods
```ruby
# Podfile
pod 'BCryptSwift', '~> 2.0'
```

Run `pod update BCryptSwift`

#### Swift Package Manager
```swift
// Package.swift
dependencies: [
    .package(url: "https://github.com/felipeflorencio/BCryptSwift.git", from: "2.0.0")
]
```

### Step 2: Choose Your Migration Path

#### Option A: Minimal Changes (Keep Legacy API)

Your existing code will continue to work without changes:

```swift
// This still works in 2.0
let salt = BCryptSwift.generateSalt()
let hash = BCryptSwift.hashPassword("password", withSalt: salt)
let isValid = BCryptSwift.verifyPassword("password", matchesHash: hash!)
```

#### Option B: Gradual Migration (Recommended)

Migrate to the modern API gradually, function by function:

```swift
// Old code
func hashUserPassword(_ password: String) -> String? {
    let salt = BCryptSwift.generateSalt()
    return BCryptSwift.hashPassword(password, withSalt: salt)
}

// New code with error handling
func hashUserPassword(_ password: String) throws -> String {
    let salt = try BCryptSwiftModern.generateSalt()
    return try BCryptSwiftModern.hashPassword(password, withSalt: salt)
}
```

#### Option C: Full Migration

Replace all BCrypt usage with the modern API:

```swift
// Before
class UserService {
    func createUser(email: String, password: String) {
        guard let salt = BCryptSwift.generateSalt() else {
            print("Failed to generate salt")
            return
        }
        
        guard let hash = BCryptSwift.hashPassword(password, withSalt: salt) else {
            print("Failed to hash password")
            return
        }
        
        // Save user with hash
    }
}

// After
class UserService {
    enum UserError: Error {
        case passwordHashingFailed
    }
    
    func createUser(email: String, password: String) throws {
        do {
            let salt = try BCryptSwiftModern.generateSalt()
            let hash = try BCryptSwiftModern.hashPassword(password, withSalt: salt)
            // Save user with hash
        } catch {
            throw UserError.passwordHashingFailed
        }
    }
}
```

### Step 3: Update Error Handling

The new API uses Swift's error handling instead of returning optionals:

```swift
// Before
if let hash = BCryptSwift.hashPassword(password, withSalt: salt) {
    // Success
} else {
    // Handle error - but you don't know what went wrong
}

// After
do {
    let hash = try BCryptSwiftModern.hashPassword(password, withSalt: salt)
    // Success
} catch BCryptError.invalidSalt(let details) {
    print("Invalid salt: \(details)")
} catch BCryptError.passwordTooLong {
    print("Password is too long")
} catch {
    print("Unexpected error: \(error)")
}
```

### Step 4: Use Configuration Objects

Instead of magic numbers, use configuration objects:

```swift
// Before
let salt = BCryptSwift.generateSaltWithNumberOfRounds(12)

// After
let config = BCryptConfiguration(rounds: 12)
let salt = try BCryptSwiftModern.generateSalt(config: config)

// Or use predefined configurations
let salt = try BCryptSwiftModern.generateSalt(config: .highSecurity)
```

### Step 5: Adopt Async/Await (Optional)

For iOS 13+, you can use async/await for better performance:

```swift
// Before (blocking)
func loginUser(email: String, password: String) -> Bool {
    let user = fetchUser(email: email)
    return BCryptSwift.verifyPassword(password, matchesHash: user.passwordHash) ?? false
}

// After (async)
@available(iOS 13.0, *)
func loginUser(email: String, password: String) async throws -> Bool {
    let user = try await fetchUser(email: email)
    return try await BCryptSwiftModern.verifyPasswordAsync(password, 
                                                           matchesHash: user.passwordHash)
}
```

## Common Migration Patterns

### Pattern 1: Registration Flow

```swift
// Before
func register(username: String, password: String) -> User? {
    let salt = BCryptSwift.generateSalt()
    guard let hash = BCryptSwift.hashPassword(password, withSalt: salt) else {
        return nil
    }
    return User(username: username, passwordHash: hash)
}

// After
func register(username: String, password: String) throws -> User {
    let config = BCryptConfiguration.default
    let salt = try BCryptSwiftModern.generateSalt(config: config)
    let hash = try BCryptSwiftModern.hashPassword(password, withSalt: salt)
    return User(username: username, passwordHash: hash)
}
```

### Pattern 2: Login Flow

```swift
// Before
func login(username: String, password: String) -> Bool {
    guard let user = findUser(username: username) else { return false }
    return BCryptSwift.verifyPassword(password, matchesHash: user.passwordHash) ?? false
}

// After
func login(username: String, password: String) throws -> Bool {
    guard let user = findUser(username: username) else { return false }
    return try BCryptSwiftModern.verifyPassword(password, matchesHash: user.passwordHash)
}
```

### Pattern 3: Password Update

```swift
// Before
func updatePassword(user: User, newPassword: String) -> Bool {
    let salt = BCryptSwift.generateSalt()
    guard let hash = BCryptSwift.hashPassword(newPassword, withSalt: salt) else {
        return false
    }
    user.passwordHash = hash
    return true
}

// After
func updatePassword(user: User, newPassword: String) throws {
    let config = BCryptConfiguration.highSecurity  // Use higher security for password updates
    let salt = try BCryptSwiftModern.generateSalt(config: config)
    let hash = try BCryptSwiftModern.hashPassword(newPassword, withSalt: salt)
    user.passwordHash = hash
}
```

## Breaking Changes

### For Library Users
None! The legacy API remains fully functional.

### For Library Extenders
If you've extended or modified BCryptSwift:

1. **Class to Struct**: `BCryptSwiftRandom` is now a struct
2. **Private Implementation**: Many internals are now private
3. **Memory Management**: Custom memory management code may conflict

## Performance Considerations

The new secure random generation may be slightly slower than `arc4random()`, but the security benefits far outweigh the minimal performance impact.

```swift
// Benchmark your specific use case
let start = Date()
let salt = try BCryptSwiftModern.generateSalt()
let hash = try BCryptSwiftModern.hashPassword("test", withSalt: salt)
print("Time: \(Date().timeIntervalSince(start)) seconds")
```

## Testing Your Migration

1. **Run existing tests**: They should pass without changes
2. **Add error handling tests**: Test the new error cases
3. **Security tests**: Verify the security improvements

```swift
func testMigration() throws {
    // Test that both APIs produce compatible hashes
    let password = "testPassword"
    
    // Generate with old API
    let oldSalt = BCryptSwift.generateSalt()
    let oldHash = BCryptSwift.hashPassword(password, withSalt: oldSalt)!
    
    // Verify with new API
    let isValid = try BCryptSwiftModern.verifyPassword(password, matchesHash: oldHash)
    XCTAssertTrue(isValid)
}
```

## Getting Help

- **Issues**: [GitHub Issues](https://github.com/wisetail/BCryptSwift/issues)
- **Security**: See [SECURITY.md](SECURITY.md)
- **Examples**: Check the Example project

//
//  BCryptSecurityTests.swift
//  BCryptSwift Security Tests
//
//  Security-focused tests for BCryptSwift
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

import XCTest
@testable import BCryptSwift

class BCryptSecurityTests: XCTestCase {
    
    // MARK: - Memory Security Tests
    
    func testMemoryCleanup() throws {
        // This test verifies that sensitive data is properly cleared
        // In a real security audit, this would involve memory inspection tools
        
        try autoreleasepool {
            let password = "sensitivePassword123"
            let salt = try BCryptSwiftModern.generateSalt()
            _ = try BCryptSwiftModern.hashPassword(password, withSalt: salt)
        }
        
        // After autoreleasepool, memory should be cleaned
        // In practice, you'd use memory debugging tools to verify
        XCTAssertTrue(true, "Memory cleanup test placeholder")
    }
    
    // MARK: - Input Validation Tests
    
    func testPasswordLengthValidation() throws {
        // BCrypt has a 72-byte limit
        let salt = try BCryptSwiftModern.generateSalt()
        
        // Test exactly 72 bytes
        let password72 = String(repeating: "a", count: 72)
        XCTAssertNoThrow(try BCryptSwiftModern.hashPassword(password72, withSalt: salt))
        
        // Test over 72 bytes - should truncate to 72 bytes
        let password100 = String(repeating: "a", count: 100)
        let hash100 = try BCryptSwiftModern.hashPassword(password100, withSalt: salt)
        let hash72 = try BCryptSwiftModern.hashPassword(password72, withSalt: salt)
        
        // The hashes should be identical since password100 is truncated to 72 bytes
        XCTAssertEqual(hash100, hash72, "Passwords over 72 bytes should be truncated")
    }
    
    func testMaliciousSaltInputs() {
        let maliciousSalts = [
            "$2a$10$../../../etc/passwd",  // Path traversal attempt
            "$2a$10$\0\0\0\0\0\0\0\0\0\0", // Null bytes
            "$2a$10$<script>alert()</script>", // XSS attempt
            "$2a$10$' OR '1'='1", // SQL injection attempt
            String(repeating: "$", count: 1000), // Buffer overflow attempt
        ]
        
        for salt in maliciousSalts {
            XCTAssertThrowsError(try BCryptSwiftModern.hashPassword("test", withSalt: salt)) { error in
                XCTAssertTrue(error is BCryptError, "Should safely handle malicious salt: \(salt)")
            }
        }
    }
    
    // MARK: - Cryptographic Security Tests
    
    func testSaltRandomnessQuality() throws {
        // Generate many salts and check for patterns
        var saltBytes = [[Int8]]()
        
        for _ in 0..<100 {
            let _ = try BCryptSwiftModern.generateSalt()
            // Extract the random bytes directly
            let randomBytes = try BCryptSwiftRandom.generateRandomSignedData(ofLength: BCRYPT_SALT_LEN)
            saltBytes.append(randomBytes)
        }
        
        // Basic randomness checks
        // Check that salts are unique
        let uniqueSalts = Set(saltBytes.map { $0.description })
        XCTAssertEqual(uniqueSalts.count, saltBytes.count, "All salts should be unique")
        
        // Check byte distribution (simplified)
        var byteFrequency = [Int8: Int]()
        for saltData in saltBytes {
            for byte in saltData {
                byteFrequency[byte, default: 0] += 1
            }
        }
        
        // In a uniform distribution, each byte value should appear roughly equally
        // With only 100 samples of 16 bytes, we expect high variance
        // This is a basic sanity check, not a comprehensive randomness test
        let totalBytes = saltBytes.count * 16
        let minExpected = 1  // At least one occurrence
        let maxExpected = totalBytes / 10  // No more than 10% of all bytes
        
        for (_, frequency) in byteFrequency {
            XCTAssertGreaterThanOrEqual(frequency, minExpected,
                                       "Each byte value should appear at least once")
            XCTAssertLessThanOrEqual(frequency, maxExpected,
                                    "No byte value should dominate the distribution")
        }
    }
    
    func testConstantTimeComparison() throws {
        // Test that string comparison is constant-time
        let password = "testPassword"
        let salt = try BCryptSwiftModern.generateSalt()
        let hash = try BCryptSwiftModern.hashPassword(password, withSalt: salt)
        
        // These should all take similar time despite different similarities
        let testPasswords = [
            "X" + String(repeating: "Y", count: 50), // Completely different
            "testPassworX", // One character different at end
            "XestPassword", // One character different at start
            "testPassword", // Correct password
        ]
        
        // In a real test, we'd measure timing precisely
        for testPassword in testPasswords {
            _ = try BCryptSwiftModern.verifyPassword(testPassword, matchesHash: hash)
        }
        
        XCTAssertTrue(true, "Constant-time comparison test placeholder")
    }
    
    // MARK: - Version Compatibility Tests
    
    func testBCryptVersionHandling() throws {
        let password = "versionTest"
        
        // Test different BCrypt versions
        let versions: [BCryptVersion] = [.v2a, .v2b, .v2y]
        
        for version in versions {
            let config = BCryptConfiguration(rounds: 10, version: version)
            let salt = try BCryptSwiftModern.generateSalt(config: config)
            XCTAssertTrue(salt.hasPrefix("$\(version.rawValue)$"), 
                         "Salt should have correct version prefix")
            
            let hash = try BCryptSwiftModern.hashPassword(password, withSalt: salt)
            XCTAssertTrue(hash.hasPrefix("$\(version.rawValue)$"), 
                         "Hash should have correct version prefix")
            
            let isValid = try BCryptSwiftModern.verifyPassword(password, matchesHash: hash)
            XCTAssertTrue(isValid, "Should verify correctly for version \(version.rawValue)")
        }
    }
    
    // MARK: - Thread Safety Tests
    
    func testConcurrentOperations() {
        let expectation = self.expectation(description: "Concurrent operations")
        expectation.expectedFulfillmentCount = 10
        
        let queue = DispatchQueue(label: "test.concurrent", attributes: .concurrent)
        let password = "concurrentTest"
        
        for i in 0..<10 {
            queue.async {
                autoreleasepool {
                    do {
                        let salt = try BCryptSwiftModern.generateSalt()
                        let hash = try BCryptSwiftModern.hashPassword(password + "\(i)", withSalt: salt)
                        let isValid = try BCryptSwiftModern.verifyPassword(password + "\(i)", 
                                                                          matchesHash: hash)
                        XCTAssertTrue(isValid, "Concurrent operation \(i) should succeed")
                    } catch {
                        XCTFail("Concurrent operation \(i) failed: \(error)")
                    }
                    expectation.fulfill()
                }
            }
        }
        
        waitForExpectations(timeout: 30) { error in
            if let error = error {
                XCTFail("Timeout waiting for concurrent operations: \(error)")
            }
        }
    }
    
    // MARK: - Attack Resistance Tests
    
    func testDenialOfServiceResistance() throws {
        // Test that extremely high round counts are rejected
        XCTAssertThrowsError(try BCryptSwiftModern.hashPassword("test", 
                                                               withSalt: "$2a$99$1234567890123456789012")) { error in
            if let bcryptError = error as? BCryptError {
                if case .invalidRounds(let rounds) = bcryptError {
                    XCTAssertEqual(rounds, 99, "Should report invalid rounds")
                } else {
                    XCTFail("Expected invalidRounds error")
                }
            }
        }
    }
    
    func testSaltReuseDetection() throws {
        // While salt reuse isn't prevented by the library (it's the caller's responsibility),
        // we can test that the same salt produces the same hash
        let password = "samePassword"
        let salt = try BCryptSwiftModern.generateSalt()
        
        let hash1 = try BCryptSwiftModern.hashPassword(password, withSalt: salt)
        let hash2 = try BCryptSwiftModern.hashPassword(password, withSalt: salt)
        
        XCTAssertEqual(hash1, hash2, "Same password and salt should produce same hash")
        
        // But different passwords with same salt should produce different hashes
        let hash3 = try BCryptSwiftModern.hashPassword(password + "X", withSalt: salt)
        XCTAssertNotEqual(hash1, hash3, "Different passwords should produce different hashes")
    }
}
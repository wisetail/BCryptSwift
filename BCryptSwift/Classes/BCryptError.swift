//
//  BCryptError.swift
//  BCryptSwift
//
//  Created for BCryptSwift security improvements
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

import Foundation

/// Errors that can occur during BCrypt operations
public enum BCryptError: LocalizedError {
    /// The salt format is invalid
    case invalidSalt(String)
    
    /// The number of rounds is outside the valid range (4-31)
    case invalidRounds(Int)
    
    /// The salt version is not supported
    case invalidVersion(String)
    
    /// The salt revision is not supported
    case invalidRevision(Character)
    
    /// The password is too long (max 72 bytes for bcrypt)
    case passwordTooLong
    
    /// Failed to generate secure random data
    case randomGenerationFailed
    
    /// The hashing operation failed
    case hashingFailed
    
    /// Memory allocation failed
    case memoryAllocationFailed
    
    /// The hash format is invalid
    case invalidHashFormat
    
    public var errorDescription: String? {
        switch self {
        case .invalidSalt(let details):
            return "Invalid salt format: \(details)"
        case .invalidRounds(let rounds):
            return "Invalid number of rounds: \(rounds). Must be between 4 and 31."
        case .invalidVersion(let version):
            return "Invalid BCrypt version: \(version)"
        case .invalidRevision(let revision):
            return "Invalid salt revision: \(revision)"
        case .passwordTooLong:
            return "Password exceeds maximum length of 72 bytes"
        case .randomGenerationFailed:
            return "Failed to generate secure random data"
        case .hashingFailed:
            return "Password hashing operation failed"
        case .memoryAllocationFailed:
            return "Failed to allocate required memory"
        case .invalidHashFormat:
            return "The provided hash has an invalid format"
        }
    }
}

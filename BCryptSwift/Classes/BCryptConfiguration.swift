//
//  BCryptConfiguration.swift
//  BCryptSwift
//
//  Configuration for BCrypt operations
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

/// BCrypt version types
public enum BCryptVersion: String {
    case v2a = "2a"
    case v2b = "2b"
    case v2y = "2y"
    
    var prefix: String {
        return "$\(rawValue)$"
    }
}

/// Configuration for BCrypt operations
public struct BCryptConfiguration {
    /// The cost factor (number of rounds). Must be between 4 and 31.
    public let rounds: UInt
    
    /// The BCrypt version to use
    public let version: BCryptVersion
    
    /// Maximum password length in bytes (bcrypt limit is 72)
    public let maxPasswordLength: Int
    
    /// Default configuration with 10 rounds
    public static let `default` = BCryptConfiguration(rounds: 10)
    
    /// Configuration for high security (12 rounds)
    public static let highSecurity = BCryptConfiguration(rounds: 12)
    
    /// Configuration for testing (4 rounds - minimum allowed)
    public static let testing = BCryptConfiguration(rounds: 4)
    
    public init(rounds: UInt = 10, version: BCryptVersion = .v2a, maxPasswordLength: Int = 72) {
        self.rounds = min(max(rounds, 4), 31)
        self.version = version
        self.maxPasswordLength = min(maxPasswordLength, 72)
    }
}

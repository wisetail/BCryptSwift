//
//  BCryptSwiftModern.swift
//  BCryptSwift
//
//  Modern, secure implementation of BCrypt
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
import Security

/// Modern BCrypt implementation with improved security and Swift patterns
public struct BCryptSwiftModern {
    
    // MARK: - Public API
    
    /// Generate a salt with the specified configuration
    /// - Parameter config: The BCrypt configuration
    /// - Returns: A properly formatted BCrypt salt
    /// - Throws: BCryptError if salt generation fails
    public static func generateSalt(config: BCryptConfiguration = .default) throws -> String {
        let randomData = try BCryptSwiftRandom.generateRandomSignedData(ofLength: BCRYPT_SALT_LEN)
        
        var salt = config.version.prefix
        salt += String(format: "%02u", config.rounds) + "$"
        salt += encodeData(randomData, ofLength: UInt(randomData.count))
        
        return salt
    }
    
    /// Hash a password using the provided salt
    /// - Parameters:
    ///   - password: The password to hash
    ///   - salt: The salt to use
    /// - Returns: The hashed password
    /// - Throws: BCryptError if hashing fails
    public static func hashPassword(_ password: String, withSalt salt: String) throws -> String {
        let result = try processPassword(password, salt: salt)
        return result
    }
    
    /// Verify a password against a hash
    /// - Parameters:
    ///   - password: The password to verify
    ///   - hash: The hash to verify against
    /// - Returns: True if the password matches, false otherwise
    /// - Throws: BCryptError if verification fails
    public static func verifyPassword(_ password: String, matchesHash hash: String) throws -> Bool {
        let computedHash = try hashPassword(password, withSalt: hash)
        return constantTimeCompare(computedHash, hash)
    }
    
    /// Hash a password asynchronously
    /// - Parameters:
    ///   - password: The password to hash
    ///   - config: The BCrypt configuration
    /// - Returns: The hashed password
    /// - Throws: BCryptError if hashing fails
    @available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
    public static func hashPasswordAsync(_ password: String, config: BCryptConfiguration = .default) async throws -> String {
        return try await withCheckedThrowingContinuation { continuation in
            Task {
                do {
                    let salt = try generateSalt(config: config)
                    let hash = try hashPassword(password, withSalt: salt)
                    continuation.resume(returning: hash)
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    /// Verify a password asynchronously
    /// - Parameters:
    ///   - password: The password to verify
    ///   - hash: The hash to verify against
    /// - Returns: True if the password matches, false otherwise
    /// - Throws: BCryptError if verification fails
    @available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
    public static func verifyPasswordAsync(_ password: String, matchesHash hash: String) async throws -> Bool {
        return try await withCheckedThrowingContinuation { continuation in
            Task {
                do {
                    let result = try verifyPassword(password, matchesHash: hash)
                    continuation.resume(returning: result)
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    // MARK: - Private Implementation
    
    private static func processPassword(_ password: String, salt: String) throws -> String {
        // Validate salt format
        guard !salt.isEmpty else {
            throw BCryptError.invalidSalt("Salt is empty")
        }
        
        guard salt.count >= 28 else {
            throw BCryptError.invalidSalt("Salt too short: \(salt.count) characters")
        }
        
        guard salt.hasPrefix("$") else {
            throw BCryptError.invalidSalt("Missing $ prefix")
        }
        
        // Parse salt components
        let components = salt.dropFirst().split(separator: "$", maxSplits: 2)
        guard components.count >= 2 else {
            throw BCryptError.invalidSalt("Invalid format")
        }
        
        // Extract version
        let versionStr = String(components[0])
        guard let version = BCryptVersion(rawValue: versionStr) else {
            throw BCryptError.invalidVersion(versionStr)
        }
        
        // Extract rounds
        let roundsStr = String(components[1].prefix(2))
        guard let rounds = Int(roundsStr), rounds >= 4, rounds <= 31 else {
            throw BCryptError.invalidRounds(Int(roundsStr) ?? -1)
        }
        
        // Extract actual salt
        let saltStartIndex = salt.index(salt.startIndex, offsetBy: version.prefix.count + 3)
        let saltEndIndex = salt.index(saltStartIndex, offsetBy: 22)
        let realSalt = String(salt[saltStartIndex..<saltEndIndex])
        
        // Prepare password data
        var passwordData = Array(password.utf8)
        if version != .v2a {
            passwordData.append(0) // null terminator for 2b/2y
        }
        
        // BCrypt has a 72-byte limit, truncate if necessary
        if passwordData.count > 72 {
            passwordData = Array(passwordData.prefix(72))
        }
        
        let passwordBytes = passwordData.map { Int8(bitPattern: $0) }
        let saltBytes = decode_base64(realSalt, ofMaxLength: BCRYPT_SALT_LEN)
        
        // Perform hashing
        let hasher = BCryptHasher()
        guard let hashedData = try hasher.hashPassword(passwordBytes, withSalt: saltBytes, numberOfRounds: rounds) else {
            throw BCryptError.hashingFailed
        }
        
        // Build result
        var result = version.prefix
        result += String(format: "%02u", rounds) + "$"
        result += encodeData(saltBytes, ofLength: UInt(saltBytes.count))
        result += encodeData(hashedData, ofLength: 23)
        
        return result
    }
    
    /// Constant-time string comparison to prevent timing attacks
    private static func constantTimeCompare(_ a: String, _ b: String) -> Bool {
        let aBytes = Array(a.utf8)
        let bBytes = Array(b.utf8)
        
        guard aBytes.count == bBytes.count else { return false }
        
        var result = 0
        for i in 0..<aBytes.count {
            result |= Int(aBytes[i] ^ bBytes[i])
        }
        
        return result == 0
    }
    
    // MARK: - Base64 Encoding/Decoding
    
    private static func encodeData(_ data: [Int8], ofLength length: UInt) -> String {
        guard !data.isEmpty, length > 0 else {
            return ""
        }
        
        let len = min(Int(length), data.count)
        var offset = 0
        var result = ""
        
        let dataArray = data.map { UInt8(bitPattern: $0) }
        
        while offset < len {
            let c1 = dataArray[offset] & 0xff
            offset += 1
            result.append(base64_code[Int((c1 >> 2) & 0x3f)])
            var c1_remainder = (c1 & 0x03) << 4
            
            if offset >= len {
                result.append(base64_code[Int(c1_remainder & 0x3f)])
                break
            }
            
            let c2 = dataArray[offset] & 0xff
            offset += 1
            c1_remainder |= (c2 >> 4) & 0x0f
            result.append(base64_code[Int(c1_remainder & 0x3f)])
            var c2_remainder = (c2 & 0x0f) << 2
            
            if offset >= len {
                result.append(base64_code[Int(c2_remainder & 0x3f)])
                break
            }
            
            let c3 = dataArray[offset] & 0xff
            offset += 1
            c2_remainder |= (c3 >> 6) & 0x03
            result.append(base64_code[Int(c2_remainder & 0x3f)])
            result.append(base64_code[Int(c3 & 0x3f)])
        }
        
        return result
    }
    
    private static func decode_base64(_ s: String, ofMaxLength maxolen: Int) -> [Int8] {
        var off = 0
        let slen = s.count
        var olen = 0
        var result = [Int8](repeating: 0, count: maxolen)
        
        let chars = Array(s)
        
        while off < slen - 1 && olen < maxolen {
            let c1 = char64of(chars[off])
            off += 1
            let c2 = char64of(chars[off])
            off += 1
            
            if c1 == -1 || c2 == -1 { break }
            
            result[olen] = (c1 << 2) | ((c2 & 0x30) >> 4)
            olen += 1
            
            if olen >= maxolen || off >= slen { break }
            
            let c3 = char64of(chars[off])
            off += 1
            if c3 == -1 { break }
            
            result[olen] = ((c2 & 0x0f) << 4) | ((c3 & 0x3c) >> 2)
            olen += 1
            
            if olen >= maxolen || off >= slen { break }
            
            let c4 = char64of(chars[off])
            off += 1
            
            result[olen] = ((c3 & 0x03) << 6) | c4
            olen += 1
        }
        
        return Array(result.prefix(olen))
    }
    
    private static func char64of(_ x: Character) -> Int8 {
        guard let scalar = x.unicodeScalars.first else { return -1 }
        let value = Int(scalar.value)
        
        if value < 0 || value >= index_64.count {
            return -1
        }
        
        return index_64[value]
    }
}

// MARK: - Internal Hasher Implementation

private final class BCryptHasher {
    private var p: UnsafeMutablePointer<Int32>?
    private var s: UnsafeMutablePointer<Int32>?
    
    deinit {
        cleanupMemory()
    }
    
    func hashPassword(_ password: [Int8], withSalt salt: [Int8], numberOfRounds: Int) throws -> [Int8]? {
        guard numberOfRounds >= 4, numberOfRounds <= 31 else {
            throw BCryptError.invalidRounds(numberOfRounds)
        }
        
        let rounds = 1 << numberOfRounds
        guard salt.count == 16 else {
            throw BCryptError.invalidSalt("Salt must be 16 bytes")
        }
        
        try initKey()
        enhanceKeySchedule(data: salt, key: password)
        
        for _ in 0..<rounds {
            key(password)
            key(salt)
        }
        
        var cdata = bf_crypt_ciphertext
        for _ in 0..<64 {
            for j in stride(from: 0, to: cdata.count, by: 2) {
                encipher(&cdata, off: j)
            }
        }
        
        var result = [Int8](repeating: 0, count: cdata.count * 4)
        var j = 0
        for i in 0..<cdata.count {
            result[j] = Int8(truncatingIfNeeded: (cdata[i] >> 24) & 0xff)
            result[j + 1] = Int8(truncatingIfNeeded: (cdata[i] >> 16) & 0xff)
            result[j + 2] = Int8(truncatingIfNeeded: (cdata[i] >> 8) & 0xff)
            result[j + 3] = Int8(truncatingIfNeeded: cdata[i] & 0xff)
            j += 4
        }
        
        cleanupMemory()
        return result
    }
    
    private func initKey() throws {
        cleanupMemory()
        
        p = UnsafeMutablePointer<Int32>.allocate(capacity: P_orig.count)
        s = UnsafeMutablePointer<Int32>.allocate(capacity: S_orig.count)
        
        guard let p = p, let s = s else {
            throw BCryptError.memoryAllocationFailed
        }
        
        p.initialize(from: P_orig, count: P_orig.count)
        s.initialize(from: S_orig, count: S_orig.count)
    }
    
    private func cleanupMemory() {
        if let p = p {
            // Securely clear memory before deallocation
            memset(p, 0, P_orig.count * MemoryLayout<Int32>.size)
            p.deinitialize(count: P_orig.count)
            p.deallocate()
            self.p = nil
        }
        
        if let s = s {
            // Securely clear memory before deallocation
            memset(s, 0, S_orig.count * MemoryLayout<Int32>.size)
            s.deinitialize(count: S_orig.count)
            s.deallocate()
            self.s = nil
        }
    }
    
    private func encipher(_ lr: UnsafeMutablePointer<Int32>, off: Int) {
        guard let p = p, let s = s else { return }
        
        var l = lr[off]
        var r = lr[off + 1]
        
        l ^= p[0]
        
        for i in stride(from: 0, to: BLOWFISH_NUM_ROUNDS, by: 2) {
            // Feistel substitution on left word
            var n = s[Int((l >> 24) & 0xff)]
            n = n &+ s[0x100 | Int((l >> 16) & 0xff)]
            n ^= s[0x200 | Int((l >> 8) & 0xff)]
            n = n &+ s[0x300 | Int(l & 0xff)]
            r ^= n ^ p[i + 1]
            
            // Feistel substitution on right word
            n = s[Int((r >> 24) & 0xff)]
            n = n &+ s[0x100 | Int((r >> 16) & 0xff)]
            n ^= s[0x200 | Int((r >> 8) & 0xff)]
            n = n &+ s[0x300 | Int(r & 0xff)]
            l ^= n ^ p[i + 2]
        }
        
        lr[off] = r ^ p[BLOWFISH_NUM_ROUNDS + 1]
        lr[off + 1] = l
    }
    
    private func key(_ key: [Int8]) {
        guard let p = p, let s = s else { return }
        
        var koffp: Int32 = 0
        var lr: [Int32] = [0, 0]
        
        key.withUnsafeBufferPointer { keyBuffer in
            guard let keyPointer = keyBuffer.baseAddress else { return }
            let keyLength = key.count
            
            for i in 0..<P_orig.count {
                p[i] = p[i] ^ streamToWord(data: UnsafeMutablePointer(mutating: keyPointer), length: keyLength, off: &koffp)
            }
        }
        
        for i in stride(from: 0, to: P_orig.count, by: 2) {
            encipher(&lr, off: 0)
            p[i] = lr[0]
            p[i + 1] = lr[1]
        }
        
        for i in stride(from: 0, to: S_orig.count, by: 2) {
            encipher(&lr, off: 0)
            s[i] = lr[0]
            s[i + 1] = lr[1]
        }
    }
    
    private func enhanceKeySchedule(data: [Int8], key: [Int8]) {
        guard let p = p, let s = s else { return }
        
        var koffp: Int32 = 0
        var doffp: Int32 = 0
        var lr: [Int32] = [0, 0]
        
        key.withUnsafeBufferPointer { keyBuffer in
            data.withUnsafeBufferPointer { dataBuffer in
                guard let keyPointer = keyBuffer.baseAddress,
                      let dataPointer = dataBuffer.baseAddress else { return }
                
                let keyLength = key.count
                let dataLength = data.count
                
                for i in 0..<P_orig.count {
                    p[i] = p[i] ^ streamToWord(data: UnsafeMutablePointer(mutating: keyPointer), length: keyLength, off: &koffp)
                }
                
                for i in stride(from: 0, to: P_orig.count, by: 2) {
                    lr[0] ^= streamToWord(data: UnsafeMutablePointer(mutating: dataPointer), length: dataLength, off: &doffp)
                    lr[1] ^= streamToWord(data: UnsafeMutablePointer(mutating: dataPointer), length: dataLength, off: &doffp)
                    encipher(&lr, off: 0)
                    p[i] = lr[0]
                    p[i + 1] = lr[1]
                }
                
                for i in stride(from: 0, to: S_orig.count, by: 2) {
                    lr[0] ^= streamToWord(data: UnsafeMutablePointer(mutating: dataPointer), length: dataLength, off: &doffp)
                    lr[1] ^= streamToWord(data: UnsafeMutablePointer(mutating: dataPointer), length: dataLength, off: &doffp)
                    encipher(&lr, off: 0)
                    s[i] = lr[0]
                    s[i + 1] = lr[1]
                }
            }
        }
    }
    
    private func streamToWord(data: UnsafeMutablePointer<Int8>, length: Int, off: inout Int32) -> Int32 {
        var word: Int32 = 0
        var offset = off
        
        // Guard against empty data which would cause division by zero
        guard length > 0 else {
            return 0
        }
        
        for _ in 0..<4 {
            word = (word << 8) | (Int32(data[Int(offset)]) & 0xff)
            offset = (offset + 1) % Int32(length)
        }
        
        off = offset
        return word
    }
}

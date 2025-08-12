# BCryptSwift

BCryptSwift is an implementation of bcrypt written in Swift. It currently is able to generate the salt and hash a phrase using a generated salt.

## Attribution

This project is based on the original BCryptSwift by Felipe Florencio Garcia (https://github.com/felipeflorencio/BCryptSwift), which in turn was based on JKBCrypt by Joe Kramer (https://github.com/meanjoe45/JKBCrypt).

Version 2.0 has been updated and is maintained by Dave Friedel / Wisetail.


[![CI Status](http://img.shields.io/travis/fatface/BCryptSwift.svg?style=flat)](https://travis-ci.org/fatface/BCryptSwift)
[![Version](https://img.shields.io/cocoapods/v/BCryptSwift.svg?style=flat)](http://cocoapods.org/pods/BCryptSwift)
[![License](https://img.shields.io/cocoapods/l/BCryptSwift.svg?style=flat)](http://cocoapods.org/pods/BCryptSwift)
[![Platform](https://img.shields.io/cocoapods/p/BCryptSwift.svg?style=flat)](http://cocoapods.org/pods/BCryptSwift)

## Using the Code

```
BCryptSwift.generateSaltWithNumberOfRounds(rounds: UInt) -> String
BCryptSwift.generateSalt() -> String
BCryptSwift.hashPassword(password: String, withSalt salt: String) -> String?
BCryptSwift.verifyPassword(password: String, matchesHash hash: String) -> Bool?
```

The `generateSaltWithNumberOfRounds()` class function will generate a random salt using the number of rounds provided. The number of rounds must be between 4 and 31 inclusively.

The `generateSalt()` class convenience function will generate a random salt using a default 10 rounds. This number can be adjusted based on your specific needs.

The `hashPassword(withSalt:)` class function will hash the password phrase using the salt. If there is an issue during processing, nil will be returned. Check the function documentation for details.

The `verifyPassword(matchesHash:)` class convenience function will hash the password phrase using the hash, then return the comparison between the new hash and the given hash. If there is an issue during processing, nil will be returned. Check the function documentation for details.

## Example

There is an example Xcode project that uses the BCryptSwift functions to calculate salts, hashes, and compare hashes. See the example project for a better understanding on how to use the functions.

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

Swift 4.0 or higher.

## Installation

BCryptSwift is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "BCryptSwift"
```

## Roadmap

### Testing

TO-DO
Provide suitable unit tests for the functions in the `BCryptSwift` and `BCryptSwiftRandom` classes.

## Issues, Bugs, etc.

If you have any issues, bugs, or feature suggestions, please create an issue.

## Refactored By

David H. Friedel, dave.friedel@wisetail.com
.NET Architect & Solution Developer
**Wisetail**

For technical support, feature requests, or enterprise inquiries, please contact the development team.

## License

Apache License Version 2.0

## Credits

- Original BCryptSwift (this fork is based on): Felipe Florencio Garcia ([BCryptSwift](https://github.com/felipeflorencio/BCryptSwift))
- Initial Swift port: Joe Kramer ([JKBCrypt](https://github.com/meanjoe45/JKBCrypt))
- Objective-C implementation: Jay Fuerstenberg ([JFCommon](https://github.com/jayfuerstenberg/JFCommon))
- Original Java bcrypt: Damien Miller ([jBCrypt](http://www.mindrot.org/projects/jBCrypt/))

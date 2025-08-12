# Security Policy

## Supported Versions

| Version | Supported          |
| ------- | ------------------ |
| 2.0.x   | :white_check_mark: |
| 1.1.x   | :x:                |
| < 1.1   | :x:                |

## Reporting a Vulnerability

We take the security of BCryptSwift seriously. If you believe you have found a security vulnerability, please report it to us as described below.

**Please do not report security vulnerabilities through public GitHub issues.**

Instead, please report them via email to: felipeflorencio@me.com

You should receive a response within 48 hours. If for some reason you do not, please follow up via email to ensure we received your original message.

Please include the following information:

- Type of issue (e.g., buffer overflow, timing attack, etc.)
- Full paths of source file(s) related to the issue
- The location of the affected source code (tag/branch/commit or direct URL)
- Any special configuration required to reproduce the issue
- Step-by-step instructions to reproduce the issue
- Proof-of-concept or exploit code (if possible)
- Impact of the issue, including how an attacker might exploit it

## Security Considerations

### Password Storage
- Never store passwords in plain text
- Store only the bcrypt hash
- Each password should have a unique salt
- Consider the 72-byte password length limit

### Timing Attacks
BCryptSwift implements constant-time string comparison to prevent timing attacks during password verification.

### Memory Security
Version 2.0+ implements secure memory cleanup to ensure sensitive data is properly cleared after use.

### Random Number Generation
Version 2.0+ uses `SecRandomCopyBytes` for cryptographically secure random number generation.

### Round Selection
- Minimum: 4 rounds (testing only)
- Default: 10 rounds
- High Security: 12+ rounds
- Maximum: 31 rounds

Choose based on your security requirements and acceptable performance.

## Security Updates

Security updates will be released as patch versions (e.g., 2.0.1, 2.0.2) and will be backward compatible.

Subscribe to repository notifications to stay informed about security updates.

## Best Practices

1. **Always use unique salts**: Generate a new salt for each password
2. **Handle errors properly**: Don't expose error details to end users
3. **Monitor performance**: Higher rounds = better security but slower performance
4. **Update regularly**: Keep BCryptSwift updated to the latest version
5. **Audit dependencies**: BCryptSwift has no external dependencies, reducing attack surface

## Known Limitations

1. **72-byte limit**: BCrypt truncates passwords longer than 72 bytes
2. **Unicode handling**: Different Unicode normalization can produce different hashes
3. **Side channels**: While we implement timing attack resistance, other side channels may exist

## Security Audit

BCryptSwift has not undergone a formal security audit. If you're using it for critical applications, consider:

1. Conducting your own security review
2. Sponsoring a professional security audit
3. Using defense in depth with additional security measures

## Acknowledgments

We appreciate security researchers who responsibly disclose vulnerabilities. Contributors will be acknowledged here (with permission) after fixes are released.
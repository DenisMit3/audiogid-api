# Keystore Setup

The automatic generation of the keystore might have failed. Please generate it manually using the following command (replace placeholders with your actual passwords):

```bash
cd apps/mobile_flutter/android
keytool -genkey -v -keystore audiogid-release.jks -keyalg RSA -keysize 2048 -validity 10000 -alias audiogid -storepass <YOUR_KEYSTORE_PASSWORD> -keypass <YOUR_KEY_PASSWORD> -dname "CN=Audiogid, OU=Dev, O=Audiogid, L=Unknown, S=Unknown, C=US"
```

**Environment Variables:**
Instead of hardcoding passwords, the signing configuration uses the following environment variables:
- `KEYSTORE_PASSWORD`: The password for the keystore.
- `KEY_PASSWORD`: The password for the key.
- `KEY_ALIAS`: The alias for the key (default: audiogid).

**Actions Required:**
1. Run the command above with your secure passwords.
2. Add the passwords to your CI/CD secrets (e.g., GitHub Secrets) as `KEYSTORE_PASSWORD` and `KEY_PASSWORD`.
3. Generate Base64 of the keystore to use in CI/CD secrets (`KEYSTORE_BASE64`):
   ```bash
   openssl base64 < apps/mobile_flutter/android/audiogid-release.jks | tr -d '\n' | pbcopy
   ```
   (On Windows, use `certutil -encode` or a similar tool to get the base64 string).
4. **Secure the keystore file**: Do not commit `audiogid-release.jks` to the repository. It is already in `.gitignore`.

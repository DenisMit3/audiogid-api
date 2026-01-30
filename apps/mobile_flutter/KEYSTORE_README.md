# Keystore Setup

The automatic generation of the keystore might have failed. Please generate it manually using the following command:

```bash
cd apps/mobile_flutter/android
keytool -genkey -v -keystore audiogid-release.jks -keyalg RSA -keysize 2048 -validity 10000 -alias audiogid -storepass changeit123 -keypass changeit123 -dname "CN=Audiogid, OU=Dev, O=Audiogid, L=Unknown, S=Unknown, C=US"
```

**Passwords:**
- KEYSTORE_PASSWORD: changeit123
- KEY_PASSWORD: changeit123

**Actions Required:**
1. Run the command above.
2. Add the passwords to GitHub Secrets (`KEYSTORE_PASSWORD`, `KEY_PASSWORD`).
3. Generate Base64 of the keystore and add to GitHub Secrets (`KEYSTORE_BASE64`):
   ```bash
   openssl base64 < apps/mobile_flutter/android/audiogid-release.jks | tr -d '\n' | pbcopy
   ```
4. Move the keystore file to a safe location (it is gitignored, but better safe than sorry).

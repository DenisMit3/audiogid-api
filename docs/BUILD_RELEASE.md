# Release Build Instructions

Since the build environment (Flutter/Java) was not automatically detected, please follow these steps manually to generate the release build.

## 1. Generate Keystore
Run the following command in the `apps/mobile_flutter/android` directory to generate the release keystore:

```bash
cd apps/mobile_flutter/android
keytool -genkey -v -keystore audiogid-release.jks -alias audiogid -keyalg RSA -keysize 2048 -validity 10000 -storepass password -keypass password
```

*Note: You can change the password, but make sure to update `apps/mobile_flutter/android/key.properties` to match.*

## 2. Build Release APK
Run the Flutter build command from the `apps/mobile_flutter` directory:

```bash
cd apps/mobile_flutter
flutter build apk --release --flavor prod
```

This will generate optimized APKs (per architecture) in `build/app/outputs/apk/prod/release/`.

## 3. Deployment
Make sure fastlane is configured (Fastfile has been updated). You can run:

```bash
cd apps/mobile_flutter/android
fastlane production
```

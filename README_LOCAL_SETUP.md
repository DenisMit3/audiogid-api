# 🛠️ Audiogid Local Setup Instructions

The codebase is fully prepared, but some steps require local Flutter tools which were not available in the agent environment.

Please run the following commands in your terminal to finalize the setup:

## 1. Setup Flutter Project

Navigate to the mobile app directory:
```bash
cd apps/mobile_flutter
flutter pub get
```

## 2. Generate Code (Crucial)

This generates database (Drift) and routing code. The app **will not compile** without this.
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

## 3. Generate App Icons

A high-quality icon asset has been generated for you at `assets/store/icon.png`. Now generate the platform-specific icons:
```bash
flutter pub run flutter_launcher_icons
```

## 4. Firebase Configuration (iOS)

A placeholder `ios/Runner/GoogleService-Info.plist` has been created.
1. Download the *real* `GoogleService-Info.plist` from your Firebase Console.
2. Replace the file in `ios/Runner/`.

## 5. Android Keystore (For Release)

Generate a release keystore if you haven't already:
```bash
keytool -genkey -v -keystore audiogid-release.jks -keyalg RSA -keysize 2048 -validity 10000 -alias audiogid
```

## 6. Run the App

```bash
flutter run
```

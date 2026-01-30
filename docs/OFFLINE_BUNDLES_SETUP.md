# Offline Bundles Implementation

This document outlines the changes made to implement offline bundles.

## 1. Dependencies Added
- `flutter_downloader`
- `archive`
- `crypto`

## 2. Configuration
- **Android**: `AndroidManifest.xml` updated permissions and added `DownloadedFileProvider`.
- **iOS**: `Info.plist` added `fetch` background mode.

## 3. Architecture
- **DownloadService**: Handles requesting builds, polling, downloading, extracting, and verifying bundles.
- **StorageManager**: Helper for checking storage.
- **OfflineManagerScreen**: Management UI.

## 4. Database
- Added `localPath` to `Media` table.
- Bumped schema version to 7.

## 5. Next Steps
Since the agent shell environment did not have `flutter` in PATH:

1.  Run `flutter pub get` in `apps/mobile_flutter`.
2.  Run `flutter pub run build_runner build --delete-conflicting-outputs` to generate Riverpod and Drift providers.
3.  Rebuild the app to apply Android Manifest changes.

## 6. Usage
- Navigate to `/offline-manager` (added to router).
- Select a city to download.

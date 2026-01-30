# Audiogid Mobile (Flutter)

This is the Flutter implementation of the Audiogid mobile application.

## Architecture

The project follows a Clean Architecture approach with a focus on Riverpod for state management and DI:
- `lib/core`: App configuration, routing (GoRouter), theme, and API providers.
- `lib/domain`: Business logic entities and repository interfaces.
- `lib/data`: Data source implementations, including API repositories and local storage (Drift).
- `lib/presentation`: UI components, screens, and state providers.

## Getting Started

1.  **Dependencies**:
    Run `flutter pub get` to install dependencies.

2.  **Code Generation**:
    Run the following command to generate Riverpod and Drift code:
    ```bash
    dart run build_runner build --delete-conflicting-outputs
    ```

3.  **Flavors**:
    The app supports three flavors: `dev`, `staging`, and `prod`.
    To run with a specific flavor:
    ```bash
    flutter run --dart-define=FLAVOR=dev
    ```

## Project Structure
- `lib/core/api`: Dio and ApiClient configuration.
- `lib/core/config`: Flavor-based configuration.
- `lib/core/router`: GoRouter navigation setup.
- `lib/core/theme`: Material 3 theme.
- `lib/data/local`: Drift database for local caching.
- `lib/data/repositories`: Implementation of domain repositories.

## API Client
This project integrates the local `packages/api_client` as a path dependency. Ensure the client is updated when the OpenAPI spec changes.

# Testing

## Running Tests
To run all tests:
```bash
flutter test
```

## Generating Mocks
This project uses `mockito` and `build_runner` for mocking.
To generate mocks, run:
```bash
dart run build_runner build --delete-conflicting-outputs
```

## Structure
- `test/services/` - Unit tests for services (Purchase, Download, Sync).
- `test/widgets/` - Widget tests for screens.
- `integration_test/` - E2E tests for testing flows on real devices.

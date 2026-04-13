# Merch Mobile — Test Suite

## Running Tests

### Prerequisites: Run code generation first

```bash
dart run build_runner build --delete-conflicting-outputs
```

This generates the Drift database code, Riverpod providers, and Freezed models that tests depend on.

### Run all tests

```bash
flutter test
```

### Run a specific test file

```bash
flutter test test/core/database/zones_dao_test.dart
```

## What is Covered

### DAO Tests (in-memory Drift) — `test/core/database/`
- `zones_dao_test.dart` — Tests `ZonesDao` using an in-memory SQLite database via `AppDatabase.forTesting(NativeDatabase.memory())`:
  - Insert + `watchAll` emits the new row
  - `upsert` updates an existing row (conflict resolution)
  - `deleteById` removes the row and `watchAll` returns empty

### Model Roundtrip Tests — `test/core/models/`
- `store_zone_roundtrip_test.dart` — Verifies `StoreZone.toJson()` / `StoreZone.fromJson()` roundtrip produces an equal object

### Smoke Tests — `test/features/`
- `auth/splash_screen_test.dart` — Verifies `SplashScreen` can be imported and is a non-null type reference

## What Requires a Device / Emulator (not covered here)

- **Firebase Auth** — Requires a running Firebase project; authentication flows (sign-in, sign-out, token refresh) cannot be tested offline without mocking the entire Firebase SDK
- **Camera / image_picker** — Requires hardware camera access; not testable in pure unit or headless widget tests
- **Network calls (Dio / ApiClient)** — Real HTTP requests to the sync API require a running backend; mock these with `mockito` or `http_mock_adapter` for integration tests
- **SyncService** — Depends on both Firebase and network; requires mocks or an emulator environment
- **GoRouter navigation** — Full navigation flows require a running `ProviderScope` + widget tree; covered by widget/integration tests, not unit tests

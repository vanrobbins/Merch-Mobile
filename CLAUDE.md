# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Status

Flutter foundation scaffold complete. Feature agents (2–5) are being developed in parallel on the `feature/build-flutter-app` branch.

## Project Context

**Merch-Mobile** — offline-first retail VM mobile app for a C490 course (Spring 2026).

## Stack

- **Framework:** Flutter (Dart)
- **State:** Riverpod (flutter_riverpod ^2.5.1 + riverpod_annotation)
- **Navigation:** GoRouter ^14.2.7 with role-based guards
- **Persistence:** Drift ^2.18.0 + drift_flutter (SQLite, offline-first)
- **Auth:** Firebase Auth ^5.1.4 with custom claims (coordinator/staff/manager)
- **Photos:** Firebase Storage + image_picker
- **HTTP:** Dio ^5.5.0+1 with Bearer token interceptor
- **Models:** @freezed with fromJson/toJson

## Build Commands

```bash
# Install dependencies
flutter pub get

# Run code generation (Drift, Riverpod, Freezed)
dart run build_runner build --delete-conflicting-outputs

# Analyze
flutter analyze

# Run tests
flutter test

# Run on device/emulator
flutter run

# Build release APK
flutter build apk --release
```

## Architecture Overview

```
lib/
├── main.dart                  # Firebase init + ProviderScope
├── app.dart                   # MaterialApp.router + GoRouter
├── core/
│   ├── database/
│   │   ├── app_database.dart  # DriftDatabase (all tables + DAOs)
│   │   ├── tables/            # ZonesTable, FixturesTable, ProductsTable, PlanogramsTable, PhotoDocsTable
│   │   └── daos/              # One DAO per table with watchAll/watchByParentId/upsert/deleteById
│   ├── models/                # @freezed models: AppUser, StoreZone, Fixture, Product, Planogram, PlanogramSlot, PhotoDoc
│   ├── providers/             # appDatabaseProvider, authStateProvider, currentUserProvider, connectivityProvider
│   ├── router/                # GoRouter with 11 named routes + auth guards
│   ├── services/              # AuthService, ApiClient (Dio), SyncService, firebase_options.dart
│   ├── theme/                 # AppTheme (warm-neutral palette), design_tokens.dart (Agent 4)
│   └── widgets/               # AppScaffold (4-tab), LoadingIndicator, mm_* components (Agent 4)
└── features/
    ├── auth/                  # SplashScreen, LoginScreen, LoginNotifier
    ├── zone_manager/          # (Agent 2) ZoneMapScreen, ZoneMapPainter, ZoneLegendPanel
    ├── floor_builder/         # (Agent 3) FloorBuilderScreen, BuilderCanvasPainter
    ├── auto_build/            # (Agent 3) AutoBuildScreen, BeforeAfterPreview
    ├── planogram/             # (Agent 2 secondary) PlanogramListScreen, PlanogramDetailScreen
    ├── product_catalog/       # (Agent 2 secondary) CatalogScreen, ProductCard
    └── photo_docs/            # (Agent 1 secondary) PhotoListScreen, PhotoDetailScreen
```

## Theme

- Primary: `#1A1917` (near-black)
- Accent: `#BF5534` (warm orange)
- Canvas background: `#F2EFE8` (warm off-white)
- Border radius: 2px throughout
- AppBar titles: ALL CAPS

## Cross-Agent File Ownership

- `lib/core/` — Agent 1 only (Agent 4 may add to `lib/core/widgets/` only)
- `lib/features/auth/` — Agent 1
- `lib/features/photo_docs/` — Agent 1 Secondary
- `lib/features/zone_manager/` — Agent 2 Primary
- `lib/features/planogram/`, `lib/features/product_catalog/` — Agent 2 Secondary
- `lib/features/floor_builder/`, `lib/features/auto_build/` — Agent 3
- `lib/core/widgets/` (shared only), `lib/core/theme/design_tokens.dart` — Agent 4
- `test/` — Agent 5 only

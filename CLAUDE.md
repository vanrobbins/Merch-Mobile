# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Context

**Merch-Mobile** — offline-first retail visual merchandising (VM) mobile app. Coordinators, managers, and staff manage store zones, floor layouts, planogram assignments, and mannequin outfits. Built as a C490 capstone (Spring 2026). See `docs/PROJECT_CONTEXT.md` for full architecture, schema, routes, and pending work — read it before exploring the codebase.

**Current branch:** `feature/v0.2` | **Current milestone:** v0.25 complete, v0.2 Agents 4/6/7 + v0.3 pending.

## Stack

| Layer | Library |
|---|---|
| Framework | Flutter (Dart) |
| State | Riverpod 2.5+ with `riverpod_annotation` (code-gen) |
| Navigation | GoRouter 14+ with role-based guards |
| Local DB | Drift 2.18+ (SQLite, offline-first), schemaVersion = 4 |
| Auth | Firebase Auth 5+ with custom claims (coordinator/manager/staff) |
| Photos | Firebase Storage + image_picker |
| HTTP | Dio 5.5+ with Bearer token interceptor |
| Models | `@freezed` with fromJson/toJson |

## Build Commands

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs  # after any schema/annotation change
flutter analyze
flutter test
flutter run
flutter build apk --release
```

## Architecture Overview

```
lib/
├── main.dart                  # Firebase init + ProviderScope
├── app.dart                   # MaterialApp.router + GoRouter
├── core/
│   ├── database/
│   │   ├── app_database.dart  # DriftDatabase — all tables + DAOs, schemaVersion = 4
│   │   ├── tables/            # One file per table
│   │   └── daos/              # One DAO file per table
│   ├── models/                # @freezed models
│   ├── providers/             # appDatabaseProvider, authStateProvider, activeStoreProvider,
│   │                          # currentMembershipProvider, connectivityProvider
│   ├── router/                # app_router.dart — GoRouter + AppRoutes/AppPaths constants
│   ├── services/              # AuthService, ApiClient (Dio), SyncService
│   ├── theme/                 # AppTheme, design_tokens.dart
│   └── widgets/               # AppScaffold (4-tab), RoleGuard, shared mm_* components
└── features/
    ├── auth/                  # SplashScreen, LoginScreen
    ├── store/                 # StoreGateScreen, CreateStoreScreen, JoinStoreScreen,
    │                          # PendingApprovalScreen, MembersScreen, GroupManagementScreen
    ├── dashboard/             # DashboardScreen
    ├── zone_manager/          # ZoneMapScreen, ZoneDetailScreen
    ├── floor_builder/         # FloorBuilderScreen, BuilderCanvasPainter, FloorBuilderProvider
    ├── auto_build/            # AutoBuildScreen (stub)
    ├── planogram/             # PlanogramListScreen, PlanogramDetailScreen, ProposalReviewScreen
    ├── product_catalog/       # CatalogScreen, ProductCard
    └── photo_docs/            # PhotoListScreen, PhotoDetailScreen
```

## Theme

- Primary: `#1A1917` (near-black)
- Accent: `#BF5534` (warm orange)
- Canvas background: `#F2EFE8` (warm off-white)
- Border radius: 2px throughout
- AppBar titles: ALL CAPS
- Mini-panel background: `#1A1917` (dark)

## Architecture Rules

1. **Store Canvas boundary** — `ZoneMapScreen` reads zones only, never fixtures.
2. **Store-scoped queries** — all DAOs scope to `storeId` via `activeStoreProvider`.
3. **RoleGuard** — every write action (FAB, edit button, delete) must be wrapped in `RoleGuard`. No raw role checks in build methods.
4. **Schema migrations** — bump `schemaVersion` + `destructiveFallback`. No incremental steps.
5. **Code generation** — after any Drift table, `@freezed`, or `@riverpod` change: run `build_runner build`.

## Skills to Use

Always check for applicable skills before starting any task. Key skills for this project:

- **`superpowers:brainstorming`** — before any new feature, refactor, or design decision
- **`superpowers:writing-plans`** — before implementing a multi-step agent scope
- **`superpowers:executing-plans`** — when working from a written plan
- **`superpowers:systematic-debugging`** — before investigating any bug or test failure
- **`superpowers:test-driven-development`** — when writing any feature or fix
- **`superpowers:verification-before-completion`** — before claiming work is done
- **`superpowers:finishing-a-development-branch`** — when a milestone is ready to merge/tag
- **`superpowers:requesting-code-review`** — after completing a major feature or agent scope
- **`frontend-design:frontend-design`** — when building or polishing any UI screen or component
- **`simplify`** — after implementing a feature, to clean up the changed code

## Keeping Context Current

After completing any meaningful work, update `docs/PROJECT_CONTEXT.md`:

- Bump `schemaVersion` in the schema table when it changes
- Update table column lists when columns are added/removed
- Mark agent/milestone status as ✅ Complete (with branch and date) when done
- Update the **Pending Work** section — remove completed items, reorder if priorities shift
- Update the **Last updated** datestamp at the top

Do this at the end of every session. Also save notable decisions, preferences, and project state to memory files in `.claude/memory/`.

## Cross-Agent File Ownership

- `lib/core/` — foundation agent only (exception: `lib/core/widgets/` is shared)
- `lib/features/zone_manager/` — zone/canvas agents
- `lib/features/floor_builder/` — floor builder agents
- `lib/features/planogram/` — planogram agents
- `test/` — test agent only

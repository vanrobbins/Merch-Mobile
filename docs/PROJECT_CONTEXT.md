# Merch Mobile — Project Context for Agents

> **Read this first.** This document is the single source of truth for project state, past decisions, and architecture rules. Check it before exploring the codebase. Last updated: 2026-04-27.

---

## What This App Is

**Merch-Mobile** — an offline-first retail visual merchandising (VM) mobile app. Coordinators, managers, and staff use it to manage store zones, floor layouts, planogram assignments, and mannequin outfits. Built as a C490 capstone project (Spring 2026).

---

## Tech Stack

| Layer | Library |
|---|---|
| Framework | Flutter (Dart) |
| State | Riverpod 2.5+ with `riverpod_annotation` (code-gen) |
| Navigation | GoRouter 14+ with role-based guards |
| Local DB | Drift 2.18+ (SQLite, offline-first) |
| Auth | Firebase Auth 5+ with custom claims |
| Photos | Firebase Storage + image_picker |
| HTTP | Dio 5.5+ with Bearer token interceptor |
| Models | `@freezed` with fromJson/toJson |

**Key pattern:** `dart run build_runner build --delete-conflicting-outputs` regenerates Drift table companions, Riverpod providers, and Freezed models. Run this after any schema or annotation change.

---

## Repository Layout

```
lib/
├── main.dart                  # Firebase init + ProviderScope
├── app.dart                   # MaterialApp.router + GoRouter
├── core/
│   ├── database/
│   │   ├── app_database.dart  # DriftDatabase — all tables + DAOs registered here
│   │   ├── tables/            # One file per table
│   │   └── daos/              # One DAO file per table
│   ├── models/                # @freezed models
│   ├── providers/             # appDatabaseProvider, authStateProvider,
│   │                          # currentUserProvider, activeStoreProvider,
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
    ├── floor_builder/         # FloorBuilderScreen, BuilderCanvasPainter,
    │                          # FloorBuilderProvider
    ├── auto_build/            # AutoBuildScreen (stub)
    ├── planogram/             # PlanogramListScreen, PlanogramDetailScreen,
    │                          # ProposalReviewScreen
    ├── product_catalog/       # CatalogScreen
    └── photo_docs/            # PhotoListScreen, PhotoDetailScreen
```

---

## Theme / Design Language

| Token | Value |
|---|---|
| Primary (near-black) | `#1A1917` |
| Accent (warm orange) | `#BF5534` |
| Canvas background | `#F2EFE8` |
| Border radius | 2px throughout |
| AppBar titles | ALL CAPS |
| Mini-panel background | `#1A1917` (dark) |

---

## Current Database Schema (schemaVersion = 2)

Migration strategy: `destructiveFallback` — dev only; schema version bumps wipe and recreate the DB.

### Tables currently in `app_database.dart`

| Table | Key columns |
|---|---|
| `stores` | id, name, invite_code, created_at, owner_uid |
| `store_memberships` | id, store_id→stores, user_uid, role, display_name, status, joined_at |
| `store_groups` | id, name, description, created_by_uid, created_at |
| `store_group_members` | id, group_id→store_groups, store_id→stores, added_at, added_by_uid |
| `zones` | id, store_id→stores, name, color, shape_points (JSON), zone_type, notes |
| `fixtures` | id, zone_id→zones, fixture_type, pos_x, pos_y, rotation, width_ft, depth_ft, label, store_id→stores, planogram_id→planograms (nullable), updated_at |
| `products` | id, sku, name, category, image_url, sizes_json, stock_qty, store_id→stores, updated_at |
| `planograms` | id, store_id→stores, name, season, (slots via separate table) |
| `photo_docs` | id, store_id→stores, zone_id, image_url, notes, status, submitted_by_uid, created_at |
| `planogram_proposals` | id, planogram_id→planograms, store_id→stores, proposed_by_uid, proposed_at, status, notes, slot_changes (JSON), reviewed_by_uid, reviewed_at |

> **Note:** `planogram_slots` data lives in planogram detail logic — verify exact table name in `lib/core/database/tables/` before writing queries.

### DAOs registered

ZonesDao, FixturesDao, ProductsDao, PlanogramsDao, PhotoDocsDao, StoresDao, StoreMembershipsDao, StoreGroupsDao, PlanogramProposalsDao

---

## Current Routes (`app_router.dart`)

```
/                              → SplashScreen
/login                         → LoginScreen
/store-gate                    → StoreGateScreen
/store-gate/create             → CreateStoreScreen
/store-gate/join               → JoinStoreScreen
/store-gate/pending            → PendingApprovalScreen
/home/dashboard                → DashboardScreen
/home/zones                    → ZoneMapScreen
/home/zones/:zoneId/detail     → ZoneDetailScreen
/home/zones/:zoneId/builder    → FloorBuilderScreen
/home/zones/:zoneId/auto       → AutoBuildScreen
/home/planograms               → PlanogramListScreen
/home/planograms/:planogramId  → PlanogramDetailScreen
/home/planograms/:planogramId/proposals → ProposalReviewScreen
/home/catalog                  → CatalogScreen
/home/photos                   → PhotoListScreen
/home/photos/:photoId          → PhotoDetailScreen
/home/members                  → MembersScreen
/home/groups                   → GroupManagementScreen
```

Router redirect: unauthenticated → `/login`; logged in + no active_store_id in SharedPreferences → `/store-gate`.

---

## Role System

Three roles on `store_memberships.role`: `coordinator` | `manager` | `staff`.

`RoleGuard` widget (`lib/core/widgets/role_guard.dart`) checks `currentMembershipProvider.value?.role` and hides/shows children. Use it to wrap any edit control that is role-restricted.

| Feature | Coordinator | Manager | Staff |
|---|---|---|---|
| Zone Manager | Full CRUD | Full CRUD | View only |
| Floor Builder | Full CRUD | Full CRUD | View only |
| Product Catalog | Full CRUD | Full CRUD | Browse/search |
| Planograms | Full CRUD | Full + approve proposals | Propose changes only |
| Dashboard | All stats | Plano/photo stats + pending | Personal stats |
| Store membership approval | Approve any role | Approve staff only | View own status |
| Store Groups | Full CRUD | View only | View only |

---

## Implementation Status

### v0.1 — Complete ✅
Foundation scaffold. Firebase Auth, GoRouter skeleton, Drift DB stub, 4-tab AppScaffold, all feature screen stubs, RoleGuard, AppTheme.

### v0.2 — Partial (branch: `feature/v0.2`) ⚠️

Spec: `docs/superpowers/specs/2026-04-13-v0.2-design.md`

| Agent | Scope | Status |
|---|---|---|
| Agent 1 — Foundation & Schema | Stores, memberships, store groups, planogram proposals tables + DAOs; store onboarding flow; `activeStoreProvider`, `currentMembershipProvider`; RoleGuard | ✅ Complete |
| Agent 2 — Zone Manager | Polygon canvas, vertex drag reshape, zone type selector, zone shape picker, ZoneDetailScreen | ✅ Complete |
| Agent 3 — Floor Builder + Catalog | Fixtures DB-backed, drag/move/rotate/delete, Product CRUD | ✅ Complete (auto_build stub still pending) |
| Agent 4 — Planogram Editor + Dashboard | Slot editing, ProductSlotPicker, proposal flow, DashboardScreen stats | ❌ Not started |
| Agent 5 — Role Enforcement | Route guards, RoleGuard audit | ✅ Complete |
| Agent 6 — UI Polish | Design token pass, empty/error states | ❌ Not started |
| Agent 7 — Tests | DAO + widget + integration tests | ❌ Not started |

**What this means:** Planogram detail is a stub. Dashboard is a stub. No tests exist. Most UI is functional but unpolished.

### v0.25 — Spec approved, not yet implemented 📋

Spec: `docs/superpowers/specs/2026-04-27-v0.25-design.md`

v0.25 fixes the incomplete interactive layout experience before v0.3. Covers:
1. Store Canvas (ZoneMapScreen upgrade — bounded canvas with store dimensions, Figma-style zone drag)
2. Fixture resize (type-aware edge handles)
3. Planogram assignment end-to-end (badge + picker sheet + mini-panel)
4. Store-level partitions (nullable zone_id)

**Schema bump:** schemaVersion 2 → 3. Changes:
- `stores`: add `width_ft REAL nullable`, `depth_ft REAL nullable`
- `fixtures`: `zone_id` becomes nullable; add `planogram_id_back INT nullable`, `wall_adjacent BOOL default false`
- New DAO methods: `StoresDao.updateDimensions`, `FixturesDao.watchByStoreId`

### v0.3 — Plans written, not yet implemented 📋

Spec: `docs/superpowers/specs/2026-04-16-v0.3-design.md`
Plans: `docs/superpowers/plans/2026-04-27-v0.3-*.md`

Adds the VM merchandising layer: brand color palettes, product templates with garment silhouettes, mannequin placement (5 body types, floor/wall/platform mount), and Mannequin Lock (outfit slot assignment per body part).

**Prerequisite:** v0.25 merged first, then v0.2 Agents 4/6/7 completed, then v0.3.

---

## Architecture Rules (Do Not Violate)

### 1. Data boundary — Store Canvas vs Floor Builder
- `ZoneMapScreen` / Store Canvas reads **zones table only**. It must never query fixtures.
- `FloorBuilderScreen` owns fixtures. Zone polygons are rendered as a background layer only in the floor builder (read from zone state passed in, not fetched independently).
- Rationale: prevents duplicated query logic as fixtures become more complex in v0.3.

### 2. Store-scoped queries
All DAOs must scope queries to `storeId` via `activeStoreProvider`. Never return cross-store data.

### 3. RoleGuard wrapping
Every write action (FAB, edit button, delete swipe) must be wrapped in `RoleGuard`. Do not use raw role checks in widget build methods — always use the widget.

### 4. Destructive migration (dev only)
`schemaVersion` bump + `destructiveFallback` is intentional for dev. Any schema change requires a version bump. Do not add incremental `MigrationStrategy` steps — just bump and wipe.

### 5. Code generation
After any change to Drift table classes, `@freezed` models, or `@riverpod` providers: run `dart run build_runner build --delete-conflicting-outputs`. The `.g.dart` files are committed to the repo.

### 6. File ownership (multi-agent sessions)
- `lib/core/` — Agent 1 / foundation agent only (exception: `lib/core/widgets/` is shared)
- `lib/features/zone_manager/` — zone/canvas agents
- `lib/features/floor_builder/` — floor builder agents
- `lib/features/planogram/` — planogram agents
- `test/` — test agent only

---

## Key Design Decisions (rationale recorded)

### Zone interaction model
**Decision:** Figma-style — drag zone interior = move whole zone; drag vertex = reshape.
**Rationale:** Most intuitive for coordinator-level users; no separate move handle clutter.

### Store Canvas data boundary
**Decision:** ZoneMapScreen reads zones only, never fixtures.
**Rationale:** User explicitly required — prevents logic duplication as fixtures grow more complex in v0.3+.

### Store dimensions
**Decision:** Manual setup via `stores.width_ft` + `stores.depth_ft`. Dialog prompts on first open if null.
**Rationale:** Coordinators know their store dimensions; auto-detection not feasible without hardware.

### Planogram assignment UX
**Decision:** Inline badge on each fixture (grey = unassigned, accent = assigned). Tap badge → picker sheet. Tap fixture body → mini-panel with VIEW → navigation.
**Rationale:** Badge always shows assignment status at a glance; separate tap target prevents gesture conflicts with fixture drag/move.

### Fixture resize
**Decision:** Edge-only handles (not Figma 8-handle), fixture-type-aware:
- Rack, Table: all 4 handles (W + D)
- Wall, Shelf: left/right only (width only — depth is fixed)
- Partition: all 4 handles, depth capped at 1.0 ft

**Rationale:** Edge handles are larger and easier to hit on mobile. Type-awareness reflects real-world fixture constraints.

### Partitions — store-level, nullable zone_id
**Decision:** Partitions and walls have `zone_id = null` (store-level elements, not zone-owned).
**Rationale:** A partition often sits on a zone boundary — assigning it to one zone is arbitrary and creates sync problems if duplicated.

### Partition dual-face planogram assignment
**Decision:** Free-standing partitions (`wall_adjacent = false`) have two independent planogram badges (front + back face via `planogram_id` + `planogram_id_back`). Wall-adjacent partitions show one badge only. Toggle via long-press action sheet — manual, not auto-detected.
**Rationale:** Both sides of a free-standing partition are accessible merchandise surfaces. Manual toggle because coordinators know their store layout.

### Planogram Editor scope
**Decision:** Planogram Editor (create/edit planogram slots) is v0.3 scope, not v0.25.
**Rationale:** v0.25 is a layout editor pass. Picker sheet (assign existing planogram to fixture) is sufficient for v0.25 goals.

---

## Pending Work (ordered)

1. **v0.25** — implement spec at `docs/superpowers/specs/2026-04-27-v0.25-design.md`
   - No implementation plan written yet (next step after this document)
2. **v0.2 Agent 4** — Planogram Editor + Dashboard (spec: v0.2 design doc §4–5)
3. **v0.2 Agent 6** — UI Polish pass
4. **v0.2 Agent 7** — Tests
5. **v0.3** — VM merchandising layer (plans at `docs/superpowers/plans/2026-04-27-v0.3-*.md`)
   - Prerequisite: v0.25 + v0.2 complete

---

## Spec and Plan Index

| Document | Description |
|---|---|
| `docs/superpowers/specs/2026-04-13-v0.2-design.md` | v0.2 full design spec |
| `docs/superpowers/specs/2026-04-27-v0.25-design.md` | v0.25 interactive layout editor spec |
| `docs/superpowers/specs/2026-04-16-v0.3-design.md` | v0.3 VM merchandising spec |
| `docs/superpowers/plans/2026-04-13-v0.2-agent*.md` | v0.2 implementation plans (Agents 1–7 + manager) |
| `docs/superpowers/plans/2026-04-27-v0.3-agent*.md` | v0.3 implementation plans (Agents 1–6 + manager) |

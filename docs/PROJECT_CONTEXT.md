# Merch Mobile — Project Context for Agents

> **Read this first.** This document is the single source of truth for project state, past decisions, and architecture rules. Check it before exploring the codebase. Last updated: 2026-04-29 (v0.3 all 6 agents ✅ complete; v0.35 all 7 agents ✅ complete; v0.39 refactor ✅ complete; planogram slot enhancements ✅ complete — all on feature/v0.3).

---

## What This App Is

**Merch-Mobile** — an offline-first retail visual merchandising (VM) mobile app. Coordinators, managers, and staff use it to manage store zones, floor layouts, planogram assignments, and mannequin outfits. Built as a C490 capstone project (Spring 2026).

---

## Tech Stack

| Layer      | Library                                             |
| ---------- | --------------------------------------------------- |
| Framework  | Flutter (Dart)                                      |
| State      | Riverpod 2.5+ with `riverpod_annotation` (code-gen) |
| Navigation | GoRouter 14+ with role-based guards                 |
| Database   | Cloud Firestore (real-time, replaces Drift/SQLite)  |
| Auth       | Firebase Auth 5+                                    |
| Photos     | Firebase Storage + image_picker                     |
| Models     | `@freezed` with fromJson/toJson                     |

**Key pattern:** `dart run build_runner build --delete-conflicting-outputs` regenerates Riverpod providers and Freezed models. Run this after any `@riverpod` or `@freezed` annotation change.

---

## Repository Layout

```
lib/
├── main.dart                  # Firebase init + ProviderScope + global error handlers
├── app.dart                   # MaterialApp.router + GoRouter
├── core/
│   ├── models/                # @freezed models (Store, StoreMembership, Zone, …)
│   ├── providers/             # authStateProvider, activeStoreIdProvider,
│   │                          # activeStoreProvider, currentMembershipProvider,
│   │                          # myStoresProvider
│   ├── router/                # app_router.dart — GoRouter + AppRoutes/AppPaths constants
│   ├── services/              # firestore_refs.dart (all collection paths)
│   ├── theme/                 # AppTheme, design_tokens.dart
│   └── widgets/               # AppScaffold (4-tab), RoleGuard, shared mm_* components
└── features/
    ├── auth/                  # SplashScreen, LoginScreen
    ├── store/                 # StoreGateScreen, CreateStoreScreen, JoinStoreScreen,
    │                          # PendingApprovalScreen, MembersScreen, GroupManagementScreen,
    │                          # StoreSwitcherSheet
    ├── dashboard/             # DashboardScreen, dashboard_provider.dart
    ├── zone_manager/          # ZoneMapScreen, ZoneDetailScreen, zone_map_provider.dart,
    │                          # ZoneActionsSheet, StoreDimensionsDialog
    ├── floor_builder/         # FloorBuilderScreen, BuilderCanvasPainter,
    │                          # FloorBuilderProvider, WallPlacementSheet,
    │                          # FixtureActionsSheet, MannequinTypeSheet,
    │                          # PropTypeSheet, ElementDeleteSheet
    ├── auto_build/            # AutoBuildScreen (stub)
    ├── planogram/             # PlanogramListScreen, PlanogramDetailScreen,
    │                          # ProposalReviewScreen, PlanogramEditorScreen,
    │                          # BayView, SlotCellWidget, FixturePickerSheet,
    │                          # ProductAssignmentSheet, ProductSlotPicker,
    │                          # SlotItem, SlotSizing, PgRow, PgSlot,
    │                          # PlanogramEditorNotifier
    ├── product_catalog/       # CatalogScreen, ProductCard
    └── photo_docs/            # PhotoListScreen, PhotoDetailScreen, photo_provider.dart
```

---

## Theme / Design Language

| Token                 | Value            | Notes |
| --------------------- | ---------------- | ----- |
| Primary (near-black)  | `#1A1917`        | AppTheme.primary |
| Accent (terracotta)   | `#A8472B`        | AppTheme.accent — deepened from v0.2 BF5534 |
| Canvas background     | `#F2EFE8`        | AppTheme.canvas |
| Card surface          | `#FFFFFF`        | AppTheme.cardSurface |
| Surface variant       | `#EAE7E0`        | AppTheme.surfaceVariant |
| Divider               | `#D5D2CB`        | AppTheme.divider |
| Text secondary        | `#6B6660`        | AppTheme.textSecondary |
| Text hint             | `#9E9890`        | AppTheme.textHint |
| Error                 | `#A8291A`        | AppTheme.errorColor |
| Success               | `#2D6A4F`        | AppTheme.successColor |
| Border radius         | 2px throughout   | AppTheme.borderRadius |
| AppBar titles         | ALL CAPS         | letterSpacingAppBar = 1.5 |
| Mini-panel background | `#1A1917` (dark) | |

---

## Firestore Collections

All data lives in Firestore. `FirestoreRefs` (`lib/core/services/firestore_refs.dart`) is the single source of truth for all collection paths.

| Collection path | Key fields |
| --- | --- |
| `/stores/{storeId}` | name, inviteCode, ownerUid, widthFt?, depthFt?, entranceJson?, createdAt |
| `/stores/{storeId}/memberships/{uid}` | uid, role, status, displayName, joinedAt |
| `/stores/{storeId}/zones/{zoneId}` | name, color, shapePoints (JSON), zoneType, notes |
| `/stores/{storeId}/fixtures/{fixtureId}` | fixtureType, posX, posY, rotation, widthFt, depthFt, label, zoneId?, planogramId?, planogramIdBack?, wallAdjacent, updatedAt |
| `/stores/{storeId}/products/{productId}` | sku, name, category, imageUrl, sizesJson, stockQty, colorId?, templateId?, updatedAt |
| `/stores/{storeId}/planograms/{planogramId}` | name, season |
| `/stores/{storeId}/proposals/{proposalId}` | planogramId, proposedByUid, proposedAt, status, notes, slotChanges (JSON), reviewedByUid?, reviewedAt? |
| `/stores/{storeId}/photos/{photoId}` | zoneId, imageUrl, notes, status, submittedByUid, createdAt |
| `/stores/{storeId}/groups/{groupId}` | name, description, createdByUid, createdAt |
| `/stores/{storeId}/brandColors/{colorId}` | name, hexValue, updatedAt — seeded with 5 defaults on store creation |
| `/stores/{storeId}/productTemplates/{templateId}` | id, name, silhouetteType — built-in garment templates |
| `/stores/{storeId}/mannequins/{mannequinId}` | storeId, zoneId, mannequinType (full_body\|half_body\|torso\|leg_form\|bra_form), mountType (floor\|wall\|platform), platformId?, positionX, positionY, rotation, outfitName?, outfitNotes?, updatedAt |
| `/stores/{storeId}/mannequins/{mannequinId}/outfitSlots/{slotId}` | mannequinId, bodySlot, productId?, colorId?, colorNotes?, displayNotes?, updatedAt |
| `/stores/{storeId}/mannequinProposals/{proposalId}` | mannequinId, storeId, proposedByUid, proposedByName, proposedAt, status (pending\|approved\|rejected), slotChanges (JSON), notes?, reviewedByUid?, reviewedAt? |
| `/stores/{storeId}/platforms/{platformId}` | storeId, zoneId, width, depth, elevation, positionX, positionY, rotation, colorHex?, updatedAt |
| `/stores/{storeId}/sceneProps/{propId}` | storeId, zoneId, propType (plant\|furniture\|riser\|signage\|other), name, positionX, positionY, rotation, width, depth, updatedAt |
| `/userStores/{uid}` | activeStoreIds: [storeId, …] — fast lookup of all stores a user belongs to |

### Active store flow

`activeStoreIdProvider` persists the selected storeId in SharedPreferences. On fresh login (storeId null), `StoreGateScreen` loads `myStoresProvider` which reads `/userStores/{uid}`. If that document is empty it runs a one-time migration scan (reads all stores, checks `/stores/{id}/memberships/{uid}`) and populates `/userStores/{uid}`. All future logins use the fast path.

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
/home/zones/outfit-proposals   → OutfitProposalReviewScreen (coordinator/manager)
/home/planograms               → PlanogramListScreen
/home/planograms/:planogramId  → PlanogramDetailScreen (read-only after v0.35 Agent 4)
/home/planograms/:planogramId/edit      → PlanogramEditorScreen (NEW in v0.35 Agent 4)
/home/planograms/:planogramId/proposals → ProposalReviewScreen
/home/catalog                  → CatalogScreen
/home/photos                   → PhotoListScreen
/home/photos/:photoId          → PhotoDetailScreen
/home/members                  → MembersScreen
/home/groups                   → GroupManagementScreen
```

Router redirect logic:
- Unauthenticated → `/login`
- Logged in + no `activeStoreId` → `/store-gate` (shows existing stores from `myStoresProvider`)
- Logged in + `activeStoreId` set + membership loaded as `pending` → `/store-gate/pending`
- Otherwise → pass through to requested route

---

## Role System

Three roles on `store_memberships.role`: `coordinator` | `manager` | `staff`.

`RoleGuard` widget (`lib/core/widgets/role_guard.dart`) checks `currentMembershipProvider.value?.role` and hides/shows children. Use it to wrap any edit control that is role-restricted.

| Feature                   | Coordinator      | Manager                     | Staff                |
| ------------------------- | ---------------- | --------------------------- | -------------------- |
| Zone Manager              | Full CRUD        | Full CRUD                   | View only            |
| Floor Builder             | Full CRUD        | Full CRUD                   | View only            |
| Product Catalog           | Full CRUD        | Full CRUD                   | Browse/search        |
| Planograms                | Full CRUD        | Full + approve proposals    | Propose changes only |
| Dashboard                 | All stats        | Plano/photo stats + pending | Personal stats       |
| Store membership approval | Approve any role | Approve staff only          | View own status      |
| Store Groups              | Full CRUD        | View only                   | View only            |

---

## Implementation Status

### v0.1 — Complete ✅

Foundation scaffold. Firebase Auth, GoRouter skeleton, Drift DB stub, 4-tab AppScaffold, all feature screen stubs, RoleGuard, AppTheme.

### v0.2 — Complete ✅ (branch: `feature/v0.2`, tagged v0.29)

Spec: `docs/superpowers/specs/2026-04-13-v0.2-design.md`

| Agent                                  | Scope                                                                                                                                                      | Status                                      |
| -------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------- |
| Agent 1 — Foundation & Schema          | Stores, memberships, store groups, planogram proposals; store onboarding flow; `activeStoreProvider`, `currentMembershipProvider`; RoleGuard               | ✅ Complete                                 |
| Agent 2 — Zone Manager                 | Polygon canvas, vertex drag reshape, zone type selector, zone shape picker, ZoneDetailScreen                                                               | ✅ Complete                                 |
| Agent 3 — Floor Builder + Catalog      | Fixtures Firestore-backed, drag/move/rotate/delete, Product CRUD                                                                                           | ✅ Complete (auto_build stub still pending) |
| Agent 4 — Planogram Editor + Dashboard | Slot editing, ProductSlotPicker, proposal flow, DashboardScreen stats                                                                                      | ✅ Complete (dashboard stats live)          |
| Agent 5 — Role Enforcement             | Route guards, RoleGuard audit                                                                                                                              | ✅ Complete                                 |
| Agent 6 — Firestore Migration          | Full Drift → Firestore rewrite; store membership reliability; `userStores` collection; invite code on members screen; pending approval flow                | ✅ Complete (v0.29)                         |
| Agent 7 — Tests                        | Integration tests                                                                                                                                          | ✅ Basic tests added                        |

### v0.25 — Complete ✅ (branch: `feature/v0.2`)

Spec: `docs/superpowers/specs/2026-04-27-v0.25-design.md`

v0.25 delivered the interactive layout experience:

1. Store Canvas (ZoneMapScreen — bounded ft grid, Figma-style zone drag, entrance as boundary cutout with ADD/EDIT/REMOVE, zone snap to walls/vertices, self-intersect guard)
2. Fixture resize (type-aware edge handles — all 4 for rack/table, width-only for wall/shelf, capped depth for partition)
3. Planogram assignment end-to-end (badge + PlanogramPickerSheet + FixtureMiniPanel + wall-adjacent toggle)
4. Store-level partitions (nullable zone_id, dual-face planogram badges)
5. Dashboard store size dialog + entrance UI

**Schema changes (v2 → v4):** `stores` gained `width_ft`, `depth_ft`, `entrance_json`; `fixtures` gained `planogram_id_back`, `wall_adjacent`, and `zone_id` became nullable. 95 tests passing.

### v0.3 — In Progress 🚧 (branch: `feature/v0.3`)

Spec: `docs/superpowers/specs/2026-04-16-v0.3-design.md`
Plans: `docs/superpowers/plans/2026-04-27-v0.3-*.md`

| Agent | Scope | Status |
| --- | --- | --- |
| Agent 1 — Schema + Seed | Mannequin/PlatformElement/SceneProp models, SeedService (5 brand colors + 20 products auto-seeded on store creation), FirestoreRefs extensions, theme deepened (accent #A8472B, surfaceVariant, textHint, divider, errorColor, successColor), typeXs 9→10 | ✅ Complete (2026-04-28) |
| Agent 2 — Product Catalog | 3-step product form (template picker → color picker → details), ColorPaletteScreen CRUD, ProductTemplateScreen (13 built-in templates + SVG silhouettes), ProductCard with SVG silhouette, catalog_provider Riverpod streams | ✅ Complete (2026-04-28) |
| Agent 3 — Mannequin Placement | FloorBuilderState mannequins/platforms/sceneProps + Firestore streams, addMannequin/addPlatform/addSceneProp methods, ElementLibraryPanel MANNEQUINS & PROPS section, mannequin type picker sheet, prop type picker sheet, ZoneDetailScreen _MannequinSection (list + DRESS placeholder) | ✅ Complete (2026-04-28) |
| Agent 4 — Mannequin Dressing | MannequinDressingSheet (DraggableScrollableSheet, SVG silhouette + slot list, role-aware save/propose), MannequinLockCard, OutfitProposalReviewScreen, DRESS button wired, PROPOSALS AppBar action, canvas renders mannequins/platforms/props | ✅ Complete (2026-04-28) |
| Agent 5 — UI Polish | Stick-figure mannequin canvas, platform shadow, color chip on ProductCard, empty states | ✅ Complete (2026-04-29) |
| Agent 6 — Tests | Integration + widget tests for v0.3 features | ✅ Complete (2026-04-29) |

### v0.35 — Feature-complete ✅ (branch: `feature/v0.3`, 2026-04-29)

Spec: `docs/superpowers/specs/2026-04-29-v0.35-design.md`
Plans: `docs/superpowers/plans/2026-04-29-v0.35-*.md`

Four features: undo/redo delta stack (floor builder + planogram editor), AutoBuild enhancements (style/density/mannequins/Firestore presets), full PlanogramEditorScreen, and product gender classification.

| Agent | Scope | Status |
| --- | --- | --- |
| Agent 1 — Undo/Redo Delta Stack | `UndoEntry` model, `FloorBuilderNotifier` private stacks, all 11 fixture + 6 mannequin/platform/prop methods wrapped, ↩/↪ AppBar buttons | ✅ Complete (2026-04-29) |
| Agent 2 — AutoBuild Enhancements | `LayoutStyle`/`LayoutDensity` enums, zone polygon bounds, style/density algorithm, mannequin output, Firestore presets, `PresetsSheet` | ✅ Complete (2026-04-29) |
| Agent 3 — Planogram Data Model | `PgRow` model, `Planogram` expansion (planogramType/rows/cols/linearFt/rowsJson/fixtureId nullable), `PgSlot` expansion (row/col/presentationMode/span/rotation/color), updated creation dialog | ✅ Complete (2026-04-29) |
| Agent 4 — PlanogramEditorScreen | `PlanogramEditorNotifier` + undo stack, `SlotSilhouetteRenderer`, `SlotCellWidget`, `PlanogramEditorScreen` (bay + grid views), detail screen read-only + EDIT button, route `/home/planograms/:id/edit` | ✅ Complete (2026-04-29) |
| Agent 5 — SVG Assets | 13 shoulder-out side-profile SVGs, 13 folded SVGs, pubspec.yaml asset declarations | ✅ Complete (2026-04-29) |
| Agent 6 — Tests | Unit tests: undo stack, AutoBuild algorithm, PgSlot/PgRow serialization (29 new tests, 102 total) | ✅ Complete (2026-04-29) |
| Agent 7 — Product Gender | `@Default('unisex') String gender` on Product, gender picker in form (Men/Women/Unisex), filter chips in CatalogScreen, filter chips in ProductSlotPicker | ✅ Complete (2026-04-29) |

**Why:** Adds full planogram editing workflow, undo/redo safety net across floor builder and planogram editor, smarter AutoBuild with preset library, and gender-based product filtering throughout the app.

### Planogram Slot Enhancements — Complete ✅ (branch: `feature/v0.3`, 2026-04-29)

Spec: `docs/superpowers/specs/2026-04-29-planogram-slot-enhancements-design.md`
Plan: `docs/superpowers/plans/2026-04-29-planogram-slot-enhancements.md`

Replaces the single-product planogram grid with a free-placement fixture system. The wall is a continuous column grid divided into **quarter-slots** (4 per row). Fixtures are placed anywhere in a column and auto-size vertically based on the tallest assigned product's hang or fold length.

**Fixture types:**

| Type | Capacity | Auto-size rule |
| --- | --- | --- |
| `shoulder` | 1 item | `ceil(hangLength / (rowHeightIn/4))` quarters |
| `faceout` | 1–6 items | sized to tallest item's hang length |
| `ubar` | 2–6 items | sized to tallest item's hang length |
| `shelf` | 1+ items | `ceil(foldedHeight / quarterIn) + 1` (clearance quarter) |

**New files:**

| File | Role |
| --- | --- |
| `slot_item.dart` | `SlotItem` model — productId/name/sku/category/colorHex? with JSON round-trip |
| `slot_sizing.dart` | Pure functions: `hangLength`, `foldedHeight`, `autoSpanQuarters`, `shelfSpanQuarters` |
| `bay_view.dart` | `BayView` — column × quarter-slot grid, FAB, placement-mode banner |
| `fixture_picker_sheet.dart` | `FixturePickerSheet` — 4-tile bottom sheet for choosing fixture type |
| `product_assignment_sheet.dart` | `ProductAssignmentSheet` — per-fixture product list, capacity counter, fit indicator |

**Modified files:** `pg_row.dart` (+heightIn), `planogram_slot.dart` (+nodeType/items/subRow/spanQuarters, full back-compat), `planogram_editor_provider.dart` (5 new methods + `_computeSpan`/`_rowHeightForSubRow` helpers), `slot_cell_widget.dart` (full rewrite for quarter-slot heights), `product_slot_picker.dart` (SlotAssignCallback extended with `category`), `planogram_editor_screen.dart` (replaces inline `_BayView` with `BayView`).

**Back-compat:** Old planograms (productId/name/sku top-level fields) are synthesised into one-item `items` list on deserialise. `subRow` absent → `row * 4`. No Firestore migration needed.

**Tests:** 145 passing (up from 102). New: `slot_sizing_test.dart` (32 tests), `slot_item_test.dart` (3 tests), expanded `pg_row_test.dart` and `pg_slot_test.dart`.

**Why:** Gives coordinators a realistic fixture-first merchandising tool where shelves, shoulder hooks, face-out hooks, and u-bars can be mixed freely within any column, with sizes driven by the actual garments assigned.

---

## Architecture Rules (Do Not Violate)

### 1. Data boundary — Store Canvas vs Floor Builder

- `ZoneMapScreen` / Store Canvas reads **zones table only**. It must never query fixtures.
- `FloorBuilderScreen` owns fixtures. Zone polygons are rendered as a background layer only in the floor builder (read from zone state passed in, not fetched independently).
- Rationale: prevents duplicated query logic as fixtures become more complex in v0.3.

### 2. Store-scoped queries

All Firestore queries must scope to `storeId` via `activeStoreIdProvider`. Never return cross-store data. Use `FirestoreRefs` helpers — never construct collection paths by hand.

### 3. RoleGuard wrapping

Every write action (FAB, edit button, delete swipe) must be wrapped in `RoleGuard`. Do not use raw role checks in widget build methods — always use the widget.

### 4. Firestore schema changes

There is no migration system — Firestore is schemaless. Adding a field requires updating `FirestoreRefs`/model fromDoc/toFirestore and deploying updated security rules if the field affects read/write access. Document the change in this file.

### 5. Code generation

After any change to `@freezed` models or `@riverpod` providers: run `dart run build_runner build --delete-conflicting-outputs`. The `.g.dart` files are committed to the repo.

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

1. **Merge `feature/v0.2` → `main`** — v0.2 is complete at tag v0.29
2. **Emulator testing + PR for `feature/v0.3`** — all feature work complete (v0.3, v0.35, v0.39, planogram slot enhancements); 145 tests pass; pending emulator smoke-test then merge to `main`

---

## Spec and Plan Index

| Document                                            | Description                                      |
| --------------------------------------------------- | ------------------------------------------------ |
| `docs/superpowers/specs/2026-04-13-v0.2-design.md`  | v0.2 full design spec                            |
| `docs/superpowers/specs/2026-04-27-v0.25-design.md` | v0.25 interactive layout editor spec             |
| `docs/superpowers/specs/2026-04-16-v0.3-design.md`  | v0.3 VM merchandising spec                       |
| `docs/superpowers/plans/2026-04-13-v0.2-agent*.md`  | v0.2 implementation plans (Agents 1–7 + manager) |
| `docs/superpowers/plans/2026-04-27-v0.3-agent*.md`  | v0.3 implementation plans (Agents 1–6 + manager) |
| `docs/superpowers/specs/2026-04-29-v0.35-design.md` | v0.35 design spec (undo/redo, AutoBuild, planogram editor) |
| `docs/superpowers/plans/2026-04-29-v0.35-manager.md` | v0.35 wave orchestration plan |
| `docs/superpowers/plans/2026-04-29-v0.35-agent*.md`  | v0.35 implementation plans (Agents 1–7) |
| `docs/superpowers/specs/2026-04-29-planogram-slot-enhancements-design.md` | Planogram slot enhancements design spec |
| `docs/superpowers/plans/2026-04-29-planogram-slot-enhancements.md` | Planogram slot enhancements implementation plan (8 tasks) |

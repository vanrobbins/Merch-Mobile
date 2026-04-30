# Merch-Mobile — Final Project Update Report
**Course:** C490 Capstone | **Term:** Spring 2026  
**Student:** Van Robbins  
**Repository:** Merch-Mobile  
**Report Date:** 2026-04-29  
**Current Branch:** `feature/v0.3` (all milestone work complete, pending final merge to `main`)

---

## Executive Summary

Merch-Mobile is a mobile application for retail visual merchandising (VM) coordinators, managers, and staff. The app enables teams to plan and manage store zones, build detailed floor layouts with fixtures and mannequins, assign planogram merchandise displays, propose and review outfit changes, document before/after states with photos, and manage store membership — all with real-time sync via Firebase and a role-based access model.

Over the course of Spring 2026, the project grew from a blank Flutter scaffold to a feature-complete retail operations tool across five versioned milestones (v0.1 through v0.39 + planogram slot enhancements). The codebase contains **118 source Dart files**, **172 git commits**, **20 test files**, and **133 passing automated tests** across unit, widget, and integration test layers.

A sixth milestone (**v0.4 — UI/UX Unification**) has been fully designed and specced with a screen-by-screen audit document; implementation is planned for the next development cycle.

---

## 1. Project Goals

The original project goal was to replace clipboard-and-binder visual merchandising workflows with a mobile-first tool that:

1. Lets coordinators draw and name store zones on a scaled canvas
2. Lets teams build detailed floor layouts with fixture placement, assignment, and sizing
3. Connects fixtures to planograms (merchandise display plans) with a structured slot-editing tool
4. Manages mannequin outfit assignments with a proposal-and-review workflow
5. Documents layout states with before/after photos linked to fixtures
6. Enforces role-based permissions so staff can propose but not approve changes
7. Works in multi-user, multi-store environments with real-time sync

All seven goals were delivered.

---

## 2. Technology Stack

| Layer | Choice | Rationale |
|---|---|---|
| Framework | Flutter (Dart) | Single codebase, native performance, mobile-first |
| State management | Riverpod 2.5+ with code generation | Compile-time safe, testable, reactive streams from Firestore |
| Navigation | GoRouter 14+ | Declarative routes, deep-link support, redirect guards |
| Database | Cloud Firestore | Real-time sync, offline persistence, schemaless flexibility |
| Authentication | Firebase Auth 5+ | Email/password + custom claims for role system |
| Photo storage | Firebase Storage + `image_picker` | Native camera integration, CDN-backed URLs |
| Model layer | `@freezed` + `@riverpod` code gen | Immutable models, serialization, auto-generated providers |
| Asset rendering | `flutter_svg` | Resolution-independent garment silhouettes |

**Notable mid-project decision:** The initial design called for a local SQLite database (Drift/SQLite). After completing the v0.2 Drift-backed foundation, the architecture was migrated entirely to Cloud Firestore (v0.29 / Agent 6) to unlock real-time multi-user sync and eliminate the complexity of manual sync logic. All schema state is now Firestore-native with no local DB.

---

## 3. Architecture Overview

```
lib/
├── main.dart                  Firebase init, ProviderScope, error handlers
├── app.dart                   MaterialApp.router, GoRouter config
├── core/
│   ├── models/                @freezed models (Store, Zone, Fixture, Product,
│   │                          Planogram, Mannequin, Photo, Proposal, …)
│   ├── providers/             authStateProvider, activeStoreProvider,
│   │                          currentMembershipProvider, myStoresProvider
│   ├── router/                GoRouter + AppRoutes/AppPaths constants
│   │                          + route guards (unauthenticated, no-store redirect)
│   ├── services/              firestore_refs.dart (all collection paths),
│   │                          AuthService, SeedService, ApiClient
│   ├── theme/                 AppTheme, DesignTokens
│   └── widgets/               AppScaffold (4-tab shell), RoleGuard,
│                              MmCard, MmChip, MmBanner, MmBottomSheet,
│                              MmSearchBar, MmEmptyState, MmColorSwatch
└── features/
    ├── auth/                  Splash, Login
    ├── store/                 Onboarding gate, Create/Join store, Approval flow,
    │                          Members, Group management, Store switcher
    ├── dashboard/             Stats overview, pending counts, store setup
    ├── zone_manager/          Polygon canvas, zone CRUD, Zone Detail,
    │                          Mannequin dressing, Outfit proposals
    ├── floor_builder/         Interactive fixture canvas, mannequin/platform/prop
    │                          placement, undo/redo stack, AutoBuild
    ├── planogram/             List, detail (read-only), editor (BayView + grid),
    │                          proposal review, slot sizing/items models
    ├── product_catalog/       3-step product form, color palettes, templates,
    │                          SVG silhouettes, gender filter
    └── photo_docs/            Before/after capture, photo list + detail,
                               approval status workflow
```

### Key Architecture Rules

- **Store-scoped queries everywhere** — every Firestore query scopes to `storeId` via `activeStoreIdProvider`. Cross-store data is never returned.
- **`FirestoreRefs` as single path authority** — all collection paths are constructed by `firestore_refs.dart`; no ad-hoc string paths in feature code.
- **`RoleGuard` for all write actions** — every FAB, edit button, or delete control is wrapped in `RoleGuard`. No raw role checks in widget build methods.
- **Canvas data boundaries** — `ZoneMapScreen` reads zones only; `FloorBuilderScreen` owns fixtures. Zone polygons appear in the floor builder as a background-only layer.
- **Code generation discipline** — `@riverpod` and `@freezed` annotations trigger `build_runner`. Generated `.g.dart` and `.freezed.dart` files are committed to the repo.

---

## 4. Role System

Three roles are assigned per store membership, stored in `/stores/{storeId}/memberships/{uid}.role`:

| Feature | Coordinator | Manager | Staff |
|---|---|---|---|
| Zone CRUD | Full | Full | View only |
| Floor Builder | Full | Full | View only |
| Product Catalog | Full CRUD | Full CRUD | Browse/search |
| Planograms | Full CRUD | Full + approve proposals | Propose changes only |
| Outfit assignments | Full + approve proposals | Full + approve proposals | Propose only |
| Dashboard | All stats + pending queues | Planogram/photo stats | Personal stats |
| Store membership approval | Approve any role | Approve staff only | View own status |
| Store Groups | Full CRUD | View only | View only |

Role enforcement is implemented in two layers:
1. **Route guards** (`route_guards.dart`) — redirect-based, prevents navigation to restricted routes
2. **`RoleGuard` widget** — hides/shows individual UI controls based on current membership role

---

## 5. Milestones Delivered

### v0.1 — Foundation (March 2026)
**Branch:** initial commits on `main`

Established the project skeleton: Firebase Auth integration, GoRouter navigation shell, 4-tab `AppScaffold`, all feature screen stubs, `RoleGuard`, `AppTheme` with design tokens, and `@freezed` model scaffolding. Every subsequent feature was built on top of this foundation without breaking changes.

---

### v0.2 — Core Feature Layer (April 13–16, 2026)
**Branch:** `feature/v0.2` | **Tag:** `v0.29` | **Agents:** 7

This was the primary feature delivery milestone. Seven parallel agent scopes were planned, designed, and executed:

| Agent | Scope | Outcome |
|---|---|---|
| 1 — Foundation | Stores, memberships, store groups, invite codes, onboarding flow | Full store creation/join/approval flow |
| 2 — Zone Manager | Polygon zone canvas, Figma-style drag/reshape, zone type selector | Interactive zone map with vertex drag |
| 3 — Floor Builder + Catalog | Fixture CRUD, drag/move/rotate/delete, Product form | Live fixture canvas with persistence |
| 4 — Planogram Editor + Dashboard | Slot editing, ProductSlotPicker, proposal flow, dashboard stats | End-to-end planogram assignment |
| 5 — Role Enforcement | Route guards audit, RoleGuard integration across all screens | All write actions role-gated |
| 6 — Firestore Migration | Full Drift → Firestore rewrite, `userStores` fast-lookup collection | Real-time sync, no SQLite dependency |
| 7 — Tests | Integration and widget tests | Test suite established |

**Key design decisions made during v0.2:**
- Figma-style zone interaction (drag interior = move, drag vertex = reshape) over a separate "move handle" pattern
- Edge-only resize handles on fixtures, type-aware (rack = all 4 edges; shelf = width-only; partition = all 4 with depth cap)
- Dual-face planogram assignment for free-standing partitions (`planogram_id` front + `planogram_id_back`)
- Partitions at store level with nullable `zone_id` to avoid zone-boundary ownership ambiguity

---

### v0.25 — Interactive Layout Editor (April 27, 2026)
**Branch:** `feature/v0.2` (continued)  
**Spec:** `docs/superpowers/specs/2026-04-27-v0.25-design.md`

Delivered the full interactive store layout experience that makes the app feel like a real tools:

1. **Scaled ft-grid store canvas** — `ZoneMapScreen` renders a bounded grid reflecting real store dimensions (set by coordinator)
2. **Entrance as canvas boundary** — entrance is rendered as a cutout in the store boundary wall with ADD/EDIT/REMOVE actions
3. **Zone snap** — zones snap to walls and neighboring zone vertices; self-intersection guard prevents invalid shapes
4. **Fixture resize** — type-aware edge handles with visual feedback; rack/table get all 4 handles, wall/shelf get width-only
5. **Planogram assignment end-to-end** — badge on each fixture (grey = unassigned, accent = assigned), tap opens `PlanogramPickerSheet`, `FixtureMiniPanel` shows current assignment with a VIEW link
6. **Store-level partitions** — free-standing dividers with dual-face planogram badges and wall-adjacent toggle
7. **Dashboard store setup flow** — dialog to enter store width/depth + entrance setup prompt

**Tests:** 95 passing at end of v0.25.

---

### v0.3 — Visual Merchandising Layer (April 28–29, 2026)
**Branch:** `feature/v0.3`  
**Spec:** `docs/superpowers/specs/2026-04-16-v0.3-design.md`  
**Agents:** 6

This milestone added the mannequin and outfit management system — the core VM feature that differentiates the app from a generic layout tool:

| Agent | Scope | Key Deliverables |
|---|---|---|
| 1 — Schema + Seed | Mannequin/PlatformElement/SceneProp models, SeedService | Auto-seed 5 brand colors + 20 products on store creation |
| 2 — Product Catalog | 3-step product form, ColorPaletteScreen, ProductTemplateScreen | 13 built-in garment templates + SVG silhouettes |
| 3 — Mannequin Placement | Mannequin/platform/prop placement in floor builder | Drag-to-place with type pickers and canvas rendering |
| 4 — Mannequin Dressing | MannequinDressingSheet, outfit proposals, OutfitProposalReviewScreen | Role-aware save/propose with review workflow |
| 5 — UI Polish | Canvas stick figures, platform shadows, color chips on ProductCard | Visual completeness pass |
| 6 — Tests | Integration + widget tests for v0.3 features | 102 total tests at completion |

**Mannequin system detail:**
- 5 mannequin types: `full_body`, `half_body`, `torso`, `leg_form`, `bra_form`
- Body slots are type-specific (e.g., full_body has head/top/bottom/shoes; torso has top only)
- Each slot can reference a product + brand color + display notes
- Staff can propose outfit changes; coordinators/managers approve via `OutfitProposalReviewScreen`
- Mannequins render as stick figures on the floor builder canvas

**Product catalog:**
- 3-step creation wizard: template picker → brand color picker → details form
- 13 built-in garment templates with shoulder-out and folded SVG silhouettes
- Product gender classification (Men/Women/Unisex) with filter chips throughout

---

### v0.35 — Advanced Tooling (April 29, 2026)
**Branch:** `feature/v0.3` (continued)  
**Spec:** `docs/superpowers/specs/2026-04-29-v0.35-design.md`  
**Agents:** 7

Four major capabilities added in a single-day sprint:

**Undo/Redo Delta Stack (Floor Builder + Planogram Editor)**
- `UndoEntry` model stores parallel before/after fixture state with action IDs
- All 11 fixture operations + 6 mannequin/platform/prop operations wrapped with delta capture
- Stack capped at 20 entries; ↩/↪ AppBar buttons in `FloorBuilderScreen`
- Separate undo stack in `PlanogramEditorNotifier` for slot operations

**AutoBuild Enhancements**
- `LayoutStyle` enum (grid / cluster / perimeter / feature) and `LayoutDensity` enum (sparse / standard / dense)
- Zone polygon bounding box algorithm to distribute fixtures within zone area
- Mannequin placement output included in AutoBuild results
- Firestore preset library (`autoBuildPresets` collection) with `PresetsSheet` UI

**Full PlanogramEditorScreen**
- `PlanogramEditorNotifier` with slot assignment, row manipulation, and undo stack
- `SlotSilhouetteRenderer` renders product SVG in slot context
- `SlotCellWidget` with active/blocked states and drag handles
- Dual view modes: Bay (visual fixture representation) and Grid (tabular slot list)
- `PlanogramDetailScreen` made read-only; EDIT button navigates to editor route (`/home/planograms/:id/edit`)

**Product Gender Classification**
- `gender` field (`male` / `female` / `unisex`, default `unisex`) on `Product` model
- Gender picker in product form Step 3
- Filter chips in `CatalogScreen` and `ProductSlotPicker`

**Tests at v0.35 completion:** 102 passing (29 new tests added).

---

### Planogram Slot Enhancements (April 29, 2026)
**Branch:** `feature/v0.3` (continued)  
**Spec:** `docs/superpowers/specs/2026-04-29-planogram-slot-enhancements-design.md`

Replaced the simple single-product planogram grid with a fixture-first quarter-slot system that reflects real retail shelving behavior:

**Quarter-slot model:**
- Wall planogram divided into columns; each column is a grid of **quarter-slots** (4 per row)
- Fixture types auto-size vertically based on assigned product dimensions:
  - `shoulder` hook: `ceil(hangLength / quarterIn)` quarters tall
  - `faceout` hook (1–6 items): sized to tallest item's hang length
  - `u-bar` (2–6 items): sized to tallest item's hang length  
  - `shelf` (1+ folded items): `ceil(foldedHeight / quarterIn) + 1` quarters (clearance)

**New files:**

| File | Role |
|---|---|
| `slot_item.dart` | `SlotItem` model — productId/name/sku/category/colorHex with JSON round-trip |
| `slot_sizing.dart` | Pure functions for hang length, folded height, quarter math |
| `bay_view.dart` | `BayView` — column × quarter-slot grid with FAB and placement-mode banner |
| `fixture_picker_sheet.dart` | 4-tile bottom sheet for fixture type selection |
| `product_assignment_sheet.dart` | Per-fixture product list with capacity counter and fit indicator |

**Back-compatibility:** Existing planograms with top-level `productId/name/sku` fields are synthesised into a one-item `items` list on deserialisation. No Firestore migration required.

**Tests at completion:** 145 passing (43 new tests: `slot_sizing_test.dart` with 32 tests, `slot_item_test.dart` with 3 tests, expanded `pg_row_test.dart` and `pg_slot_test.dart`).

---

### v0.39 — Refactor Pass (April 29, 2026)
**Branch:** `feature/v0.3` (continued)

Targeted structural cleanup after the v0.35 and slot enhancements feature burst:

- Extracted inline bottom sheets and dialogs (`WallPlacementSheet`, `FixtureActionsSheet`, `MannequinTypeSheet`, `PropTypeSheet`, `ElementDeleteSheet`, `ZoneActionsSheet`, `StoreDimensionsDialog`) from monolithic screen files
- Deduplicated snap-to-grid logic into a shared `_snap` helper in `FloorBuilderProvider`
- Collapsed scattered `_patchDoc` calls into a single unified method
- `ZoneEdgeHelper` utility extracted for wall-adjacency detection
- File size targets: `floor_builder_screen.dart` and `zone_detail_screen.dart` reduced significantly

---

## 6. Current Test Suite

**133 tests total | 20 test files | 3 known failures (pre-existing, minor assertion drift)**

| Test File | Coverage |
|---|---|
| `slot_sizing_test.dart` | 32 tests — hang length, fold height, quarter math for all 4 fixture types |
| `undo_stack_test.dart` | Stack cap, add/delete/move op round-trips, canUndo/canRedo state |
| `pg_slot_test.dart` | PgSlot serialization, items priority over legacy productId, nodeType enum |
| `pg_row_test.dart` | PgRow defaults, heightIn quarter math |
| `slot_item_test.dart` | SlotItem JSON round-trip |
| `auto_build_test.dart` | Layout algorithm, density/style combinations, mannequin output |
| `planogram_editor_test.dart` | Slot assignment, undo/redo, row height updates |
| `zone_map_test.dart` | Zone canvas rendering, entrance cutout |
| `fixture_mini_panel_test.dart` | Assignment badge states, planogram link |
| `mannequin_lock_card_test.dart` | Slot display, unfilled slots hidden |
| `planogram_picker_sheet_test.dart` | Loading state, planogram tile display |
| `dashboard_stats_test.dart` | Stat card counts, pending badge display |
| `firestore_integration_test.dart` | Store creation, membership join, zone CRUD |
| `widget_test.dart` | Placeholder (app-level smoke test) |
| + 6 additional test files | Role guard, auth flow, model serialization |

---

## 7. Firestore Data Model

All data is stored in Firestore under a per-store hierarchy. Every collection is accessed via `FirestoreRefs` — no ad-hoc path construction exists anywhere in the codebase.

```
/stores/{storeId}
  name, inviteCode, ownerUid, widthFt?, depthFt?, entranceJson?

  /memberships/{uid}
    role (coordinator|manager|staff), status (active|pending), displayName

  /zones/{zoneId}
    name, color, shapePoints (JSON polygon), zoneType, notes

  /fixtures/{fixtureId}
    fixtureType, posX, posY, rotation, widthFt, depthFt, label,
    zoneId? (null = store-level), planogramId?, planogramIdBack?,
    wallAdjacent, updatedAt

  /products/{productId}
    sku, name, category, gender, imageUrl, sizesJson,
    colorId?, templateId?, updatedAt

  /planograms/{planogramId}
    name, season, planogramType, rows, cols, linearFt,
    rowsJson (JSON), fixtureId?

  /proposals/{proposalId}
    planogramId, proposedByUid, status, slotChanges (JSON),
    reviewedByUid?, reviewedAt?

  /mannequins/{mannequinId}
    mannequinType, mountType, positionX/Y, rotation,
    outfitName?, platformId?, zoneId, updatedAt

    /outfitSlots/{slotId}
      bodySlot, productId?, colorId?, colorNotes?, displayNotes?

  /mannequinProposals/{proposalId}
    mannequinId, proposedByUid, status, slotChanges (JSON)

  /photos/{photoId}
    zoneId, imageUrl, notes, status, submittedByUid, createdAt

  /groups/{groupId}
    name, description, createdByUid

  /brandColors/{colorId}
    name, hexValue — 5 defaults seeded on store creation

  /productTemplates/{templateId}
    id, name, silhouetteType — 20 defaults seeded on store creation

  /platforms/{platformId}
    width, depth, elevation, positionX/Y, rotation, colorHex?, zoneId

  /sceneProps/{propId}
    propType, name, positionX/Y, rotation, width, depth, zoneId

  /autoBuildPresets/{presetId}
    name, style, density, hasMannequins, season

/userStores/{uid}
  activeStoreIds: [storeId, …] — fast reverse-lookup for multi-store users
```

---

## 8. Screen Inventory

The app contains **21 screens and 15+ bottom sheets / dialogs**:

**Auth & Onboarding (5 screens)**
- SplashScreen, LoginScreen, StoreGateScreen, CreateStoreScreen, JoinStoreScreen, PendingApprovalScreen

**Dashboard (1 screen)**
- DashboardScreen — stat cards for zones, fixtures, proposals, mannequins, photos; pending request indicators; store setup prompt

**Zone Manager (2 screens + 2 sheets)**
- ZoneMapScreen — polygon canvas with entrance, zone snap, vertex drag reshape
- ZoneDetailScreen — fixture list + mannequin section + outfit proposals link
- ZoneActionsSheet, ZonePropertiesPanel

**Floor Builder (1 screen + 6 sheets)**
- FloorBuilderScreen — fixture/mannequin/platform/prop canvas with undo/redo, AutoBuild, multi-select
- WallPlacementSheet, FixtureActionsSheet, MannequinTypeSheet, PropTypeSheet, ElementDeleteSheet, PlanogramPickerSheet

**Planogram (4 screens + 3 sheets)**
- PlanogramListScreen — filterable list of all store planograms
- PlanogramDetailScreen — read-only slot view with EDIT button (role-gated)
- PlanogramEditorScreen — bay view + grid view with fixture placement, slot assignment, undo/redo
- ProposalReviewScreen — coordinator/manager review queue for staff-proposed changes
- FixturePickerSheet, ProductAssignmentSheet, ProductSlotPicker

**Product Catalog (3 screens)**
- CatalogScreen — full product list with gender/category filter chips and search
- ProductFormScreen — 3-step wizard (template → color → details)
- ColorPaletteScreen — brand color CRUD
- ProductTemplateScreen — 13 built-in garment templates with SVG previews

**Photo Docs (2 screens)**
- PhotoListScreen — before/after tab view with approval status overlays
- PhotoDetailScreen — full-image view with notes and approval action

**Store Management (4 screens + 1 sheet)**
- MembersScreen — pending approvals + active member list
- GroupManagementScreen — staff group CRUD
- StoreSwitcherSheet — switch active store without logging out

**Mannequin Dressing (1 screen + 1 sheet)**
- OutfitProposalReviewScreen — coordinator/manager outfit proposal review
- MannequinDressingSheet — full-body SVG silhouette + body slot assignment

**Auto-Build (1 screen)**
- AutoBuildScreen — style/density/mannequins controls + preset library

---

## 9. Navigation Architecture

GoRouter with 20 named routes and three redirect guards:

```
/                          → SplashScreen
/login                     → LoginScreen
/store-gate                → StoreGateScreen
/store-gate/create         → CreateStoreScreen
/store-gate/join           → JoinStoreScreen
/store-gate/pending        → PendingApprovalScreen
/home/dashboard            → DashboardScreen
/home/zones                → ZoneMapScreen
/home/zones/:zoneId/detail → ZoneDetailScreen
/home/zones/:zoneId/builder → FloorBuilderScreen
/home/zones/:zoneId/auto   → AutoBuildScreen
/home/zones/outfit-proposals → OutfitProposalReviewScreen
/home/planograms           → PlanogramListScreen
/home/planograms/:id       → PlanogramDetailScreen
/home/planograms/:id/edit  → PlanogramEditorScreen
/home/planograms/:id/proposals → ProposalReviewScreen
/home/catalog              → CatalogScreen
/home/photos               → PhotoListScreen
/home/photos/:photoId      → PhotoDetailScreen
/home/members              → MembersScreen
/home/groups               → GroupManagementScreen
```

**Redirect guards:**
1. Unauthenticated → `/login`
2. Logged in + no active store → `/store-gate`
3. Logged in + store pending membership → `/store-gate/pending`

---

## 10. Codebase Metrics

| Metric | Value |
|---|---|
| Total git commits | 172 |
| Source Dart files (non-generated) | 118 |
| Generated files (`.g.dart`, `.freezed.dart`) | ~40 |
| Test files | 20 |
| Test assertions (passing) | 133 |
| Firestore collections | 17 |
| Named app routes | 20 |
| Shared `mm_*` widgets | 9 |
| Built-in product templates | 13 |
| SVG silhouette assets | 26 (13 shoulder-out + 13 folded) |
| Design spec documents | 9 |
| Implementation plan documents | 16+ |

**Commit activity by date:**

| Date | Commits |
|---|---|
| 2026-04-27 | 68 |
| 2026-04-29 | 61 |
| 2026-04-13 | 22 |
| 2026-04-28 | 10 |
| 2026-04-16 | 8 |
| 2026-04-15 | 2 |
| 2026-03-28 | 1 |
| **Total** | **172** |

---

## 11. Design System

The app uses a consistent design language established in `AppTheme` and `DesignTokens`:

| Token | Value |
|---|---|
| Primary (near-black) | `#1A1917` |
| Accent (terracotta) | `#A8472B` |
| Canvas background | `#F2EFE8` |
| Card surface | `#FFFFFF` |
| Surface variant | `#EAE7E0` |
| Divider | `#D5D2CB` |
| Text secondary | `#6B6660` |
| Error red | `#A8291A` |
| Success green | `#2D6A4F` |
| Border radius | 2px |
| AppBar titles | ALL CAPS + letter spacing 1.5 |

Shared widget library (`lib/core/widgets/`):
- `AppScaffold` — 4-tab bottom navigation shell with role-aware tab visibility
- `RoleGuard` — wraps any UI control to hide/show based on current membership role
- `MmCard` — standardized card surface
- `MmChip` — category and type selector chips
- `MmBanner` — dismissible info/warning banners
- `MmBottomSheet` — drag-handle bottom sheet wrapper
- `MmSearchBar` — debounced search input
- `MmEmptyState` — empty list state with icon, headline, and optional CTA
- `MmColorSwatch` — brand color display swatch

---

## 12. Planned Next Milestone — v0.4 UI/UX Unification

A comprehensive design audit and specification for v0.4 was completed on 2026-04-29:  
`docs/superpowers/specs/2026-04-29-v0.4-design.md`

**v0.4 is a pure polish pass — no new features or Firestore collections.** It has four goals:

**1. Design Unification**
- Replace static `AppTheme.*` constants with an `AppColors` ThemeExtension
- Full dark mode + light mode support driven by `MediaQuery.platformBrightness`
- New shape scale: `radiusCard` (12px), `radiusCta` (10px), `radiusBadge` (6px), `radiusXs` (4px), `radiusPill` (100px)
- Replace `BottomNavigationBar` (deprecated) with `NavigationBar` (Material 3)
- Apple HIG–inspired large titles (`SliverAppBar` with expandedHeight 88px) on list screens

**2. UX Structural Fixes** (screen-by-screen audit findings)
- Dashboard: remove static welcome banner; conditional setup card; wire all dead stat cards; move logout to profile sheet
- Zone Map: replace single-item `PopupMenuButton` with direct icon button
- Zone Detail: slim AppBar from 5 actions to 3; proposals badge icon with count
- Zone Settings sheet: remove REPLACE SHAPE (wrong context), remove redundant type label
- Photo List: fix hardcoded `phase: 'before'` FAB bug; per-tab phase-aware FABs
- Planograms: EDIT TextButton → icon button; PROPOSE CHANGE → GoRouter; `_ProposalStatusChip` colors → tokens; raw UID → display name

**3. New Shared Widgets**
- `MmButton` — replaces 20+ scattered `ElevatedButton.styleFrom` patterns
- `MmTextField` — standardized input decoration
- `MmDialog` — replaces raw `AlertDialog` across 3 screens
- `MmListTile` + `MmListSection` — Apple grouped-list rows
- `MmEyebrow` — ALL-CAPS section header used in 15+ places

**4. Dependency Hygiene**
- Bump `flutter_riverpod` to 2.6.1, `go_router` to 14.6.0, Firebase suite to latest patches
- Upgrade `flutter_lints` to 5.0.0 (major, stricter rules)
- Run `dart fix --apply` across the full codebase

**v0.4 implementation plan:** 4 agents (Foundation, Screen Sweep, Simplification Pass using the `simplify` skill, Tests).

---

## 13. Known Issues

| Issue | Severity | Location | Status |
|---|---|---|---|
| 3 test failures | Low | `planogram_picker_sheet_test`, `dashboard_stats_test`, `widget_test` | Pre-existing assertion drift; no feature impact |
| PROPOSE CHANGE uses `Navigator.push` | Medium | `PlanogramDetailScreen` | Tracked in v0.4 §5.9 |
| `PhotoListScreen` FAB always `phase: 'before'` | Medium | `photo_list_screen.dart` | Tracked in v0.4 §5.6 |
| Raw UID displayed in proposal review | Low | `ProposalReviewScreen` | Tracked in v0.4 §5.9 |
| `BottomNavigationBar` deprecation warning | Low | `AppScaffold` | Tracked in v0.4 §4 |
| `Colors.white` / hardcoded colors | Low | Multiple screens | Tracked in v0.4 §7.2 |

---

## 14. Summary

Merch-Mobile was built from scratch over Spring 2026 and delivers a production-grade retail visual merchandising tool. Starting from a blank Flutter project in late March, the app grew through five complete development milestones — each preceded by a formal design spec, broken into agent-scoped implementation plans, and validated with automated tests.

The final state of the codebase represents a realistic, functional tool: coordinators can sketch a store layout on a scaled canvas, populate it with fixtures and mannequins, assign planograms that reflect actual garment dimensions in a realistic bay view, have staff propose outfit and merchandise changes, and capture before/after photo documentation — all synchronized across users in real time, with role permissions enforced at both the route and UI control level.

The design specification for v0.4 (UI/UX unification) is complete and ready for implementation. The `feature/v0.3` branch is pending a final emulator smoke test and merge to `main`.

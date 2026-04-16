# Manager Agent Decision Log — Merch Mobile v0.2

Decisions made autonomously during v0.2 implementation.

---

## Agent 1 — Foundation & Schema (2026-04-13)

### RadioListTile deprecation in members_screen.dart
Flutter 3.32 deprecated `RadioListTile.groupValue` and `RadioListTile.onChanged` in favor of a `RadioGroup` ancestor widget. However, the new API is still in preview and the old API remains functional. Decision: keep the existing RadioListTile approach since it works correctly and a migration to RadioGroup would require significant refactoring of the dialog widgets. This can be updated when Flutter stabilizes the RadioGroup API.

### Riverpod generated Ref types deprecated
`riverpod_generator ^2.4.3` generates typed `*Ref` classes (e.g., `ActiveStoreRef`) that are deprecated by `riverpod_annotation ^2.3.5` in favor of `Ref`. These are generated code — the fix would require upgrading riverpod_generator or using a workaround. Left as-is since they are pre-existing from v0.1 and all agents are using the same versions.

### Import strategy: app_database.dart instead of table files
Drift generates Companion and Data classes in `app_database.g.dart` which is part of `app_database.dart`. Screen files that need Companion types (e.g., `StoresTableCompanion`) must import `app_database.dart`, not the individual table files. This is the correct pattern for Drift-generated code.

---

## Agent 5 — Role Enforcement (2026-04-13)

### RoleGuard placement: wrap Padding not Expanded
In `auto_build_screen.dart`, the action buttons (APPLY + SAVE PRESET) were originally inside a `Row` as `Expanded` children. Wrapping `Expanded` inside `RoleGuard` (which is not a `Flex` widget) would cause a layout error because `Expanded` must be a direct child of `Row`/`Column`/`Flex`. Decision: moved `RoleGuard` to wrap the entire `Padding` block containing the `Row`, so the fallback `SizedBox.shrink()` collapses the entire button bar rather than just one button.

### route_guards.dart: removed old requireAuth/redirectIfAuthed helpers
The original `route_guards.dart` had `requireAuth()` and `redirectIfAuthed()` functions that were v0.1 scaffolding. The router now handles auth redirect inline in its `redirect` callback (set up by Agent 1). These helpers were unused and replaced with the `checkRole()` helper per the v0.2 plan.

### photo_detail_screen.dart: extended RoleGuard to include 'manager' role
The original code used `isCoordinator` (only `coordinator` role). Per the v0.2 plan, approve/reject actions should be available to both `coordinator` and `manager` roles, since managers need operational approval authority. Updated RoleGuard to `['coordinator', 'manager']`.

### store gate redirect: already present (no changes needed)
Agent 1 already added the store gate redirect logic to `app_router.dart`. Verified and left in place. Removed the `TODO(Agent5)` marker since the work is complete.

---

## Agent 4 — Planogram Editor + Dashboard (2026-04-15)

### Feature-scoped slot model `PgSlot` instead of reusing `core/models/planogram_slot.dart`
The existing `PlanogramSlot` in `lib/core/models/` (freezed) has a v0.1 shape with `required String productId`, `sequence`, and `facings`. The v0.2 editor needs nullable `productId`, `productName`, `productSku`, and a 1-based `position`. Those fields are incompatible, and `core/` belongs to Agent 1. Decision: create a new `PgSlot` class in `lib/features/planogram/planogram_slot.dart` with its own JSON encode/decode helpers. Named `PgSlot` (not `PlanogramSlot`) so that accidentally mixing imports would produce a clear compile error rather than silent ambiguity. `PgSlot.fromJson` also accepts a legacy `sequence` key so rows written by the v0.1 notifier still load.

### Replaced v0.1 `PlanogramNotifier` entirely
The previous `PlanogramNotifier` held all planograms in state and implemented add/remove/reorder slot operations. The v0.2 design uses two smaller providers (`planogramListProvider` + `planogramDetailProvider`) plus a `planogramEditorProvider(planogramId)` family that holds only the slots for the currently open planogram. Since `PlanogramNotifier` was only referenced by the two planogram screens (which I'm rewriting anyway), I removed it instead of maintaining two parallel state systems. The legacy `core/models/planogram.dart` freezed model is no longer imported anywhere in `lib/features/planogram/`.

### Dashboard "My Photos" counts all store photos (schema gap)
The staff dashboard wants a "My Photos" count, but `PhotoDocsTable` has no uploader column (no `uploadedByUid`). Decision: fall back to "photos in this store" for `myPhotoCount` rather than leave it as 0 or add a new column (core schema is Agent 1 territory). Documented inline so a future pass can wire it to a real uploader field once the schema grows it.

### Proposal review route added as subroute of planogramDetail
`AppRoutes.proposalReview` + `AppPaths.proposalReview` already existed in the router constants (Agent 1 reserved the names), but there was no matching `GoRoute`. Added `ProposalReviewScreen` as a child of `planogramDetail` at path `proposals`, reachable as `/home/planograms/:planogramId/proposals`. No screen currently navigates there yet — the route is available for managers/coordinators to deep-link or for a future "View proposals" action on the detail screen.

### `PlanogramsDao.watchByParentId` kept as legacy alias
The v0.2 plan's example code removed `watchByParentId(fixtureId)` entirely in favor of `watchByStore`. I kept it as a backward-compatibility alias since it's a lightweight method and removing it would risk breaking any other agent's in-progress code that still uses the old name. `watchByStore` is the canonical query going forward.

### `FixturesDao.watchByStore` added (not removed)
Added `Stream<List<FixturesTableData>> watchByStore(String storeId)` to `fixtures_dao.dart` as explicitly required by the work order's "IMPORTANT" note. The existing `watchByZone(storeId, zoneId)` and `watchByParentId(zoneId)` methods were left untouched.

## v0.2 Complete
All 7 agents finished. PR created at https://github.com/vanrobbins/Merch-Mobile/pull/2.

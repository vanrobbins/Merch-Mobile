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

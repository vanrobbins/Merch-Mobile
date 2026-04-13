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

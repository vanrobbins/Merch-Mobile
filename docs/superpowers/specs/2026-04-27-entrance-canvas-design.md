# Entrance Canvas Placement — Design Spec

**Date:** 2026-04-27
**Branch:** feature/v0.2
**Status:** Approved

---

## Problem

The current entrance-placement UX (wall chips + position/width sliders in a Dashboard bottom sheet) is inconsistent with how every other spatial element is placed in the app — zones and fixtures are dragged directly on a canvas. The sliders are abstract, non-spatial, and buried under the Dashboard.

---

## Solution

Move entrance placement onto the Zone Map canvas as a first-class drag interaction. The Dashboard retains status/entry-point buttons for coordinators; the slider sheet is removed entirely.

---

## What Gets Removed

- `_EntranceEditorSheet` in `dashboard_screen.dart` — deleted entirely
- The `showModalBottomSheet` call in `_EntranceRow._showEditor` — replaced with navigation

---

## Dashboard Changes (`dashboard_screen.dart`)

`_EntranceRow` (coordinator Store Setup card only):

- **No entrance set:** "ADD ENTRANCE" `OutlinedButton.icon` navigates to Zone Map with query param `entranceEdit=true` via `context.goNamed(AppRoutes.zoneMap, queryParameters: {'entranceEdit': 'true'})`
- **Entrance set:** "EDIT ENTRANCE (WALL)" button does the same navigation. "REMOVE" `OutlinedButton` is unchanged — calls `notifier.removeEntrance()` in place, no canvas needed.
- No bottom sheet is ever opened from the dashboard. `_EntranceEditorSheet` and `_showEditor` are deleted.

---

## Zone Map Changes (`zone_map_screen.dart`)

### AppBar overflow menu

A `PopupMenuButton` (three-dot `⋮`) is added to the Zone Map `AppBar` actions, wrapped in `RoleGuard(allowedRoles: ['coordinator', 'manager'])`. Menu items:

- **Edit Entrance** — calls `_enterEntranceEditMode()`

### Auto-entry from dashboard

`ZoneMapScreen` reads the `entranceEdit` query parameter from `GoRouterState.of(context).uri.queryParameters`. If `'true'`, `initState` calls `_enterEntranceEditMode()` after the first frame via `addPostFrameCallback`.

### Entrance-edit mode state

`_ZoneMapScreenState` gains:

```dart
bool _entranceEditMode = false;
StoreEntrance? _editEntrance; // live preview during drag, not yet persisted
```

`_enterEntranceEditMode()` sets `_entranceEditMode = true` and seeds `_editEntrance` from current store data.

`_exitEntranceEditMode()`:
1. If `_editEntrance != null`, calls `notifier.setEntrance(_editEntrance!.toJson())`
2. Sets `_entranceEditMode = false`, clears `_editEntrance`

### AppBar in edit mode

When `_entranceEditMode == true`:
- Banner below AppBar (via `PreferredSize` bottom or `Column`): accent-tinted bar reading `DRAG GAP · DRAG ENDS TO RESIZE · TAP WALL TO PLACE`
- AppBar `actions` replaced with a single `TextButton` **DONE** → calls `_exitEntranceEditMode()`
- The `⋮` menu is hidden

### Zone interaction in edit mode

When `_entranceEditMode == true`, all zone gestures (vertex drag, zone move, zone tap) are suppressed — `_onPointerDown`, `_onPointerMove`, `_onPointerUp`, `_onTapUp`, `_onLongPress` all early-return if `_entranceEditMode`.

---

## Canvas Interaction (`zone_map_screen.dart` — `_ZoneCanvasState`)

### Hit regions (screen pixels, divided by `_viewScale` for canvas space)

| Target | Hit radius | Action |
|---|---|---|
| Center handle (gap midpoint on wall) | 20px | Drag slides `pos` along wall |
| Left endpoint handle | 16px | Drag adjusts `widthFrac` (expands/shrinks left side) |
| Right endpoint handle | 16px | Drag adjusts `widthFrac` (expands/shrinks right side) |
| Wall segment (no entrance) | 12px | Tap places entrance at that fractional `pos`, default `widthFrac = 0.15` |
| Different wall (entrance exists) | 12px | Tap moves entrance to that wall, preserves `pos` and `widthFrac` |

### Drag mechanics

**Center handle drag:**
- `pos` updates continuously: `newPos = (tapFraction along wall).clamp(widthFrac/2, 1 - widthFrac/2)` — gap stays fully within wall
- Live: updates `_editEntrance` → `setState` → repaints via `ZoneMapPainter`
- On pointer-up: `_editEntrance` is the final value (persisted when DONE is tapped)

**Endpoint handle drag:**
- Dragging left endpoint: `widthFrac` grows/shrinks from the left, `pos` adjusts to keep right edge fixed
- Dragging right endpoint: `widthFrac` grows/shrinks from the right, `pos` adjusts to keep left edge fixed
- `widthFrac` clamped to `[0.05, 0.40]`

### Placement hit test

Wall proximity uses `_pointToSegmentDist` (already in `_ZoneCanvasState`). Each of the 4 store boundary wall segments is tested; the closest within threshold wins. The fractional position along that wall is computed from the tap point.

### "No entrance" visual hint

When `_entranceEditMode == true` and `_editEntrance == null`, `ZoneMapPainter` renders faint dashed segments on all 4 walls with a label "TAP TO PLACE" at each wall's midpoint. This requires passing `entranceEditMode` flag to the painter.

---

## Data Flow

No schema changes. `StoreEntrance` model and `zoneMapNotifierProvider.notifier.setEntrance()` / `removeEntrance()` are unchanged. The only new persistence call is `setEntrance()` triggered from `_exitEntranceEditMode()`.

---

## Files Changed

| File | Change |
|---|---|
| `lib/features/dashboard/dashboard_screen.dart` | Remove `_EntranceEditorSheet`, `_showEditor`; update `_EntranceRow` buttons to navigate |
| `lib/features/zone_manager/zone_map_screen.dart` | Add `⋮` menu, entrance-edit mode state, pointer gesture routing, auto-entry from query param |
| `lib/features/zone_manager/zone_map_painter.dart` | Add `entranceEditMode` flag + handle/hint rendering |
| `lib/core/router/app_router.dart` | No change needed — `queryParameters` are passed through GoRouter automatically |

---

## Out of Scope

- Entrance width unit display (ft label) — cosmetic, not blocking
- Animated entrance handle highlight — not needed for v0.26
- Undo/redo for entrance — deferred to v0.3 Agent 3

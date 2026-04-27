# Entrance Canvas Placement Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace the abstract slider-based entrance bottom sheet with a direct canvas drag interaction on the Zone Map screen.

**Architecture:** `ZoneMapPainter` gains entrance-edit rendering (handles + placement hints). `_ZoneCanvasState` gains entrance-drag gesture handling. `ZoneMapScreen` gains an edit mode (banner + DONE button + `⋮` overflow menu). Dashboard `_EntranceRow` navigates to the Zone Map instead of opening a sheet.

**Tech Stack:** Flutter, Riverpod, GoRouter, CustomPainter, existing `StoreEntrance` model + `zoneMapNotifierProvider`

---

## File Map

| File | Change |
|---|---|
| `lib/features/zone_manager/zone_map_painter.dart` | Add `entranceEditMode`, `liveEntrance` params; add `_drawEntranceHandles`, `_drawEntrancePlacementHints` |
| `lib/features/zone_manager/zone_map_screen.dart` | Add edit-mode state, `⋮` menu, banner, DONE button, auto-entry from query param, gesture routing |
| `lib/features/dashboard/dashboard_screen.dart` | Remove `_EntranceEditorSheet` + `_showEditor`; update `_EntranceRow` to navigate |
| `test/features/zone_manager/entrance_edit_test.dart` | New — widget tests for overflow menu visibility + dashboard navigation |

---

## Task 1: Extend ZoneMapPainter for entrance-edit rendering

**Files:**
- Modify: `lib/features/zone_manager/zone_map_painter.dart`
- Test: `test/features/zone_manager/entrance_edit_test.dart`

- [ ] **Step 1: Write a failing test — painter `shouldRepaint` reflects new params**

```dart
// test/features/zone_manager/entrance_edit_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:merch_mobile/features/zone_manager/zone_map_painter.dart';
import 'package:merch_mobile/features/zone_manager/store_entrance.dart';

void main() {
  group('ZoneMapPainter shouldRepaint', () {
    ZoneMapPainter _painter({
      bool entranceEditMode = false,
      StoreEntrance? liveEntrance,
    }) =>
        ZoneMapPainter(
          zones: const [],
          canvasSize: const Size(400, 400),
          entranceEditMode: entranceEditMode,
          liveEntrance: liveEntrance,
        );

    test('repaint when entranceEditMode changes', () {
      final a = _painter(entranceEditMode: false);
      final b = _painter(entranceEditMode: true);
      expect(b.shouldRepaint(a), isTrue);
    });

    test('repaint when liveEntrance changes', () {
      final a = _painter();
      final b = _painter(
        liveEntrance: const StoreEntrance(wall: 0, pos: 0.5),
      );
      expect(b.shouldRepaint(a), isTrue);
    });

    test('no repaint when both unchanged', () {
      final entrance = const StoreEntrance(wall: 0, pos: 0.5);
      final a = _painter(entranceEditMode: true, liveEntrance: entrance);
      final b = _painter(entranceEditMode: true, liveEntrance: entrance);
      expect(b.shouldRepaint(a), isFalse);
    });
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

```bash
flutter test test/features/zone_manager/entrance_edit_test.dart
```

Expected: FAIL — `ZoneMapPainter` constructor does not accept `entranceEditMode` or `liveEntrance`.

- [ ] **Step 3: Add params to ZoneMapPainter constructor and shouldRepaint**

In `lib/features/zone_manager/zone_map_painter.dart`, update the constructor and add fields:

```dart
class ZoneMapPainter extends CustomPainter {
  ZoneMapPainter({
    required this.zones,
    required this.canvasSize,
    this.selectedZoneId,
    this.widthFt,
    this.depthFt,
    this.entranceJson,
    this.activeVertexIdx,
    this.snapPreviewPoints,
    this.entranceEditMode = false,   // ADD
    this.liveEntrance,               // ADD
  });

  // ... existing fields ...
  final bool entranceEditMode;       // ADD
  final StoreEntrance? liveEntrance; // ADD
```

Update `shouldRepaint`:

```dart
  @override
  bool shouldRepaint(ZoneMapPainter old) =>
      old.zones != zones ||
      old.selectedZoneId != selectedZoneId ||
      old.widthFt != widthFt ||
      old.depthFt != depthFt ||
      old.entranceJson != entranceJson ||
      old.activeVertexIdx != activeVertexIdx ||
      old.snapPreviewPoints != snapPreviewPoints ||
      old.entranceEditMode != entranceEditMode ||  // ADD
      old.liveEntrance != liveEntrance;            // ADD
```

- [ ] **Step 4: Add entrance-edit rendering in `paint()`**

In `paint()`, after `_drawStoreBoundary` call, add:

```dart
    if (_hasStoreDims) _drawStoreBoundary(canvas);
    // ADD: entrance-edit overlay
    if (entranceEditMode && _hasStoreDims) {
      final e = liveEntrance;
      if (e != null) {
        _drawEntranceHandles(canvas, e);
      } else {
        _drawEntrancePlacementHints(canvas);
      }
    }
```

Add `_drawEntranceHandles` method:

```dart
  void _drawEntranceHandles(Canvas canvas, StoreEntrance e) {
    final rect = _storeRect;
    final walls = [
      (Offset(rect.right, rect.bottom), Offset(rect.left, rect.bottom)),
      (Offset(rect.right, rect.top), Offset(rect.right, rect.bottom)),
      (Offset(rect.left, rect.top), Offset(rect.right, rect.top)),
      (Offset(rect.left, rect.bottom), Offset(rect.left, rect.top)),
    ];
    final (from, to) = walls[e.wall];
    final dir = to - from;
    final gapStart = (e.pos - e.widthFrac / 2).clamp(0.0, 1.0);
    final gapEnd = (e.pos + e.widthFrac / 2).clamp(0.0, 1.0);
    final pCenter = from + dir * e.pos;
    final pEnd1 = from + dir * gapStart;
    final pEnd2 = from + dir * gapEnd;

    // Highlight gap line
    canvas.drawLine(
      pEnd1, pEnd2,
      Paint()
        ..color = const Color(0xFFBF5534)
        ..strokeWidth = 3.0
        ..strokeCap = StrokeCap.round,
    );

    // Center drag handle (larger)
    _drawHandle(canvas, pCenter, radius: 8.0, fill: const Color(0xFFBF5534));

    // Endpoint handles (smaller)
    _drawHandle(canvas, pEnd1, radius: 6.0, fill: const Color(0xFFBF5534));
    _drawHandle(canvas, pEnd2, radius: 6.0, fill: const Color(0xFFBF5534));
  }

  void _drawHandle(Canvas canvas, Offset center, {required double radius, required Color fill}) {
    canvas.drawCircle(center, radius + 1.5, Paint()..color = Colors.white);
    canvas.drawCircle(center, radius, Paint()..color = fill);
  }
```

Add `_drawEntrancePlacementHints` method (shown when no entrance set in edit mode):

```dart
  void _drawEntrancePlacementHints(Canvas canvas) {
    final rect = _storeRect;
    final hintPaint = Paint()
      ..color = const Color(0xFFBF5534).withValues(alpha: 0.35)
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    // Draw dashed overlay on each wall midpoint with a small label
    final wallMids = [
      Offset(rect.center.dx, rect.bottom),
      Offset(rect.right, rect.center.dy),
      Offset(rect.center.dx, rect.top),
      Offset(rect.left, rect.center.dy),
    ];
    final wallNormals = [
      const Offset(0, 1),
      const Offset(1, 0),
      const Offset(0, -1),
      const Offset(-1, 0),
    ];
    for (var i = 0; i < 4; i++) {
      final mid = wallMids[i];
      final norm = wallNormals[i];
      // Small outward tick marks
      canvas.drawLine(mid, mid + norm * 10, hintPaint);
      _drawLabel(canvas, 'TAP TO PLACE', mid + norm * 16,
          color: const Color(0xFFBF5534).withValues(alpha: 0.5), fontSize: 9);
    }
  }
```

Add `_drawLabel` helper (if not already present — check; if it exists as `_drawEdgeLabel`, reuse its pattern):

```dart
  void _drawLabel(Canvas canvas, String text, Offset center,
      {Color? color, double fontSize = 10}) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: color ?? const Color(0xFF1A1917),
          fontSize: fontSize,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.8,
        ),
      ),
      textDirection: ui.TextDirection.ltr,
    )..layout();
    tp.paint(canvas, center - Offset(tp.width / 2, tp.height / 2));
  }
```

- [ ] **Step 5: Run tests to verify they pass**

```bash
flutter test test/features/zone_manager/entrance_edit_test.dart
```

Expected: All 3 `shouldRepaint` tests pass.

- [ ] **Step 6: Analyze for errors**

```bash
flutter analyze lib/features/zone_manager/zone_map_painter.dart
```

Expected: No issues. Fix any deprecation warnings using `.withValues(alpha: x)` instead of `.withOpacity(x)`.

---

## Task 2: Add entrance-edit mode to ZoneMapScreen

**Files:**
- Modify: `lib/features/zone_manager/zone_map_screen.dart`
- Test: `test/features/zone_manager/entrance_edit_test.dart`

- [ ] **Step 1: Write failing widget tests for mode UI**

Add to `test/features/zone_manager/entrance_edit_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:merch_mobile/features/zone_manager/zone_map_screen.dart';
import 'package:merch_mobile/core/providers/store_provider.dart';
import 'package:merch_mobile/core/providers/auth_provider.dart';

// Minimal provider overrides — same pattern as existing widget tests
Widget _buildScreen({String? role}) {
  return ProviderScope(
    overrides: [
      currentMembershipProvider.overrideWith((ref) => Stream.value(
        role == null ? null : _fakeMembership(role),
      )),
      activeStoreIdProvider.overrideWith((ref) async => 'store1'),
    ],
    child: const MaterialApp(home: ZoneMapScreen()),
  );
}

// Use the same fake membership helper as other widget tests in the project.
// See test/features/auth/login_screen_test.dart for the pattern.

group('ZoneMapScreen entrance edit mode', () {
  testWidgets('overflow menu hidden for staff role', (tester) async {
    await tester.pumpWidget(_buildScreen(role: 'staff'));
    await tester.pump();
    expect(find.byIcon(Icons.more_vert), findsNothing);
  });

  testWidgets('overflow menu shown for coordinator role', (tester) async {
    await tester.pumpWidget(_buildScreen(role: 'coordinator'));
    await tester.pump();
    expect(find.byIcon(Icons.more_vert), findsOneWidget);
  });

  testWidgets('Edit Entrance item appears in overflow menu', (tester) async {
    await tester.pumpWidget(_buildScreen(role: 'coordinator'));
    await tester.pump();
    await tester.tap(find.byIcon(Icons.more_vert));
    await tester.pumpAndSettle();
    expect(find.text('Edit Entrance'), findsOneWidget);
  });
});
```

- [ ] **Step 2: Run tests to verify they fail**

```bash
flutter test test/features/zone_manager/entrance_edit_test.dart --name "entrance edit mode"
```

Expected: FAIL — `ZoneMapScreen` has no overflow menu.

- [ ] **Step 3: Add entrance-edit mode state to `_ZoneMapScreenState`**

In `lib/features/zone_manager/zone_map_screen.dart`, add to `_ZoneMapScreenState`:

```dart
  bool _entranceEditMode = false;

  void _enterEntranceEditMode() {
    setState(() => _entranceEditMode = true);
  }

  void _exitEntranceEditMode(BuildContext context) {
    // Canvas persists _editEntrance via callback — we just exit mode
    setState(() => _entranceEditMode = false);
  }
```

- [ ] **Step 4: Auto-entry from query param in `initState`**

In `initState`, after `_checkStoreDimensions()`:

```dart
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkStoreDimensions();
      // Auto-enter entrance edit mode if navigated from dashboard
      final params = GoRouterState.of(context).uri.queryParameters;
      if (params['entranceEdit'] == 'true') _enterEntranceEditMode();
    });
  }
```

- [ ] **Step 5: Update `build()` AppBar and body**

Replace the current `Scaffold` return with:

```dart
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(zoneMapNotifierProvider);

    ref.listen(zoneMapNotifierProvider, (prev, next) {
      if (prev?.storeData == null && _needsDimensions(next.storeData)) {
        _showSetupDialog();
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(_entranceEditMode ? 'ENTRANCE' : 'ZONE MAP'),
        bottom: _entranceEditMode
            ? PreferredSize(
                preferredSize: const Size.fromHeight(28),
                child: Container(
                  color: const Color(0xFFBF5534).withValues(alpha: 0.12),
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: const Center(
                    child: Text(
                      'DRAG GAP · DRAG ENDS TO RESIZE · TAP WALL TO PLACE',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                        color: Color(0xFFBF5534),
                      ),
                    ),
                  ),
                ),
              )
            : null,
        actions: _entranceEditMode
            ? [
                TextButton(
                  onPressed: () => _exitEntranceEditMode(context),
                  child: const Text(
                    'DONE',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
              ]
            : [
                RoleGuard(
                  allowedRoles: const ['coordinator', 'manager'],
                  child: PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert),
                    onSelected: (value) {
                      if (value == 'entrance') _enterEntranceEditMode();
                    },
                    itemBuilder: (_) => const [
                      PopupMenuItem(
                        value: 'entrance',
                        child: Text('Edit Entrance'),
                      ),
                    ],
                  ),
                ),
              ],
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : _ZoneCanvas(
              onZoneTap: _entranceEditMode ? (_) {} : _onZoneTap,
              entranceEditMode: _entranceEditMode,
            ),
      floatingActionButton: _entranceEditMode
          ? null
          : RoleGuard(
              allowedRoles: const ['coordinator', 'manager'],
              child: FloatingActionButton.extended(
                onPressed: () =>
                    ref.read(zoneMapNotifierProvider.notifier).addZone(),
                label: const Text('ADD ZONE'),
                icon: const Icon(Icons.add),
                backgroundColor: AppTheme.accent,
              ),
            ),
    );
  }
```

- [ ] **Step 6: Update `_ZoneCanvas` to accept new params**

Change `_ZoneCanvas` constructor:

```dart
class _ZoneCanvas extends ConsumerStatefulWidget {
  const _ZoneCanvas({
    required this.onZoneTap,
    this.entranceEditMode = false,
  });
  final void Function(String zoneId) onZoneTap;
  final bool entranceEditMode;

  @override
  ConsumerState<_ZoneCanvas> createState() => _ZoneCanvasState();
}
```

- [ ] **Step 7: Run tests**

```bash
flutter test test/features/zone_manager/entrance_edit_test.dart --name "entrance edit mode"
```

Expected: All 3 tests pass.

- [ ] **Step 8: Analyze**

```bash
flutter analyze lib/features/zone_manager/zone_map_screen.dart
```

Expected: No issues.

---

## Task 3: Entrance gesture handling in `_ZoneCanvasState`

**Files:**
- Modify: `lib/features/zone_manager/zone_map_screen.dart` (`_ZoneCanvasState` section)

No new tests for this task — gesture math is integration-level and covered by the existing canvas test patterns. Verify manually via `flutter run`.

- [ ] **Step 1: Add entrance drag state fields to `_ZoneCanvasState`**

Add to `_ZoneCanvasState` field declarations (alongside existing drag fields):

```dart
  // Entrance drag state
  StoreEntrance? _editEntrance;
  String? _entranceDragMode; // 'center' | 'end1' | 'end2'
  Offset? _entranceDragStartCanvas;
  StoreEntrance? _entranceDragStartState;
```

Add `_resetEntranceGesture()`:

```dart
  void _resetEntranceGesture() {
    _entranceDragMode = null;
    _entranceDragStartCanvas = null;
    _entranceDragStartState = null;
  }
```

- [ ] **Step 2: Add entrance helper methods**

Add to `_ZoneCanvasState`:

```dart
  /// Returns the store rect in canvas coordinates.
  Rect get _storeRectCanvas {
    final st = ref.read(zoneMapNotifierProvider);
    final w = st.storeData?.widthFt;
    final d = st.storeData?.depthFt;
    if (w == null || d == null) return Rect.zero;
    final ppf = (_canvasSize.width / w).clamp(0.0, _canvasSize.height / d);
    return Rect.fromLTWH(0, 0, w * ppf, d * ppf);
  }

  /// Wall segments in the same order as StoreEntrance (0=bottom,1=right,2=top,3=left).
  List<(Offset, Offset)> _wallSegments(Rect rect) => [
    (Offset(rect.right, rect.bottom), Offset(rect.left, rect.bottom)),
    (Offset(rect.right, rect.top), Offset(rect.right, rect.bottom)),
    (Offset(rect.left, rect.top), Offset(rect.right, rect.top)),
    (Offset(rect.left, rect.bottom), Offset(rect.left, rect.top)),
  ];

  /// Returns the wall index (0-3) closest to [canvas] within threshold, or null.
  int? _hitEntranceWall(Offset canvas) {
    final rect = _storeRectCanvas;
    if (rect == Rect.zero) return null;
    final threshold = 12.0 / _viewScale;
    final walls = _wallSegments(rect);
    int? best;
    double bestDist = threshold;
    for (var i = 0; i < walls.length; i++) {
      final d = _pointToSegmentDist(canvas, walls[i].$1, walls[i].$2);
      if (d < bestDist) { bestDist = d; best = i; }
    }
    return best;
  }

  /// Fractional position (0-1) of [canvas] along wall [wallIdx].
  double _wallFraction(int wallIdx, Offset canvas) {
    final rect = _storeRectCanvas;
    final walls = _wallSegments(rect);
    final (from, to) = walls[wallIdx];
    final dir = to - from;
    final len2 = dir.dx * dir.dx + dir.dy * dir.dy;
    if (len2 == 0) return 0.5;
    final t = ((canvas - from).dx * dir.dx + (canvas - from).dy * dir.dy) / len2;
    return t.clamp(0.0, 1.0);
  }

  /// Compute canvas positions of the 3 entrance handles: (center, end1, end2).
  ({Offset center, Offset end1, Offset end2})? _entranceHandlePositions(StoreEntrance e) {
    final rect = _storeRectCanvas;
    if (rect == Rect.zero) return null;
    final walls = _wallSegments(rect);
    final (from, to) = walls[e.wall];
    final dir = to - from;
    final gapStart = (e.pos - e.widthFrac / 2).clamp(0.0, 1.0);
    final gapEnd = (e.pos + e.widthFrac / 2).clamp(0.0, 1.0);
    return (
      center: from + dir * e.pos,
      end1: from + dir * gapStart,
      end2: from + dir * gapEnd,
    );
  }
```

- [ ] **Step 3: Add `_handleEntrancePointerDown`**

```dart
  void _handleEntrancePointerDown(PointerDownEvent event) {
    final canvas = _toCanvas(event.localPosition);
    final e = _editEntrance;

    if (e != null) {
      final handles = _entranceHandlePositions(e);
      if (handles != null) {
        final centerR = 20.0 / _viewScale;
        final endR = 16.0 / _viewScale;

        if ((handles.center - canvas).distance < centerR) {
          _primaryPointer = event.pointer;
          setState(() {
            _entranceDragMode = 'center';
            _entranceDragStartCanvas = canvas;
            _entranceDragStartState = e;
          });
          return;
        }
        if ((handles.end1 - canvas).distance < endR) {
          _primaryPointer = event.pointer;
          setState(() {
            _entranceDragMode = 'end1';
            _entranceDragStartCanvas = canvas;
            _entranceDragStartState = e;
          });
          return;
        }
        if ((handles.end2 - canvas).distance < endR) {
          _primaryPointer = event.pointer;
          setState(() {
            _entranceDragMode = 'end2';
            _entranceDragStartCanvas = canvas;
            _entranceDragStartState = e;
          });
          return;
        }
      }
    }

    // Tap on a wall — place or move entrance
    final wallIdx = _hitEntranceWall(canvas);
    if (wallIdx != null) {
      final frac = _wallFraction(wallIdx, canvas);
      if (e == null || wallIdx != e.wall) {
        // Place new or move to different wall
        final newEntrance = StoreEntrance(
          wall: wallIdx,
          pos: frac.clamp(0.075, 0.925), // keep gap within wall
          widthFrac: e?.widthFrac ?? 0.15,
        );
        setState(() => _editEntrance = newEntrance);
      }
    }
  }
```

- [ ] **Step 4: Add `_handleEntrancePointerMove`**

```dart
  void _handleEntrancePointerMove(PointerMoveEvent event) {
    if (event.pointer != _primaryPointer) return;
    if (_entranceDragMode == null || _entranceDragStartState == null) return;

    final canvas = _toCanvas(event.localPosition);
    final start = _entranceDragStartState!;

    if (_entranceDragMode == 'center') {
      final frac = _wallFraction(start.wall, canvas)
          .clamp(start.widthFrac / 2, 1.0 - start.widthFrac / 2);
      setState(() => _editEntrance = start.copyWith(pos: frac));
    } else if (_entranceDragMode == 'end1') {
      // end1 is the start of the gap; dragging it changes widthFrac keeping end2 fixed
      final frac = _wallFraction(start.wall, canvas).clamp(0.0, 1.0);
      final end2Frac = (start.pos + start.widthFrac / 2).clamp(0.0, 1.0);
      final newWidthFrac = (end2Frac - frac).clamp(0.05, 0.40);
      final newPos = end2Frac - newWidthFrac / 2;
      setState(() => _editEntrance = start.copyWith(pos: newPos, widthFrac: newWidthFrac));
    } else if (_entranceDragMode == 'end2') {
      // end2 is the end of the gap; dragging it changes widthFrac keeping end1 fixed
      final frac = _wallFraction(start.wall, canvas).clamp(0.0, 1.0);
      final end1Frac = (start.pos - start.widthFrac / 2).clamp(0.0, 1.0);
      final newWidthFrac = (frac - end1Frac).clamp(0.05, 0.40);
      final newPos = end1Frac + newWidthFrac / 2;
      setState(() => _editEntrance = start.copyWith(pos: newPos, widthFrac: newWidthFrac));
    }
  }
```

- [ ] **Step 5: Add `_handleEntrancePointerUp`**

```dart
  void _handleEntrancePointerUp(PointerUpEvent event) {
    if (event.pointer != _primaryPointer) return;
    // Persist current _editEntrance to provider
    if (_editEntrance != null) {
      ref
          .read(zoneMapNotifierProvider.notifier)
          .setEntrance(_editEntrance!.toJson());
    }
    setState(() {
      _primaryPointer = null;
      _resetEntranceGesture();
    });
  }
```

- [ ] **Step 6: Route gesture events through entrance mode in `_onPointerDown/Move/Up`**

At the top of each gesture handler, add early-return routing:

```dart
  void _onPointerDown(PointerDownEvent event) {
    _activePointers[event.pointer] = event.localPosition;
    if (_activePointers.length >= 2) { /* existing pinch logic */ return; }
    if (_activePointers.length > 2) return;
    if (_primaryPointer != null) return;

    // ADD: entrance edit routing
    if (widget.entranceEditMode) {
      _handleEntrancePointerDown(event);
      return;
    }
    // ... rest of existing _onPointerDown ...
  }

  void _onPointerMove(PointerMoveEvent event) {
    _activePointers[event.pointer] = event.localPosition;
    if (_activePointers.length >= 2) { _updatePinch(); return; }
    if (event.pointer != _primaryPointer) return;

    // ADD: entrance edit routing
    if (widget.entranceEditMode) {
      _handleEntrancePointerMove(event);
      return;
    }
    // ... rest of existing _onPointerMove ...
  }

  void _onPointerUp(PointerUpEvent event) {
    _activePointers.remove(event.pointer);
    if (_activePointers.length < 2) _resetPinch();

    // ADD: entrance edit routing
    if (widget.entranceEditMode) {
      _handleEntrancePointerUp(event);
      return;
    }
    // ... rest of existing _onPointerUp ...
  }
```

Also suppress `_onTapUp` and `_onLongPress` in entrance mode:

```dart
  void _onTapUp(TapUpDetails details) {
    if (widget.entranceEditMode) return; // ADD
    // ... existing ...
  }

  void _onLongPress(LongPressStartDetails details) {
    if (widget.entranceEditMode) return; // ADD
    // ... existing ...
  }
```

- [ ] **Step 7: Sync `_editEntrance` from provider state when entering edit mode**

In `_ZoneCanvasState`, add a `didUpdateWidget` override so `_editEntrance` seeds from current store data when edit mode activates:

```dart
  @override
  void didUpdateWidget(_ZoneCanvas old) {
    super.didUpdateWidget(old);
    if (!old.entranceEditMode && widget.entranceEditMode) {
      // Seed from current store data
      final entrance = StoreEntrance.fromJson(
        ref.read(zoneMapNotifierProvider).storeData?.entranceJson,
      );
      setState(() => _editEntrance = entrance);
    }
    if (old.entranceEditMode && !widget.entranceEditMode) {
      setState(() {
        _editEntrance = null;
        _resetEntranceGesture();
      });
    }
  }
```

- [ ] **Step 8: Pass `liveEntrance` and `entranceEditMode` to `ZoneMapPainter`**

In `_ZoneCanvasState.build()`, update the `ZoneMapPainter` constructor call:

```dart
        _painter = ZoneMapPainter(
          zones: state.zones,
          canvasSize: _canvasSize,
          selectedZoneId: state.selectedZoneId,
          widthFt: state.storeData?.widthFt,
          depthFt: state.storeData?.depthFt,
          entranceJson: state.storeData?.entranceJson,
          activeVertexIdx: _dragVertexIdx,
          snapPreviewPoints: (snapPreview != null && snapPreview != _dragPoints)
              ? snapPreview
              : null,
          entranceEditMode: widget.entranceEditMode,  // ADD
          liveEntrance: _editEntrance,                // ADD
        );
```

- [ ] **Step 9: Analyze**

```bash
flutter analyze lib/features/zone_manager/zone_map_screen.dart
```

Expected: No issues.

---

## Task 4: Update Dashboard — remove sheet, navigate to Zone Map

**Files:**
- Modify: `lib/features/dashboard/dashboard_screen.dart`
- Test: `test/features/zone_manager/entrance_edit_test.dart`

- [ ] **Step 1: Write failing test — dashboard ADD ENTRANCE button is present and tappable**

Add to `test/features/zone_manager/entrance_edit_test.dart`:

```dart
import 'package:merch_mobile/features/dashboard/dashboard_screen.dart';

group('DashboardScreen entrance row', () {
  testWidgets('shows ADD ENTRANCE when no entrance set', (tester) async {
    // Use the same ProviderScope pattern as fixture_mini_panel_test.dart
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          // Override zoneMapNotifierProvider to return a state with no entrance
          zoneMapNotifierProvider.overrideWith(
            (ref) => ZoneMapNotifier()..state = ZoneMapState(
              zones: const [],
              storeData: _fakeStore(entranceJson: null),
            ),
          ),
          currentMembershipProvider.overrideWith(
            (ref) => Stream.value(_fakeMembership('coordinator')),
          ),
          dashboardStatsProvider.overrideWith(
            (ref) async => const DashboardStats(
              zoneCount: 0, fixtureCount: 0, productCount: 0,
              pendingJoinRequests: 0, pendingProposals: 0,
              myPhotoCount: 0, myProposalCount: 0,
            ),
          ),
          activeStoreIdProvider.overrideWith((ref) async => 'store1'),
        ],
        child: const MaterialApp(home: DashboardScreen()),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('ADD ENTRANCE'), findsOneWidget);
    // Should NOT find any bottom sheet slider content
    expect(find.text('POSITION'), findsNothing);
  });
});
```

- [ ] **Step 2: Run test to confirm it passes already (no sheet on initial render)**

```bash
flutter test test/features/zone_manager/entrance_edit_test.dart --name "dashboard entrance"
```

Expected: PASS — `ADD ENTRANCE` exists, no `POSITION` slider text. (This verifies the existing state is clean.)

- [ ] **Step 3: Remove `_EntranceEditorSheet` and `_showEditor` from `dashboard_screen.dart`**

In `lib/features/dashboard/dashboard_screen.dart`:

1. Delete the entire `_EntranceEditorSheet` class (the `StatefulWidget` and its `State`).
2. Delete the `_showEditor` method from `_EntranceRow`.

- [ ] **Step 4: Update `_EntranceRow` buttons to navigate**

Replace the `build` method of `_EntranceRow`:

```dart
  @override
  Widget build(BuildContext context) {
    final entrance = StoreEntrance.fromJson(store?.entranceJson);

    if (entrance == null) {
      return SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          onPressed: () => context.goNamed(
            AppRoutes.zoneMap,
            queryParameters: {'entranceEdit': 'true'},
          ),
          icon: const Icon(Icons.door_front_door_outlined, size: 16),
          label: const Text('ADD ENTRANCE'),
        ),
      );
    }

    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => context.goNamed(
              AppRoutes.zoneMap,
              queryParameters: {'entranceEdit': 'true'},
            ),
            icon: const Icon(Icons.door_front_door_outlined, size: 16),
            label: Text('EDIT ENTRANCE (${entrance.wallName})'),
          ),
        ),
        const SizedBox(width: DesignTokens.spaceXs),
        OutlinedButton(
          onPressed: () => ref.read(zoneMapNotifierProvider.notifier).removeEntrance(),
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.red.shade600,
            side: BorderSide(color: Colors.red.shade600),
          ),
          child: const Text('REMOVE'),
        ),
      ],
    );
  }
```

Remove the unused `onSave` field from `_EntranceRow` since the sheet is gone:

```dart
class _EntranceRow extends StatelessWidget {
  const _EntranceRow({required this.ref, required this.store});
  final WidgetRef ref;
  final StoresTableData? store;
  // onSave removed
```

- [ ] **Step 5: Analyze**

```bash
flutter analyze lib/features/dashboard/dashboard_screen.dart
```

Expected: No issues. Remove any imports that are now unused (e.g., `store_entrance.dart` import may still be needed for `StoreEntrance.fromJson` — keep it).

---

## Task 5: Run full suite and commit

- [ ] **Step 1: Run all tests**

```bash
flutter test
```

Expected: All tests pass (95+ passing).

- [ ] **Step 2: Commit**

```bash
git add \
  lib/features/zone_manager/zone_map_painter.dart \
  lib/features/zone_manager/zone_map_screen.dart \
  lib/features/dashboard/dashboard_screen.dart \
  test/features/zone_manager/entrance_edit_test.dart
git commit -m "feat: entrance placement on canvas — drag gap, resize endpoints, wall-tap to place"
```

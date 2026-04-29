import 'dart:math';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/store_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/design_tokens.dart';
import '../zone_manager/zone_shape.dart';
import 'builder_canvas_painter.dart';
import 'element_delete_sheet.dart';
import 'element_library_panel.dart';
import 'fixture_actions_sheet.dart';
import 'fixture_mini_panel.dart';
import 'floor_builder_provider.dart';
import 'mannequin_type_sheet.dart';
import 'planogram_picker_sheet.dart';
import 'prop_type_sheet.dart';
import 'snap_grid.dart';
import 'wall_placement_sheet.dart';
import 'zone_edge_helper.dart';

class FloorBuilderScreen extends ConsumerStatefulWidget {
  const FloorBuilderScreen({super.key, required this.zoneId});
  final String zoneId;

  @override
  ConsumerState<FloorBuilderScreen> createState() => _FloorBuilderScreenState();
}

class _FloorBuilderScreenState extends ConsumerState<FloorBuilderScreen> {
  double _pixelsPerFt = 20.0;
  Size _canvasSize = Size.zero;

  // View transform
  double _viewScale = 1.0;
  Offset _viewOffset = Offset.zero;
  final Map<int, Offset> _activePointers = {};
  double? _pinchDistanceStart;
  Offset? _pinchFocalStart;
  double? _pinchScaleStart;
  Offset? _pinchOffsetStart;

  // Single-finger pan on empty canvas
  bool _isPanning = false;
  Offset? _panStartScreen;
  Offset? _panStartOffset;

  // Ghost drag state
  Offset? _ghostPos;
  String? _ghostType;

  // Wall placement mode
  List<ZoneEdge>? _wallEdges;

  // Fixture drag state
  BuilderCanvasPainter? _painter;
  String? _dragFixtureId;
  Offset? _dragFixtureBeforePos;
  int? _primaryPointer;

  // Non-fixture drag state
  String? _dragPropId;
  Offset? _dragPropBeforePos;
  String? _dragMannequinId;
  Offset? _dragMannequinBeforePos;
  String? _dragPlatformId;
  Offset? _dragPlatformBeforePos;

  // Resize state
  String? _resizingFixtureId;
  String? _resizeHandle;
  Offset? _resizeStartPos;
  double? _resizeStartWidth;
  double? _resizeStartDepth;
  double? _resizeStartAngle;
  double? _resizeStartPosX;
  double? _resizeStartPosY;

  // Drag offset — prevents jump-to-cursor on pointer-down
  Offset? _dragPointerOffsetFt;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(floorBuilderNotifierProvider.notifier).loadFixtures(widget.zoneId);
    });
  }

  void _showElementLibrary() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) => ElementLibraryPanel(
        onFixtureSelected: (type) {
          ref.read(floorBuilderNotifierProvider.notifier)
              .addFixture(type, _viewCenterFt());
        },
        onWallSelected: _enterWallMode,
        onDragStarted: () => Navigator.of(sheetCtx).pop(),
        onMannequinSelected: () => _showMannequinTypePicker(),
        onPlatformSelected: () {
          ref.read(floorBuilderNotifierProvider.notifier)
              .addPlatform(positionFt: _viewCenterFt());
        },
        onPropSelected: () => _showPropTypePicker(),
      ),
    );
  }

  void _showMannequinTypePicker() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => MannequinTypeSheet(
        onSelect: (type, mount) {
          ref.read(floorBuilderNotifierProvider.notifier).addMannequin(
            mannequinType: type,
            mountType: mount,
            positionFt: _viewCenterFt(),
          );
        },
      ),
    );
  }

  void _showPropTypePicker() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => PropTypeSheet(
        onSelect: (type) {
          ref.read(floorBuilderNotifierProvider.notifier).addSceneProp(
            propType: type,
            positionFt: _viewCenterFt(),
          );
        },
      ),
    );
  }

  void _enterWallMode() {
    final zone = ref.read(zoneByIdProvider(widget.zoneId)).valueOrNull;
    if (zone == null) return;
    final zonePts = ZoneShape.decode(zone.shapePoints);
    if (zonePts.length < 3) return;
    final store = ref.read(activeStoreProvider).valueOrNull;
    final edges = ZoneEdge.compute(
      zonePts,
      _canvasSize,
      _pixelsPerFt,
      zoneOriginNorm: Offset(zone.posX, zone.posY),
      storeWidthFt: store?.widthFt,
      storeDepthFt: store?.depthFt,
    );
    if (edges.isEmpty) return;
    setState(() => _wallEdges = edges);
    _showWallPlacementSheet(edges);
  }

  void _showWallPlacementSheet(List<ZoneEdge> edges) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => WallPlacementSheet(
        edges: edges,
        pixelsPerFt: _pixelsPerFt,
        onPlace: (edge, lengthFt) {
          final centerFt = Offset(
            edge.midPx.dx / _pixelsPerFt,
            edge.midPx.dy / _pixelsPerFt,
          );
          ref.read(floorBuilderNotifierProvider.notifier).addWallFixture(
            centerFt: centerFt,
            lengthFt: lengthFt,
            angleDeg: edge.angleDeg,
          );
          setState(() => _wallEdges = null);
        },
      ),
    ).whenComplete(() => setState(() => _wallEdges = null));
  }

  void _onFixtureLongPress(String fixtureId, String currentLabel) {
    final fixture = ref
        .read(floorBuilderNotifierProvider)
        .fixtures
        .firstWhere((f) => f.id == fixtureId);
    showModalBottomSheet<void>(
      context: context,
      builder: (_) => FixtureActionsSheet(
        fixtureId: fixtureId,
        currentLabel: currentLabel,
        fixtureType: fixture.fixtureType,
        wallAdjacent: fixture.wallAdjacent,
        notifier: ref.read(floorBuilderNotifierProvider.notifier),
      ),
    );
  }

  void _openPlanogramPicker(String fixtureId, {required bool front}) {
    final state = ref.read(floorBuilderNotifierProvider);
    final fixture = state.fixtures.firstWhere((f) => f.id == fixtureId);
    final planogramList = state.planograms.values.toList();
    final currentId = front ? fixture.planogramId : fixture.planogramIdBack;
    final label = fixture.label.isNotEmpty ? fixture.label : fixture.fixtureType.toUpperCase();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => PlanogramPickerSheet(
        planograms: planogramList,
        currentPlanogramId: currentId,
        fixtureLabel: label,
        onSelect: (id) {
          if (front) {
            ref.read(floorBuilderNotifierProvider.notifier).assignPlanogram(fixtureId, id);
          } else {
            ref.read(floorBuilderNotifierProvider.notifier).assignPlanogramBack(fixtureId, id);
          }
        },
      ),
    );
  }

  void _handleLongPressInCanvas(LongPressStartDetails details) {
    if (_painter == null) return;
    final canvas = _toCanvas(details.localPosition);
    final state = ref.read(floorBuilderNotifierProvider);

    // Fixtures → multi-select
    for (final entry in _painter!.fixtureRects.entries) {
      if (_hitFixtureBody(entry.key, entry.value, canvas)) {
        final fixture = state.fixtures.firstWhereOrNull((f) => f.id == entry.key);
        if (fixture == null) continue;
        if (!state.isMultiSelectMode) {
          ref.read(floorBuilderNotifierProvider.notifier).enterMultiSelect(fixture.id);
        } else {
          ref.read(floorBuilderNotifierProvider.notifier).toggleMultiSelectFixture(fixture.id);
        }
        return;
      }
    }

    // Props → delete sheet
    for (final entry in _painter!.propRects.entries) {
      if (entry.value.contains(canvas)) {
        _showPropActionsSheet(entry.key);
        return;
      }
    }

    // Mannequins → delete sheet
    for (final entry in _painter!.mannequinRects.entries) {
      if (entry.value.contains(canvas)) {
        _showMannequinActionsSheet(entry.key);
        return;
      }
    }

    // Platforms → delete sheet
    for (final entry in _painter!.platformRects.entries) {
      if (entry.value.contains(canvas)) {
        _showPlatformActionsSheet(entry.key);
        return;
      }
    }
  }

  void _showPropActionsSheet(String propId) {
    final prop = ref.read(floorBuilderNotifierProvider).sceneProps
        .firstWhereOrNull((p) => p.id == propId);
    if (prop == null) return;
    showModalBottomSheet<void>(
      context: context,
      builder: (_) => ElementDeleteSheet(
        title: prop.propType.toUpperCase(),
        subtitle: 'SCENE PROP',
        onDelete: () =>
            ref.read(floorBuilderNotifierProvider.notifier).deleteSceneProp(propId),
      ),
    );
  }

  void _showMannequinActionsSheet(String mannequinId) {
    final m = ref.read(floorBuilderNotifierProvider).mannequins
        .firstWhereOrNull((m) => m.id == mannequinId);
    if (m == null) return;
    showModalBottomSheet<void>(
      context: context,
      builder: (_) => ElementDeleteSheet(
        title: m.mannequinType.toUpperCase().replaceAll('_', ' '),
        subtitle: 'MANNEQUIN',
        onDelete: () =>
            ref.read(floorBuilderNotifierProvider.notifier).deleteMannequin(mannequinId),
      ),
    );
  }

  void _showPlatformActionsSheet(String platformId) {
    showModalBottomSheet<void>(
      context: context,
      builder: (_) => ElementDeleteSheet(
        title: 'PLATFORM',
        subtitle: 'RAISED ELEMENT',
        onDelete: () =>
            ref.read(floorBuilderNotifierProvider.notifier).deletePlatform(platformId),
      ),
    );
  }

  void _onPointerDown(PointerDownEvent event) {
    _activePointers[event.pointer] = event.localPosition;

    if (_activePointers.length == 2) {
      if (_primaryPointer != null) {
        setState(() {
          _dragFixtureId = null;
          _dragFixtureBeforePos = null;
          _dragPropId = null;
          _dragPropBeforePos = null;
          _dragMannequinId = null;
          _dragMannequinBeforePos = null;
          _dragPlatformId = null;
          _dragPlatformBeforePos = null;
          _resizingFixtureId = null;
          _resizeHandle = null;
          _resizeStartPos = null;
          _resizeStartAngle = null;
          _dragPointerOffsetFt = null;
          _resizeStartPosX = null;
          _resizeStartPosY = null;
          _isPanning = false;
          _panStartScreen = null;
        });
        _primaryPointer = null;
      }
      _pinchScaleStart = _viewScale;
      _pinchOffsetStart = _viewOffset;
      _pinchFocalStart = _pinchFocal();
      _pinchDistanceStart = _pinchDistance();
      return;
    }
    if (_activePointers.length > 2) return;
    if (_painter == null || _primaryPointer != null) return;

    final canvas = _toCanvas(event.localPosition);

    // 1. Resize handle hit-test (highest priority)
    for (final entry in _painter!.resizeHandleRects.entries) {
      for (final hEntry in entry.value.entries) {
        if (hEntry.value.contains(canvas)) {
          _primaryPointer = event.pointer;
          final fixture = ref
              .read(floorBuilderNotifierProvider)
              .fixtures
              .firstWhere((f) => f.id == entry.key);
          setState(() {
            _resizingFixtureId = entry.key;
            _resizeHandle = hEntry.key;
            _resizeStartPos = canvas;
            _resizeStartWidth = fixture.widthFt;
            _resizeStartDepth = fixture.depthFt;
            _resizeStartAngle = fixture.rotation * pi / 180;
            _resizeStartPosX = fixture.posX;
            _resizeStartPosY = fixture.posY;
          });
          return;
        }
      }
    }

    // 2. Badge hit-test
    for (final entry in _painter!.badgeRects.entries) {
      if (entry.value.contains(canvas)) {
        _primaryPointer = event.pointer;
        _openPlanogramPicker(entry.key, front: true);
        return;
      }
    }
    for (final entry in _painter!.badgeBackRects.entries) {
      if (entry.value.contains(canvas)) {
        _primaryPointer = event.pointer;
        _openPlanogramPicker(entry.key, front: false);
        return;
      }
    }

    // 3. Fixture body hit-test
    for (final entry in _painter!.fixtureRects.entries) {
      if (_hitFixtureBody(entry.key, entry.value, canvas)) {
        _primaryPointer = event.pointer;
        final currentState = ref.read(floorBuilderNotifierProvider);
        if (currentState.isMultiSelectMode) {
          ref.read(floorBuilderNotifierProvider.notifier).toggleMultiSelectFixture(entry.key);
          return;
        }
        ref.read(floorBuilderNotifierProvider.notifier).selectFixture(entry.key);
        final f = currentState.fixtures.firstWhereOrNull((f) => f.id == entry.key);
        final cursorFtF = Offset(canvas.dx / _pixelsPerFt, canvas.dy / _pixelsPerFt);
        setState(() {
          _dragFixtureId = entry.key;
          _dragFixtureBeforePos = f != null ? Offset(f.posX, f.posY) : null;
          _dragPointerOffsetFt = f != null
              ? Offset(cursorFtF.dx - f.posX, cursorFtF.dy - f.posY)
              : Offset.zero;
        });
        return;
      }
    }

    // 4. Prop hit-test
    for (final entry in _painter!.propRects.entries) {
      if (entry.value.contains(canvas)) {
        _primaryPointer = event.pointer;
        final p = ref.read(floorBuilderNotifierProvider).sceneProps
            .firstWhereOrNull((p) => p.id == entry.key);
        final cursorFtP = Offset(canvas.dx / _pixelsPerFt, canvas.dy / _pixelsPerFt);
        setState(() {
          _dragPropId = entry.key;
          _dragPropBeforePos = p != null ? Offset(p.positionX, p.positionY) : null;
          _dragPointerOffsetFt = p != null
              ? Offset(cursorFtP.dx - p.positionX, cursorFtP.dy - p.positionY)
              : Offset.zero;
        });
        return;
      }
    }

    // 5. Mannequin hit-test
    for (final entry in _painter!.mannequinRects.entries) {
      if (entry.value.contains(canvas)) {
        _primaryPointer = event.pointer;
        final m = ref.read(floorBuilderNotifierProvider).mannequins
            .firstWhereOrNull((m) => m.id == entry.key);
        final cursorFtM = Offset(canvas.dx / _pixelsPerFt, canvas.dy / _pixelsPerFt);
        setState(() {
          _dragMannequinId = entry.key;
          _dragMannequinBeforePos = m != null ? Offset(m.positionX, m.positionY) : null;
          _dragPointerOffsetFt = m != null
              ? Offset(cursorFtM.dx - m.positionX, cursorFtM.dy - m.positionY)
              : Offset.zero;
        });
        return;
      }
    }

    // 6. Platform hit-test
    for (final entry in _painter!.platformRects.entries) {
      if (entry.value.contains(canvas)) {
        _primaryPointer = event.pointer;
        final p = ref.read(floorBuilderNotifierProvider).platforms
            .firstWhereOrNull((p) => p.id == entry.key);
        final cursorFtPl = Offset(canvas.dx / _pixelsPerFt, canvas.dy / _pixelsPerFt);
        setState(() {
          _dragPlatformId = entry.key;
          _dragPlatformBeforePos = p != null ? Offset(p.positionX, p.positionY) : null;
          _dragPointerOffsetFt = p != null
              ? Offset(cursorFtPl.dx - p.positionX, cursorFtPl.dy - p.positionY)
              : Offset.zero;
        });
        return;
      }
    }

    // 7. Empty canvas — deselect + pan
    final currentState = ref.read(floorBuilderNotifierProvider);
    if (currentState.isMultiSelectMode) {
      ref.read(floorBuilderNotifierProvider.notifier).exitMultiSelect();
      _primaryPointer = event.pointer;
      return;
    }
    ref.read(floorBuilderNotifierProvider.notifier).selectFixture(null);
    _primaryPointer = event.pointer;
    _isPanning = true;
    _panStartScreen = event.localPosition;
    _panStartOffset = _viewOffset;
  }

  void _onPointerMove(PointerMoveEvent event) {
    _activePointers[event.pointer] = event.localPosition;

    if (_activePointers.length >= 2) {
      _updatePinch();
      return;
    }

    if (event.pointer != _primaryPointer) return;
    final canvas = _toCanvas(event.localPosition);

    // Resize
    if (_resizingFixtureId != null && _resizeHandle != null && _resizeStartPos != null) {
      final delta = canvas - _resizeStartPos!;
      final angle = _resizeStartAngle ?? 0.0;
      final localW = (delta.dx * cos(angle) + delta.dy * sin(angle)) / _pixelsPerFt;
      final localD = (-delta.dx * sin(angle) + delta.dy * cos(angle)) / _pixelsPerFt;
      double? newWidth;
      double? newDepth;
      double? newPosX;
      double? newPosY;
      switch (_resizeHandle!) {
        case 'right':
          newWidth = (_resizeStartWidth! + localW).clamp(0.5, double.infinity);
        case 'left':
          newWidth = (_resizeStartWidth! - localW).clamp(0.5, double.infinity);
          newPosX = _resizeStartPosX! + (_resizeStartWidth! - newWidth);
        case 'bottom':
          newDepth = (_resizeStartDepth! + localD).clamp(0.5, double.infinity);
        case 'top':
          newDepth = (_resizeStartDepth! - localD).clamp(0.5, double.infinity);
          newPosY = _resizeStartPosY! + (_resizeStartDepth! - newDepth);
      }
      ref.read(floorBuilderNotifierProvider.notifier).resizeFixtureLocal(
            _resizingFixtureId!, newWidth, newDepth,
            posX: newPosX, posY: newPosY);
      return;
    }

    // Drag fixture
    if (_dragFixtureId != null) {
      final off = _dragPointerOffsetFt ?? Offset.zero;
      ref.read(floorBuilderNotifierProvider.notifier).moveFixtureLocal(
            _dragFixtureId!,
            Offset(canvas.dx / _pixelsPerFt - off.dx, canvas.dy / _pixelsPerFt - off.dy),
          );
      return;
    }

    // Drag prop
    if (_dragPropId != null) {
      final off = _dragPointerOffsetFt ?? Offset.zero;
      ref.read(floorBuilderNotifierProvider.notifier).moveScenePropLocal(
            _dragPropId!,
            Offset(canvas.dx / _pixelsPerFt - off.dx, canvas.dy / _pixelsPerFt - off.dy),
          );
      return;
    }

    // Drag mannequin
    if (_dragMannequinId != null) {
      final off = _dragPointerOffsetFt ?? Offset.zero;
      ref.read(floorBuilderNotifierProvider.notifier).moveMannequinLocal(
            _dragMannequinId!,
            Offset(canvas.dx / _pixelsPerFt - off.dx, canvas.dy / _pixelsPerFt - off.dy),
          );
      return;
    }

    // Drag platform
    if (_dragPlatformId != null) {
      final off = _dragPointerOffsetFt ?? Offset.zero;
      ref.read(floorBuilderNotifierProvider.notifier).movePlatformLocal(
            _dragPlatformId!,
            Offset(canvas.dx / _pixelsPerFt - off.dx, canvas.dy / _pixelsPerFt - off.dy),
          );
      return;
    }

    // Pan
    if (_isPanning && _panStartScreen != null) {
      final delta = event.localPosition - _panStartScreen!;
      setState(() => _viewOffset = _panStartOffset! + delta);
    }
  }

  void _onPointerUp(PointerUpEvent event) {
    _activePointers.remove(event.pointer);
    if (_activePointers.length < 2) _resetPinch();
    if (event.pointer != _primaryPointer) return;
    _primaryPointer = null;

    if (_resizingFixtureId != null) {
      final id = _resizingFixtureId!;
      final fixture = ref
          .read(floorBuilderNotifierProvider)
          .fixtures
          .firstWhereOrNull((f) => f.id == id);
      if (fixture != null) {
        ref
            .read(floorBuilderNotifierProvider.notifier)
            .resizeFixture(id, fixture.widthFt, fixture.depthFt);
      }
      setState(() {
        _resizingFixtureId = null;
        _resizeHandle = null;
        _resizeStartPos = null;
        _resizeStartWidth = null;
        _resizeStartDepth = null;
        _resizeStartAngle = null;
        _resizeStartPosX = null;
        _resizeStartPosY = null;
      });
    }

    if (_dragFixtureId != null) {
      if (_dragFixtureBeforePos != null) {
        ref.read(floorBuilderNotifierProvider.notifier)
            .commitMoveFixture(_dragFixtureId!, _dragFixtureBeforePos!);
      }
      setState(() { _dragFixtureId = null; _dragFixtureBeforePos = null; _dragPointerOffsetFt = null; });
    }
    if (_dragPropId != null) {
      if (_dragPropBeforePos != null) {
        ref.read(floorBuilderNotifierProvider.notifier)
            .commitMoveSceneProp(_dragPropId!, _dragPropBeforePos!);
      }
      setState(() { _dragPropId = null; _dragPropBeforePos = null; _dragPointerOffsetFt = null; });
    }
    if (_dragMannequinId != null) {
      if (_dragMannequinBeforePos != null) {
        ref.read(floorBuilderNotifierProvider.notifier)
            .commitMoveMannequin(_dragMannequinId!, _dragMannequinBeforePos!);
      }
      setState(() { _dragMannequinId = null; _dragMannequinBeforePos = null; _dragPointerOffsetFt = null; });
    }
    if (_dragPlatformId != null) {
      if (_dragPlatformBeforePos != null) {
        ref.read(floorBuilderNotifierProvider.notifier)
            .commitMovePlatform(_dragPlatformId!, _dragPlatformBeforePos!);
      }
      setState(() { _dragPlatformId = null; _dragPlatformBeforePos = null; _dragPointerOffsetFt = null; });
    }
    if (_isPanning) setState(() { _isPanning = false; _panStartScreen = null; _panStartOffset = null; });
  }

  bool _hasFitView = false;

  Offset _toCanvas(Offset screen) => (screen - _viewOffset) / _viewScale;

  Offset _normalizeOffset(Offset pixelOffset) {
    return Offset(pixelOffset.dx / _pixelsPerFt, pixelOffset.dy / _pixelsPerFt);
  }

  // Returns the canvas-center in feet — used for element placement.
  Offset _viewCenterFt() {
    final c = _toCanvas(Offset(_canvasSize.width / 2, _canvasSize.height / 2));
    return Offset(c.dx / _pixelsPerFt, c.dy / _pixelsPerFt);
  }

  // Rotation-aware body hit-test for fixtures.
  bool _hitFixtureBody(String id, Rect rect, Offset canvasPos) {
    final angle = (_painter?.fixtureAngles[id] ?? 0.0) * pi / 180;
    if (angle == 0.0) return rect.contains(canvasPos);
    final cx = rect.center.dx;
    final cy = rect.center.dy;
    final dx = canvasPos.dx - cx;
    final dy = canvasPos.dy - cy;
    final localX = cx + dx * cos(angle) + dy * sin(angle);
    final localY = cy - dx * sin(angle) + dy * cos(angle);
    return rect.contains(Offset(localX, localY));
  }

  void _fitFixtures(List<dynamic> fixtures, {Rect? zoneBoundsPx}) {
    if (_canvasSize == Size.zero) return;
    double minX = double.infinity, maxX = double.negativeInfinity;
    double minY = double.infinity, maxY = double.negativeInfinity;

    if (zoneBoundsPx != null) {
      minX = min(minX, zoneBoundsPx.left);   maxX = max(maxX, zoneBoundsPx.right);
      minY = min(minY, zoneBoundsPx.top);    maxY = max(maxY, zoneBoundsPx.bottom);
    }

    for (final f in fixtures) {
      final l = f.posX * _pixelsPerFt;
      final t = f.posY * _pixelsPerFt;
      final r = (f.posX + f.widthFt) * _pixelsPerFt;
      final b = (f.posY + f.depthFt) * _pixelsPerFt;
      minX = min(minX, l); maxX = max(maxX, r);
      minY = min(minY, t); maxY = max(maxY, b);
    }

    if (minX == double.infinity) return;
    const pad = 60.0;
    minX -= pad; maxX += pad; minY -= pad; maxY += pad;
    final contentW = maxX - minX;
    final contentH = maxY - minY;
    if (contentW <= 0 || contentH <= 0) return;
    final scale = min(_canvasSize.width / contentW, _canvasSize.height / contentH).clamp(0.2, 6.0);
    final cx = (minX + maxX) / 2;
    final cy = (minY + maxY) / 2;
    setState(() {
      _viewScale = scale;
      _viewOffset = Offset(_canvasSize.width / 2 - cx * scale, _canvasSize.height / 2 - cy * scale);
    });
  }

  void _resetPinch() {
    _pinchScaleStart = null;
    _pinchFocalStart = null;
    _pinchDistanceStart = null;
    _pinchOffsetStart = null;
  }

  Offset _pinchFocal() {
    final pts = _activePointers.values.toList();
    return (pts[0] + pts[1]) / 2;
  }

  double _pinchDistance() {
    final pts = _activePointers.values.toList();
    return (pts[0] - pts[1]).distance;
  }

  void _updatePinch() {
    if (_pinchScaleStart == null) return;
    final focal = _pinchFocal();
    final dist = _pinchDistance();
    final newScale = (_pinchScaleStart! * dist / _pinchDistanceStart!).clamp(0.2, 6.0);
    final canvasFocalAtStart = (_pinchFocalStart! - _pinchOffsetStart!) / _pinchScaleStart!;
    setState(() {
      _viewScale = newScale;
      _viewOffset = focal - canvasFocalAtStart * newScale;
    });
  }

  Widget _buildMiniPanel(FloorBuilderState state) {
    final fixture = state.fixtures
        .where((f) => f.id == state.selectedFixtureId)
        .firstOrNull;
    if (fixture == null) return const SizedBox.shrink();
    final planogram = fixture.planogramId != null
        ? state.planograms[fixture.planogramId!]
        : null;
    return FixtureMiniPanel(
      fixture: fixture,
      planogram: planogram,
      onDismiss: () =>
          ref.read(floorBuilderNotifierProvider.notifier).selectFixture(null),
      onRotate: () =>
          ref.read(floorBuilderNotifierProvider.notifier).rotateFixture(fixture.id),
      onEdit: () => _onFixtureLongPress(
        fixture.id,
        fixture.label.isNotEmpty ? fixture.label : fixture.fixtureType.toUpperCase(),
      ),
      onDelete: () {
        ref.read(floorBuilderNotifierProvider.notifier).deleteFixture(fixture.id);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(floorBuilderNotifierProvider);
    final zoneAsync = ref.watch(zoneByIdProvider(widget.zoneId));
    final zone = zoneAsync.valueOrNull;
    final zonePts = zone != null ? ZoneShape.decode(zone.shapePoints) : null;
    final store = ref.watch(activeStoreProvider).valueOrNull;

    return Scaffold(
      appBar: AppBar(
        title: const Text('FLOOR BUILDER'),
        actions: [
          IconButton(
            icon: const Icon(Icons.undo),
            tooltip: 'Undo',
            onPressed: state.canUndo
                ? () => ref.read(floorBuilderNotifierProvider.notifier).undo()
                : null,
          ),
          IconButton(
            icon: const Icon(Icons.redo),
            tooltip: 'Redo',
            onPressed: state.canRedo
                ? () => ref.read(floorBuilderNotifierProvider.notifier).redo()
                : null,
          ),
          IconButton(
            icon: const Icon(Icons.fit_screen_outlined),
            tooltip: 'Fit to view',
            onPressed: () {
              final z = ref.read(zoneByIdProvider(widget.zoneId)).valueOrNull;
              final s = ref.read(activeStoreProvider).valueOrNull;
              Rect? bounds;
              if (z != null && s?.widthFt != null && s?.depthFt != null) {
                final zPts = ZoneShape.decode(z.shapePoints);
                if (zPts.length >= 3) {
                  final minX = zPts.map((p) => p.dx).reduce((a, b) => a < b ? a : b);
                  final maxX = zPts.map((p) => p.dx).reduce((a, b) => a > b ? a : b);
                  final minY = zPts.map((p) => p.dy).reduce((a, b) => a < b ? a : b);
                  final maxY = zPts.map((p) => p.dy).reduce((a, b) => a > b ? a : b);
                  bounds = Rect.fromLTWH(0, 0,
                    (maxX - minX) * s!.widthFt! * _pixelsPerFt,
                    (maxY - minY) * s.depthFt! * _pixelsPerFt);
                }
              }
              _fitFixtures(state.fixtures, zoneBoundsPx: bounds);
            },
          ),
          IconButton(
            icon: Icon(
              state.snapGridEnabled ? Icons.grid_on : Icons.grid_off,
              color: state.snapGridEnabled ? AppTheme.accent : Colors.white54,
            ),
            tooltip: 'Toggle snap grid',
            onPressed: () => ref.read(floorBuilderNotifierProvider.notifier).toggleSnap(),
          ),
        ],
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : DragTarget<String>(
              onMove: (details) {
                final box = context.findRenderObject() as RenderBox?;
                if (box == null) return;
                final localPos = box.globalToLocal(details.offset);
                setState(() {
                  _ghostPos = _toCanvas(localPos);
                  _ghostType = details.data;
                });
              },
              onLeave: (_) {
                setState(() {
                  _ghostPos = null;
                  _ghostType = null;
                });
              },
              onAcceptWithDetails: (details) {
                final box = context.findRenderObject() as RenderBox?;
                final localPos = box != null
                    ? box.globalToLocal(details.offset)
                    : details.offset;
                final normalizedPos = _normalizeOffset(_toCanvas(localPos));
                ref.read(floorBuilderNotifierProvider.notifier).addFixture(details.data, normalizedPos);
                setState(() {
                  _ghostPos = null;
                  _ghostType = null;
                });
              },
              builder: (context, candidateData, rejectedData) {
                return LayoutBuilder(
                  builder: (context, constraints) {
                    _canvasSize = constraints.biggest;
                    _pixelsPerFt = constraints.maxWidth / 20;
                    final hasZonePts = zonePts != null && zonePts.length >= 3;
                    Rect? zoneBoundsPx;
                    if (hasZonePts && store?.widthFt != null && store?.depthFt != null) {
                      final minX = zonePts.map((p) => p.dx).reduce((a, b) => a < b ? a : b);
                      final maxX = zonePts.map((p) => p.dx).reduce((a, b) => a > b ? a : b);
                      final minY = zonePts.map((p) => p.dy).reduce((a, b) => a < b ? a : b);
                      final maxY = zonePts.map((p) => p.dy).reduce((a, b) => a > b ? a : b);
                      zoneBoundsPx = Rect.fromLTWH(
                        0, 0,
                        (maxX - minX) * store!.widthFt! * _pixelsPerFt,
                        (maxY - minY) * store.depthFt! * _pixelsPerFt,
                      );
                    }
                    if (!_hasFitView && _canvasSize != Size.zero &&
                        (state.fixtures.isNotEmpty || hasZonePts)) {
                      _hasFitView = true;
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (mounted) _fitFixtures(state.fixtures, zoneBoundsPx: zoneBoundsPx);
                      });
                    }
                    _painter = BuilderCanvasPainter(
                      fixtures: state.fixtures,
                      selectedFixtureId: state.selectedFixtureId,
                      ghostPos: _ghostPos,
                      ghostType: _ghostType,
                      pixelsPerFt: _pixelsPerFt,
                      viewScale: _viewScale,
                      zoneNormalizedPts: hasZonePts ? zonePts : null,
                      zoneOriginNorm: zone != null ? Offset(zone.posX, zone.posY) : null,
                      storeWidthFt: store?.widthFt,
                      storeDepthFt: store?.depthFt,
                      zoneColor: zone != null ? Color(zone.colorValue) : null,
                      zoneName: zone?.name,
                      wallEdges: _wallEdges,
                      planograms: state.planograms,
                      mannequins: state.mannequins,
                      platforms: state.platforms,
                      sceneProps: state.sceneProps,
                      selectedFixtureIds: state.selectedFixtureIds,
                    );
                    return ClipRect(
                      child: Stack(
                        children: [
                          if (state.snapGridEnabled)
                            Positioned.fill(
                              child: Transform(
                                transform: Matrix4.identity()
                                  ..translate(_viewOffset.dx, _viewOffset.dy)
                                  ..scale(_viewScale),
                                alignment: Alignment.topLeft,
                                child: SnapGrid(
                                  gridSizeFt: state.gridSizeFt,
                                  pixelsPerFt: _pixelsPerFt,
                                ),
                              ),
                            ),
                          SizedBox.expand(
                            child: GestureDetector(
                              onLongPressStart: _handleLongPressInCanvas,
                              child: Listener(
                                onPointerDown: _onPointerDown,
                                onPointerMove: _onPointerMove,
                                onPointerUp: _onPointerUp,
                                child: Transform(
                                  transform: Matrix4.identity()
                                    ..translate(_viewOffset.dx, _viewOffset.dy)
                                    ..scale(_viewScale),
                                  alignment: Alignment.topLeft,
                                  child: CustomPaint(
                                    painter: _painter,
                                    size: _canvasSize,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          if (state.selectedFixtureId != null &&
                              _dragFixtureId == null &&
                              _resizingFixtureId == null &&
                              !state.isMultiSelectMode)
                            Positioned(
                              left: 0,
                              right: 0,
                              bottom: 0,
                              child: _buildMiniPanel(state),
                            ),
                          if (state.isMultiSelectMode)
                            Positioned(
                              left: 0,
                              right: 0,
                              bottom: 0,
                              child: Container(
                                color: AppTheme.primary,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: DesignTokens.spaceMd,
                                  vertical: DesignTokens.spaceMd,
                                ),
                                child: Row(
                                  children: [
                                    Text(
                                      '${state.selectedFixtureIds.length} SELECTED',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: DesignTokens.weightBold,
                                        fontSize: DesignTokens.typeSm,
                                        letterSpacing: DesignTokens.letterSpacingEyebrow,
                                      ),
                                    ),
                                    const Spacer(),
                                    ElevatedButton.icon(
                                      icon: const Icon(Icons.delete_outline, size: 16),
                                      label: const Text('DELETE ALL'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppTheme.errorColor,
                                        foregroundColor: Colors.white,
                                      ),
                                      onPressed: () => ref
                                          .read(floorBuilderNotifierProvider.notifier)
                                          .deleteSelectedFixtures(),
                                    ),
                                    const SizedBox(width: DesignTokens.spaceSm),
                                    TextButton(
                                      onPressed: () => ref
                                          .read(floorBuilderNotifierProvider.notifier)
                                          .exitMultiSelect(),
                                      child: const Text(
                                        'CANCEL',
                                        style: TextStyle(color: Colors.white70),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
      floatingActionButton: state.isMultiSelectMode
          ? null
          : FloatingActionButton(
              heroTag: 'add',
              onPressed: _showElementLibrary,
              backgroundColor: AppTheme.accent,
              foregroundColor: Colors.white,
              tooltip: 'Add element',
              child: const Icon(Icons.add),
            ),
    );
  }
}

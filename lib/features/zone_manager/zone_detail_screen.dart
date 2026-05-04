import 'dart:math';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../core/models/fixture.dart';
import '../../core/models/mannequin.dart';
import '../../core/models/store_zone.dart';
import '../../core/providers/store_provider.dart';
import '../../core/router/app_router.dart';
import '../../core/services/firestore_refs.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/design_tokens.dart';
import '../../core/widgets/mm_button.dart';
import '../../core/widgets/mm_eyebrow.dart';
import '../../core/widgets/mm_text_field.dart';
import '../../core/widgets/role_guard.dart';
import '../floor_builder/builder_canvas_painter.dart';
import '../floor_builder/element_delete_sheet.dart';
import '../floor_builder/element_library_panel.dart';
import '../floor_builder/fixture_mini_panel.dart';
import '../floor_builder/floor_builder_provider.dart';
import '../floor_builder/mannequin_type_sheet.dart';
import '../floor_builder/planogram_picker_sheet.dart';
import '../../core/models/planogram.dart';
import '../planogram/bay_view.dart';
import '../planogram/planogram_editor_provider.dart';
import '../floor_builder/prop_type_sheet.dart';
import '../floor_builder/snap_grid.dart';
import '../floor_builder/zone_edge_helper.dart';
import 'mannequin_dressing_sheet.dart';
import 'zone_properties_panel.dart';
import 'zone_shape.dart';

part 'zone_detail_screen.g.dart';

@riverpod
Stream<List<StoreZone>> zoneDetailZones(Ref ref, String storeId) {
  if (storeId.isEmpty) return Stream.value([]);
  return FirestoreRefs.zones(storeId)
      .snapshots()
      .map((s) => s.docs.map(StoreZoneFirestore.fromDoc).toList());
}

class ZoneDetailScreen extends ConsumerStatefulWidget {
  const ZoneDetailScreen({super.key, required this.zoneId});
  final String zoneId;

  @override
  ConsumerState<ZoneDetailScreen> createState() => _ZoneDetailScreenState();
}

class _ZoneDetailScreenState extends ConsumerState<ZoneDetailScreen> {
  double _pixelsPerFt = 20.0;
  Size _canvasSize = Size.zero;
  BuilderCanvasPainter? _painter;
  bool _hasFitView = false;

  bool _isEditing = false;

  // key for the mini panel overlay — used to skip canvas touch handling within its bounds
  final GlobalKey _miniPanelKey = GlobalKey();

  double _viewScale = 1.0;
  Offset _viewOffset = Offset.zero;
  final Map<int, Offset> _activePointers = {};
  double? _pinchDistanceStart;
  Offset? _pinchFocalStart;
  double? _pinchScaleStart;
  Offset? _pinchOffsetStart;
  bool _isPanning = false;
  Offset? _panStartScreen;
  Offset? _panStartOffset;
  int? _primaryPointer;

  Offset? _ghostPos;
  String? _ghostType;

  List<ZoneEdge>? _wallEdges;

  // drag state
  String? _dragFixtureId;
  Offset? _dragFixtureBeforePos;
  String? _dragPropId;
  Offset? _dragPropBeforePos;
  String? _dragMannequinId;
  Offset? _dragMannequinBeforePos;
  String? _dragPlatformId;
  Offset? _dragPlatformBeforePos;
  Offset? _dragPointerOffsetFt;

  // resize state
  String? _resizingFixtureId;
  String? _resizeHandle;
  Offset? _resizeStartPos;
  double? _resizeStartWidth;
  double? _resizeStartDepth;
  double? _resizeStartAngle;
  double? _resizeStartPosX;
  double? _resizeStartPosY;
  Fixture? _resizeStartFixture;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(floorBuilderNotifierProvider.notifier).loadFixtures(widget.zoneId);
    });
  }

  // ── Transform helpers ───────────────────────────────────────────────────────

  Offset _toCanvas(Offset screen) => (screen - _viewOffset) / _viewScale;
  Offset _normalizeOffset(Offset px) => Offset(px.dx / _pixelsPerFt, px.dy / _pixelsPerFt);
  Offset _viewCenterFt() {
    final c = _toCanvas(Offset(_canvasSize.width / 2, _canvasSize.height / 2));
    return Offset(c.dx / _pixelsPerFt, c.dy / _pixelsPerFt);
  }

  bool _hitFixtureBody(String id, Rect rect, Offset canvasPos) {
    final angle = (_painter?.fixtureAngles[id] ?? 0.0) * pi / 180;
    if (angle == 0.0) return rect.contains(canvasPos);
    final cx = rect.center.dx;
    final cy = rect.center.dy;
    final dx = canvasPos.dx - cx;
    final dy = canvasPos.dy - cy;
    return rect.contains(Offset(
      cx + dx * cos(angle) + dy * sin(angle),
      cy - dx * sin(angle) + dy * cos(angle),
    ));
  }

  void _fitFixtures(List<dynamic> fixtures, {Rect? zoneBoundsPx}) {
    if (_canvasSize == Size.zero) return;
    double minX = double.infinity, maxX = double.negativeInfinity;
    double minY = double.infinity, maxY = double.negativeInfinity;
    if (zoneBoundsPx != null) {
      minX = min(minX, zoneBoundsPx.left); maxX = max(maxX, zoneBoundsPx.right);
      minY = min(minY, zoneBoundsPx.top);  maxY = max(maxY, zoneBoundsPx.bottom);
    }
    for (final f in fixtures) {
      minX = min(minX, f.posX * _pixelsPerFt);
      maxX = max(maxX, (f.posX + f.widthFt) * _pixelsPerFt);
      minY = min(minY, f.posY * _pixelsPerFt);
      maxY = max(maxY, (f.posY + f.depthFt) * _pixelsPerFt);
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
    _pinchScaleStart = null; _pinchFocalStart = null;
    _pinchDistanceStart = null; _pinchOffsetStart = null;
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

  // ── Edit-mode methods ───────────────────────────────────────────────────────

  void _showElementLibrary() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) => ElementLibraryPanel(
        onFixtureSelected: (type) =>
            ref.read(floorBuilderNotifierProvider.notifier).addFixture(type, _viewCenterFt()),
        onWallDragStarted: _computeWallEdges,
        onDragStarted: () => Navigator.of(sheetCtx).pop(),
        onMannequinSelected: _showMannequinTypePicker,
        onPlatformSelected: () =>
            ref.read(floorBuilderNotifierProvider.notifier).addPlatform(positionFt: _viewCenterFt()),
        onPropSelected: _showPropTypePicker,
      ),
    );
  }

  void _computeWallEdges() {
    final zone = ref.read(zoneByIdProvider(widget.zoneId)).valueOrNull;
    if (zone == null) return;
    final zonePts = ZoneShape.decode(zone.shapePoints);
    if (zonePts.length < 3) return;
    final store = ref.read(activeStoreProvider).valueOrNull;
    final allEdges = ZoneEdge.compute(zonePts, _canvasSize, _pixelsPerFt,
        zoneOriginNorm: Offset(zone.posX, zone.posY),
        storeWidthFt: store?.widthFt,
        storeDepthFt: store?.depthFt);
    final wallEdges = allEdges.where((e) => e.isOnStoreWall).toList();
    if (wallEdges.isNotEmpty) {
      setState(() => _wallEdges = wallEdges);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No edges of this zone touch the store wall.')),
      );
    }
  }

  void _showMannequinTypePicker() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => MannequinTypeSheet(
        onSelect: (type, mount) => ref.read(floorBuilderNotifierProvider.notifier).addMannequin(
          mannequinType: type, mountType: mount, positionFt: _viewCenterFt()),
      ),
    );
  }

  void _showPropTypePicker() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => PropTypeSheet(
        onSelect: (type) => ref.read(floorBuilderNotifierProvider.notifier)
            .addSceneProp(propType: type, positionFt: _viewCenterFt()),
      ),
    );
  }

  void _handleLongPressInCanvas(LongPressStartDetails details) {
    if (!_isEditing || _painter == null) return;
    final canvas = _toCanvas(details.localPosition);
    final state = ref.read(floorBuilderNotifierProvider);

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
    for (final entry in _painter!.propRects.entries) {
      if (entry.value.contains(canvas)) {
        final prop = state.sceneProps.firstWhereOrNull((p) => p.id == entry.key);
        _showDeleteSheet(
          title: prop?.propType.toUpperCase() ?? 'PROP', subtitle: 'SCENE PROP',
          onDelete: () => ref.read(floorBuilderNotifierProvider.notifier).deleteSceneProp(entry.key),
        );
        return;
      }
    }
    for (final entry in _painter!.mannequinRects.entries) {
      if (entry.value.contains(canvas)) {
        final m = state.mannequins.firstWhereOrNull((m) => m.id == entry.key);
        _showDeleteSheet(
          title: m?.mannequinType.toUpperCase().replaceAll('_', ' ') ?? 'MANNEQUIN',
          subtitle: 'MANNEQUIN',
          onDelete: () => ref.read(floorBuilderNotifierProvider.notifier).deleteMannequin(entry.key),
        );
        return;
      }
    }
    for (final entry in _painter!.platformRects.entries) {
      if (entry.value.contains(canvas)) {
        _showDeleteSheet(
          title: 'PLATFORM', subtitle: 'RAISED ELEMENT',
          onDelete: () => ref.read(floorBuilderNotifierProvider.notifier).deletePlatform(entry.key),
        );
        return;
      }
    }
  }

  void _showDeleteSheet({required String title, required String subtitle, required VoidCallback onDelete}) {
    showModalBottomSheet<void>(
      context: context,
      builder: (_) => ElementDeleteSheet(title: title, subtitle: subtitle, onDelete: onDelete),
    );
  }

  // ── Pointer handling ────────────────────────────────────────────────────────

  bool _isOverMiniPanel(Offset localPosition) {
    final ctx = _miniPanelKey.currentContext;
    if (ctx == null) return false;
    final box = ctx.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) return false;
    final myBox = context.findRenderObject() as RenderBox?;
    if (myBox == null) return false;
    final globalPos = myBox.localToGlobal(localPosition);
    return (box.localToGlobal(Offset.zero) & box.size).contains(globalPos);
  }

  void _onPointerDown(PointerDownEvent event) {
    if (_isOverMiniPanel(event.localPosition)) return;
    _activePointers[event.pointer] = event.localPosition;

    if (_activePointers.length == 2) {
      if (_primaryPointer != null) {
        setState(() {
          _dragFixtureId = null; _dragFixtureBeforePos = null;
          _dragPropId = null; _dragPropBeforePos = null;
          _dragMannequinId = null; _dragMannequinBeforePos = null;
          _dragPlatformId = null; _dragPlatformBeforePos = null;
          _resizingFixtureId = null; _resizeHandle = null; _resizeStartPos = null;
          _resizeStartAngle = null; _dragPointerOffsetFt = null;
          _resizeStartPosX = null; _resizeStartPosY = null; _resizeStartFixture = null;
          _isPanning = false; _panStartScreen = null;
        });
        _primaryPointer = null;
      }
      _pinchScaleStart = _viewScale;
      _pinchOffsetStart = _viewOffset;
      _pinchFocalStart = _pinchFocal();
      _pinchDistanceStart = _pinchDistance();
      return;
    }
    if (_activePointers.length > 2 || _primaryPointer != null) return;

    if (_isEditing) {
      _onPointerDownEdit(event);
    } else {
      _onPointerDownView(event);
    }
  }

  void _onPointerDownView(PointerDownEvent event) {
    final canvas = _toCanvas(event.localPosition);
    if (_painter != null) {
      const kMinHitPx = 44.0;
      for (final entry in _painter!.fixtureRects.entries) {
        final r = entry.value;
        final hitRect = Rect.fromCenter(
          center: r.center,
          width: max(r.width, kMinHitPx / _viewScale),
          height: max(r.height, kMinHitPx / _viewScale),
        );
        if (_hitFixtureBody(entry.key, hitRect, canvas)) {
          _primaryPointer = event.pointer;
          ref.read(floorBuilderNotifierProvider.notifier).selectFixture(entry.key);
          return;
        }
      }
    }
    ref.read(floorBuilderNotifierProvider.notifier).selectFixture(null);
    _primaryPointer = event.pointer;
    _isPanning = true;
    _panStartScreen = event.localPosition;
    _panStartOffset = _viewOffset;
  }

  void _onPointerDownEdit(PointerDownEvent event) {
    if (_painter == null) return;

    if (_wallEdges != null) {
      _primaryPointer = event.pointer;
      return;
    }

    final canvas = _toCanvas(event.localPosition);

    // 1. Resize handles
    for (final entry in _painter!.resizeHandleRects.entries) {
      for (final hEntry in entry.value.entries) {
        if (hEntry.value.contains(canvas)) {
          _primaryPointer = event.pointer;
          final fixture = ref.read(floorBuilderNotifierProvider).fixtures
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
            _resizeStartFixture = fixture;
          });
          return;
        }
      }
    }

    // 2. Planogram badges
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

    // 3. Fixture body
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
        final cursorFt = Offset(canvas.dx / _pixelsPerFt, canvas.dy / _pixelsPerFt);
        setState(() {
          _dragFixtureId = entry.key;
          _dragFixtureBeforePos = f != null ? Offset(f.posX, f.posY) : null;
          _dragPointerOffsetFt = f != null
              ? Offset(cursorFt.dx - f.posX, cursorFt.dy - f.posY) : Offset.zero;
        });
        return;
      }
    }

    // 4. Prop
    for (final entry in _painter!.propRects.entries) {
      if (entry.value.contains(canvas)) {
        _primaryPointer = event.pointer;
        final p = ref.read(floorBuilderNotifierProvider).sceneProps
            .firstWhereOrNull((p) => p.id == entry.key);
        final cursorFt = Offset(canvas.dx / _pixelsPerFt, canvas.dy / _pixelsPerFt);
        setState(() {
          _dragPropId = entry.key;
          _dragPropBeforePos = p != null ? Offset(p.positionX, p.positionY) : null;
          _dragPointerOffsetFt = p != null
              ? Offset(cursorFt.dx - p.positionX, cursorFt.dy - p.positionY) : Offset.zero;
        });
        return;
      }
    }

    // 5. Mannequin
    for (final entry in _painter!.mannequinRects.entries) {
      if (entry.value.contains(canvas)) {
        _primaryPointer = event.pointer;
        final m = ref.read(floorBuilderNotifierProvider).mannequins
            .firstWhereOrNull((m) => m.id == entry.key);
        final cursorFt = Offset(canvas.dx / _pixelsPerFt, canvas.dy / _pixelsPerFt);
        setState(() {
          _dragMannequinId = entry.key;
          _dragMannequinBeforePos = m != null ? Offset(m.positionX, m.positionY) : null;
          _dragPointerOffsetFt = m != null
              ? Offset(cursorFt.dx - m.positionX, cursorFt.dy - m.positionY) : Offset.zero;
        });
        return;
      }
    }

    // 6. Platform
    for (final entry in _painter!.platformRects.entries) {
      if (entry.value.contains(canvas)) {
        _primaryPointer = event.pointer;
        final p = ref.read(floorBuilderNotifierProvider).platforms
            .firstWhereOrNull((p) => p.id == entry.key);
        final cursorFt = Offset(canvas.dx / _pixelsPerFt, canvas.dy / _pixelsPerFt);
        setState(() {
          _dragPlatformId = entry.key;
          _dragPlatformBeforePos = p != null ? Offset(p.positionX, p.positionY) : null;
          _dragPointerOffsetFt = p != null
              ? Offset(cursorFt.dx - p.positionX, cursorFt.dy - p.positionY) : Offset.zero;
        });
        return;
      }
    }

    // 7. Pan / deselect / exit multi-select
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
    if (!_activePointers.containsKey(event.pointer)) return;
    _activePointers[event.pointer] = event.localPosition;
    if (_activePointers.length >= 2) { _updatePinch(); return; }
    if (event.pointer != _primaryPointer) return;
    final canvas = _toCanvas(event.localPosition);

    if (_isEditing) {
      if (_resizingFixtureId != null && _resizeHandle != null && _resizeStartPos != null) {
        final delta = canvas - _resizeStartPos!;
        final angle = _resizeStartAngle ?? 0.0;
        final cosA = cos(angle);
        final sinA = sin(angle);
        final localW = (delta.dx * cosA + delta.dy * sinA) / _pixelsPerFt;
        final localD = (-delta.dx * sinA + delta.dy * cosA) / _pixelsPerFt;
        double? newWidth;
        double? newDepth;
        double newPosX = _resizeStartPosX!;
        double newPosY = _resizeStartPosY!;
        switch (_resizeHandle!) {
          case 'right':
            newWidth = (_resizeStartWidth! + localW).clamp(0.5, double.infinity);
            newPosX = _resizeStartPosX! + (_resizeStartWidth! - newWidth) / 2 * (1 - cosA);
            newPosY = _resizeStartPosY! - (_resizeStartWidth! - newWidth) / 2 * sinA;
          case 'left':
            newWidth = (_resizeStartWidth! - localW).clamp(0.5, double.infinity);
            newPosX = _resizeStartPosX! + (_resizeStartWidth! - newWidth) / 2 * (1 + cosA);
            newPosY = _resizeStartPosY! + (_resizeStartWidth! - newWidth) / 2 * sinA;
          case 'bottom':
            newDepth = (_resizeStartDepth! + localD).clamp(0.5, double.infinity);
            newPosX = _resizeStartPosX! + (_resizeStartDepth! - newDepth) / 2 * sinA;
            newPosY = _resizeStartPosY! + (_resizeStartDepth! - newDepth) / 2 * (1 - cosA);
          case 'top':
            newDepth = (_resizeStartDepth! - localD).clamp(0.5, double.infinity);
            newPosX = _resizeStartPosX! - (_resizeStartDepth! - newDepth) / 2 * sinA;
            newPosY = _resizeStartPosY! + (_resizeStartDepth! - newDepth) / 2 * (1 + cosA);
        }
        ref.read(floorBuilderNotifierProvider.notifier)
            .resizeFixtureLocal(_resizingFixtureId!, newWidth, newDepth, posX: newPosX, posY: newPosY);
        return;
      }
      if (_dragFixtureId != null) {
        final off = _dragPointerOffsetFt ?? Offset.zero;
        ref.read(floorBuilderNotifierProvider.notifier).moveFixtureLocal(
            _dragFixtureId!, Offset(canvas.dx / _pixelsPerFt - off.dx, canvas.dy / _pixelsPerFt - off.dy));
        return;
      }
      if (_dragPropId != null) {
        final off = _dragPointerOffsetFt ?? Offset.zero;
        ref.read(floorBuilderNotifierProvider.notifier).moveScenePropLocal(
            _dragPropId!, Offset(canvas.dx / _pixelsPerFt - off.dx, canvas.dy / _pixelsPerFt - off.dy));
        return;
      }
      if (_dragMannequinId != null) {
        final off = _dragPointerOffsetFt ?? Offset.zero;
        ref.read(floorBuilderNotifierProvider.notifier).moveMannequinLocal(
            _dragMannequinId!, Offset(canvas.dx / _pixelsPerFt - off.dx, canvas.dy / _pixelsPerFt - off.dy));
        return;
      }
      if (_dragPlatformId != null) {
        final off = _dragPointerOffsetFt ?? Offset.zero;
        ref.read(floorBuilderNotifierProvider.notifier).movePlatformLocal(
            _dragPlatformId!, Offset(canvas.dx / _pixelsPerFt - off.dx, canvas.dy / _pixelsPerFt - off.dy));
        return;
      }
    }

    if (_isPanning && _panStartScreen != null) {
      final delta = event.localPosition - _panStartScreen!;
      setState(() => _viewOffset = _panStartOffset! + delta);
    }
  }

  void _onPointerUp(PointerUpEvent event) {
    if (!_activePointers.containsKey(event.pointer)) return;
    _activePointers.remove(event.pointer);
    if (_activePointers.length < 2) _resetPinch();
    if (event.pointer != _primaryPointer) return;
    _primaryPointer = null;

    if (_isEditing) {
      if (_wallEdges != null) {
        final canvasPos = _toCanvas(event.localPosition);
        final edges = _wallEdges!;
        setState(() => _wallEdges = null);
        var nearest = edges.first;
        var minDist = (nearest.midPx - canvasPos).distance;
        for (final e in edges.skip(1)) {
          final d = (e.midPx - canvasPos).distance;
          if (d < minDist) { minDist = d; nearest = e; }
        }
        ref.read(floorBuilderNotifierProvider.notifier).addWallFixture(
          centerFt: Offset(nearest.midPx.dx / _pixelsPerFt, nearest.midPx.dy / _pixelsPerFt),
          lengthFt: nearest.lengthFt,
          angleDeg: nearest.angleDeg,
        );
        return;
      }

      if (_resizingFixtureId != null) {
        final id = _resizingFixtureId!;
        final fixture = ref.read(floorBuilderNotifierProvider).fixtures
            .firstWhereOrNull((f) => f.id == id);
        if (fixture != null) {
          double finalW = fixture.widthFt;
          double finalD = fixture.depthFt;
          double finalPosX = fixture.posX;
          double finalPosY = fixture.posY;
          final fType = fixture.fixtureType;
          if (fType == 'wall' || fType == 'shelf' || fType == 'rack' || fType == 'partition') {
            final cosA = cos(_resizeStartAngle ?? 0.0);
            final sinA = sin(_resizeStartAngle ?? 0.0);
            final startW = _resizeStartWidth ?? finalW;
            final startD = _resizeStartDepth ?? finalD;
            final startPX = _resizeStartPosX ?? finalPosX;
            final startPY = _resizeStartPosY ?? finalPosY;
            final snappedW = finalW.round().toDouble().clamp(1.0, double.infinity);
            final snappedD = finalD.round().toDouble().clamp(1.0, double.infinity);
            switch (_resizeHandle) {
              case 'right':
                finalPosX = startPX + (startW - snappedW) / 2 * (1 - cosA);
                finalPosY = startPY - (startW - snappedW) / 2 * sinA;
              case 'left':
                finalPosX = startPX + (startW - snappedW) / 2 * (1 + cosA);
                finalPosY = startPY + (startW - snappedW) / 2 * sinA;
              case 'bottom':
                finalPosX = startPX + (startD - snappedD) / 2 * sinA;
                finalPosY = startPY + (startD - snappedD) / 2 * (1 - cosA);
              case 'top':
                finalPosX = startPX - (startD - snappedD) / 2 * sinA;
                finalPosY = startPY + (startD - snappedD) / 2 * (1 + cosA);
            }
            finalW = snappedW; finalD = snappedD;
            ref.read(floorBuilderNotifierProvider.notifier)
                .resizeFixtureLocal(id, finalW, finalD, posX: finalPosX, posY: finalPosY);
          }
          ref.read(floorBuilderNotifierProvider.notifier)
              .resizeFixture(id, finalW, finalD, before: _resizeStartFixture);
        }
        setState(() {
          _resizingFixtureId = null; _resizeHandle = null; _resizeStartPos = null;
          _resizeStartWidth = null; _resizeStartDepth = null; _resizeStartAngle = null;
          _resizeStartPosX = null; _resizeStartPosY = null; _resizeStartFixture = null;
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
    }

    if (_isPanning) setState(() { _isPanning = false; _panStartScreen = null; _panStartOffset = null; });
  }

  // ── Shared helpers ──────────────────────────────────────────────────────────

  void _openPlanogramPicker(String fixtureId, {required bool front}) {
    final state = ref.read(floorBuilderNotifierProvider);
    final fixture = state.fixtures.firstWhere((f) => f.id == fixtureId);
    final label = fixture.label.isNotEmpty ? fixture.label : fixture.fixtureType.toUpperCase();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => PlanogramPickerSheet(
        planograms: state.planograms.values.toList(),
        currentPlanogramId: front ? fixture.planogramId : fixture.planogramIdBack,
        fixtureLabel: label,
        onSelect: (id) => front
            ? ref.read(floorBuilderNotifierProvider.notifier).assignPlanogram(fixtureId, id)
            : ref.read(floorBuilderNotifierProvider.notifier).assignPlanogramBack(fixtureId, id),
      ),
    );
  }

  void _showFixtureEdit(String fixtureId, String label, String fixtureType, bool wallAdjacent) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => _FixtureEditSheet(
        fixtureId: fixtureId,
        currentLabel: label,
        fixtureType: fixtureType,
        wallAdjacent: wallAdjacent,
        notifier: ref.read(floorBuilderNotifierProvider.notifier),
        onOpenPlanogram: (id) {
          Navigator.of(ctx).pop();
          context.goNamed(AppRoutes.planogramDetail, pathParameters: {'planogramId': id});
        },
        onAssignPlanogram: (id, front) {
          Navigator.of(ctx).pop();
          _openPlanogramPicker(id, front: front);
        },
      ),
    );
  }

  void _showMannequinListSheet(String storeId, List<Mannequin> mannequins) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.5,
        minChildSize: 0.3,
        maxChildSize: 0.9,
        expand: false,
        builder: (_, ctrl) => _MannequinSection(
          storeId: storeId,
          zoneId: widget.zoneId,
          mannequins: mannequins,
          scrollController: ctrl,
        ),
      ),
    );
  }

  Widget _buildMiniPanel(FloorBuilderState state) {
    final fixture = state.fixtures.firstWhereOrNull((f) => f.id == state.selectedFixtureId);
    if (fixture == null) return const SizedBox.shrink();
    final planogram = fixture.planogramId != null ? state.planograms[fixture.planogramId!] : null;
    return FixtureMiniPanel(
      fixture: fixture,
      planogram: planogram,
      onDismiss: () => ref.read(floorBuilderNotifierProvider.notifier).selectFixture(null),
      onRotate: _isEditing
          ? () => ref.read(floorBuilderNotifierProvider.notifier).rotateFixture(fixture.id)
          : null,
      onEdit: _isEditing
          ? () => _showFixtureEdit(
                fixture.id,
                fixture.label.isNotEmpty ? fixture.label : fixture.fixtureType.toUpperCase(),
                fixture.fixtureType,
                fixture.wallAdjacent,
              )
          : null,
      onDelete: _isEditing
          ? () => ref.read(floorBuilderNotifierProvider.notifier).deleteFixture(fixture.id)
          : null,
      onExpandPlanogram: planogram != null
          ? () => _showPlanogramPreview(planogram)
          : () => _openPlanogramPicker(fixture.id, front: true),
    );
  }

  void _showPlanogramPreview(Planogram planogram) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      enableDrag: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.5,
        minChildSize: 0.2,
        maxChildSize: 0.92,
        expand: false,
        snap: true,
        snapSizes: const [0.5, 0.92],
        builder: (_, ctrl) => _PlanogramPreviewSheet(
          planogram: planogram,
          scrollController: ctrl,
          onOpen: () {
            Navigator.pop(ctx);
            context.goNamed(AppRoutes.planogramDetail,
                pathParameters: {'planogramId': planogram.id});
          },
        ),
      ),
    );
  }

  // ── Build ───────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final storeId = ref.watch(activeStoreIdProvider).value ?? '';
    final zonesAsync = ref.watch(zoneDetailZonesProvider(storeId));
    final zone = zonesAsync.value?.where((z) => z.id == widget.zoneId).firstOrNull;
    final zoneRow = ref.watch(zoneByIdProvider(widget.zoneId)).valueOrNull;
    final zonePts = zoneRow != null ? ZoneShape.decode(zoneRow.shapePoints) : null;
    final store = ref.watch(activeStoreProvider).valueOrNull;
    final state = ref.watch(floorBuilderNotifierProvider);

    return Scaffold(
      appBar: _isEditing
          ? AppBar(
              title: Text(zone != null ? zone.name.toUpperCase() : 'ZONE'),
              leading: TextButton(
                onPressed: () => setState(() { _isEditing = false; _wallEdges = null; }),
                child: const Text('DONE', style: TextStyle(color: AppTheme.cardSurface, fontSize: 13, fontWeight: FontWeight.w700)),
              ),
              leadingWidth: 64,
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
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert),
                  onSelected: (v) {
                    if (v == 'fit') {
                      Rect? bounds;
                      if (zoneRow != null && store?.widthFt != null && store?.depthFt != null) {
                        final zPts = ZoneShape.decode(zoneRow.shapePoints);
                        if (zPts.length >= 3) {
                          final minX = zPts.map((p) => p.dx).reduce((a, b) => a < b ? a : b);
                          final maxX = zPts.map((p) => p.dx).reduce((a, b) => a > b ? a : b);
                          final minY = zPts.map((p) => p.dy).reduce((a, b) => a < b ? a : b);
                          final maxY = zPts.map((p) => p.dy).reduce((a, b) => a > b ? a : b);
                          bounds = Rect.fromLTWH(0, 0,
                              (maxX - minX) * store!.widthFt! * _pixelsPerFt,
                              (maxY - minY) * store.depthFt! * _pixelsPerFt);
                        }
                      }
                      _fitFixtures(state.fixtures, zoneBoundsPx: bounds);
                    } else if (v == 'snap') {
                      ref.read(floorBuilderNotifierProvider.notifier).toggleSnap();
                    }
                  },
                  itemBuilder: (_) => [
                    const PopupMenuItem(value: 'fit', child: Text('Fit to view')),
                    PopupMenuItem(
                      value: 'snap',
                      child: Text(state.snapGridEnabled ? 'Snap: ON' : 'Snap: OFF'),
                    ),
                  ],
                ),
              ],
            )
          : AppBar(
              title: Text(zone != null ? zone.name.toUpperCase() : 'ZONE'),
              actions: [
                RoleGuard(
                  allowedRoles: const ['coordinator', 'manager'],
                  child: IconButton(
                    icon: const Icon(Icons.rate_review_outlined),
                    tooltip: 'Outfit proposals',
                    onPressed: () => context.goNamed(AppRoutes.outfitProposalReview),
                  ),
                ),
                RoleGuard(
                  allowedRoles: const ['coordinator', 'manager'],
                  child: IconButton(
                    icon: const Icon(Icons.tune_outlined),
                    tooltip: 'Zone settings',
                    onPressed: zone == null
                        ? null
                        : () => showModalBottomSheet<void>(
                              context: context,
                              isScrollControlled: true,
                              backgroundColor: Colors.transparent,
                              builder: (_) => ZonePropertiesPanel(
                                zone: zone,
                                onDeleted: () => context.goNamed(AppRoutes.zoneMap),
                              ),
                            ),
                  ),
                ),
                RoleGuard(
                  allowedRoles: const ['coordinator', 'manager'],
                  child: IconButton(
                    icon: const Icon(Icons.edit_outlined),
                    tooltip: 'Edit floor',
                    onPressed: () => setState(() { _isEditing = true; _hasFitView = false; }),
                  ),
                ),
              ],
            ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildCanvas(context, state, zone, zoneRow, zonePts, store),
      floatingActionButton: _isEditing
          ? (state.isMultiSelectMode
              ? null
              : FloatingActionButton(
                  heroTag: 'add',
                  onPressed: _showElementLibrary,
                  backgroundColor: AppTheme.accent,
                  foregroundColor: AppTheme.cardSurface,
                  tooltip: 'Add element',
                  child: const Icon(Icons.add),
                ))
          : (state.selectedFixtureId == null
              ? FloatingActionButton.extended(
                  heroTag: 'styling',
                  onPressed: () => _showMannequinListSheet(storeId, state.mannequins),
                  backgroundColor: AppTheme.primary,
                  foregroundColor: AppTheme.cardSurface,
                  icon: const Icon(Icons.style_outlined),
                  label: Text(
                    state.mannequins.isEmpty
                        ? 'STYLING'
                        : 'STYLING (${state.mannequins.length})',
                    style: const TextStyle(
                      fontSize: DesignTokens.typeXs,
                      fontWeight: DesignTokens.weightBold,
                      letterSpacing: DesignTokens.letterSpacingEyebrow,
                    ),
                  ),
                )
              : null),
    );
  }

  Widget _buildCanvas(BuildContext outerCtx, FloorBuilderState state,
      dynamic zone, dynamic zoneRow, List<Offset>? zonePts, dynamic store) {
    final hasZonePts = zonePts != null && zonePts.length >= 3;

    return LayoutBuilder(builder: (lbCtx, constraints) {
      _canvasSize = constraints.biggest;
      _pixelsPerFt = constraints.maxWidth / 20;

      Rect? zoneBoundsPx;
      if (hasZonePts && store?.widthFt != null && store?.depthFt != null) {
        final minX = zonePts.map((p) => p.dx).reduce((a, b) => a < b ? a : b);
        final maxX = zonePts.map((p) => p.dx).reduce((a, b) => a > b ? a : b);
        final minY = zonePts.map((p) => p.dy).reduce((a, b) => a < b ? a : b);
        final maxY = zonePts.map((p) => p.dy).reduce((a, b) => a > b ? a : b);
        zoneBoundsPx = Rect.fromLTWH(0, 0,
            (maxX - minX) * store!.widthFt! * _pixelsPerFt,
            (maxY - minY) * store.depthFt! * _pixelsPerFt);
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
        showResizeHandles: _isEditing,
        ghostPos: _isEditing ? _ghostPos : null,
        ghostType: _isEditing ? _ghostType : null,
        pixelsPerFt: _pixelsPerFt,
        viewScale: _viewScale,
        zoneNormalizedPts: hasZonePts ? zonePts : null,
        zoneOriginNorm: zoneRow != null ? Offset(zoneRow.posX, zoneRow.posY) : null,
        storeWidthFt: store?.widthFt,
        storeDepthFt: store?.depthFt,
        zoneColor: zoneRow != null ? Color(zoneRow.colorValue) : null,
        zoneName: zoneRow?.name,
        wallEdges: _isEditing ? _wallEdges : null,
        planograms: state.planograms,
        mannequins: state.mannequins,
        platforms: state.platforms,
        sceneProps: state.sceneProps,
        selectedFixtureIds: _isEditing ? state.selectedFixtureIds : const {},
      );

      final canvasStack = ClipRect(
        child: Stack(children: [
          if (_isEditing && state.snapGridEnabled)
            Positioned.fill(
              child: Transform(
                transform: Matrix4.identity()
                  ..translateByDouble(_viewOffset.dx, _viewOffset.dy, 0.0, 1.0)
                  ..scaleByDouble(_viewScale, _viewScale, _viewScale, 1.0),
                alignment: Alignment.topLeft,
                child: SnapGrid(gridSizeFt: state.gridSizeFt, pixelsPerFt: _pixelsPerFt),
              ),
            ),
          SizedBox.expand(
            child: GestureDetector(
              onLongPressStart: _handleLongPressInCanvas,
              child: Listener(
                behavior: HitTestBehavior.opaque,
                onPointerDown: _onPointerDown,
                onPointerMove: _onPointerMove,
                onPointerUp: _onPointerUp,
                child: Transform(
                  transform: Matrix4.identity()
                    ..translateByDouble(_viewOffset.dx, _viewOffset.dy, 0.0, 1.0)
                    ..scaleByDouble(_viewScale, _viewScale, _viewScale, 1.0),
                  alignment: Alignment.topLeft,
                  child: CustomPaint(painter: _painter, size: _canvasSize),
                ),
              ),
            ),
          ),
          if (_isEditing && _wallEdges != null)
            Positioned(
              top: 12, left: 0, right: 0,
              child: Center(
                child: Material(
                  color: AppTheme.primary,
                  borderRadius: BorderRadius.circular(20),
                  child: InkWell(
                    onTap: () => setState(() => _wallEdges = null),
                    borderRadius: BorderRadius.circular(20),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        Text('Tap edge to place wall',
                            style: TextStyle(color: AppTheme.cardSurface, fontSize: 12)),
                        SizedBox(width: 8),
                        Icon(Icons.close, color: AppTheme.cardSurface, size: 14),
                      ]),
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
              key: _miniPanelKey,
              left: 0, right: 0, bottom: 0,
              child: _buildMiniPanel(state),
            ),
          if (_isEditing && state.isMultiSelectMode)
            Positioned(
              left: 0, right: 0, bottom: 0,
              child: Container(
                color: AppTheme.primary,
                padding: const EdgeInsets.symmetric(
                    horizontal: DesignTokens.spaceMd, vertical: DesignTokens.spaceMd),
                child: Row(children: [
                  Text('${state.selectedFixtureIds.length} SELECTED',
                      style: const TextStyle(
                        color: AppTheme.cardSurface,
                        fontWeight: DesignTokens.weightBold,
                        fontSize: DesignTokens.typeSm,
                        letterSpacing: DesignTokens.letterSpacingEyebrow,
                      )),
                  const Spacer(),
                  MmButton.destructive(
                    label: 'DELETE ALL',
                    icon: Icons.delete_outline,
                    onPressed: () => ref
                        .read(floorBuilderNotifierProvider.notifier)
                        .deleteSelectedFixtures(),
                  ),
                  const SizedBox(width: DesignTokens.spaceSm),
                  MmButton.text(
                    label: 'CANCEL',
                    onPressed: () =>
                        ref.read(floorBuilderNotifierProvider.notifier).exitMultiSelect(),
                  ),
                ]),
              ),
            ),
        ]),
      );

      if (!_isEditing) return canvasStack;

      return DragTarget<String>(
        onMove: (details) {
          if (details.data == 'wall') return;
          final box = lbCtx.findRenderObject() as RenderBox?;
          if (box == null) return;
          final localPos = box.globalToLocal(details.offset);
          setState(() { _ghostPos = _toCanvas(localPos); _ghostType = details.data; });
        },
        onLeave: (data) {
          setState(() {
            _ghostPos = null; _ghostType = null;
            if (data != 'wall') _wallEdges = null;
          });
        },
        onAcceptWithDetails: (details) {
          final box = lbCtx.findRenderObject() as RenderBox?;
          final localPos = box != null ? box.globalToLocal(details.offset) : details.offset;
          final canvasPos = _toCanvas(localPos);
          setState(() { _ghostPos = null; _ghostType = null; });
          if (details.data != 'wall') {
            ref.read(floorBuilderNotifierProvider.notifier)
                .addFixture(details.data, _normalizeOffset(canvasPos));
          }
        },
        builder: (_, __, ___) => canvasStack,
      );
    });
  }
}

// ── Fixture edit sheet ────────────────────────────────────────────────────────

class _FixtureEditSheet extends StatefulWidget {
  const _FixtureEditSheet({
    required this.fixtureId,
    required this.currentLabel,
    required this.fixtureType,
    required this.wallAdjacent,
    required this.notifier,
    required this.onOpenPlanogram,
    required this.onAssignPlanogram,
  });
  final String fixtureId;
  final String currentLabel;
  final String fixtureType;
  final bool wallAdjacent;
  final FloorBuilderNotifier notifier;
  final void Function(String planogramId) onOpenPlanogram;
  final void Function(String fixtureId, bool front) onAssignPlanogram;

  @override
  State<_FixtureEditSheet> createState() => _FixtureEditSheetState();
}

class _FixtureEditSheetState extends State<_FixtureEditSheet> {
  late TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.currentLabel);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        left: 16, right: 16, top: 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const MmEyebrow('FIXTURE OPTIONS'),
          const SizedBox(height: DesignTokens.spaceMd),
          MmTextField(
            label: 'Label',
            controller: _ctrl,
          ),
          const SizedBox(height: DesignTokens.spaceSm),
          MmButton.outlined(
            label: 'ASSIGN PLANOGRAM (FRONT)',
            icon: Icons.grid_view_rounded,
            onPressed: () => widget.onAssignPlanogram(widget.fixtureId, true),
          ),
          const SizedBox(height: DesignTokens.spaceXs),
          MmButton.outlined(
            label: 'ASSIGN PLANOGRAM (BACK)',
            icon: Icons.grid_view_rounded,
            onPressed: () => widget.onAssignPlanogram(widget.fixtureId, false),
          ),
          const SizedBox(height: DesignTokens.spaceMd),
          Row(children: [
            Expanded(
              child: MmButton.outlined(
                label: 'RENAME',
                onPressed: () {
                  widget.notifier.renameFixture(widget.fixtureId, _ctrl.text);
                  Navigator.pop(context);
                },
              ),
            ),
            const SizedBox(width: DesignTokens.spaceSm),
            Expanded(
              child: MmButton.destructive(
                label: 'DELETE',
                onPressed: () {
                  widget.notifier.deleteFixture(widget.fixtureId);
                  Navigator.pop(context);
                },
              ),
            ),
          ]),
        ],
      ),
    );
  }
}

// ── Mannequin list sheet ──────────────────────────────────────────────────────

class _MannequinSection extends StatelessWidget {
  const _MannequinSection({
    required this.storeId,
    required this.zoneId,
    required this.mannequins,
    this.scrollController,
  });
  final String storeId;
  final String zoneId;
  final List<Mannequin> mannequins;
  final ScrollController? scrollController;

  String _fmt(String type) => type.replaceAll('_', ' ').toUpperCase();

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: DesignTokens.spaceSm),
            child: Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                  color: AppTheme.divider,
                  borderRadius: BorderRadius.circular(2)),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(
              DesignTokens.spaceMd, 0, DesignTokens.spaceMd, DesignTokens.spaceSm),
          child: Text(
            mannequins.isEmpty ? 'STYLING' : 'STYLING (${mannequins.length})',
            style: const TextStyle(
              fontSize: DesignTokens.typeXs,
              fontWeight: DesignTokens.weightBold,
              letterSpacing: DesignTokens.letterSpacingEyebrow,
              color: AppTheme.textSecondary,
            ),
          ),
        ),
        if (mannequins.isEmpty)
          const Expanded(
            child: Center(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.accessibility_new_outlined, size: 40, color: AppTheme.textHint),
                SizedBox(height: DesignTokens.spaceSm),
                Text('No styling elements in this zone.',
                    style: TextStyle(color: AppTheme.textSecondary, fontSize: DesignTokens.typeMd)),
                SizedBox(height: DesignTokens.spaceXs),
                Text('Add mannequins via the edit floor button.',
                    style: TextStyle(color: AppTheme.textHint, fontSize: DesignTokens.typeSm)),
              ]),
            ),
          )
        else
          Expanded(
            child: ListView.separated(
              controller: scrollController,
              padding: const EdgeInsets.only(bottom: DesignTokens.spaceLg),
              itemCount: mannequins.length,
              separatorBuilder: (_, __) =>
                  const Divider(height: 1, indent: DesignTokens.spaceMd),
              itemBuilder: (context, i) {
                final m = mannequins[i];
                final displayName =
                    m.name?.isNotEmpty == true ? m.name! : _fmt(m.mannequinType);
                return ListTile(
                  leading: const Icon(Icons.accessibility_new_outlined,
                      color: AppTheme.textSecondary),
                  title: Text(displayName,
                      style: const TextStyle(
                          fontSize: DesignTokens.typeMd, fontWeight: DesignTokens.weightBold)),
                  subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('${_fmt(m.mannequinType)}  ·  ${_fmt(m.mountType)}',
                        style: const TextStyle(
                            fontSize: DesignTokens.typeSm, color: AppTheme.textSecondary)),
                    if (m.outfitName != null && m.outfitName!.isNotEmpty)
                      Text(m.outfitName!,
                          style: const TextStyle(
                              fontSize: DesignTokens.typeXs,
                              color: AppTheme.accent,
                              fontWeight: DesignTokens.weightBold,
                              letterSpacing: 0.5)),
                  ]),
                  trailing: OutlinedButton(
                    onPressed: () => showMannequinDressingSheet(context, m, storeId),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.accent,
                      side: const BorderSide(color: AppTheme.accent),
                      padding: const EdgeInsets.symmetric(horizontal: DesignTokens.spaceSm),
                      shape: const RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.all(Radius.circular(AppTheme.borderRadius))),
                    ),
                    child: const Text('DRESS',
                        style: TextStyle(
                            fontSize: DesignTokens.typeXs,
                            fontWeight: DesignTokens.weightBold,
                            letterSpacing: 1.0)),
                  ),
                );
              },
            ),
          ),
      ]),
    );
  }
}

// ── Planogram preview sheet ───────────────────────────────────────────────────

class _PlanogramPreviewSheet extends ConsumerWidget {
  const _PlanogramPreviewSheet({
    required this.planogram,
    required this.scrollController,
    required this.onOpen,
  });
  final Planogram planogram;
  final ScrollController scrollController;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final editorState = ref.watch(
        planogramEditorNotifierProvider(planogram.id));
    final isTable = planogram.planogramType == 'table';

    return Container(
      decoration: const BoxDecoration(
        color: AppTheme.cardSurface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(DesignTokens.radiusLg)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 40, height: 4,
              margin: const EdgeInsets.symmetric(vertical: DesignTokens.spaceSm),
              decoration: BoxDecoration(
                color: AppTheme.divider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
                DesignTokens.spaceMd, 0, DesignTokens.spaceMd, DesignTokens.spaceSm),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        planogram.title.toUpperCase(),
                        style: const TextStyle(
                          fontSize: DesignTokens.typeMd,
                          fontWeight: DesignTokens.weightBold,
                          letterSpacing: DesignTokens.letterSpacingEyebrow,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${planogram.season} · ${planogram.status.toUpperCase()}',
                        style: const TextStyle(
                          fontSize: DesignTokens.typeSm,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                OutlinedButton(
                  onPressed: onOpen,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.accent,
                    side: const BorderSide(color: AppTheme.accent),
                    padding: const EdgeInsets.symmetric(
                        horizontal: DesignTokens.spaceSm,
                        vertical: DesignTokens.spaceXs),
                  ),
                  child: const Text('OPEN',
                      style: TextStyle(
                          fontSize: DesignTokens.typeXs,
                          fontWeight: DesignTokens.weightBold)),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: editorState.planogram == null
                ? const Center(child: CircularProgressIndicator())
                : isTable
                    ? ListView(
                        controller: scrollController,
                        padding: const EdgeInsets.all(DesignTokens.spaceMd),
                        children: [
                          Text(
                            '${planogram.rows} rows · ${planogram.cols} cols',
                            style: const TextStyle(
                                fontSize: DesignTokens.typeSm,
                                color: AppTheme.textSecondary),
                          ),
                          const SizedBox(height: DesignTokens.spaceMd),
                          const Text('Open planogram to view table layout.',
                              style: TextStyle(color: AppTheme.textHint)),
                        ],
                      )
                    : PrimaryScrollController(
                        controller: scrollController,
                        child: BayView(planogramId: planogram.id, isEditing: false),
                      ),
          ),
        ],
      ),
    );
  }
}

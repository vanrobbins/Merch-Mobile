import 'dart:math';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/design_tokens.dart';
import '../zone_manager/zone_shape.dart';
import 'builder_canvas_painter.dart';
import 'element_library_panel.dart';
import 'fixture_mini_panel.dart';
import 'floor_builder_provider.dart';
import 'planogram_picker_sheet.dart';
import 'snap_grid.dart';
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
  int? _primaryPointer;

  // Resize state
  String? _resizingFixtureId;
  String? _resizeHandle;
  Offset? _resizeStartPos;
  double? _resizeStartWidth;
  double? _resizeStartDepth;

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
              .addFixture(type, const Offset(2, 2));
        },
        onWallSelected: _enterWallMode,
        onDragStarted: () => Navigator.of(sheetCtx).pop(),
        onMannequinSelected: () => _showMannequinTypePicker(),
        onPlatformSelected: () {
          ref.read(floorBuilderNotifierProvider.notifier)
              .addPlatform(positionFt: const Offset(3, 3));
        },
        onPropSelected: () => _showPropTypePicker(),
      ),
    );
  }

  void _showMannequinTypePicker() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _MannequinTypeSheet(
        onSelect: (type, mount) {
          ref.read(floorBuilderNotifierProvider.notifier).addMannequin(
            mannequinType: type,
            mountType: mount,
            positionFt: const Offset(3, 3),
          );
        },
      ),
    );
  }

  void _showPropTypePicker() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _PropTypeSheet(
        onSelect: (type) {
          ref.read(floorBuilderNotifierProvider.notifier).addSceneProp(
            propType: type,
            positionFt: const Offset(3, 3),
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
    final canvasSize = _canvasSize;
    final edges = ZoneEdge.compute(zonePts, canvasSize, _pixelsPerFt);
    if (edges.isEmpty) return;
    setState(() => _wallEdges = edges);
    _showWallPlacementSheet(edges);
  }

  void _showWallPlacementSheet(List<ZoneEdge> edges) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _WallPlacementSheet(
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
      builder: (_) => _FixtureActionsSheet(
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
    for (final entry in _painter!.fixtureRects.entries) {
      if (entry.value.contains(canvas)) {
        final fixture = ref
            .read(floorBuilderNotifierProvider)
            .fixtures
            .firstWhereOrNull((f) => f.id == entry.key);
        if (fixture == null) continue;
        _onFixtureLongPress(fixture.id, fixture.label.isNotEmpty ? fixture.label : fixture.fixtureType.toUpperCase());
        return;
      }
    }
  }

  void _onPointerDown(PointerDownEvent event) {
    _activePointers[event.pointer] = event.localPosition;

    if (_activePointers.length == 2) {
      if (_primaryPointer != null) {
        setState(() {
          _dragFixtureId = null;
          _resizingFixtureId = null;
          _resizeHandle = null;
          _resizeStartPos = null;
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
      if (entry.value.contains(canvas)) {
        _primaryPointer = event.pointer;
        ref.read(floorBuilderNotifierProvider.notifier).selectFixture(entry.key);
        setState(() => _dragFixtureId = entry.key);
        return;
      }
    }

    // 4. Empty canvas — deselect + pan
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
      final dFt = Offset(delta.dx / _pixelsPerFt, delta.dy / _pixelsPerFt);
      double? newWidth;
      double? newDepth;
      switch (_resizeHandle!) {
        case 'right':
          newWidth = (_resizeStartWidth! + dFt.dx).clamp(0.5, double.infinity);
        case 'left':
          newWidth = (_resizeStartWidth! - dFt.dx).clamp(0.5, double.infinity);
        case 'bottom':
          newDepth = (_resizeStartDepth! + dFt.dy).clamp(0.5, double.infinity);
        case 'top':
          newDepth = (_resizeStartDepth! - dFt.dy).clamp(0.5, double.infinity);
      }
      ref.read(floorBuilderNotifierProvider.notifier).resizeFixtureLocal(
            _resizingFixtureId!, newWidth, newDepth);
      return;
    }

    // Drag fixture
    if (_dragFixtureId != null) {
      ref.read(floorBuilderNotifierProvider.notifier).moveFixture(
            _dragFixtureId!,
            Offset(canvas.dx / _pixelsPerFt, canvas.dy / _pixelsPerFt),
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
      });
    }

    if (_dragFixtureId != null) setState(() => _dragFixtureId = null);
    if (_isPanning) setState(() { _isPanning = false; _panStartScreen = null; _panStartOffset = null; });
  }

  bool _hasFitView = false;

  Offset _toCanvas(Offset screen) => (screen - _viewOffset) / _viewScale;

  Offset _normalizeOffset(Offset pixelOffset) {
    return Offset(pixelOffset.dx / _pixelsPerFt, pixelOffset.dy / _pixelsPerFt);
  }

  // Replicates _drawZoneBackground's coordinate math to get the zone's canvas-space bounds.
  Rect? _computeZoneBoundsOnCanvas(List<Offset> zonePts) {
    if (zonePts.length < 3 || _canvasSize == Size.zero) return null;
    final minX = zonePts.map((p) => p.dx).reduce(min);
    final maxX = zonePts.map((p) => p.dx).reduce(max);
    final minY = zonePts.map((p) => p.dy).reduce(min);
    final maxY = zonePts.map((p) => p.dy).reduce(max);
    final rangeX = (maxX - minX).clamp(0.01, 1.0);
    final rangeY = (maxY - minY).clamp(0.01, 1.0);
    const padding = 40.0;
    final usableW = _canvasSize.width - padding * 2;
    final usableH = _canvasSize.height - padding * 2;
    final scale = (usableW / rangeX).clamp(0.0, usableH / rangeY);
    final scaledW = rangeX * scale;
    final scaledH = rangeY * scale;
    final offsetX = padding + (usableW - scaledW) / 2;
    final offsetY = padding + (usableH - scaledH) / 2;
    return Rect.fromLTWH(offsetX, offsetY, scaledW, scaledH);
  }

  void _fitFixtures(List<dynamic> fixtures, {List<Offset>? zonePts}) {
    if (_canvasSize == Size.zero) return;
    double minX = double.infinity, maxX = double.negativeInfinity;
    double minY = double.infinity, maxY = double.negativeInfinity;

    final zoneBounds = zonePts != null ? _computeZoneBoundsOnCanvas(zonePts) : null;
    if (zoneBounds != null) {
      minX = min(minX, zoneBounds.left);   maxX = max(maxX, zoneBounds.right);
      minY = min(minY, zoneBounds.top);    maxY = max(maxY, zoneBounds.bottom);
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('FLOOR BUILDER'),
        actions: [
          IconButton(
            icon: const Icon(Icons.fit_screen_outlined),
            tooltip: 'Fit to view',
            onPressed: () {
              final zoneAsync = ref.read(zoneByIdProvider(widget.zoneId));
              final z = zoneAsync.valueOrNull;
              final pts = z != null ? ZoneShape.decode(z.shapePoints) : null;
              _fitFixtures(state.fixtures, zonePts: pts != null && pts.length >= 3 ? pts : null);
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
                    if (!_hasFitView && _canvasSize != Size.zero &&
                        (state.fixtures.isNotEmpty || hasZonePts)) {
                      _hasFitView = true;
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (mounted) _fitFixtures(state.fixtures, zonePts: hasZonePts ? zonePts : null);
                      });
                    }
                    _painter = BuilderCanvasPainter(
                      fixtures: state.fixtures,
                      selectedFixtureId: state.selectedFixtureId,
                      ghostPos: _ghostPos,
                      ghostType: _ghostType,
                      pixelsPerFt: _pixelsPerFt,
                      zoneNormalizedPts: (zonePts != null && zonePts.length >= 3) ? zonePts : null,
                      zoneColor: zone != null ? Color(zone.colorValue) : null,
                      zoneName: zone?.name,
                      wallEdges: _wallEdges,
                      planograms: state.planograms,
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
                              _resizingFixtureId == null)
                            Positioned(
                              left: 0,
                              right: 0,
                              bottom: 0,
                              child: _buildMiniPanel(state),
                            ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
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

class _WallPlacementSheet extends StatefulWidget {
  const _WallPlacementSheet({
    required this.edges,
    required this.pixelsPerFt,
    required this.onPlace,
  });
  final List<ZoneEdge> edges;
  final double pixelsPerFt;
  final void Function(ZoneEdge edge, double lengthFt) onPlace;

  @override
  State<_WallPlacementSheet> createState() => _WallPlacementSheetState();
}

class _WallPlacementSheetState extends State<_WallPlacementSheet> {
  ZoneEdge? _selectedEdge;
  final _lengthCtrl = TextEditingController();

  @override
  void dispose() {
    _lengthCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(DesignTokens.radiusLg)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom +
            MediaQuery.of(context).padding.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: DesignTokens.spaceSm),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.divider,
                borderRadius: BorderRadius.circular(AppTheme.borderRadius),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(DesignTokens.spaceMd),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'PLACE WALL',
                  style: TextStyle(
                    fontSize: DesignTokens.typeLg,
                    fontWeight: DesignTokens.weightBold,
                    letterSpacing: DesignTokens.letterSpacingEyebrow,
                  ),
                ),
                const SizedBox(height: DesignTokens.spaceXs),
                Text(
                  _selectedEdge == null ? 'SELECT A ZONE EDGE' : 'ENTER WALL LENGTH',
                  style: const TextStyle(
                    fontSize: DesignTokens.typeXs,
                    color: AppTheme.textSecondary,
                    letterSpacing: DesignTokens.letterSpacingEyebrow,
                  ),
                ),
                const SizedBox(height: DesignTokens.spaceMd),
                if (_selectedEdge == null) ...[
                  ...widget.edges.asMap().entries.map((entry) {
                    final edge = entry.value;
                    final num = entry.key + 1;
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: CircleAvatar(
                        radius: 14,
                        backgroundColor: AppTheme.accent,
                        child: Text(
                          '$num',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: DesignTokens.typeXs,
                            fontWeight: DesignTokens.weightBold,
                          ),
                        ),
                      ),
                      title: Text(
                        'EDGE $num',
                        style: const TextStyle(
                          fontWeight: DesignTokens.weightBold,
                          fontSize: DesignTokens.typeSm,
                          letterSpacing: DesignTokens.letterSpacingEyebrow,
                        ),
                      ),
                      subtitle: Text(
                        '${edge.lengthFt.toStringAsFixed(1)} ft',
                        style: const TextStyle(
                          fontSize: DesignTokens.typeXs,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      trailing: const Icon(Icons.chevron_right, color: AppTheme.textSecondary),
                      onTap: () => setState(() {
                        _selectedEdge = edge;
                        _lengthCtrl.text = edge.lengthFt.toStringAsFixed(1);
                      }),
                    );
                  }),
                ] else ...[
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 14,
                        backgroundColor: AppTheme.accent,
                        child: Text(
                          '${_selectedEdge!.index + 1}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: DesignTokens.typeXs,
                            fontWeight: DesignTokens.weightBold,
                          ),
                        ),
                      ),
                      const SizedBox(width: DesignTokens.spaceSm),
                      Text(
                        'EDGE ${_selectedEdge!.index + 1}  \u2022  ${_selectedEdge!.lengthFt.toStringAsFixed(1)} ft',
                        style: const TextStyle(
                          fontWeight: DesignTokens.weightBold,
                          fontSize: DesignTokens.typeSm,
                          letterSpacing: DesignTokens.letterSpacingEyebrow,
                        ),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: () => setState(() => _selectedEdge = null),
                        child: const Text(
                          'CHANGE',
                          style: TextStyle(
                            fontSize: DesignTokens.typeXs,
                            color: AppTheme.accent,
                            fontWeight: DesignTokens.weightBold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: DesignTokens.spaceMd),
                  TextField(
                    controller: _lengthCtrl,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: 'Wall length',
                      border: UnderlineInputBorder(),
                      suffixText: 'ft',
                    ),
                  ),
                  const SizedBox(height: DesignTokens.spaceLg),
                  ElevatedButton(
                    onPressed: () {
                      final parsed = double.tryParse(_lengthCtrl.text) ?? 4.0;
                      final lengthFt = parsed < 0.5 ? 0.5 : parsed;
                      widget.onPlace(_selectedEdge!, lengthFt);
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.accent,
                      foregroundColor: Colors.white,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(AppTheme.borderRadius)),
                      ),
                    ),
                    child: const Text('PLACE WALL'),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FixtureActionsSheet extends StatefulWidget {
  const _FixtureActionsSheet({
    required this.fixtureId,
    required this.currentLabel,
    required this.fixtureType,
    required this.wallAdjacent,
    required this.notifier,
  });
  final String fixtureId;
  final String currentLabel;
  final String fixtureType;
  final bool wallAdjacent;
  final FloorBuilderNotifier notifier;

  @override
  State<_FixtureActionsSheet> createState() => _FixtureActionsSheetState();
}

class _FixtureActionsSheetState extends State<_FixtureActionsSheet> {
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
          const Text(
            'FIXTURE OPTIONS',
            style: TextStyle(
              fontWeight: DesignTokens.weightBold,
              fontSize: DesignTokens.typeMd,
              letterSpacing: DesignTokens.letterSpacingEyebrow,
            ),
          ),
          const SizedBox(height: DesignTokens.spaceMd),
          TextField(
            controller: _ctrl,
            decoration: const InputDecoration(
              labelText: 'Label',
              border: UnderlineInputBorder(),
            ),
          ),
          if (widget.fixtureType == 'partition') ...[
            const SizedBox(height: DesignTokens.spaceSm),
            OutlinedButton(
              onPressed: () {
                widget.notifier.toggleWallAdjacent(widget.fixtureId);
                Navigator.pop(context);
              },
              child: Text(widget.wallAdjacent ? 'MARK AS FREE-STANDING' : 'MARK AS WALL-ADJACENT'),
            ),
          ],
          const SizedBox(height: DesignTokens.spaceMd),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    widget.notifier.renameFixture(widget.fixtureId, _ctrl.text);
                    Navigator.pop(context);
                  },
                  style: OutlinedButton.styleFrom(
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(
                          Radius.circular(AppTheme.borderRadius)),
                    ),
                  ),
                  child: const Text('RENAME'),
                ),
              ),
              const SizedBox(width: DesignTokens.spaceSm),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    widget.notifier.rotateFixture(widget.fixtureId);
                  },
                  icon: const Icon(Icons.rotate_right, size: 16),
                  label: const Text('ROTATE'),
                  style: OutlinedButton.styleFrom(
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(
                          Radius.circular(AppTheme.borderRadius)),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: DesignTokens.spaceSm),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.errorColor,
                    foregroundColor: Colors.white,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(
                          Radius.circular(AppTheme.borderRadius)),
                    ),
                  ),
                  onPressed: () {
                    widget.notifier.deleteFixture(widget.fixtureId);
                    Navigator.pop(context);
                  },
                  child: const Text('DELETE'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MannequinTypeSheet extends StatelessWidget {
  const _MannequinTypeSheet({required this.onSelect});
  final void Function(String type, String mountType) onSelect;

  static const _types = [
    _MannequinTypeDef('full_body', Icons.accessibility_new_outlined, 'FULL BODY', 'floor'),
    _MannequinTypeDef('half_body', Icons.person_outline, 'HALF BODY', 'floor'),
    _MannequinTypeDef('torso', Icons.radio_button_unchecked, 'TORSO', 'floor'),
    _MannequinTypeDef('leg_form', Icons.vertical_align_bottom_outlined, 'LEG FORM', 'floor'),
    _MannequinTypeDef('bra_form', Icons.radio_button_checked, 'BRA FORM', 'floor'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppTheme.cardSurface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(DesignTokens.radiusLg)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: DesignTokens.spaceSm),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.divider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(DesignTokens.spaceMd),
            child: Text(
              'MANNEQUIN TYPE',
              style: TextStyle(
                fontSize: DesignTokens.typeLg,
                fontWeight: DesignTokens.weightBold,
                letterSpacing: DesignTokens.letterSpacingEyebrow,
              ),
            ),
          ),
          ..._types.map((t) => ListTile(
                leading: Icon(t.icon, color: AppTheme.accent),
                title: Text(
                  t.label,
                  style: const TextStyle(
                    fontWeight: DesignTokens.weightBold,
                    fontSize: DesignTokens.typeMd,
                    letterSpacing: DesignTokens.letterSpacingEyebrow,
                  ),
                ),
                trailing: const Icon(Icons.chevron_right, color: AppTheme.textSecondary),
                onTap: () {
                  Navigator.pop(context);
                  onSelect(t.type, t.mountType);
                },
              )),
          SizedBox(height: MediaQuery.of(context).padding.bottom + DesignTokens.spaceSm),
        ],
      ),
    );
  }
}

class _MannequinTypeDef {
  const _MannequinTypeDef(this.type, this.icon, this.label, this.mountType);
  final String type;
  final IconData icon;
  final String label;
  final String mountType;
}

class _PropTypeSheet extends StatelessWidget {
  const _PropTypeSheet({required this.onSelect});
  final void Function(String type) onSelect;

  static const _types = [
    _PropTypeDef('plant', Icons.park_outlined, 'PLANT'),
    _PropTypeDef('furniture', Icons.chair_outlined, 'FURNITURE'),
    _PropTypeDef('riser', Icons.layers_outlined, 'RISER'),
    _PropTypeDef('signage', Icons.campaign_outlined, 'SIGNAGE'),
    _PropTypeDef('other', Icons.category_outlined, 'OTHER'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppTheme.cardSurface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(DesignTokens.radiusLg)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: DesignTokens.spaceSm),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.divider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(DesignTokens.spaceMd),
            child: Text(
              'PROP TYPE',
              style: TextStyle(
                fontSize: DesignTokens.typeLg,
                fontWeight: DesignTokens.weightBold,
                letterSpacing: DesignTokens.letterSpacingEyebrow,
              ),
            ),
          ),
          ..._types.map((t) => ListTile(
                leading: Icon(t.icon, color: AppTheme.primary),
                title: Text(
                  t.label,
                  style: const TextStyle(
                    fontWeight: DesignTokens.weightBold,
                    fontSize: DesignTokens.typeMd,
                    letterSpacing: DesignTokens.letterSpacingEyebrow,
                  ),
                ),
                trailing: const Icon(Icons.chevron_right, color: AppTheme.textSecondary),
                onTap: () {
                  Navigator.pop(context);
                  onSelect(t.type);
                },
              )),
          SizedBox(height: MediaQuery.of(context).padding.bottom + DesignTokens.spaceSm),
        ],
      ),
    );
  }
}

class _PropTypeDef {
  const _PropTypeDef(this.type, this.icon, this.label);
  final String type;
  final IconData icon;
  final String label;
}

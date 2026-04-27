import 'dart:math';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/database/app_database.dart';
import '../../core/widgets/role_guard.dart';
import '../../core/theme/app_theme.dart';
import 'zone_map_painter.dart';
import 'zone_map_provider.dart';
import 'zone_properties_panel.dart';
import 'zone_shape.dart';

class ZoneMapScreen extends ConsumerStatefulWidget {
  const ZoneMapScreen({super.key});

  @override
  ConsumerState<ZoneMapScreen> createState() => _ZoneMapScreenState();
}

class _ZoneMapScreenState extends ConsumerState<ZoneMapScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkStoreDimensions());
  }

  bool _needsDimensions(StoresTableData? store) =>
      store != null && (store.widthFt == null || store.depthFt == null);

  void _checkStoreDimensions() {
    if (_needsDimensions(ref.read(zoneMapNotifierProvider).storeData)) {
      _showSetupDialog();
    }
  }

  void _showSetupDialog() {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _StoreDimensionsDialog(
        onSave: (w, d) => ref
            .read(zoneMapNotifierProvider.notifier)
            .updateStoreDimensions(w, d),
      ),
    );
  }

  void _onZoneTap(String zoneId) {
    final notifier = ref.read(zoneMapNotifierProvider.notifier);
    final selectedId = ref.read(zoneMapNotifierProvider).selectedZoneId;
    if (selectedId == zoneId) {
      final zone = ref.read(zoneMapNotifierProvider).zones
          .firstWhereOrNull((z) => z.id == zoneId);
      if (zone == null) return;
      showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => ZonePropertiesPanel(zone: zone),
      );
    } else {
      notifier.selectZone(zoneId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(zoneMapNotifierProvider);

    ref.listen(zoneMapNotifierProvider, (prev, next) {
      if (prev?.storeData == null && _needsDimensions(next.storeData)) {
        _showSetupDialog();
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('ZONE MAP')),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : _ZoneCanvas(onZoneTap: _onZoneTap),
      floatingActionButton: RoleGuard(
        allowedRoles: const ['coordinator', 'manager'],
        child: FloatingActionButton.extended(
          onPressed: () => ref.read(zoneMapNotifierProvider.notifier).addZone(),
          label: const Text('ADD ZONE'),
          icon: const Icon(Icons.add),
          backgroundColor: AppTheme.accent,
        ),
      ),
    );
  }
}

class _ZoneCanvas extends ConsumerStatefulWidget {
  const _ZoneCanvas({required this.onZoneTap});
  final void Function(String zoneId) onZoneTap;

  @override
  ConsumerState<_ZoneCanvas> createState() => _ZoneCanvasState();
}

class _ZoneCanvasState extends ConsumerState<_ZoneCanvas> {
  static const _vertexHitScreenPx = 20.0;
  static const _snapScreenPx = 22.0;

  Size _canvasSize = Size.zero;
  ZoneMapPainter? _painter;
  int? _primaryPointer;

  // View transform
  double _viewScale = 1.0;
  Offset _viewOffset = Offset.zero;
  final Map<int, Offset> _activePointers = {};
  double? _pinchDistanceStart;
  Offset? _pinchFocalStart;
  double? _pinchScaleStart;
  Offset? _pinchOffsetStart;

  // Vertex drag state
  String? _dragZoneId;
  int? _dragVertexIdx;
  List<Offset>? _dragPoints;
  List<Offset>? _dragStartPoints; // original shape at drag start for revert

  // Whole-zone move state
  String? _moveZoneId;
  Offset? _moveStartCanvas;
  List<Offset>? _moveStartPoints;
  List<Offset>? _moveCurrentPoints;

  // Single-finger pan on empty canvas
  bool _isPanning = false;
  Offset? _panStartScreen;
  Offset? _panStartOffset;

  bool _hasFitView = false;

  ZoneMapNotifier get _notifier => ref.read(zoneMapNotifierProvider.notifier);

  void _fitView() {
    if (_canvasSize == Size.zero) return;
    final st = ref.read(zoneMapNotifierProvider);
    final widthFt = st.storeData?.widthFt;
    final depthFt = st.storeData?.depthFt;

    double minX, maxX, minY, maxY;

    if (widthFt != null && depthFt != null) {
      final ppf = (_canvasSize.width / widthFt).clamp(0.0, _canvasSize.height / depthFt);
      minX = 0; maxX = widthFt * ppf; minY = 0; maxY = depthFt * ppf;
    } else if (st.zones.isNotEmpty) {
      minX = double.infinity; maxX = double.negativeInfinity;
      minY = double.infinity; maxY = double.negativeInfinity;
    } else {
      return;
    }

    for (final zone in st.zones) {
      for (final p in ZoneShape.decode(zone.shapePoints)) {
        final px = p.dx * _canvasSize.width;
        final py = p.dy * _canvasSize.height;
        minX = min(minX, px); maxX = max(maxX, px);
        minY = min(minY, py); maxY = max(maxY, py);
      }
    }

    if (minX >= maxX || minY >= maxY) return;
    const padPx = 40.0;
    minX -= padPx; maxX += padPx; minY -= padPx; maxY += padPx;
    final cw = maxX - minX; final ch = maxY - minY;
    if (cw <= 0 || ch <= 0) return;
    final scale = min(_canvasSize.width / cw, _canvasSize.height / ch).clamp(0.2, 6.0);
    final cx = (minX + maxX) / 2;
    final cy = (minY + maxY) / 2;
    setState(() {
      _viewScale = scale;
      _viewOffset = Offset(_canvasSize.width / 2 - cx * scale, _canvasSize.height / 2 - cy * scale);
    });
  }

  Offset _toCanvas(Offset screen) => (screen - _viewOffset) / _viewScale;

  Offset _normalize(Offset canvas) => Offset(
        (canvas.dx / _canvasSize.width).clamp(0.0, 1.0),
        (canvas.dy / _canvasSize.height).clamp(0.0, 1.0),
      );

  Offset _normalizeDelta(Offset canvasDelta) =>
      Offset(canvasDelta.dx / _canvasSize.width, canvasDelta.dy / _canvasSize.height);

  int _hitVertex(ZonesTableData zone, Offset canvas) {
    final pts = ZoneShape.decode(zone.shapePoints);
    final radius = _vertexHitScreenPx / _viewScale;
    for (var i = 0; i < pts.length; i++) {
      final pt = Offset(pts[i].dx * _canvasSize.width, pts[i].dy * _canvasSize.height);
      if ((pt - canvas).distance < radius) return i;
    }
    return -1;
  }

  /// Returns the edge index (i → i+1) closest to [canvas] within threshold,
  /// or -1 if no edge is close enough.
  int _hitEdge(ZonesTableData zone, Offset canvas) {
    final normPts = ZoneShape.decode(zone.shapePoints);
    final n = normPts.length;
    final threshold = _vertexHitScreenPx / _viewScale;
    int bestEdge = -1;
    double bestDist = threshold;
    for (var i = 0; i < n; i++) {
      final a = Offset(normPts[i].dx * _canvasSize.width, normPts[i].dy * _canvasSize.height);
      final b = Offset(normPts[(i + 1) % n].dx * _canvasSize.width, normPts[(i + 1) % n].dy * _canvasSize.height);
      final d = _pointToSegmentDist(canvas, a, b);
      if (d < bestDist) { bestDist = d; bestEdge = i; }
    }
    return bestEdge;
  }

  double _pointToSegmentDist(Offset p, Offset a, Offset b) {
    final ab = b - a;
    final len2 = ab.dx * ab.dx + ab.dy * ab.dy;
    if (len2 == 0) return (p - a).distance;
    final t = ((p - a).dx * ab.dx + (p - a).dy * ab.dy) / len2;
    final clamped = t.clamp(0.0, 1.0);
    final proj = a + Offset(ab.dx * clamped, ab.dy * clamped);
    return (p - proj).distance;
  }

  void _onLongPress(LongPressStartDetails details) {
    final state = ref.read(zoneMapNotifierProvider);
    final selectedId = state.selectedZoneId;
    if (selectedId == null) return;
    final zone = state.zones.firstWhereOrNull((z) => z.id == selectedId);
    if (zone == null) return;

    final canvas = _toCanvas(details.localPosition);

    // Long-press on a vertex → remove it
    final vIdx = _hitVertex(zone, canvas);
    if (vIdx >= 0) {
      _notifier.removeVertex(selectedId, vIdx);
      setState(_resetGesture); // prevent _onPointerUp from restoring old shape
      return;
    }

    // Long-press on an edge → insert vertex at that position
    final eIdx = _hitEdge(zone, canvas);
    if (eIdx >= 0) {
      _notifier.addVertex(selectedId, eIdx, _normalize(canvas));
      setState(_resetGesture);
    }
  }

  /// Snaps the move delta so the closest vertex pair aligns with another zone
  /// or a store boundary wall. [startPts] must be the original vertex positions
  /// at move-start so the delta and positions stay in the same coordinate frame.
  Offset _trySnapZoneMove(String zoneId, Offset normDelta, List<Offset> startPts) {
    final st = ref.read(zoneMapNotifierProvider);
    final threshold = _snapScreenPx / _viewScale;

    // Zone-to-zone vertex snap (XY together).
    Offset? bestDelta;
    double bestDist = threshold;
    for (final pt in startPts) {
      final movedX = (pt.dx + normDelta.dx) * _canvasSize.width;
      final movedY = (pt.dy + normDelta.dy) * _canvasSize.height;
      for (final other in st.zones) {
        if (other.id == zoneId) continue;
        for (final otherPt in ZoneShape.decode(other.shapePoints)) {
          final d = Offset(movedX - otherPt.dx * _canvasSize.width,
                           movedY - otherPt.dy * _canvasSize.height).distance;
          if (d < bestDist) {
            bestDist = d;
            bestDelta = Offset(otherPt.dx - pt.dx, otherPt.dy - pt.dy);
          }
        }
      }
    }
    if (bestDelta != null) return bestDelta;

    // Store boundary snap (X and Y axes independently).
    final widthFt = st.storeData?.widthFt;
    final depthFt = st.storeData?.depthFt;
    if (widthFt != null && depthFt != null) {
      final ppf = (_canvasSize.width / widthFt).clamp(0.0, _canvasSize.height / depthFt);
      final storeW = widthFt * ppf;
      final storeH = depthFt * ppf;
      double? snapDx, snapDy;
      double bestX = threshold, bestY = threshold;
      for (final pt in startPts) {
        final mx = (pt.dx + normDelta.dx) * _canvasSize.width;
        final my = (pt.dy + normDelta.dy) * _canvasSize.height;
        for (final bx in [0.0, storeW]) {
          final d = (mx - bx).abs();
          if (d < bestX) { bestX = d; snapDx = bx / _canvasSize.width - pt.dx; }
        }
        for (final by in [0.0, storeH]) {
          final d = (my - by).abs();
          if (d < bestY) { bestY = d; snapDy = by / _canvasSize.height - pt.dy; }
        }
      }
      if (snapDx != null || snapDy != null) {
        return Offset(snapDx ?? normDelta.dx, snapDy ?? normDelta.dy);
      }
    }

    return normDelta;
  }

  // Snap to nearest vertex of any OTHER zone.
  Offset _snapToVertex(Offset canvas, String dragZoneId) {
    final threshold = _snapScreenPx / _viewScale;
    final state = ref.read(zoneMapNotifierProvider);
    Offset best = canvas;
    double bestDist = threshold;
    for (final zone in state.zones) {
      if (zone.id == dragZoneId) continue;
      for (final norm in ZoneShape.decode(zone.shapePoints)) {
        final pt = Offset(norm.dx * _canvasSize.width, norm.dy * _canvasSize.height);
        final d = (pt - canvas).distance;
        if (d < bestDist) {
          bestDist = d;
          best = pt;
        }
      }
    }
    return best;
  }

  // Snap vertex X/Y to adjacent vertices' coordinates → creates right-angle edges.
  Offset _snapOrthogonal(Offset canvas, List<Offset> normPts, int idx) {
    final n = normPts.length;
    final threshold = _snapScreenPx / _viewScale;

    final prev = Offset(normPts[(idx - 1 + n) % n].dx * _canvasSize.width,
        normPts[(idx - 1 + n) % n].dy * _canvasSize.height);
    final next = Offset(normPts[(idx + 1) % n].dx * _canvasSize.width,
        normPts[(idx + 1) % n].dy * _canvasSize.height);

    double x = canvas.dx;
    double y = canvas.dy;
    double bestX = threshold, bestY = threshold;

    for (final ax in [prev.dx, next.dx]) {
      final d = (x - ax).abs();
      if (d < bestX) { bestX = d; x = ax; }
    }
    for (final ay in [prev.dy, next.dy]) {
      final d = (y - ay).abs();
      if (d < bestY) { bestY = d; y = ay; }
    }
    return Offset(x, y);
  }

  // Combined snap: vertex-to-vertex takes priority, then orthogonal.
  Offset _snapAll(Offset canvas, String dragZoneId, int vertexIdx) {
    final vtx = _snapToVertex(canvas, dragZoneId);
    if (vtx != canvas) return vtx;
    if (_dragPoints != null) return _snapOrthogonal(canvas, _dragPoints!, vertexIdx);
    return canvas;
  }

  // On pointer-up: try to perfect the shape into a rectangle or right triangle.
  List<Offset>? _trySnapToShape(List<Offset> normPts) {
    if (normPts.length == 4) return _tryRectangle(normPts);
    if (normPts.length == 3) return _tryRightTriangle(normPts);
    return null;
  }

  List<Offset>? _tryRectangle(List<Offset> pts) {
    if (_canvasSize == Size.zero) return null;
    final cPts = pts.map((p) => Offset(p.dx * _canvasSize.width, p.dy * _canvasSize.height)).toList();

    double minX = cPts.map((p) => p.dx).reduce(min);
    double maxX = cPts.map((p) => p.dx).reduce(max);
    double minY = cPts.map((p) => p.dy).reduce(min);
    double maxY = cPts.map((p) => p.dy).reduce(max);

    final corners = [
      Offset(minX, minY), Offset(maxX, minY),
      Offset(maxX, maxY), Offset(minX, maxY),
    ];

    final threshold = 30.0 / _viewScale;
    final assignments = <int>[];
    for (final pt in cPts) {
      int best = -1;
      double bestDist = threshold;
      for (var c = 0; c < 4; c++) {
        if (assignments.contains(c)) continue;
        final d = (corners[c] - pt).distance;
        if (d < bestDist) { bestDist = d; best = c; }
      }
      if (best == -1) return null;
      assignments.add(best);
    }
    if (assignments.toSet().length < 4) return null;

    return List.generate(4, (i) => Offset(
      corners[assignments[i]].dx / _canvasSize.width,
      corners[assignments[i]].dy / _canvasSize.height,
    ));
  }

  bool _segmentsIntersect(Offset p1, Offset p2, Offset p3, Offset p4) {
    final d1 = p2 - p1;
    final d2 = p4 - p3;
    final cross = d1.dx * d2.dy - d1.dy * d2.dx;
    if (cross.abs() < 1e-10) return false;
    final t = ((p3.dx - p1.dx) * d2.dy - (p3.dy - p1.dy) * d2.dx) / cross;
    final u = ((p3.dx - p1.dx) * d1.dy - (p3.dy - p1.dy) * d1.dx) / cross;
    return t > 1e-10 && t < 1 - 1e-10 && u > 1e-10 && u < 1 - 1e-10;
  }

  bool _isSelfIntersecting(List<Offset> pts) {
    final n = pts.length;
    for (var i = 0; i < n; i++) {
      final a = pts[i]; final b = pts[(i + 1) % n];
      for (var j = i + 2; j < n; j++) {
        if (i == 0 && j == n - 1) continue; // adjacent wrap
        final c = pts[j]; final d = pts[(j + 1) % n];
        if (_segmentsIntersect(a, b, c, d)) return true;
      }
    }
    return false;
  }

  List<Offset>? _tryRightTriangle(List<Offset> pts) {
    if (_canvasSize == Size.zero) return null;
    final threshold = 25.0 / _viewScale;
    for (var i = 0; i < 3; i++) {
      final a = Offset(pts[i].dx * _canvasSize.width, pts[i].dy * _canvasSize.height);
      final b = Offset(pts[(i + 1) % 3].dx * _canvasSize.width, pts[(i + 1) % 3].dy * _canvasSize.height);
      final c = Offset(pts[(i + 2) % 3].dx * _canvasSize.width, pts[(i + 2) % 3].dy * _canvasSize.height);
      for (final candidate in [Offset(a.dx, c.dy), Offset(c.dx, a.dy)]) {
        if ((candidate - b).distance < threshold) {
          final snapped = List.of(pts);
          snapped[(i + 1) % 3] = Offset(
            candidate.dx / _canvasSize.width,
            candidate.dy / _canvasSize.height,
          );
          return snapped;
        }
      }
    }
    return null;
  }

  void _resetGesture() {
    _primaryPointer = null;
    _dragZoneId = null;
    _dragVertexIdx = null;
    _dragPoints = null;
    _dragStartPoints = null;
    _moveZoneId = null;
    _moveStartCanvas = null;
    _moveStartPoints = null;
    _moveCurrentPoints = null;
    _isPanning = false;
    _panStartScreen = null;
    _panStartOffset = null;
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

  void _onPointerDown(PointerDownEvent event) {
    _activePointers[event.pointer] = event.localPosition;

    if (_activePointers.length == 2) {
      if (_primaryPointer != null) setState(_resetGesture);
      _pinchScaleStart = _viewScale;
      _pinchOffsetStart = _viewOffset;
      _pinchFocalStart = _pinchFocal();
      _pinchDistanceStart = _pinchDistance();
      return;
    }
    if (_activePointers.length > 2) return;
    if (_primaryPointer != null) return;

    final state = ref.read(zoneMapNotifierProvider);
    final canvas = _toCanvas(event.localPosition);

    if (state.selectedZoneId != null) {
      final zone = state.zones.firstWhereOrNull((z) => z.id == state.selectedZoneId);
      if (zone != null) {
        final idx = _hitVertex(zone, canvas);
        if (idx >= 0) {
          _primaryPointer = event.pointer;
          setState(() {
            _dragZoneId = state.selectedZoneId;
            _dragVertexIdx = idx;
            _dragPoints = ZoneShape.decode(zone.shapePoints);
            _dragStartPoints = List.of(_dragPoints!);
          });
          return;
        }
      }
    }

    final hitId = _painter?.zoneIdAt(canvas);
    if (hitId != null) {
      _primaryPointer = event.pointer;
      final zone = state.zones.firstWhere((z) => z.id == hitId);
      setState(() {
        _moveZoneId = hitId;
        _moveStartCanvas = canvas;
        _moveStartPoints = ZoneShape.decode(zone.shapePoints);
      });
      return;
    }

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

    if (_dragZoneId != null && _dragVertexIdx != null && _dragPoints != null) {
      final snapped = _snapAll(canvas, _dragZoneId!, _dragVertexIdx!);
      final updated = List.of(_dragPoints!)..[_dragVertexIdx!] = _normalize(snapped);
      setState(() => _dragPoints = updated);
      _notifier.updateZoneShapeLocal(_dragZoneId!, updated);
      return;
    }

    if (_moveZoneId != null && _moveStartCanvas != null && _moveStartPoints != null) {
      var normDelta = _normalizeDelta(canvas - _moveStartCanvas!);
      normDelta = _trySnapZoneMove(_moveZoneId!, normDelta, _moveStartPoints!);
      final moved = [
        for (final p in _moveStartPoints!)
          Offset((p.dx + normDelta.dx).clamp(0.0, 1.0), (p.dy + normDelta.dy).clamp(0.0, 1.0)),
      ];
      _moveCurrentPoints = moved;
      _notifier.updateZoneShapeLocal(_moveZoneId!, moved);
      return;
    }

    if (_isPanning && _panStartScreen != null) {
      final delta = event.localPosition - _panStartScreen!;
      setState(() => _viewOffset = _panStartOffset! + delta);
    }
  }

  void _onPointerUp(PointerUpEvent event) {
    _activePointers.remove(event.pointer);
    if (_activePointers.length < 2) _resetPinch();
    if (event.pointer != _primaryPointer) return;

    if (_dragZoneId != null && _dragPoints != null) {
      final shaped = _trySnapToShape(_dragPoints!);
      final finalPts = shaped ?? _dragPoints!;
      if (_isSelfIntersecting(finalPts)) {
        // Revert to the shape before this drag
        _notifier.updateZoneShape(_dragZoneId!, _dragStartPoints ?? _dragPoints!);
      } else {
        _notifier.updateZoneShape(_dragZoneId!, finalPts);
      }
    } else if (_moveZoneId != null && _moveCurrentPoints != null) {
      _notifier.updateZoneShape(_moveZoneId!, _moveCurrentPoints!);
    }

    setState(_resetGesture);
  }

  void _onTapUp(TapUpDetails details) {
    final canvas = _toCanvas(details.localPosition);
    final id = _painter?.zoneIdAt(canvas);
    if (id != null) {
      widget.onZoneTap(id);
    } else {
      _notifier.selectZone(null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(zoneMapNotifierProvider);
    return LayoutBuilder(
      builder: (context, constraints) {
        _canvasSize = constraints.biggest;
        if (!_hasFitView && !state.isLoading && _canvasSize != Size.zero) {
          _hasFitView = true;
          WidgetsBinding.instance.addPostFrameCallback((_) { if (mounted) _fitView(); });
        }
        final snapPreview = _dragPoints != null ? _trySnapToShape(_dragPoints!) : null;
        _painter = ZoneMapPainter(
          zones: state.zones,
          canvasSize: _canvasSize,
          selectedZoneId: state.selectedZoneId,
          widthFt: state.storeData?.widthFt,
          depthFt: state.storeData?.depthFt,
          activeVertexIdx: _dragVertexIdx,
          snapPreviewPoints: (snapPreview != null && snapPreview != _dragPoints) ? snapPreview : null,
        );
        return ClipRect(
          child: Listener(
            onPointerDown: _onPointerDown,
            onPointerMove: _onPointerMove,
            onPointerUp: _onPointerUp,
            child: GestureDetector(
              onTapUp: _onTapUp,
              onLongPressStart: _onLongPress,
              child: SizedBox.expand(
                child: Transform(
                  transform: Matrix4.identity()
                    ..translate(_viewOffset.dx, _viewOffset.dy)
                    ..scale(_viewScale),
                  alignment: Alignment.topLeft,
                  child: CustomPaint(painter: _painter, size: _canvasSize),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _StoreDimensionsDialog extends StatefulWidget {
  const _StoreDimensionsDialog({required this.onSave});
  final void Function(double widthFt, double depthFt) onSave;

  @override
  State<_StoreDimensionsDialog> createState() => _StoreDimensionsDialogState();
}

class _StoreDimensionsDialogState extends State<_StoreDimensionsDialog> {
  final _widthCtrl = TextEditingController();
  final _depthCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _widthCtrl.dispose();
    _depthCtrl.dispose();
    super.dispose();
  }

  String? _validatePositive(String? v) {
    final n = double.tryParse(v ?? '');
    if (n == null || n <= 0) return 'Enter a positive number';
    return null;
  }

  void _onConfirm() {
    if (_formKey.currentState!.validate()) {
      widget.onSave(
        double.parse(_widthCtrl.text),
        double.parse(_depthCtrl.text),
      );
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('STORE DIMENSIONS'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Enter the floor dimensions of your store to enable the ft grid and boundary.',
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _widthCtrl,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Width (ft)',
                border: OutlineInputBorder(),
              ),
              validator: _validatePositive,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _depthCtrl,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Depth (ft)',
                border: OutlineInputBorder(),
              ),
              validator: _validatePositive,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('SKIP'),
        ),
        ElevatedButton(
          onPressed: _onConfirm,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.accent,
            foregroundColor: Colors.white,
          ),
          child: const Text('CONFIRM'),
        ),
      ],
    );
  }
}

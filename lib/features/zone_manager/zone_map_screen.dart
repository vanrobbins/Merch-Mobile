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

  void _fitZones(List<ZonesTableData> zones) {
    if (_canvasSize == Size.zero || zones.isEmpty) return;
    double minX = double.infinity, maxX = double.negativeInfinity;
    double minY = double.infinity, maxY = double.negativeInfinity;
    for (final zone in zones) {
      for (final pt in ZoneShape.decode(zone.shapePoints)) {
        minX = min(minX, pt.dx); maxX = max(maxX, pt.dx);
        minY = min(minY, pt.dy); maxY = max(maxY, pt.dy);
      }
    }
    if (minX >= maxX || minY >= maxY) return;
    const pad = 0.08;
    minX -= pad; maxX += pad; minY -= pad; maxY += pad;
    final contentW = (maxX - minX) * _canvasSize.width;
    final contentH = (maxY - minY) * _canvasSize.height;
    final scale = min(_canvasSize.width / contentW, _canvasSize.height / contentH).clamp(0.2, 6.0);
    final cx = (minX + maxX) / 2 * _canvasSize.width;
    final cy = (minY + maxY) / 2 * _canvasSize.height;
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

  Offset _snap(Offset canvas, String dragZoneId) {
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

  void _resetGesture() {
    _primaryPointer = null;
    _dragZoneId = null;
    _dragVertexIdx = null;
    _dragPoints = null;
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
      final snapped = _snap(canvas, _dragZoneId!);
      final updated = List.of(_dragPoints!)..[_dragVertexIdx!] = _normalize(snapped);
      setState(() => _dragPoints = updated);
      _notifier.updateZoneShapeLocal(_dragZoneId!, updated);
      return;
    }

    if (_moveZoneId != null && _moveStartCanvas != null && _moveStartPoints != null) {
      final normDelta = _normalizeDelta(canvas - _moveStartCanvas!);
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
      _notifier.updateZoneShape(_dragZoneId!, _dragPoints!);
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
        if (!_hasFitView && state.zones.isNotEmpty && _canvasSize != Size.zero) {
          _hasFitView = true;
          WidgetsBinding.instance.addPostFrameCallback((_) { if (mounted) _fitZones(state.zones); });
        }
        _painter = ZoneMapPainter(
          zones: state.zones,
          canvasSize: _canvasSize,
          selectedZoneId: state.selectedZoneId,
          widthFt: state.storeData?.widthFt,
          depthFt: state.storeData?.depthFt,
          activeVertexIdx: _dragVertexIdx,
        );
        return ClipRect(
          child: Listener(
            onPointerDown: _onPointerDown,
            onPointerMove: _onPointerMove,
            onPointerUp: _onPointerUp,
            child: GestureDetector(
              onTapUp: _onTapUp,
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

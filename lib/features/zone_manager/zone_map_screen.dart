import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/database/app_database.dart';
import '../../core/router/app_router.dart';
import '../../core/widgets/role_guard.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/design_tokens.dart';
import 'zone_map_painter.dart';
import 'zone_map_provider.dart';
import 'zone_legend_panel.dart';
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
      context.goNamed(AppRoutes.zoneDetail, pathParameters: {'zoneId': zoneId});
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
      body: Column(
        children: [
          Expanded(
            child: state.isLoading
                ? const Center(child: CircularProgressIndicator())
                : InteractiveViewer(
                    boundaryMargin: const EdgeInsets.all(80),
                    minScale: 0.5,
                    maxScale: 4.0,
                    child: _ZoneCanvas(onZoneTap: _onZoneTap),
                  ),
          ),
          _SelectedZoneBanner(state: state),
          const ZoneLegendPanel(),
        ],
      ),
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

/// Shows the name + type of the currently selected zone above the legend.
class _SelectedZoneBanner extends StatelessWidget {
  const _SelectedZoneBanner({required this.state});
  final ZoneMapState state;

  @override
  Widget build(BuildContext context) {
    final selectedId = state.selectedZoneId;
    if (selectedId == null) return const SizedBox.shrink();
    final zone = state.zones.where((z) => z.id == selectedId).firstOrNull;
    if (zone == null) return const SizedBox.shrink();

    final color = Color(zone.colorValue);
    return Container(
      width: double.infinity,
      color: color.withOpacity(0.12),
      padding: const EdgeInsets.symmetric(
        horizontal: DesignTokens.spaceMd,
        vertical: DesignTokens.spaceXs,
      ),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: DesignTokens.spaceSm),
          Text(
            zone.name.toUpperCase(),
            style: TextStyle(
              fontSize: DesignTokens.typeSm,
              fontWeight: DesignTokens.weightBold,
              letterSpacing: DesignTokens.letterSpacingEyebrow,
              color: color,
            ),
          ),
          const SizedBox(width: DesignTokens.spaceXs),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: color.withOpacity(0.18),
              borderRadius: BorderRadius.circular(AppTheme.borderRadius),
            ),
            child: Text(
              zone.zoneType.toUpperCase().replaceAll('_', ' '),
              style: TextStyle(
                fontSize: DesignTokens.typeXs,
                fontWeight: DesignTokens.weightBold,
                color: color,
              ),
            ),
          ),
          const Spacer(),
          Text(
            'TAP AGAIN TO OPEN',
            style: TextStyle(
              fontSize: DesignTokens.typeXs,
              color: AppTheme.textSecondary,
              letterSpacing: DesignTokens.letterSpacingEyebrow,
            ),
          ),
        ],
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
  static const _canvasSize = Size(800, 600);
  static const _vertexHitRadius = 20.0;

  ZoneMapPainter? _painter;
  int? _primaryPointer;

  // Vertex drag state
  String? _dragZoneId;
  int? _dragVertexIdx;
  List<Offset>? _dragPoints;

  // Whole-zone move state
  String? _moveZoneId;
  Offset? _moveStartPos;
  List<Offset>? _moveStartPoints;
  List<Offset>? _moveCurrentPoints;

  ZoneMapNotifier get _notifier => ref.read(zoneMapNotifierProvider.notifier);

  Offset _normalize(Offset position) => Offset(
        (position.dx / _canvasSize.width).clamp(0.0, 1.0),
        (position.dy / _canvasSize.height).clamp(0.0, 1.0),
      );

  Offset _normalizeDelta(Offset delta) =>
      Offset(delta.dx / _canvasSize.width, delta.dy / _canvasSize.height);

  /// Returns the index of a vertex of [zone] hit by [position], or -1.
  int _hitVertex(ZonesTableData zone, Offset position) {
    final pts = ZoneShape.decode(zone.shapePoints);
    for (var i = 0; i < pts.length; i++) {
      final screenPt = Offset(
        pts[i].dx * _canvasSize.width,
        pts[i].dy * _canvasSize.height,
      );
      if ((screenPt - position).distance < _vertexHitRadius) return i;
    }
    return -1;
  }

  void _resetGesture() {
    _primaryPointer = null;
    _dragZoneId = null;
    _dragVertexIdx = null;
    _dragPoints = null;
    _moveZoneId = null;
    _moveStartPos = null;
    _moveStartPoints = null;
    _moveCurrentPoints = null;
  }

  void _onPointerDown(PointerDownEvent event) {
    if (_primaryPointer != null) return;
    final state = ref.read(zoneMapNotifierProvider);
    final selectedId = state.selectedZoneId;

    // 1. Try to grab a vertex of the selected zone first.
    if (selectedId != null) {
      final zone = state.zones.where((z) => z.id == selectedId).firstOrNull;
      if (zone != null) {
        final idx = _hitVertex(zone, event.localPosition);
        if (idx >= 0) {
          _primaryPointer = event.pointer;
          setState(() {
            _dragZoneId = selectedId;
            _dragVertexIdx = idx;
            _dragPoints = ZoneShape.decode(zone.shapePoints);
          });
          return;
        }
      }
    }

    // 2. Otherwise try to grab a whole zone for moving.
    final hitId = _painter?.zoneIdAt(event.localPosition);
    if (hitId != null) {
      _primaryPointer = event.pointer;
      final zone = state.zones.firstWhere((z) => z.id == hitId);
      setState(() {
        _moveZoneId = hitId;
        _moveStartPos = event.localPosition;
        _moveStartPoints = ZoneShape.decode(zone.shapePoints);
      });
    }
  }

  void _onPointerMove(PointerMoveEvent event) {
    if (event.pointer != _primaryPointer) return;

    if (_dragZoneId != null && _dragVertexIdx != null && _dragPoints != null) {
      final updated = List.of(_dragPoints!)
        ..[_dragVertexIdx!] = _normalize(event.localPosition);
      setState(() => _dragPoints = updated);
      _notifier.updateZoneShapeLocal(_dragZoneId!, updated);
      return;
    }

    if (_moveZoneId != null && _moveStartPos != null && _moveStartPoints != null) {
      final normDelta = _normalizeDelta(event.localPosition - _moveStartPos!);
      final moved = [
        for (final p in _moveStartPoints!)
          Offset(
            (p.dx + normDelta.dx).clamp(0.0, 1.0),
            (p.dy + normDelta.dy).clamp(0.0, 1.0),
          ),
      ];
      _moveCurrentPoints = moved;
      _notifier.updateZoneShapeLocal(_moveZoneId!, moved);
    }
  }

  void _onPointerUp(PointerUpEvent event) {
    if (event.pointer != _primaryPointer) return;

    if (_dragZoneId != null && _dragPoints != null) {
      _notifier.updateZoneShape(_dragZoneId!, _dragPoints!);
    } else if (_moveZoneId != null && _moveCurrentPoints != null) {
      _notifier.updateZoneShape(_moveZoneId!, _moveCurrentPoints!);
    }

    setState(_resetGesture);
  }

  void _onTapUp(TapUpDetails details) {
    final id = _painter?.zoneIdAt(details.localPosition);
    if (id != null) {
      widget.onZoneTap(id);
    } else {
      _notifier.selectZone(null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(zoneMapNotifierProvider);
    _painter = ZoneMapPainter(
      zones: state.zones,
      canvasSize: _canvasSize,
      selectedZoneId: state.selectedZoneId,
      widthFt: state.storeData?.widthFt,
      depthFt: state.storeData?.depthFt,
    );
    return Listener(
      onPointerDown: _onPointerDown,
      onPointerMove: _onPointerMove,
      onPointerUp: _onPointerUp,
      child: GestureDetector(
        onTapUp: _onTapUp,
        child: CustomPaint(painter: _painter, size: _canvasSize),
      ),
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

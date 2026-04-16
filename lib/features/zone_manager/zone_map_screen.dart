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
  }

  void _onZoneTap(String zoneId) {
    final zone = ref
        .read(zoneMapNotifierProvider)
        .zones
        .firstWhere((z) => z.id == zoneId);
    ref.read(zoneMapNotifierProvider.notifier).selectZone(zoneId);
    _showZoneSheet(zone);
  }

  void _showZoneSheet(ZonesTableData zone) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ZoneEditSheet(zone: zone),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(zoneMapNotifierProvider);

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
                    child: _ZoneCanvas(
                      onZoneTap: _onZoneTap,
                    ),
                  ),
          ),
          const ZoneLegendPanel(),
        ],
      ),
      floatingActionButton: RoleGuard(
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
}

// Handles tap (zone select) and pan (vertex drag) on the zone canvas.
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

  // Vertex drag state
  String? _dragZoneId;
  int? _dragVertexIdx;
  List<Offset>? _dragPoints; // normalized 0..1

  void _onPanStart(DragStartDetails d) {
    final state = ref.read(zoneMapNotifierProvider);
    final selectedId = state.selectedZoneId;
    if (selectedId == null) return;
    final zone = state.zones.firstWhere((z) => z.id == selectedId,
        orElse: () => throw StateError('not found'));
    final pts = ZoneShape.decode(zone.shapePoints);
    if (pts.isEmpty) return;

    // Convert normalized pts → screen px
    final screenPts = pts
        .map((p) => Offset(p.dx * _canvasSize.width, p.dy * _canvasSize.height))
        .toList();

    for (var i = 0; i < screenPts.length; i++) {
      if ((screenPts[i] - d.localPosition).distance < _vertexHitRadius) {
        setState(() {
          _dragZoneId = selectedId;
          _dragVertexIdx = i;
          _dragPoints = List.of(pts);
        });
        return;
      }
    }
  }

  void _onPanUpdate(DragUpdateDetails d) {
    if (_dragZoneId == null || _dragVertexIdx == null || _dragPoints == null) return;
    final norm = Offset(
      (d.localPosition.dx / _canvasSize.width).clamp(0.0, 1.0),
      (d.localPosition.dy / _canvasSize.height).clamp(0.0, 1.0),
    );
    final updated = List.of(_dragPoints!)..[_dragVertexIdx!] = norm;
    setState(() => _dragPoints = updated);
    ref.read(zoneMapNotifierProvider.notifier)
        .updateZoneShapeLocal(_dragZoneId!, updated);
  }

  void _onPanEnd(DragEndDetails _) {
    if (_dragZoneId != null && _dragPoints != null) {
      ref.read(zoneMapNotifierProvider.notifier)
          .updateZoneShape(_dragZoneId!, _dragPoints!);
    }
    setState(() {
      _dragZoneId = null;
      _dragVertexIdx = null;
      _dragPoints = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(zoneMapNotifierProvider);
    _painter = ZoneMapPainter(
      zones: state.zones,
      canvasSize: _canvasSize,
      selectedZoneId: state.selectedZoneId,
      onZoneTap: widget.onZoneTap,
    );
    return GestureDetector(
      onTapUp: (d) {
        final id = _painter?.zoneIdAt(d.localPosition);
        if (id != null) widget.onZoneTap(id);
      },
      onPanStart: _onPanStart,
      onPanUpdate: _onPanUpdate,
      onPanEnd: _onPanEnd,
      child: CustomPaint(
        painter: _painter,
        size: _canvasSize,
      ),
    );
  }
}

class _ZoneEditSheet extends ConsumerStatefulWidget {
  const _ZoneEditSheet({required this.zone});
  final ZonesTableData zone;

  @override
  ConsumerState<_ZoneEditSheet> createState() => _ZoneEditSheetState();
}

class _ZoneEditSheetState extends ConsumerState<_ZoneEditSheet> {
  late TextEditingController _nameCtrl;

  static const _swatches = <int>[
    0xFF3B6BC2, // womens
    0xFF3A7D44, // mens
    0xFFC19A6B, // accessories
    0xFF8B3D8B, // fitting
    0xFFE07B54, // entrance
    0xFF757575, // neutrals
    0xFF9E9E9E,
    0xFFBDBDBD,
    0xFF616161,
    0xFF424242,
  ];

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.zone.name);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final notifier = ref.read(zoneMapNotifierProvider.notifier);

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
            top: Radius.circular(DesignTokens.radiusLg)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom +
            MediaQuery.of(context).padding.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: DesignTokens.spaceSm),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius:
                    BorderRadius.circular(AppTheme.borderRadius),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(DesignTokens.spaceMd),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'EDIT ZONE',
                  style: TextStyle(
                    fontSize: DesignTokens.typeLg,
                    fontWeight: DesignTokens.weightBold,
                    letterSpacing: DesignTokens.letterSpacingEyebrow,
                  ),
                ),
                const SizedBox(height: DesignTokens.spaceMd),
                TextField(
                  controller: _nameCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Zone Name',
                    border: UnderlineInputBorder(),
                  ),
                  onSubmitted: (v) => notifier.updateZoneName(widget.zone.id, v),
                ),
                const SizedBox(height: DesignTokens.spaceMd),
                const Text(
                  'COLOR',
                  style: TextStyle(
                    fontSize: DesignTokens.typeXs,
                    fontWeight: DesignTokens.weightBold,
                    letterSpacing: DesignTokens.letterSpacingEyebrow,
                    color: AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: DesignTokens.spaceSm),
                Wrap(
                  spacing: DesignTokens.spaceSm,
                  runSpacing: DesignTokens.spaceSm,
                  children: _swatches.map((c) {
                    final isSelected = widget.zone.colorValue == c;
                    return GestureDetector(
                      onTap: () => notifier.updateZoneColor(widget.zone.id, c),
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: Color(c),
                          borderRadius: BorderRadius.circular(AppTheme.borderRadius),
                          border: Border.all(
                            color: isSelected ? AppTheme.accent : Colors.transparent,
                            width: 2,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: DesignTokens.spaceLg),
                ElevatedButton(
                  onPressed: () {
                    notifier.updateZoneName(widget.zone.id, _nameCtrl.text);
                    Navigator.pop(context);
                    context.goNamed(
                      AppRoutes.floorBuilder,
                      pathParameters: {'zoneId': widget.zone.id},
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.accent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppTheme.borderRadius),
                    ),
                  ),
                  child: const Text('OPEN BUILDER'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/design_tokens.dart';
import '../zone_manager/zone_shape.dart';
import 'builder_canvas_painter.dart';
import 'element_library_panel.dart';
import 'floor_builder_provider.dart';
import 'snap_grid.dart';
import 'zone_edge_helper.dart';

class FloorBuilderScreen extends ConsumerStatefulWidget {
  const FloorBuilderScreen({super.key, required this.zoneId});
  final String zoneId;

  @override
  ConsumerState<FloorBuilderScreen> createState() => _FloorBuilderScreenState();
}

class _FloorBuilderScreenState extends ConsumerState<FloorBuilderScreen> {
  static const _pixelsPerFt = 20.0;

  // Ghost drag state
  Offset? _ghostPos;
  String? _ghostType;

  // Wall placement mode
  List<ZoneEdge>? _wallEdges;

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
      ),
    );
  }

  void _enterWallMode() {
    final zone = ref.read(zoneByIdProvider(widget.zoneId)).valueOrNull;
    if (zone == null) return;
    final zonePts = ZoneShape.decode(zone.shapePoints);
    if (zonePts.length < 3) return;
    const canvasSize = Size(800, 600);
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

  void _onCanvasTap(TapUpDetails details) {
    // Deselect on background tap
    ref.read(floorBuilderNotifierProvider.notifier).selectFixture(null);
  }

  void _onFixtureLongPress(String fixtureId, String currentLabel) {
    showModalBottomSheet<void>(
      context: context,
      builder: (_) => _FixtureActionsSheet(
        fixtureId: fixtureId,
        currentLabel: currentLabel,
        notifier: ref.read(floorBuilderNotifierProvider.notifier),
      ),
    );
  }

  void _handleLongPressStart(LongPressStartDetails details, BuilderCanvasPainter painter) {
    final pos = details.localPosition;
    for (final entry in painter.fixtureRects.entries) {
      if (entry.value.contains(pos)) {
        final fixture = ref
            .read(floorBuilderNotifierProvider)
            .fixtures
            .firstWhere((f) => f.id == entry.key, orElse: () => throw StateError('not found'));
        _onFixtureLongPress(fixture.id, fixture.label.isNotEmpty ? fixture.label : fixture.fixtureType.toUpperCase());
        return;
      }
    }
  }

  Offset _normalizeOffset(Offset pixelOffset) {
    return Offset(pixelOffset.dx / _pixelsPerFt, pixelOffset.dy / _pixelsPerFt);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(floorBuilderNotifierProvider);
    final zoneAsync = ref.watch(zoneByIdProvider(widget.zoneId));
    final zone = zoneAsync.valueOrNull;
    final zonePts = zone != null ? ZoneShape.decode(zone.shapePoints) : null;
    final painter = BuilderCanvasPainter(
      fixtures: state.fixtures,
      selectedFixtureId: state.selectedFixtureId,
      ghostPos: _ghostPos,
      ghostType: _ghostType,
      pixelsPerFt: _pixelsPerFt,
      zoneNormalizedPts: (zonePts != null && zonePts.length >= 3) ? zonePts : null,
      zoneColor: zone != null ? Color(zone.colorValue) : null,
      zoneName: zone?.name,
      wallEdges: _wallEdges,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('FLOOR BUILDER'),
        actions: [
          // Snap toggle
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
                // Convert global position to local canvas coordinates
                final box = context.findRenderObject() as RenderBox?;
                if (box == null) return;
                final localPos = box.globalToLocal(details.offset);
                setState(() {
                  _ghostPos = localPos;
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
                final normalizedPos = _normalizeOffset(localPos);
                ref.read(floorBuilderNotifierProvider.notifier).addFixture(details.data, normalizedPos);
                setState(() {
                  _ghostPos = null;
                  _ghostType = null;
                });
              },
              builder: (context, candidateData, rejectedData) {
                return GestureDetector(
                  onTapUp: _onCanvasTap,
                  onLongPressStart: (details) => _handleLongPressStart(details, painter),
                  child: Stack(
                    children: [
                      // Grid layer
                      if (state.snapGridEnabled)
                        Positioned.fill(
                          child: SnapGrid(
                            gridSizeFt: state.gridSizeFt,
                            pixelsPerFt: _pixelsPerFt,
                          ),
                        ),
                      // Canvas layer
                      InteractiveViewer(
                        boundaryMargin: const EdgeInsets.all(100),
                        minScale: 0.5,
                        maxScale: 4.0,
                        child: CustomPaint(
                          painter: painter,
                          size: const Size(800, 600),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            heroTag: 'rotate',
            mini: true,
            onPressed: state.selectedFixtureId != null
                ? () => ref.read(floorBuilderNotifierProvider.notifier).rotateFixture(state.selectedFixtureId!)
                : null,
            backgroundColor: state.selectedFixtureId != null ? AppTheme.primary : Colors.grey,
            child: const Icon(Icons.rotate_right),
          ),
          const SizedBox(height: DesignTokens.spaceSm),
          FloatingActionButton.extended(
            heroTag: 'library',
            onPressed: _showElementLibrary,
            label: const Text('ELEMENT LIBRARY'),
            icon: const Icon(Icons.add),
            backgroundColor: AppTheme.accent,
          ),
        ],
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
  late TextEditingController _lengthCtrl;

  @override
  void initState() {
    super.initState();
    _lengthCtrl = TextEditingController();
  }

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
                color: Colors.grey.shade300,
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
    required this.notifier,
  });
  final String fixtureId;
  final String currentLabel;
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
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade600,
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

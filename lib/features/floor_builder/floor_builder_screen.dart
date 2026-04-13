import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import 'builder_canvas_painter.dart';
import 'element_library_panel.dart';
import 'floor_builder_provider.dart';
import 'snap_grid.dart';

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
      builder: (_) => ElementLibraryPanel(
        onFixtureSelected: (type) {
          // Add fixture at center of canvas
          ref.read(floorBuilderNotifierProvider.notifier).addFixture(type, const Offset(10, 10));
        },
      ),
    );
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
    final painter = BuilderCanvasPainter(
      fixtures: state.fixtures,
      selectedFixtureId: state.selectedFixtureId,
      ghostPos: _ghostPos,
      ghostType: _ghostType,
      pixelsPerFt: _pixelsPerFt,
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
          const SizedBox(height: 8),
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
          const Text('FIXTURE OPTIONS', style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 14,
            letterSpacing: 1.2,
          )),
          const SizedBox(height: 16),
          TextField(
            controller: _ctrl,
            decoration: const InputDecoration(labelText: 'Label', border: UnderlineInputBorder()),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    widget.notifier.renameFixture(widget.fixtureId, _ctrl.text);
                    Navigator.pop(context);
                  },
                  child: const Text('RENAME'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  onPressed: () {
                    widget.notifier.deleteFixture(widget.fixtureId);
                    Navigator.pop(context);
                  },
                  child: const Text('DELETE', style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

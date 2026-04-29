import 'dart:math';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../core/models/mannequin.dart';
import '../../core/models/store_zone.dart';
import '../../core/providers/store_provider.dart';
import '../../core/router/app_router.dart';
import '../../core/services/firestore_refs.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/design_tokens.dart';
import '../../core/widgets/role_guard.dart';
import '../floor_builder/builder_canvas_painter.dart';
import '../floor_builder/fixture_mini_panel.dart';
import '../floor_builder/floor_builder_provider.dart';
import '../floor_builder/planogram_picker_sheet.dart';
import 'mannequin_dressing_sheet.dart';
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

  // View transform
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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(floorBuilderNotifierProvider.notifier).loadFixtures(widget.zoneId);
    });
  }

  bool _hasFitView = false;

  Offset _toCanvas(Offset screen) => (screen - _viewOffset) / _viewScale;

  void _fitFixtures(List<dynamic> fixtures) {
    if (_canvasSize == Size.zero || fixtures.isEmpty) return;
    double minX = double.infinity, maxX = double.negativeInfinity;
    double minY = double.infinity, maxY = double.negativeInfinity;
    for (final f in fixtures) {
      final l = f.posX * _pixelsPerFt;
      final t = f.posY * _pixelsPerFt;
      final r = (f.posX + f.widthFt) * _pixelsPerFt;
      final b = (f.posY + f.depthFt) * _pixelsPerFt;
      minX = min(minX, l); maxX = max(maxX, r);
      minY = min(minY, t); maxY = max(maxY, b);
    }
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

  void _onPointerDown(PointerDownEvent event) {
    _activePointers[event.pointer] = event.localPosition;

    if (_activePointers.length == 2) {
      _primaryPointer = null;
      _isPanning = false;
      _panStartScreen = null;
      _pinchScaleStart = _viewScale;
      _pinchOffsetStart = _viewOffset;
      _pinchFocalStart = _pinchFocal();
      _pinchDistanceStart = _pinchDistance();
      return;
    }
    if (_activePointers.length > 2 || _primaryPointer != null) return;

    final canvas = _toCanvas(event.localPosition);

    // Hit-test fixture
    if (_painter != null) {
      for (final entry in _painter!.fixtureRects.entries) {
        if (entry.value.contains(canvas)) {
          _primaryPointer = event.pointer;
          ref.read(floorBuilderNotifierProvider.notifier).selectFixture(entry.key);
          return;
        }
      }
    }

    // Empty canvas — pan + deselect
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
    if (_isPanning) setState(() { _isPanning = false; _panStartScreen = null; _panStartOffset = null; });
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

  @override
  Widget build(BuildContext context) {
    final storeId = ref.watch(activeStoreIdProvider).value ?? '';
    final zonesAsync = ref.watch(zoneDetailZonesProvider(storeId));
    final zone = zonesAsync.value?.where((z) => z.id == widget.zoneId).firstOrNull;
    final zoneAsync = ref.watch(zoneByIdProvider(widget.zoneId));
    final zoneRow = zoneAsync.valueOrNull;
    final zonePts = zoneRow != null ? ZoneShape.decode(zoneRow.shapePoints) : null;

    final builderState = ref.watch(floorBuilderNotifierProvider);
    final selectedId = builderState.selectedFixtureId;
    final selectedFixture = selectedId != null
        ? builderState.fixtures.firstWhereOrNull((f) => f.id == selectedId)
        : null;
    final selectedPlanogram = selectedFixture?.planogramId != null
        ? builderState.planograms[selectedFixture!.planogramId!]
        : null;

    return Scaffold(
      appBar: AppBar(
        title: Text(zone != null ? zone.name.toUpperCase() : 'ZONE'),
        actions: [
          RoleGuard(
            allowedRoles: const ['coordinator', 'manager'],
            child: TextButton(
              onPressed: () => context.goNamed(AppRoutes.outfitProposalReview),
              child: const Text('PROPOSALS',
                  style: TextStyle(color: Colors.white)),
            ),
          ),
          RoleGuard(
            allowedRoles: const ['coordinator', 'manager'],
            child: TextButton(
              onPressed: () => context.goNamed(
                AppRoutes.floorBuilder,
                pathParameters: {'zoneId': widget.zoneId},
              ),
              child: const Text('EDIT FLOOR', style: TextStyle(color: Colors.white)),
            ),
          ),
        ],
      ),
      body: builderState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.5,
                  child: Stack(
                    children: [
                      LayoutBuilder(
                        builder: (context, constraints) {
                          _canvasSize = constraints.biggest;
                          _pixelsPerFt = constraints.maxWidth / 20;
                          if (!_hasFitView && builderState.fixtures.isNotEmpty && _canvasSize != Size.zero) {
                            _hasFitView = true;
                            WidgetsBinding.instance.addPostFrameCallback((_) { if (mounted) _fitFixtures(builderState.fixtures); });
                          }
                          _painter = BuilderCanvasPainter(
                            fixtures: builderState.fixtures,
                            selectedFixtureId: selectedId,
                            ghostPos: null,
                            ghostType: null,
                            pixelsPerFt: _pixelsPerFt,
                            zoneNormalizedPts: (zonePts != null && zonePts.length >= 3) ? zonePts : null,
                            zoneColor: zoneRow != null ? Color(zoneRow.colorValue) : null,
                            zoneName: zoneRow?.name,
                            wallEdges: null,
                            planograms: builderState.planograms,
                            mannequins: builderState.mannequins,
                            platforms: builderState.platforms,
                            sceneProps: builderState.sceneProps,
                          );
                          return ClipRect(
                            child: Listener(
                              onPointerDown: _onPointerDown,
                              onPointerMove: _onPointerMove,
                              onPointerUp: _onPointerUp,
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
                          );
                        },
                      ),
                      if (selectedFixture != null)
                        Positioned(
                          left: 0,
                          right: 0,
                          bottom: 0,
                          child: FixtureMiniPanel(
                            fixture: selectedFixture,
                            planogram: selectedPlanogram,
                            onDismiss: () => ref
                                .read(floorBuilderNotifierProvider.notifier)
                                .selectFixture(null),
                            onRotate: () => ref
                                .read(floorBuilderNotifierProvider.notifier)
                                .rotateFixture(selectedFixture.id),
                            onEdit: () => _showFixtureEdit(
                              selectedFixture.id,
                              selectedFixture.label.isNotEmpty
                                  ? selectedFixture.label
                                  : selectedFixture.fixtureType.toUpperCase(),
                              selectedFixture.fixtureType,
                              selectedFixture.wallAdjacent,
                            ),
                            onDelete: () => ref
                                .read(floorBuilderNotifierProvider.notifier)
                                .deleteFixture(selectedFixture.id),
                          ),
                        ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                _MannequinSection(
                  storeId: storeId,
                  zoneId: widget.zoneId,
                  mannequins: builderState.mannequins,
                ),
              ],
            ),
    );
  }
}

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
          const SizedBox(height: DesignTokens.spaceSm),
          OutlinedButton.icon(
            onPressed: () => widget.onAssignPlanogram(widget.fixtureId, true),
            icon: const Icon(Icons.grid_view_rounded, size: 16),
            label: const Text('ASSIGN PLANOGRAM (FRONT)'),
          ),
          const SizedBox(height: DesignTokens.spaceXs),
          OutlinedButton.icon(
            onPressed: () => widget.onAssignPlanogram(widget.fixtureId, false),
            icon: const Icon(Icons.grid_view_rounded, size: 16),
            label: const Text('ASSIGN PLANOGRAM (BACK)'),
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
                      borderRadius: BorderRadius.all(Radius.circular(AppTheme.borderRadius)),
                    ),
                  ),
                  child: const Text('RENAME'),
                ),
              ),
              const SizedBox(width: DesignTokens.spaceSm),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.errorColor,
                    foregroundColor: Colors.white,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(AppTheme.borderRadius)),
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

class _MannequinSection extends StatelessWidget {
  const _MannequinSection({
    required this.storeId,
    required this.zoneId,
    required this.mannequins,
  });

  final String storeId;
  final String zoneId;
  final List<Mannequin> mannequins;

  String _formatType(String type) {
    return type.replaceAll('_', ' ').toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    if (mannequins.isEmpty) {
      return const Expanded(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.accessibility_new_outlined, size: 40, color: AppTheme.textHint),
              SizedBox(height: DesignTokens.spaceSm),
              Text(
                'No mannequins in this zone',
                style: TextStyle(color: AppTheme.textSecondary, fontSize: DesignTokens.typeMd),
              ),
              SizedBox(height: DesignTokens.spaceXs),
              Text(
                'Add mannequins in the Floor Builder.',
                style: TextStyle(color: AppTheme.textHint, fontSize: DesignTokens.typeSm),
              ),
            ],
          ),
        ),
      );
    }

    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
                DesignTokens.spaceMd, DesignTokens.spaceSm, DesignTokens.spaceMd, 0),
            child: Text(
              'MANNEQUINS (${mannequins.length})',
              style: const TextStyle(
                fontSize: DesignTokens.typeXs,
                fontWeight: DesignTokens.weightBold,
                letterSpacing: DesignTokens.letterSpacingEyebrow,
                color: AppTheme.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: DesignTokens.spaceSm),
              itemCount: mannequins.length,
              separatorBuilder: (_, __) =>
                  const Divider(height: 1, indent: DesignTokens.spaceMd),
              itemBuilder: (context, i) {
                final m = mannequins[i];
                final displayName = m.name?.isNotEmpty == true
                    ? m.name!
                    : _formatType(m.mannequinType);
                return ListTile(
                  leading: const Icon(Icons.accessibility_new_outlined,
                      color: AppTheme.textSecondary),
                  title: Text(
                    displayName,
                    style: const TextStyle(
                      fontSize: DesignTokens.typeMd,
                      fontWeight: DesignTokens.weightBold,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${_formatType(m.mannequinType)}  ·  ${_formatType(m.mountType)}',
                        style: const TextStyle(
                          fontSize: DesignTokens.typeSm,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      if (m.outfitName != null && m.outfitName!.isNotEmpty)
                        Text(
                          m.outfitName!,
                          style: const TextStyle(
                            fontSize: DesignTokens.typeXs,
                            color: AppTheme.accent,
                            fontWeight: DesignTokens.weightBold,
                            letterSpacing: 0.5,
                          ),
                        ),
                    ],
                  ),
                  trailing: OutlinedButton(
                    onPressed: () =>
                        showMannequinDressingSheet(context, m, storeId),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.accent,
                      side: const BorderSide(color: AppTheme.accent),
                      padding: const EdgeInsets.symmetric(
                          horizontal: DesignTokens.spaceSm),
                      shape: const RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.all(Radius.circular(AppTheme.borderRadius)),
                      ),
                    ),
                    child: const Text(
                      'DRESS',
                      style: TextStyle(
                        fontSize: DesignTokens.typeXs,
                        fontWeight: DesignTokens.weightBold,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

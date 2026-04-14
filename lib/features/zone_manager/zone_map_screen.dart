import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/database/app_database.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/design_tokens.dart';
import 'zone_map_painter.dart';
import 'zone_map_provider.dart';
import 'zone_legend_panel.dart';

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
    final user = ref.watch(currentUserProvider).value;

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
                    child: CustomPaint(
                      painter: ZoneMapPainter(
                        zones: state.zones,
                        canvasSize: const Size(800, 600),
                        selectedZoneId: state.selectedZoneId,
                        onZoneTap: _onZoneTap,
                      ),
                      size: const Size(800, 600),
                    ),
                  ),
          ),
          const ZoneLegendPanel(),
        ],
      ),
      floatingActionButton: user?.role == 'coordinator'
          ? FloatingActionButton.extended(
              onPressed: () =>
                  ref.read(zoneMapNotifierProvider.notifier).addZone(),
              label: const Text('ADD ZONE'),
              icon: const Icon(Icons.add),
              backgroundColor: AppTheme.accent,
            )
          : null,
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
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
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
              margin: const EdgeInsets.only(top: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
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
                  spacing: 8,
                  runSpacing: 8,
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

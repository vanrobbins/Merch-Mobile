import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/database/app_database.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/design_tokens.dart';
import 'zone_map_provider.dart';

class ZoneLegendPanel extends ConsumerWidget {
  const ZoneLegendPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(zoneMapNotifierProvider);
    return _LegendRow(
      zones: state.zones,
      selectedZoneId: state.selectedZoneId,
      onSelect: (id) => ref.read(zoneMapNotifierProvider.notifier).selectZone(id),
    );
  }
}

class _LegendRow extends StatelessWidget {
  const _LegendRow({
    required this.zones,
    this.selectedZoneId,
    required this.onSelect,
  });

  final List<ZonesTableData> zones;
  final String? selectedZoneId;
  final void Function(String id) onSelect;

  @override
  Widget build(BuildContext context) {
    if (zones.isEmpty) return const SizedBox.shrink();
    return Container(
      height: 44,
      color: AppTheme.canvasBg,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(
          horizontal: DesignTokens.spaceSm,
          vertical: DesignTokens.spaceXs,
        ),
        child: Row(
          children: zones.map((zone) {
            final isSelected = zone.id == selectedZoneId;
            final color = Color(zone.colorValue);
            return GestureDetector(
              onTap: () => onSelect(zone.id),
              child: Container(
                margin: const EdgeInsets.only(right: DesignTokens.spaceXs),
                padding: const EdgeInsets.symmetric(
                  horizontal: DesignTokens.spaceSm,
                  vertical: DesignTokens.spaceXs,
                ),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(DesignTokens.radiusSm),
                  border: Border.all(
                    color: isSelected ? AppTheme.accent : color,
                    width: isSelected ? 2.0 : 1.0,
                  ),
                ),
                child: Text(
                  zone.name.toUpperCase(),
                  style: TextStyle(
                    fontSize: DesignTokens.typeXs,
                    fontWeight: DesignTokens.weightBold,
                    letterSpacing: DesignTokens.letterSpacingEyebrow,
                    color: isSelected ? AppTheme.accent : AppTheme.textPrimary,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/database/app_database.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/design_tokens.dart';
import '../../core/widgets/role_guard.dart';
import 'zone_map_provider.dart';
import 'zone_shape_picker.dart';

class ZonePropertiesPanel extends ConsumerStatefulWidget {
  const ZonePropertiesPanel({super.key, required this.zone});

  final ZonesTableData zone;

  @override
  ConsumerState<ZonePropertiesPanel> createState() =>
      _ZonePropertiesPanelState();
}

class _ZonePropertiesPanelState extends ConsumerState<ZonePropertiesPanel> {
  late TextEditingController _nameCtrl;

  static const _swatches = [
    0xFF3B6BC2,
    0xFF3A7D44,
    0xFFC19A6B,
    0xFF8B3D8B,
    0xFFE07B54,
    0xFF757575,
    0xFF9E9E9E,
  ];

  static const _zoneTypes = [
    ('display', 'Display'),
    ('cash_wrap', 'Cash Wrap'),
    ('fitting_room', 'Fitting Room'),
    ('entrance', 'Entrance'),
    ('storage', 'Storage'),
    ('other', 'Other'),
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
            MediaQuery.of(context).padding.bottom +
            16,
        left: 16,
        right: 16,
        top: 8,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'EDIT ZONE',
            style: TextStyle(
              fontSize: DesignTokens.typeLg,
              fontWeight: DesignTokens.weightBold,
              letterSpacing: DesignTokens.letterSpacingEyebrow,
            ),
          ),
          const SizedBox(height: DesignTokens.spaceMd),

          // Name
          TextField(
            controller: _nameCtrl,
            decoration: const InputDecoration(labelText: 'Zone Name'),
            onSubmitted: (v) => notifier.updateZoneName(widget.zone.id, v),
          ),
          const SizedBox(height: DesignTokens.spaceMd),

          // Zone type
          const Text(
            'ZONE TYPE',
            style: TextStyle(
              fontSize: DesignTokens.typeXs,
              fontWeight: DesignTokens.weightBold,
              letterSpacing: DesignTokens.letterSpacingEyebrow,
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: _zoneTypes.map(((String, String) t) {
              final isSelected = widget.zone.zoneType == t.$1;
              return ChoiceChip(
                label: Text(t.$2),
                selected: isSelected,
                selectedColor: AppTheme.primary,
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : null,
                  fontSize: DesignTokens.typeXs,
                ),
                onSelected: (_) =>
                    notifier.updateZoneType(widget.zone.id, t.$1),
              );
            }).toList(),
          ),
          const SizedBox(height: DesignTokens.spaceMd),

          // Color swatches
          const Text(
            'COLOR',
            style: TextStyle(
              fontSize: DesignTokens.typeXs,
              fontWeight: DesignTokens.weightBold,
              letterSpacing: DesignTokens.letterSpacingEyebrow,
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
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
                    borderRadius:
                        BorderRadius.circular(AppTheme.borderRadius),
                    border: Border.all(
                      color:
                          isSelected ? AppTheme.accent : Colors.transparent,
                      width: 2,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: DesignTokens.spaceMd),

          // Shape controls — coordinator/manager only
          RoleGuard(
            allowedRoles: const ['coordinator', 'manager'],
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      ZoneShapePicker.show(context, ref, widget.zone.id);
                    },
                    child: const Text('REPLACE SHAPE'),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: DesignTokens.spaceMd),

          // Open detail / Delete — coordinator/manager only
          RoleGuard(
            allowedRoles: const ['coordinator', 'manager'],
            child: Row(
              children: [
                if (widget.zone.zoneType == 'display')
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        notifier.updateZoneName(
                            widget.zone.id, _nameCtrl.text);
                        Navigator.pop(context);
                        context.goNamed(
                          AppRoutes.zoneDetail,
                          pathParameters: {'zoneId': widget.zone.id},
                        );
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.accent),
                      child: const Text('OPEN ZONE'),
                    ),
                  ),
                if (widget.zone.zoneType == 'display')
                  const SizedBox(width: 8),
                OutlinedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    notifier.deleteZone(widget.zone.id);
                  },
                  style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red),
                  child: const Text('DELETE'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/design_tokens.dart';
import 'zone_map_provider.dart';

class ZoneShapePicker {
  static void show(BuildContext context, WidgetRef ref, String zoneId) {
    showModalBottomSheet<void>(
      context: context,
      builder: (_) => _ZoneShapePickerSheet(zoneId: zoneId, ref: ref),
    );
  }
}

class _ZoneShapePickerSheet extends StatelessWidget {
  const _ZoneShapePickerSheet({required this.zoneId, required this.ref});
  final String zoneId;
  final WidgetRef ref;

  static const _shapes = [
    ('rectangle', 'Rectangle', Icons.crop_square),
    ('l_shape', 'L-Shape', Icons.crop),
    ('t_shape', 'T-Shape', Icons.add),
    ('u_shape', 'U-Shape', Icons.crop_free),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(DesignTokens.spaceMd),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'CHOOSE SHAPE',
            style: TextStyle(
              fontWeight: DesignTokens.weightBold,
              letterSpacing: DesignTokens.letterSpacingEyebrow,
              fontSize: DesignTokens.typeMd,
            ),
          ),
          const SizedBox(height: DesignTokens.spaceMd),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: _shapes.map(((String, String, IconData) s) {
              return GestureDetector(
                onTap: () {
                  ref
                      .read(zoneMapNotifierProvider.notifier)
                      .applyPreset(zoneId, s.$1);
                  Navigator.pop(context);
                },
                child: Container(
                  width: 100,
                  height: 80,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(s.$3, size: 32, color: AppTheme.primary),
                      const SizedBox(height: 4),
                      Text(s.$2, style: const TextStyle(fontSize: 11)),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: DesignTokens.spaceMd),
          const Text(
            'After selecting, drag the vertex handles to fine-tune the shape.',
            style: TextStyle(
              fontSize: DesignTokens.typeXs,
              color: AppTheme.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/design_tokens.dart';

class MannequinTypeSheet extends StatelessWidget {
  const MannequinTypeSheet({super.key, required this.onSelect});
  final void Function(String type, String mountType) onSelect;

  static const _types = [
    _MannequinTypeDef('full_body', Icons.accessibility_new_outlined, 'FULL BODY', 'floor'),
    _MannequinTypeDef('half_body', Icons.person_outline, 'HALF BODY', 'floor'),
    _MannequinTypeDef('torso', Icons.radio_button_unchecked, 'TORSO', 'floor'),
    _MannequinTypeDef('leg_form', Icons.vertical_align_bottom_outlined, 'LEG FORM', 'floor'),
    _MannequinTypeDef('bra_form', Icons.radio_button_checked, 'BRA FORM', 'floor'),
    _MannequinTypeDef('bag_stand', Icons.shopping_bag_outlined, 'BAG STAND', 'floor'),
    _MannequinTypeDef('hat_stand', Icons.hive_outlined, 'HAT STAND', 'floor'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppTheme.cardSurface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(DesignTokens.radiusLg)),
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
                color: AppTheme.divider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(DesignTokens.spaceMd),
            child: Text(
              'MANNEQUIN TYPE',
              style: TextStyle(
                fontSize: DesignTokens.typeLg,
                fontWeight: DesignTokens.weightBold,
                letterSpacing: DesignTokens.letterSpacingEyebrow,
              ),
            ),
          ),
          ..._types.map((t) => ListTile(
                leading: Icon(t.icon, color: AppTheme.accent),
                title: Text(
                  t.label,
                  style: const TextStyle(
                    fontWeight: DesignTokens.weightBold,
                    fontSize: DesignTokens.typeMd,
                    letterSpacing: DesignTokens.letterSpacingEyebrow,
                  ),
                ),
                trailing: const Icon(Icons.chevron_right, color: AppTheme.textSecondary),
                onTap: () {
                  Navigator.pop(context);
                  onSelect(t.type, t.mountType);
                },
              )),
          SizedBox(height: MediaQuery.of(context).padding.bottom + DesignTokens.spaceSm),
        ],
      ),
    );
  }
}

class _MannequinTypeDef {
  const _MannequinTypeDef(this.type, this.icon, this.label, this.mountType);
  final String type;
  final IconData icon;
  final String label;
  final String mountType;
}

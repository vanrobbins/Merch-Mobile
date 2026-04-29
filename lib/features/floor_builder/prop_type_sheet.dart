import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/design_tokens.dart';

class PropTypeSheet extends StatelessWidget {
  const PropTypeSheet({super.key, required this.onSelect});
  final void Function(String type) onSelect;

  static const _types = [
    _PropTypeDef('plant', Icons.park_outlined, 'PLANT'),
    _PropTypeDef('furniture', Icons.chair_outlined, 'FURNITURE'),
    _PropTypeDef('riser', Icons.layers_outlined, 'RISER'),
    _PropTypeDef('signage', Icons.campaign_outlined, 'SIGNAGE'),
    _PropTypeDef('other', Icons.category_outlined, 'OTHER'),
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
              'PROP TYPE',
              style: TextStyle(
                fontSize: DesignTokens.typeLg,
                fontWeight: DesignTokens.weightBold,
                letterSpacing: DesignTokens.letterSpacingEyebrow,
              ),
            ),
          ),
          ..._types.map((t) => ListTile(
                leading: Icon(t.icon, color: AppTheme.primary),
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
                  onSelect(t.type);
                },
              )),
          SizedBox(height: MediaQuery.of(context).padding.bottom + DesignTokens.spaceSm),
        ],
      ),
    );
  }
}

class _PropTypeDef {
  const _PropTypeDef(this.type, this.icon, this.label);
  final String type;
  final IconData icon;
  final String label;
}

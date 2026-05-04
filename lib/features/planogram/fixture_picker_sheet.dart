import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../core/theme/design_tokens.dart';

/// Bottom sheet that lets the user choose a fixture type to place.
/// Calls [onPick] with the chosen nodeType string, then dismisses.
class FixturePickerSheet extends StatelessWidget {
  const FixturePickerSheet({super.key, required this.onPick});

  final ValueChanged<String> onPick;

  static const _fixtures = [
    _FixtureConfig('shoulder', 'Shoulder', Icons.dry_cleaning, Color(0xFF3A3735)),
    _FixtureConfig('faceout',  'Face-out', Icons.view_agenda_outlined, Color(0xFF2E6DA4)),
    _FixtureConfig('ubar',     'U-Bar',    Icons.horizontal_rule,  AppTheme.accent),
    _FixtureConfig('shelf',    'Shelf',    Icons.table_rows_outlined, AppTheme.textSecondary),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppTheme.cardSurface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
      padding: const EdgeInsets.fromLTRB(
          DesignTokens.spaceMd, DesignTokens.spaceMd, DesignTokens.spaceMd, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.only(bottom: DesignTokens.spaceMd),
              decoration: BoxDecoration(
                color: AppTheme.surfaceVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const Text(
            'ADD FIXTURE',
            style: TextStyle(
              fontSize: DesignTokens.typeSm,
              fontWeight: DesignTokens.weightBold,
              letterSpacing: DesignTokens.letterSpacingEyebrow,
              color: AppTheme.primary,
            ),
          ),
          const SizedBox(height: DesignTokens.spaceMd),
          Row(
            children: _fixtures.map((config) {
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: _FixtureTile(
                    label: config.label,
                    icon: config.icon,
                    color: config.color,
                    onTap: () {
                      Navigator.pop(context);
                      onPick(config.nodeType);
                    },
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _FixtureTile extends StatelessWidget {
  const _FixtureTile({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: AppTheme.canvasBg,
          border: Border.all(color: AppTheme.divider),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 6),
            Text(
              label.toUpperCase(),
              style: TextStyle(
                fontSize: 8,
                fontWeight: DesignTokens.weightBold,
                letterSpacing: DesignTokens.letterSpacingEyebrow,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Immutable fixture type configuration.
class _FixtureConfig {
  const _FixtureConfig(this.nodeType, this.label, this.icon, this.color);

  final String nodeType;
  final String label;
  final IconData icon;
  final Color color;
}

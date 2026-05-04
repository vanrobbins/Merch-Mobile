import 'package:flutter/material.dart';
import '../../core/models/store_zone.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/design_tokens.dart';
import '../../core/widgets/mm_button.dart';

class ZoneActionsSheet extends StatelessWidget {
  const ZoneActionsSheet({
    super.key,
    required this.zone,
    required this.onEdit,
    this.onOpen,
  });
  final StoreZone zone;
  final VoidCallback onEdit;
  final VoidCallback? onOpen;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppTheme.cardSurface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(DesignTokens.radiusLg)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).padding.bottom + DesignTokens.spaceMd,
        left: DesignTokens.spaceMd,
        right: DesignTokens.spaceMd,
        top: DesignTokens.spaceSm,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: DesignTokens.spaceSm),
              decoration: BoxDecoration(
                color: AppTheme.divider,
                borderRadius: BorderRadius.circular(AppTheme.borderRadius),
              ),
            ),
          ),
          Text(
            zone.name.toUpperCase(),
            style: const TextStyle(
              fontSize: DesignTokens.typeLg,
              fontWeight: DesignTokens.weightBold,
              letterSpacing: DesignTokens.letterSpacingEyebrow,
            ),
          ),
          Text(
            zone.zoneType.replaceAll('_', ' ').toUpperCase(),
            style: const TextStyle(
              fontSize: DesignTokens.typeXs,
              color: AppTheme.textSecondary,
              fontWeight: DesignTokens.weightBold,
              letterSpacing: DesignTokens.letterSpacingEyebrow,
            ),
          ),
          const SizedBox(height: DesignTokens.spaceMd),
          Row(
            children: [
              Expanded(
                child: MmButton.outlined(
                  label: 'EDIT ZONE',
                  icon: Icons.edit_outlined,
                  onPressed: onEdit,
                ),
              ),
              if (onOpen != null) ...[
                const SizedBox(width: DesignTokens.spaceSm),
                Expanded(
                  child: MmButton(
                    label: 'OPEN ZONE',
                    icon: Icons.open_in_new,
                    onPressed: onOpen,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

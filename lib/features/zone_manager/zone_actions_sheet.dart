import 'package:flutter/material.dart';
import '../../core/models/store_zone.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/design_tokens.dart';

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
        color: Colors.white,
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
                color: Colors.grey.shade300,
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
                child: OutlinedButton.icon(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit_outlined, size: 18),
                  label: const Text('EDIT ZONE'),
                  style: OutlinedButton.styleFrom(
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(AppTheme.borderRadius)),
                    ),
                  ),
                ),
              ),
              if (onOpen != null) ...[
                const SizedBox(width: DesignTokens.spaceSm),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: onOpen,
                    icon: const Icon(Icons.open_in_new, size: 18),
                    label: const Text('OPEN ZONE'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.accent,
                      foregroundColor: Colors.white,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(AppTheme.borderRadius)),
                      ),
                    ),
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

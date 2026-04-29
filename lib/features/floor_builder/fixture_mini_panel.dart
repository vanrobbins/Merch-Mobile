import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/models/fixture.dart';
import '../../core/models/planogram.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/design_tokens.dart';
import 'planogram_slot_count.dart';

class FixtureMiniPanel extends StatelessWidget {
  const FixtureMiniPanel({
    super.key,
    required this.fixture,
    required this.planogram,
    required this.onDismiss,
    this.onEdit,
    this.onRotate,
    this.onDelete,
  });

  final Fixture fixture;
  final Planogram? planogram;
  final VoidCallback onDismiss;
  final VoidCallback? onEdit;
  final VoidCallback? onRotate;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final slotCount = countPlanogramSlots(planogram?.slotsJson);
    final label =
        (fixture.label.isNotEmpty ? fixture.label : fixture.fixtureType)
            .toUpperCase();

    return Container(
      decoration: const BoxDecoration(
        color: AppTheme.primary,
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 12, offset: Offset(0, -2))],
      ),
      padding: EdgeInsets.only(
        left: DesignTokens.spaceMd,
        right: DesignTokens.spaceSm,
        top: DesignTokens.spaceSm,
        bottom: MediaQuery.of(context).padding.bottom + DesignTokens.spaceSm,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 32,
              height: 3,
              margin: const EdgeInsets.only(bottom: DesignTokens.spaceSm),
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          // Header row: label + quick actions
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: DesignTokens.typeMd,
                        fontWeight: DesignTokens.weightBold,
                        letterSpacing: DesignTokens.letterSpacingEyebrow,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${fixture.widthFt.toStringAsFixed(1)} × ${fixture.depthFt.toStringAsFixed(1)} ft  ·  ${fixture.fixtureType}',
                      style: const TextStyle(color: Colors.white54, fontSize: DesignTokens.typeSm),
                    ),
                  ],
                ),
              ),
              // Quick actions
              if (onRotate != null)
                _MiniAction(
                  icon: Icons.rotate_right,
                  tooltip: 'Rotate 90°',
                  onTap: onRotate!,
                ),
              if (onEdit != null)
                _MiniAction(
                  icon: Icons.edit_outlined,
                  tooltip: 'Rename / options',
                  onTap: onEdit!,
                ),
              if (onDelete != null)
                _MiniAction(
                  icon: Icons.delete_outline,
                  tooltip: 'Delete',
                  color: AppTheme.accent,
                  onTap: onDelete!,
                ),
              _MiniAction(
                icon: Icons.close,
                tooltip: 'Dismiss',
                color: Colors.white54,
                onTap: onDismiss,
              ),
            ],
          ),
          // Planogram row
          const SizedBox(height: DesignTokens.spaceSm),
          Row(
            children: [
              const Icon(Icons.grid_view_rounded, color: Colors.white38, size: 15),
              const SizedBox(width: 6),
              Expanded(
                child: planogram == null
                    ? const Text(
                        'No planogram assigned',
                        style: TextStyle(color: Colors.white54, fontSize: DesignTokens.typeSm),
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            planogram!.title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: DesignTokens.typeSm,
                              fontWeight: DesignTokens.weightBold,
                            ),
                          ),
                          Text(
                            '$slotCount slots · ${planogram!.season}',
                            style: const TextStyle(
                              color: Colors.white54,
                              fontSize: DesignTokens.typeSm,
                            ),
                          ),
                        ],
                      ),
              ),
              if (planogram != null)
                TextButton(
                  onPressed: () => context.goNamed(
                    AppRoutes.planogramDetail,
                    pathParameters: {'planogramId': planogram!.id},
                  ),
                  style: TextButton.styleFrom(
                    foregroundColor: AppTheme.accent,
                    padding: const EdgeInsets.symmetric(horizontal: DesignTokens.spaceSm),
                  ),
                  child: const Text(
                    'VIEW →',
                    style: TextStyle(
                      fontWeight: DesignTokens.weightBold,
                      fontSize: DesignTokens.typeSm,
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniAction extends StatelessWidget {
  const _MiniAction({
    required this.icon,
    required this.onTap,
    this.tooltip,
    this.color = Colors.white70,
  });
  final IconData icon;
  final VoidCallback onTap;
  final String? tooltip;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(icon, color: color, size: 20),
      onPressed: onTap,
      tooltip: tooltip,
      padding: const EdgeInsets.all(DesignTokens.spaceSm),
      constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
    );
  }
}

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
    this.onExpandPlanogram,
  });

  final Fixture fixture;
  final Planogram? planogram;
  final VoidCallback onDismiss;
  final VoidCallback? onEdit;
  final VoidCallback? onRotate;
  final VoidCallback? onDelete;
  final VoidCallback? onExpandPlanogram;

  @override
  Widget build(BuildContext context) {
    final slotCount = countPlanogramSlots(planogram?.slotsJson);
    final label =
        (fixture.label.isNotEmpty ? fixture.label : fixture.fixtureType)
            .toUpperCase();

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.primary,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
        boxShadow: [BoxShadow(color: AppTheme.primary.withValues(alpha: 0.15), blurRadius: 12, offset: const Offset(0, -2))],
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
          GestureDetector(
            onTap: onExpandPlanogram,
            onVerticalDragEnd: onExpandPlanogram == null
                ? null
                : (d) {
                    if ((d.primaryVelocity ?? 0) < -100) onExpandPlanogram!();
                  },
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppTheme.canvasBg.withValues(alpha: onExpandPlanogram != null ? 0.54 : 0.24),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        color: AppTheme.canvasBg,
                        fontSize: DesignTokens.typeMd,
                        fontWeight: DesignTokens.weightBold,
                        letterSpacing: DesignTokens.letterSpacingEyebrow,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${fixture.widthFt.toStringAsFixed(1)} × ${fixture.depthFt.toStringAsFixed(1)} ft  ·  ${fixture.fixtureType}',
                      style: TextStyle(color: AppTheme.canvasBg.withValues(alpha: 0.54), fontSize: DesignTokens.typeSm),
                    ),
                  ],
                ),
              ),
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
                color: AppTheme.canvasBg,
                onTap: onDismiss,
              ),
            ],
          ),
          const SizedBox(height: DesignTokens.spaceSm),
          InkWell(
            onTap: onExpandPlanogram,
            borderRadius: BorderRadius.circular(4),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Icon(Icons.grid_view_rounded, color: AppTheme.canvasBg.withValues(alpha: 0.38), size: 15),
                  const SizedBox(width: 6),
                  Expanded(
                    child: planogram == null
                        ? Text(
                            'No planogram assigned',
                            style: TextStyle(color: AppTheme.canvasBg.withValues(alpha: 0.54), fontSize: DesignTokens.typeSm),
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                planogram!.title,
                                style: const TextStyle(
                                  color: AppTheme.canvasBg,
                                  fontSize: DesignTokens.typeSm,
                                  fontWeight: DesignTokens.weightBold,
                                ),
                              ),
                              Text(
                                '$slotCount slots · ${planogram!.season}',
                                style: TextStyle(
                                  color: AppTheme.canvasBg.withValues(alpha: 0.54),
                                  fontSize: DesignTokens.typeSm,
                                ),
                              ),
                            ],
                          ),
                  ),
                  if (planogram == null && onExpandPlanogram != null)
                    const Text(
                      'ASSIGN →',
                      style: TextStyle(
                        color: AppTheme.accent,
                        fontSize: DesignTokens.typeSm,
                        fontWeight: DesignTokens.weightBold,
                        letterSpacing: 1.0,
                      ),
                    ),
                  if (planogram != null && onExpandPlanogram != null)
                    Icon(Icons.keyboard_arrow_up, color: AppTheme.canvasBg.withValues(alpha: 0.38), size: 18),
                  if (planogram != null && onExpandPlanogram == null)
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
            ),
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
    this.color = AppTheme.canvasBg,
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

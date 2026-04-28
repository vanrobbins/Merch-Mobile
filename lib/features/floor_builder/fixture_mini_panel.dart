import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/models/fixture.dart';
import '../../core/models/planogram.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/app_theme.dart';
import 'planogram_slot_count.dart';

class FixtureMiniPanel extends StatelessWidget {
  const FixtureMiniPanel({
    super.key,
    required this.fixture,
    required this.planogram,
    required this.onDismiss,
    this.onEdit,
  });

  final Fixture fixture;
  final Planogram? planogram;
  final VoidCallback onDismiss;
  final VoidCallback? onEdit;

  @override
  Widget build(BuildContext context) {
    final slotCount = countPlanogramSlots(planogram?.slotsJson);

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF1A1917),
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
      padding: const EdgeInsets.fromLTRB(16, 8, 8, 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  (fixture.label.isNotEmpty ? fixture.label : fixture.fixtureType).toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              if (onEdit != null)
                IconButton(
                  icon: const Icon(Icons.edit_outlined, color: Colors.white70, size: 20),
                  onPressed: onEdit,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  tooltip: 'Edit fixture',
                ),
              const SizedBox(width: 4),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white54, size: 20),
                onPressed: onDismiss,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            '${fixture.widthFt.toStringAsFixed(1)} \u00d7 ${fixture.depthFt.toStringAsFixed(1)} ft',
            style: const TextStyle(color: Colors.white54, fontSize: 11),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.grid_view_rounded, color: Colors.white38, size: 16),
              const SizedBox(width: 6),
              Expanded(
                child: planogram == null
                    ? const Text('No planogram', style: TextStyle(color: Colors.white54, fontSize: 12))
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(planogram!.title,
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700)),
                          Text('$slotCount slots assigned \u00b7 ${planogram!.season}',
                              style: const TextStyle(color: Colors.white54, fontSize: 11)),
                        ],
                      ),
              ),
              if (planogram != null)
                TextButton(
                  onPressed: () => _navigateToPlanogram(context, planogram!.id),
                  style: TextButton.styleFrom(
                    foregroundColor: AppTheme.accent,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                  child: const Text('VIEW \u2192',
                      style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12, letterSpacing: 1.2)),
                ),
            ],
          ),
        ],
      ),
    );
  }

  void _navigateToPlanogram(BuildContext context, String planogramId) {
    context.goNamed(
      AppRoutes.planogramDetail,
      pathParameters: {'planogramId': planogramId},
    );
  }
}

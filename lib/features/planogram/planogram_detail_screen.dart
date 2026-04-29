import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/app_router.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/design_tokens.dart';
import '../../core/providers/store_provider.dart';
import '../../core/widgets/role_guard.dart';
import 'planogram_provider.dart';
import 'planogram_proposal_screen.dart';
import 'planogram_slot.dart';

/// Read-only planogram detail for all roles.
/// Coordinator/manager see an EDIT button that opens PlanogramEditorScreen.
/// Staff see a PROPOSE CHANGE FAB.
class PlanogramDetailScreen extends ConsumerWidget {
  const PlanogramDetailScreen({super.key, required this.planogramId});

  final String planogramId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final planogramAsync = ref.watch(planogramDetailProvider(planogramId));
    final slots = ref.watch(planogramEditorProvider(planogramId));
    final membership = ref.watch(currentMembershipProvider).value;
    final role = membership?.role ?? 'staff';

    return planogramAsync.when(
      data: (planogram) {
        if (planogram == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('PLANOGRAM')),
            body: const Center(child: Text('Not found')),
          );
        }

        // Lazy-init slots once per planogram row. loadSlots() falls back to
        // defaults(6) when slotsJson is empty.
        if (slots.isEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ref
                .read(planogramEditorProvider(planogramId).notifier)
                .loadSlots(planogram.slotsJson);
          });
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(planogram.title.toUpperCase()),
            actions: [
              RoleGuard(
                allowedRoles: const ['coordinator', 'manager'],
                child: TextButton(
                  onPressed: () => context.goNamed(
                    AppRoutes.planogramEdit,
                    pathParameters: {'planogramId': planogramId},
                  ),
                  child: const Text(
                    'EDIT',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
          body: Column(
            children: [
              // Status + season chip row
              Padding(
                padding: const EdgeInsets.all(DesignTokens.spaceMd),
                child: Row(
                  children: [
                    _StatusChip(status: planogram.status),
                    const SizedBox(width: DesignTokens.spaceSm),
                    Text(
                      '${planogram.season} · ${slots.length} slots',
                      style: const TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: DesignTokens.typeXs,
                      ),
                    ),
                  ],
                ),
              ),
              // Slot grid (read-only)
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.all(DesignTokens.spaceMd),
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                    childAspectRatio: 0.85,
                  ),
                  itemCount: slots.length,
                  itemBuilder: (_, i) => _SlotCard(slot: slots[i]),
                ),
              ),
            ],
          ),
          floatingActionButton: role == 'staff'
              ? FloatingActionButton.extended(
                  onPressed: () => Navigator.push<void>(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PlanogramProposalScreen(
                        planogramId: planogramId,
                      ),
                    ),
                  ),
                  label: const Text('PROPOSE CHANGE'),
                  icon: const Icon(Icons.edit_note),
                  backgroundColor: AppTheme.accent,
                  foregroundColor: Colors.white,
                )
              : null,
        );
      },
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(body: Center(child: Text('Error: $e'))),
    );
  }
}

class _SlotCard extends StatelessWidget {
  const _SlotCard({required this.slot});

  final PgSlot slot;

  @override
  Widget build(BuildContext context) {
    final hasProduct = slot.productId != null;
    final inner = Padding(
      padding: const EdgeInsets.all(DesignTokens.spaceSm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: DesignTokens.spaceXs,
              vertical: 1,
            ),
            decoration: BoxDecoration(
              color: hasProduct
                  // ignore: deprecated_member_use
                  ? AppTheme.primary.withOpacity(0.08)
                  : Colors.grey.shade200,
              borderRadius: BorderRadius.circular(AppTheme.borderRadius),
            ),
            child: Text(
              '#${slot.position}',
              style: const TextStyle(
                fontSize: DesignTokens.typeXs,
                fontWeight: DesignTokens.weightBold,
                letterSpacing: DesignTokens.letterSpacingEyebrow,
                color: AppTheme.textSecondary,
              ),
            ),
          ),
          const Spacer(),
          if (hasProduct) ...[
            Text(
              slot.productName ?? '',
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              slot.productSku ?? '',
              style: const TextStyle(
                fontSize: 10,
                color: AppTheme.textSecondary,
              ),
            ),
          ] else
            const Text(
              'UNASSIGNED',
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey,
                fontWeight: DesignTokens.weightBold,
                letterSpacing: DesignTokens.letterSpacingEyebrow,
              ),
            ),
        ],
      ),
    );

    // Empty slots get a dashed border; assigned slots get a solid border.
    final content = hasProduct
        ? Container(
            decoration: BoxDecoration(
              color: AppTheme.canvasBg,
              border: Border.all(
                // ignore: deprecated_member_use
                color: AppTheme.primary.withOpacity(0.4),
              ),
              borderRadius: BorderRadius.circular(AppTheme.borderRadius),
            ),
            child: inner,
          )
        : CustomPaint(
            painter: _DashedBorderPainter(
              color: Colors.grey.shade400,
              radius: AppTheme.borderRadius,
            ),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(AppTheme.borderRadius),
              ),
              child: inner,
            ),
          );

    return content;
  }
}

/// Colored status chip used in the planogram detail header.
class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});
  final String status;

  @override
  Widget build(BuildContext context) {
    final lower = status.toLowerCase();
    Color bg;
    Color fg;
    switch (lower) {
      case 'published':
      case 'approved':
        bg = Colors.green.shade600;
        fg = Colors.white;
        break;
      case 'rejected':
        bg = Colors.red.shade600;
        fg = Colors.white;
        break;
      case 'pending':
        bg = Colors.amber.shade700;
        fg = Colors.white;
        break;
      default:
        bg = Colors.grey.shade600;
        fg = Colors.white;
    }
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: DesignTokens.spaceSm,
        vertical: 3,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppTheme.borderRadius),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: fg,
          fontSize: DesignTokens.typeXs,
          fontWeight: DesignTokens.weightBold,
          letterSpacing: DesignTokens.letterSpacingEyebrow,
        ),
      ),
    );
  }
}

/// Paints a dashed rounded-rectangle border around the child.
class _DashedBorderPainter extends CustomPainter {
  _DashedBorderPainter({required this.color, required this.radius});
  final Color color;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    final rect = RRect.fromRectAndRadius(
      Offset.zero & size,
      Radius.circular(radius),
    );
    final path = Path()..addRRect(rect);
    const dash = 4.0;
    const gap = 3.0;
    for (final metric in path.computeMetrics()) {
      var dist = 0.0;
      while (dist < metric.length) {
        final end = (dist + dash).clamp(0.0, metric.length);
        canvas.drawPath(metric.extractPath(dist, end), paint);
        dist += dash + gap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedBorderPainter old) =>
      old.color != color || old.radius != radius;
}

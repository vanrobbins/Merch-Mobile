import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../core/theme/design_tokens.dart';
import '../../core/providers/store_provider.dart';
import '../../core/widgets/role_guard.dart';
import 'planogram_provider.dart';
import 'planogram_proposal_screen.dart';
import 'planogram_slot.dart';
import 'product_slot_picker.dart';

/// Coordinator/manager: tap slot to assign, long-press to clear.
/// Staff: read-only + floating action button to submit a proposal.
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
                  onPressed: () => ref
                      .read(planogramEditorProvider(planogramId).notifier)
                      .save(planogramId),
                  child: const Text(
                    'SAVE',
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
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: planogram.status == 'published'
                            ? Colors.green
                            : Colors.grey,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        planogram.status.toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: DesignTokens.weightBold,
                        ),
                      ),
                    ),
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
              // Slot grid
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
                  itemBuilder: (_, i) => _SlotCard(
                    slot: slots[i],
                    planogramId: planogramId,
                    role: role,
                    onAssign: () => ProductSlotPicker.show(
                      context,
                      planogramId,
                      slots[i].id,
                    ),
                    onClear: () => ref
                        .read(planogramEditorProvider(planogramId).notifier)
                        .clearSlot(slots[i].id),
                  ),
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
  const _SlotCard({
    required this.slot,
    required this.planogramId,
    required this.role,
    required this.onAssign,
    required this.onClear,
  });

  final PgSlot slot;
  final String planogramId;
  final String role;
  final VoidCallback onAssign;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final canEdit = role == 'coordinator' || role == 'manager';
    final hasProduct = slot.productId != null;
    return GestureDetector(
      onTap: canEdit ? onAssign : null,
      onLongPress: canEdit && hasProduct ? onClear : null,
      child: Container(
        decoration: BoxDecoration(
          color: hasProduct ? AppTheme.canvasBg : Colors.grey.shade100,
          border: Border.all(
            color: hasProduct
                // ignore: deprecated_member_use
                ? AppTheme.primary.withOpacity(0.4)
                : Colors.grey.shade300,
          ),
          borderRadius: BorderRadius.circular(AppTheme.borderRadius),
        ),
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '#${slot.position}',
              style: const TextStyle(
                fontSize: 10,
                color: AppTheme.textSecondary,
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
                style: TextStyle(fontSize: 10, color: Colors.grey),
              ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models/planogram_proposal.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/providers/store_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/design_tokens.dart';
import '../../core/widgets/mm_button.dart';
import '../../core/widgets/mm_empty_state.dart';
import 'planogram_provider.dart';
import 'planogram_slot.dart';

/// Manager/coordinator-facing queue of pending planogram proposals for a
/// specific planogram. Approves or rejects each proposal and records the
/// reviewer + timestamp.
class ProposalReviewScreen extends ConsumerWidget {
  const ProposalReviewScreen({super.key, required this.planogramId});

  final String planogramId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final proposalsAsync = ref.watch(proposalListProvider);

    final filtered = proposalsAsync.whenData(
      (list) => list
          .where((p) => p.planogramId == planogramId && p.status == 'pending')
          .toList(),
    );

    return Scaffold(
      appBar: AppBar(title: const Text('PROPOSALS')),
      body: filtered.when(
        data: (proposals) => proposals.isEmpty
            ? const MmEmptyState(
                icon: Icons.inbox_outlined,
                headline: 'No Pending Proposals',
                body: 'All clear. New proposals will appear here.',
              )
            : ListView.separated(
                padding: const EdgeInsets.all(DesignTokens.spaceMd),
                itemCount: proposals.length,
                separatorBuilder: (_, __) =>
                    const SizedBox(height: DesignTokens.spaceMd),
                itemBuilder: (_, i) =>
                    _ProposalCard(proposal: proposals[i]),
              ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(DesignTokens.spaceLg),
            child: Text(
              'Error: $e',
              style: const TextStyle(color: AppTheme.textSecondary),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}

/// Colored status chip for proposal status.
class _ProposalStatusChip extends StatelessWidget {
  const _ProposalStatusChip({required this.status});
  final String status;

  @override
  Widget build(BuildContext context) {
    Color bg;
    switch (status.toLowerCase()) {
      case 'approved':
        bg = AppTheme.successColor;
        break;
      case 'rejected':
        bg = AppTheme.errorColor;
        break;
      case 'pending':
      default:
        bg = AppTheme.accent;
    }
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: DesignTokens.spaceSm,
        vertical: 3,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(DesignTokens.radiusBadge),
      ),
      child: Text(
        status.toUpperCase(),
        style: const TextStyle(
          color: AppTheme.canvasBg,
          fontSize: DesignTokens.typeXs,
          fontWeight: DesignTokens.weightBold,
          letterSpacing: DesignTokens.letterSpacingEyebrow,
        ),
      ),
    );
  }
}

class _ProposalCard extends ConsumerWidget {
  const _ProposalCard({required this.proposal});
  final PlanogramProposal proposal;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final slots = proposal.slotChanges.isNotEmpty
        ? PgSlot.decodeList(proposal.slotChanges)
        : <PgSlot>[];
    final assignedCount = slots.where((s) => s.productId != null).length;

    // Never show raw UIDs in the UI — use a friendly fallback.
    const proposerLabel = 'a team member';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(DesignTokens.spaceMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Proposed by $proposerLabel',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: DesignTokens.typeSm,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: DesignTokens.spaceSm),
                _ProposalStatusChip(status: proposal.status),
              ],
            ),
            if (proposal.notes.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: DesignTokens.spaceXs),
                child: Text(
                  proposal.notes,
                  style:
                      const TextStyle(color: AppTheme.textSecondary),
                ),
              ),
            const SizedBox(height: DesignTokens.spaceSm),
            Text(
              '$assignedCount/${slots.length} slots assigned',
              style: const TextStyle(
                fontSize: DesignTokens.typeXs,
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: DesignTokens.spaceMd),
            Row(
              children: [
                Expanded(
                  child: MmButton(
                    label: 'APPROVE',
                    onPressed: () => _review(ref, 'approved'),
                  ),
                ),
                const SizedBox(width: DesignTokens.spaceSm),
                Expanded(
                  child: MmButton.destructive(
                    label: 'REJECT',
                    onPressed: () => _review(ref, 'rejected'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _review(WidgetRef ref, String status) {
    final storeId = ref.read(activeStoreIdProvider).value ?? '';
    final user = ref.read(authStateProvider).value;
    updateProposalStatus(storeId, proposal.id, status, user?.uid ?? '');
  }
}

import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/database/app_database.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/providers/database_provider.dart';
import '../../core/providers/store_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/design_tokens.dart';
import '../../core/widgets/mm_empty_state.dart';
import 'planogram_slot.dart';

/// Manager/coordinator-facing queue of pending planogram proposals for a
/// specific planogram. Approves or rejects each proposal and records the
/// reviewer + timestamp.
class ProposalReviewScreen extends ConsumerWidget {
  const ProposalReviewScreen({super.key, required this.planogramId});

  final String planogramId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.watch(appDatabaseProvider);
    final storeId = ref.watch(activeStoreIdProvider).value ?? '';

    final proposalsAsync = ref.watch(
      StreamProvider<List<PlanogramProposalsTableData>>(
        (r) => db.planogramProposalsDao.watchPendingByStore(storeId),
      ),
    );

    final filtered = proposalsAsync.whenData(
      (list) => list.where((p) => p.planogramId == planogramId).toList(),
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
        bg = Colors.green.shade600;
        break;
      case 'rejected':
        bg = Colors.red.shade600;
        break;
      case 'pending':
      default:
        bg = Colors.amber.shade700;
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
        style: const TextStyle(
          color: Colors.white,
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
  final PlanogramProposalsTableData proposal;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final slots = proposal.slotChanges != null
        ? PgSlot.decodeList(proposal.slotChanges!)
        : <PgSlot>[];
    final assignedCount = slots.where((s) => s.productId != null).length;

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
                    'Proposed by ${proposal.proposedByUid}',
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
            if (proposal.notes != null)
              Padding(
                padding: const EdgeInsets.only(top: DesignTokens.spaceXs),
                child: Text(
                  proposal.notes!,
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
                  child: ElevatedButton(
                    onPressed: () => _review(ref, 'approved'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade600,
                      foregroundColor: Colors.white,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(
                            Radius.circular(AppTheme.borderRadius)),
                      ),
                    ),
                    child: const Text('APPROVE'),
                  ),
                ),
                const SizedBox(width: DesignTokens.spaceSm),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _review(ref, 'rejected'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red.shade600,
                      side: BorderSide(color: Colors.red.shade600),
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(
                            Radius.circular(AppTheme.borderRadius)),
                      ),
                    ),
                    child: const Text('REJECT'),
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
    final db = ref.read(appDatabaseProvider);
    final user = ref.read(authStateProvider).value;
    db.planogramProposalsDao.upsert(
      proposal.toCompanion(true).copyWith(
            status: Value(status),
            reviewedByUid: Value(user?.uid),
            reviewedAt: Value(DateTime.now().millisecondsSinceEpoch),
          ),
    );
  }
}

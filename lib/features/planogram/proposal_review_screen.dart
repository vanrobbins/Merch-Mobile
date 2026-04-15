import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/database/app_database.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/providers/database_provider.dart';
import '../../core/providers/store_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/design_tokens.dart';
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
            ? const Center(
                child: Text(
                  'No pending proposals.',
                  style: TextStyle(color: AppTheme.textSecondary),
                ),
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
        error: (e, _) => Center(child: Text('Error: $e')),
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
            Text(
              'Proposed by ${proposal.proposedByUid}',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: DesignTokens.typeSm,
              ),
            ),
            if (proposal.notes != null)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  proposal.notes!,
                  style:
                      const TextStyle(color: AppTheme.textSecondary),
                ),
              ),
            const SizedBox(height: 8),
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
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('APPROVE'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _review(ref, 'rejected'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
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

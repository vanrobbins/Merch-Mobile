import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/models/mannequin_outfit_proposal.dart';
import '../../core/models/mannequin_outfit_slot.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/providers/store_provider.dart';
import '../../core/services/firestore_refs.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/design_tokens.dart';
import '../../core/widgets/mm_button.dart';
import '../../core/widgets/mm_empty_state.dart';

/// Manager / coordinator screen listing all pending mannequin outfit proposals
/// for the active store. Each card lets the reviewer APPROVE or REJECT.
class OutfitProposalReviewScreen extends ConsumerWidget {
  const OutfitProposalReviewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final storeId = ref.watch(activeStoreIdProvider).value ?? '';

    return Scaffold(
      appBar: AppBar(title: const Text('OUTFIT PROPOSALS')),
      body: storeId.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: FirestoreRefs.mannequinProposals(storeId)
                  .where('status', isEqualTo: 'pending')
                  .snapshots(),
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snap.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(DesignTokens.spaceLg),
                      child: Text(
                        'Error: ${snap.error}',
                        style: const TextStyle(color: AppTheme.textSecondary),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }

                final proposals = snap.data?.docs
                        .map(MannequinOutfitProposal.fromDoc)
                        .toList() ??
                    [];

                if (proposals.isEmpty) {
                  return const MmEmptyState(
                    icon: Icons.inbox_outlined,
                    headline: 'No Pending Proposals',
                    body: 'All clear. New outfit proposals will appear here.',
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(DesignTokens.spaceMd),
                  itemCount: proposals.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(height: DesignTokens.spaceMd),
                  itemBuilder: (_, i) => _ProposalCard(
                    proposal: proposals[i],
                    storeId: storeId,
                  ),
                );
              },
            ),
    );
  }
}

// ---------------------------------------------------------------------------
// Proposal card
// ---------------------------------------------------------------------------

class _ProposalCard extends ConsumerWidget {
  const _ProposalCard({required this.proposal, required this.storeId});

  final MannequinOutfitProposal proposal;
  final String storeId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final slotChanges = proposal.decodedSlotChanges;
    final dateStr =
        DateFormat('MMM d, yyyy').format(proposal.proposedAt.toLocal());

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(DesignTokens.spaceMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        proposal.proposedByName,
                        style: const TextStyle(
                          fontWeight: DesignTokens.weightBold,
                          fontSize: DesignTokens.typeMd,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        dateStr,
                        style: const TextStyle(
                          fontSize: DesignTokens.typeSm,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                _StatusChip(status: proposal.status),
              ],
            ),

            const SizedBox(height: DesignTokens.spaceSm),

            // Mannequin ID (truncated)
            Row(
              children: [
                const Icon(Icons.accessibility_new_outlined,
                    size: DesignTokens.iconSm, color: AppTheme.textHint),
                const SizedBox(width: DesignTokens.spaceXs),
                Expanded(
                  child: Text(
                    'Mannequin: ${proposal.mannequinId.length > 12 ? proposal.mannequinId.substring(0, 12) : proposal.mannequinId}…',
                    style: const TextStyle(
                      fontSize: DesignTokens.typeSm,
                      color: AppTheme.textSecondary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),

            // Slot count
            Padding(
              padding: const EdgeInsets.only(top: DesignTokens.spaceXs),
              child: Text(
                '${slotChanges.length} slot change${slotChanges.length == 1 ? '' : 's'}',
                style: const TextStyle(
                  fontSize: DesignTokens.typeXs,
                  fontWeight: DesignTokens.weightBold,
                  letterSpacing: DesignTokens.letterSpacingEyebrow,
                  color: AppTheme.textSecondary,
                ),
              ),
            ),

            // Notes
            if (proposal.notes != null && proposal.notes!.isNotEmpty) ...[
              const SizedBox(height: DesignTokens.spaceXs),
              Text(
                proposal.notes!,
                style: const TextStyle(
                  fontSize: DesignTokens.typeSm,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],

            const SizedBox(height: DesignTokens.spaceMd),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: MmButton(
                    label: 'APPROVE',
                    onPressed: () => _review(context, ref, 'approved'),
                  ),
                ),
                const SizedBox(width: DesignTokens.spaceSm),
                Expanded(
                  child: MmButton.outlined(
                    label: 'REJECT',
                    onPressed: () => _review(context, ref, 'rejected'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _review(
      BuildContext context, WidgetRef ref, String newStatus) async {
    final user = ref.read(authStateProvider).value;
    final reviewerUid = user?.uid ?? '';
    final now = Timestamp.fromDate(DateTime.now());

    try {
      if (newStatus == 'approved') {
        await _approveAndApplySlots(reviewerUid, now);
      } else {
        // Reject — just update status.
        await FirestoreRefs.mannequinProposals(storeId).doc(proposal.id).update({
          'status': 'rejected',
          'reviewedByUid': reviewerUid,
          'reviewedAt': now,
        });
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<void> _approveAndApplySlots(
      String reviewerUid, Timestamp now) async {
    final batch = FirebaseFirestore.instance.batch();

    // Mark proposal approved.
    batch.update(
        FirestoreRefs.mannequinProposals(storeId).doc(proposal.id), {
      'status': 'approved',
      'reviewedByUid': reviewerUid,
      'reviewedAt': now,
    });

    // Delete old outfit slots for the mannequin.
    final oldDocs = await FirestoreRefs.mannequinOutfitSlots(
            storeId, proposal.mannequinId)
        .get();
    for (final doc in oldDocs.docs) {
      batch.delete(doc.reference);
    }

    // Write new slots from proposal.
    for (final change in proposal.decodedSlotChanges) {
      final bodySlot = change['bodySlot'] as String;
      final productId = change['productId'] as String?;
      if (productId == null) continue;

      final ref = FirestoreRefs.mannequinOutfitSlots(
              storeId, proposal.mannequinId)
          .doc();
      batch.set(
        ref,
        MannequinOutfitSlot(
          id: ref.id,
          mannequinId: proposal.mannequinId,
          bodySlot: bodySlot,
          productId: productId,
          updatedAt: DateTime.now(),
        ).toFirestore(),
      );
    }

    await batch.commit();
  }
}

// ---------------------------------------------------------------------------
// Status chip
// ---------------------------------------------------------------------------

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});
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
        bg = const Color(0xFFB07D1A); // amber-ish, no hardcoded Colors.amber
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
          color: AppTheme.cardSurface,
          fontSize: DesignTokens.typeXs,
          fontWeight: DesignTokens.weightBold,
          letterSpacing: DesignTokens.letterSpacingEyebrow,
        ),
      ),
    );
  }
}

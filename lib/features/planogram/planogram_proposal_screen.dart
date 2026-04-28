import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../core/models/planogram_proposal.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/providers/store_provider.dart';
import '../../core/services/firestore_refs.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/design_tokens.dart';
import 'planogram_provider.dart';
import 'planogram_slot.dart';

/// Staff-facing screen to submit a proposed planogram change for review.
/// Captures optional notes and the current in-memory editor slot state.
class PlanogramProposalScreen extends ConsumerStatefulWidget {
  const PlanogramProposalScreen({super.key, required this.planogramId});

  final String planogramId;

  @override
  ConsumerState<PlanogramProposalScreen> createState() =>
      _PlanogramProposalScreenState();
}

class _PlanogramProposalScreenState
    extends ConsumerState<PlanogramProposalScreen> {
  final _notesCtrl = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _loading = true);
    try {
      final user = ref.read(authStateProvider).value;
      final storeId = ref.read(activeStoreIdProvider).value ?? '';
      final slots = ref.read(planogramEditorProvider(widget.planogramId));
      final notes = _notesCtrl.text.trim();
      final now = DateTime.now();

      final proposal = PlanogramProposal(
        id: const Uuid().v4(),
        planogramId: widget.planogramId,
        storeId: storeId,
        proposedByUid: user?.uid ?? '',
        status: 'pending',
        notes: notes,
        slotChanges: PgSlot.encodeList(slots),
        updatedAt: now,
      );

      await FirestoreRefs.proposals(storeId)
          .doc(proposal.id)
          .set({
        ...proposal.toFirestore(),
        'proposedAt': Timestamp.fromDate(now),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Proposal submitted for review.')),
        );
        Navigator.pop(context);
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('PROPOSE CHANGE')),
      body: Padding(
        padding: const EdgeInsets.all(DesignTokens.spaceLg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Describe your proposed changes. A manager or coordinator will review.',
              style: TextStyle(color: AppTheme.textSecondary),
            ),
            const SizedBox(height: DesignTokens.spaceMd),
            TextField(
              controller: _notesCtrl,
              decoration: const InputDecoration(
                labelText: 'Notes (optional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 4,
            ),
            const SizedBox(height: DesignTokens.spaceLg),
            ElevatedButton(
              onPressed: _loading ? null : _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _loading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text('SUBMIT PROPOSAL'),
            ),
          ],
        ),
      ),
    );
  }
}

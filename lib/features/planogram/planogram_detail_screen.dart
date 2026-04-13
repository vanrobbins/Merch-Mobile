import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../core/models/planogram_slot.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/design_tokens.dart';
import '../../core/widgets/mm_chip.dart';
import '../../core/widgets/mm_empty_state.dart';
import 'planogram_provider.dart';

class PlanogramDetailScreen extends ConsumerStatefulWidget {
  const PlanogramDetailScreen({super.key, required this.planogramId});

  final String planogramId;

  @override
  ConsumerState<PlanogramDetailScreen> createState() =>
      _PlanogramDetailScreenState();
}

class _PlanogramDetailScreenState
    extends ConsumerState<PlanogramDetailScreen> {
  final _productIdController = TextEditingController();

  @override
  void dispose() {
    _productIdController.dispose();
    super.dispose();
  }

  Color _statusColor(String status) {
    return switch (status) {
      'published' => Colors.green.shade600,
      _ => Colors.grey.shade400,
    };
  }

  Future<void> _showAddSlotDialog() async {
    _productIdController.clear();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(
          'ADD SLOT',
          style: TextStyle(
            fontWeight: DesignTokens.weightBold,
            letterSpacing: DesignTokens.letterSpacingEyebrow,
            fontSize: DesignTokens.typeMd,
          ),
        ),
        content: TextField(
          controller: _productIdController,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'Product ID',
            hintText: 'Enter product ID',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('CANCEL'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accent,
              foregroundColor: Colors.white,
            ),
            child: const Text('ADD'),
          ),
        ],
      ),
    );

    if (confirmed == true && _productIdController.text.isNotEmpty) {
      final state = ref.read(planogramNotifierProvider);
      final planogram =
          state.planograms.firstWhere((p) => p.id == widget.planogramId);
      final slot = PlanogramSlot(
        id: const Uuid().v4(),
        productId: _productIdController.text.trim(),
        sequence: planogram.slots.length + 1,
        facings: 1,
      );
      await ref
          .read(planogramNotifierProvider.notifier)
          .addSlot(widget.planogramId, slot);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(planogramNotifierProvider);
    final userAsync = ref.watch(currentUserProvider);
    final isCoordinator = userAsync.valueOrNull?.role == 'coordinator';

    // Find planogram — might not be loaded yet
    final planogramOrNull = state.planograms
        .cast<dynamic>()
        .firstWhere((p) => p.id == widget.planogramId, orElse: () => null);

    if (state.isLoading && planogramOrNull == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('PLANOGRAM')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (planogramOrNull == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('PLANOGRAM')),
        body: const MmEmptyState(
          icon: Icons.error_outline,
          headline: 'Not Found',
          body: 'This planogram could not be found.',
        ),
      );
    }

    final planogram = planogramOrNull;

    return Scaffold(
      appBar: AppBar(
        title: Text(planogram.title.toUpperCase()),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header info
          Padding(
            padding: const EdgeInsets.all(DesignTokens.spaceMd),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _InfoRow(label: 'FIXTURE', value: planogram.fixtureId),
                          const SizedBox(height: DesignTokens.spaceXs),
                          _InfoRow(label: 'SEASON', value: planogram.season),
                        ],
                      ),
                    ),
                    MmChip(
                      label: planogram.status,
                      color: _statusColor(planogram.status),
                    ),
                  ],
                ),
                // Coordinator publish/retract buttons
                if (isCoordinator) ...[
                  const SizedBox(height: DesignTokens.spaceMd),
                  Row(
                    children: [
                      if (planogram.status == 'draft')
                        ElevatedButton(
                          onPressed: () async {
                            final messenger = ScaffoldMessenger.of(context);
                            try {
                              await ref
                                  .read(planogramNotifierProvider.notifier)
                                  .publish(widget.planogramId);
                            } catch (e) {
                              if (mounted) {
                                messenger.showSnackBar(
                                  SnackBar(content: Text(e.toString())),
                                );
                              }
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green.shade600,
                            foregroundColor: Colors.white,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(
                                  Radius.circular(DesignTokens.radiusSm)),
                            ),
                          ),
                          child: const Text('PUBLISH'),
                        ),
                      if (planogram.status == 'published')
                        OutlinedButton(
                          onPressed: () async {
                            await ref
                                .read(planogramNotifierProvider.notifier)
                                .retractToDraft(widget.planogramId);
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppTheme.primary,
                            side: const BorderSide(color: AppTheme.primary),
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(
                                  Radius.circular(DesignTokens.radiusSm)),
                            ),
                          ),
                          child: const Text('RETRACT'),
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          const Divider(height: 1),
          // Slots label
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: DesignTokens.spaceMd,
              vertical: DesignTokens.spaceSm,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'SLOTS',
                  style: TextStyle(
                    fontSize: DesignTokens.typeXs,
                    fontWeight: DesignTokens.weightBold,
                    letterSpacing: DesignTokens.letterSpacingEyebrow,
                    color: AppTheme.textSecondary,
                  ),
                ),
                TextButton.icon(
                  onPressed: _showAddSlotDialog,
                  icon: const Icon(Icons.add, size: DesignTokens.iconSm),
                  label: const Text('ADD SLOT'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppTheme.accent,
                  ),
                ),
              ],
            ),
          ),
          // Slots list
          Expanded(
            child: planogram.slots.isEmpty
                ? const MmEmptyState(
                    icon: Icons.view_column_outlined,
                    headline: 'No Slots',
                    body: 'Add product slots to this planogram.',
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: DesignTokens.spaceMd,
                    ),
                    itemCount: planogram.slots.length,
                    itemBuilder: (context, index) {
                      final slot = planogram.slots[index];
                      return _SlotTile(slot: slot);
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          '$label: ',
          style: const TextStyle(
            fontSize: DesignTokens.typeXs,
            fontWeight: DesignTokens.weightBold,
            letterSpacing: DesignTokens.letterSpacingEyebrow,
            color: AppTheme.textSecondary,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: DesignTokens.typeSm,
            fontWeight: DesignTokens.weightMedium,
            color: AppTheme.textPrimary,
          ),
        ),
      ],
    );
  }
}

class _SlotTile extends StatelessWidget {
  const _SlotTile({required this.slot});

  final PlanogramSlot slot;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: DesignTokens.spaceXs),
      child: ListTile(
        leading: CircleAvatar(
          radius: 14,
          backgroundColor: AppTheme.canvasBg,
          child: Text(
            '${slot.sequence}',
            style: const TextStyle(
              fontSize: DesignTokens.typeSm,
              fontWeight: DesignTokens.weightBold,
              color: AppTheme.textPrimary,
            ),
          ),
        ),
        title: Text(
          slot.productId.isNotEmpty ? slot.productId : '—',
          style: const TextStyle(
            fontSize: DesignTokens.typeSm,
            fontFamily: 'monospace',
          ),
        ),
        subtitle: Text(
          '${slot.facings} facing${slot.facings == 1 ? '' : 's'}',
          style: const TextStyle(
            fontSize: DesignTokens.typeXs,
            color: AppTheme.textSecondary,
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/models/planogram.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/design_tokens.dart';
import '../../core/widgets/mm_chip.dart';
import '../../core/widgets/mm_empty_state.dart';
import 'planogram_provider.dart';

class PlanogramListScreen extends ConsumerWidget {
  const PlanogramListScreen({super.key});

  Color _statusColor(String status) {
    return switch (status) {
      'published' => Colors.green.shade600,
      _ => Colors.grey.shade400,
    };
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(planogramNotifierProvider);
    final userAsync = ref.watch(currentUserProvider);
    final isCoordinator = userAsync.valueOrNull?.role == 'coordinator';

    // Group by fixtureId
    final Map<String, List<Planogram>> grouped = {};
    for (final p in state.planograms) {
      grouped.putIfAbsent(p.fixtureId, () => []).add(p);
    }

    return Scaffold(
      appBar: AppBar(title: const Text('PLANOGRAMS')),
      floatingActionButton: isCoordinator
          ? FloatingActionButton.extended(
              onPressed: () => _showCreateDialog(context, ref),
              backgroundColor: AppTheme.accent,
              foregroundColor: Colors.white,
              label: const Text('NEW PLANOGRAM'),
              icon: const Icon(Icons.add),
            )
          : null,
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.planograms.isEmpty
              ? const MmEmptyState(
                  icon: Icons.view_module_outlined,
                  headline: 'No Planograms',
                  body: 'Create your first planogram to get started.',
                )
              : ListView(
                  padding: const EdgeInsets.all(DesignTokens.spaceMd),
                  children: [
                    for (final entry in grouped.entries) ...[
                      // Fixture header
                      Padding(
                        padding: const EdgeInsets.only(
                          top: DesignTokens.spaceMd,
                          bottom: DesignTokens.spaceXs,
                        ),
                        child: Text(
                          'FIXTURE ${entry.key}'.toUpperCase(),
                          style: const TextStyle(
                            fontSize: DesignTokens.typeXs,
                            fontWeight: DesignTokens.weightBold,
                            letterSpacing: DesignTokens.letterSpacingEyebrow,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ),
                      for (final planogram in entry.value)
                        _PlanogramTile(
                          planogram: planogram,
                          statusColor: _statusColor(planogram.status),
                          onTap: () => context.goNamed(
                            AppRoutes.planogramDetail,
                            pathParameters: {'planogramId': planogram.id},
                          ),
                        ),
                    ],
                  ],
                ),
    );
  }

  Future<void> _showCreateDialog(BuildContext context, WidgetRef ref) async {
    final fixtureIdController = TextEditingController();
    final titleController = TextEditingController();
    String season = 'Spring';

    await showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text(
            'NEW PLANOGRAM',
            style: TextStyle(
              fontWeight: DesignTokens.weightBold,
              letterSpacing: DesignTokens.letterSpacingEyebrow,
              fontSize: DesignTokens.typeMd,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: fixtureIdController,
                decoration: const InputDecoration(labelText: 'Fixture ID'),
                autofocus: true,
              ),
              const SizedBox(height: DesignTokens.spaceSm),
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Title'),
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: DesignTokens.spaceMd),
              DropdownButtonFormField<String>(
                // ignore: deprecated_member_use
                value: season,
                decoration: const InputDecoration(labelText: 'Season'),
                items: ['Spring', 'Summer', 'Fall', 'Winter']
                    .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                    .toList(),
                onChanged: (v) => setDialogState(() => season = v ?? season),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('CANCEL'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (fixtureIdController.text.isNotEmpty &&
                    titleController.text.isNotEmpty) {
                  await ref.read(planogramNotifierProvider.notifier).createPlanogram(
                        fixtureIdController.text.trim(),
                        titleController.text.trim(),
                        season,
                      );
                  if (ctx.mounted) Navigator.pop(ctx);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accent,
                foregroundColor: Colors.white,
              ),
              child: const Text('CREATE'),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlanogramTile extends StatelessWidget {
  const _PlanogramTile({
    required this.planogram,
    required this.statusColor,
    required this.onTap,
  });

  final Planogram planogram;
  final Color statusColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: DesignTokens.spaceSm),
      child: ListTile(
        onTap: onTap,
        title: Text(
          planogram.title,
          style: const TextStyle(
            fontWeight: DesignTokens.weightMedium,
            fontSize: DesignTokens.typeMd,
          ),
        ),
        subtitle: Text(
          planogram.season,
          style: const TextStyle(
            fontSize: DesignTokens.typeSm,
            color: AppTheme.textSecondary,
          ),
        ),
        trailing: MmChip(
          label: planogram.status,
          color: statusColor,
        ),
      ),
    );
  }
}

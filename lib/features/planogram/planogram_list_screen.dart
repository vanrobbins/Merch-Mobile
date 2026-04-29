import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../core/models/planogram.dart';
import '../../core/providers/store_provider.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/design_tokens.dart';
import '../../core/widgets/mm_empty_state.dart';
import '../../core/widgets/role_guard.dart';
import 'pg_row.dart';
import 'planogram_provider.dart';

/// List of planograms for the active store. Coordinator/manager can create
/// new planograms; staff see the list read-only.
class PlanogramListScreen extends ConsumerWidget {
  const PlanogramListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final planogramsAsync = ref.watch(planogramListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('PLANOGRAMS')),
      body: planogramsAsync.when(
        data: (planograms) => planograms.isEmpty
            ? const MmEmptyState(
                icon: Icons.grid_view_outlined,
                headline: 'No Planograms',
                body: 'Create a planogram to start arranging products.',
              )
            : ListView.separated(
                padding: const EdgeInsets.all(DesignTokens.spaceMd),
                itemCount: planograms.length,
                separatorBuilder: (_, __) =>
                    const SizedBox(height: DesignTokens.spaceSm),
                itemBuilder: (_, i) =>
                    _PlanogramTile(planogram: planograms[i]),
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
      floatingActionButton: RoleGuard(
        allowedRoles: const ['coordinator', 'manager'],
        child: FloatingActionButton.extended(
          onPressed: () => _createPlanogram(context, ref),
          label: const Text('NEW PLANOGRAM'),
          icon: const Icon(Icons.add),
          backgroundColor: AppTheme.accent,
          foregroundColor: Colors.white,
        ),
      ),
    );
  }

  void _createPlanogram(BuildContext context, WidgetRef ref) {
    final titleCtrl = TextEditingController();
    final seasonCtrl = TextEditingController();
    final rowsCtrl = TextEditingController(text: '2');
    final colsCtrl = TextEditingController(text: '4');
    final linearFtCtrl = TextEditingController(text: '8');
    String selectedType = 'shelf';

    showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          final isWallOrShelf =
              selectedType == 'wall' || selectedType == 'shelf';
          return AlertDialog(
            title: const Text('NEW PLANOGRAM',
                style: TextStyle(
                  fontWeight: DesignTokens.weightBold,
                  letterSpacing: DesignTokens.letterSpacingEyebrow,
                  fontSize: DesignTokens.typeMd,
                )),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    controller: titleCtrl,
                    decoration: const InputDecoration(labelText: 'Title'),
                    autofocus: true,
                    textCapitalization: TextCapitalization.words,
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: seasonCtrl,
                    decoration: const InputDecoration(labelText: 'Season'),
                    textCapitalization: TextCapitalization.words,
                  ),
                  const SizedBox(height: 16),
                  const Text('TYPE',
                      style: TextStyle(
                        fontSize: DesignTokens.typeXs,
                        fontWeight: DesignTokens.weightBold,
                        letterSpacing: DesignTokens.letterSpacingEyebrow,
                        color: AppTheme.textSecondary,
                      )),
                  const SizedBox(height: 6),
                  SegmentedButton<String>(
                    segments: const [
                      ButtonSegment(value: 'wall', label: Text('Wall')),
                      ButtonSegment(value: 'shelf', label: Text('Shelf')),
                      ButtonSegment(value: 'table', label: Text('Table')),
                      ButtonSegment(value: 'rack', label: Text('Rack')),
                    ],
                    selected: {selectedType},
                    onSelectionChanged: (s) =>
                        setDialogState(() => selectedType = s.first),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: rowsCtrl,
                    decoration: const InputDecoration(labelText: 'Rows'),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 8),
                  if (isWallOrShelf)
                    TextField(
                      controller: linearFtCtrl,
                      decoration: const InputDecoration(
                          labelText: 'Linear Ft',
                          hintText: 'e.g. 8'),
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                    )
                  else
                    TextField(
                      controller: colsCtrl,
                      decoration: const InputDecoration(labelText: 'Cols'),
                      keyboardType: TextInputType.number,
                    ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('CANCEL'),
              ),
              ElevatedButton(
                onPressed: () async {
                  final title = titleCtrl.text.trim();
                  if (title.isEmpty) return;

                  final rowCount =
                      int.tryParse(rowsCtrl.text.trim()) ?? 2;
                  final double? linearFt = isWallOrShelf
                      ? double.tryParse(linearFtCtrl.text.trim())
                      : null;
                  final cols = isWallOrShelf
                      ? ((linearFt ?? 8.0) / 2).round().clamp(1, 20)
                      : (int.tryParse(colsCtrl.text.trim()) ?? 4);

                  final storeId =
                      ref.read(activeStoreIdProvider).value ?? '';
                  final planogram = Planogram(
                    id: const Uuid().v4(),
                    title: title,
                    season: seasonCtrl.text.trim(),
                    planogramType: selectedType,
                    rows: rowCount,
                    cols: cols,
                    linearFt: linearFt,
                    rowsJson: PgRow.encodeList(
                        PgRow.defaults(rowCount, selectedType)),
                    slotsJson: '',
                    updatedAt: DateTime.now(),
                  );
                  await upsertPlanogram(storeId, planogram);
                  if (ctx.mounted) Navigator.pop(ctx);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.accent,
                  foregroundColor: Colors.white,
                ),
                child: const Text('CREATE'),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _PlanogramTile extends StatelessWidget {
  const _PlanogramTile({required this.planogram});
  final Planogram planogram;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(
          planogram.title,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          '${planogram.season} · ${planogram.status.toUpperCase()}',
          style: const TextStyle(fontSize: DesignTokens.typeXs),
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => context.goNamed(
          AppRoutes.planogramDetail,
          pathParameters: {'planogramId': planogram.id},
        ),
      ),
    );
  }
}

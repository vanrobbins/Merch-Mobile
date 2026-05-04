import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../core/models/planogram.dart';
import '../../core/providers/store_provider.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/design_tokens.dart';
import '../../core/widgets/mm_button.dart';
import '../../core/widgets/mm_dialog.dart';
import '../../core/widgets/mm_empty_state.dart';
import '../../core/widgets/mm_eyebrow.dart';
import '../../core/widgets/mm_list_tile.dart';
import '../../core/widgets/mm_text_field.dart';
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
      body: planogramsAsync.when(
        data: (planograms) => CustomScrollView(
          slivers: [
            const SliverAppBar(
              expandedHeight: 88,
              pinned: true,
              backgroundColor: AppTheme.primary,
              flexibleSpace: FlexibleSpaceBar(
                titlePadding: EdgeInsets.fromLTRB(16, 0, 16, 12),
                title: Text(
                  'PLANOGRAMS',
                  style: TextStyle(
                    color: AppTheme.canvasBg,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                collapseMode: CollapseMode.pin,
              ),
            ),
            if (planograms.isEmpty)
              const SliverFillRemaining(
                child: MmEmptyState(
                  icon: Icons.grid_view_outlined,
                  headline: 'No Planograms',
                  body: 'Create a planogram to start arranging products.',
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.all(DesignTokens.spaceMd),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (_, i) => Padding(
                      padding: const EdgeInsets.only(
                          bottom: DesignTokens.spaceSm),
                      child: MmListSection(
                        children: [
                          MmListTile(
                            title: planograms[i].title,
                            subtitle:
                                '${planograms[i].season} · ${planograms[i].status.toUpperCase()}',
                            onTap: () => context.goNamed(
                              AppRoutes.planogramDetail,
                              pathParameters: {
                                'planogramId': planograms[i].id
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    childCount: planograms.length,
                  ),
                ),
              ),
          ],
        ),
        loading: () => const CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 88,
              pinned: true,
              backgroundColor: AppTheme.primary,
              flexibleSpace: FlexibleSpaceBar(
                titlePadding: EdgeInsets.fromLTRB(16, 0, 16, 12),
                title: Text(
                  'PLANOGRAMS',
                  style: TextStyle(
                    color: AppTheme.canvasBg,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                collapseMode: CollapseMode.pin,
              ),
            ),
            SliverFillRemaining(
              child: Center(child: CircularProgressIndicator(color: AppTheme.accent)),
            ),
          ],
        ),
        error: (e, _) => CustomScrollView(
          slivers: [
            const SliverAppBar(
              expandedHeight: 88,
              pinned: true,
              backgroundColor: AppTheme.primary,
              flexibleSpace: FlexibleSpaceBar(
                titlePadding: EdgeInsets.fromLTRB(16, 0, 16, 12),
                title: Text(
                  'PLANOGRAMS',
                  style: TextStyle(
                    color: AppTheme.canvasBg,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                collapseMode: CollapseMode.pin,
              ),
            ),
            SliverFillRemaining(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(DesignTokens.spaceLg),
                  child: Text(
                    'Error: $e',
                    style:
                        const TextStyle(color: AppTheme.textSecondary),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: RoleGuard(
        allowedRoles: const ['coordinator', 'manager'],
        child: FloatingActionButton.extended(
          onPressed: () => _createPlanogram(context, ref),
          label: const Text('NEW PLANOGRAM'),
          icon: const Icon(Icons.add),
          backgroundColor: AppTheme.accent,
          foregroundColor: AppTheme.canvasBg,
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

    MmDialog.show<void>(
      context,
      title: 'NEW PLANOGRAM',
      content: StatefulBuilder(
        builder: (ctx, setDialogState) {
          final isWallOrShelf =
              selectedType == 'wall' || selectedType == 'shelf';
          return SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                MmTextField(
                  label: 'Title',
                  controller: titleCtrl,
                  autofocus: true,
                  maxLength: 80,
                ),
                const SizedBox(height: 8),
                MmTextField(
                  label: 'Season',
                  controller: seasonCtrl,
                ),
                const SizedBox(height: 16),
                const MmEyebrow('TYPE'),
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
                MmTextField(
                  label: 'Rows',
                  controller: rowsCtrl,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 8),
                if (isWallOrShelf)
                  MmTextField(
                    label: 'Linear Ft',
                    hint: 'e.g. 8',
                    controller: linearFtCtrl,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                  )
                else
                  MmTextField(
                    label: 'Cols',
                    controller: colsCtrl,
                    keyboardType: TextInputType.number,
                  ),
              ],
            ),
          );
        },
      ),
      actions: [
        MmButton.outlined(
          label: 'CANCEL',
          onPressed: () => Navigator.pop(context),
        ),
        MmButton(
          label: 'CREATE',
          onPressed: () async {
            final title = titleCtrl.text.trim();
            if (title.isEmpty) return;

            final isWallOrShelf =
                selectedType == 'wall' || selectedType == 'shelf';
            final rowCount = int.tryParse(rowsCtrl.text.trim()) ?? 2;
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
              rowsJson:
                  PgRow.encodeList(PgRow.defaults(rowCount, selectedType)),
              slotsJson: '',
              updatedAt: DateTime.now(),
            );
            await upsertPlanogram(storeId, planogram);
            if (context.mounted) Navigator.pop(context);
          },
        ),
      ],
    );
  }
}

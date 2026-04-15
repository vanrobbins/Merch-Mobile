import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../core/database/app_database.dart';
import '../../core/providers/database_provider.dart';
import '../../core/providers/store_provider.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/design_tokens.dart';
import '../../core/widgets/role_guard.dart';
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
            ? const Center(
                child: Text(
                  'No planograms yet.',
                  style: TextStyle(color: AppTheme.textSecondary),
                ),
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
        error: (e, _) => Center(child: Text('Error: $e')),
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
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('New Planogram'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleCtrl,
              decoration: const InputDecoration(labelText: 'Title'),
              autofocus: true,
              textCapitalization: TextCapitalization.words,
            ),
            TextField(
              controller: seasonCtrl,
              decoration: const InputDecoration(labelText: 'Season'),
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
              final title = titleCtrl.text.trim();
              if (title.isEmpty) return;
              final db = ref.read(appDatabaseProvider);
              final storeId =
                  ref.read(activeStoreIdProvider).value ?? '';
              await db.planogramsDao.upsert(
                PlanogramsTableCompanion.insert(
                  id: const Uuid().v4(),
                  fixtureId: '',
                  title: title,
                  season: seasonCtrl.text.trim(),
                  updatedAt: DateTime.now(),
                  storeId: Value(storeId),
                ),
              );
              if (ctx.mounted) Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accent,
              foregroundColor: Colors.white,
            ),
            child: const Text('CREATE'),
          ),
        ],
      ),
    );
  }
}

class _PlanogramTile extends StatelessWidget {
  const _PlanogramTile({required this.planogram});
  final PlanogramsTableData planogram;

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

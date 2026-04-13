import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../core/database/app_database.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/providers/database_provider.dart';
import '../../core/providers/store_provider.dart';
import '../../core/theme/app_theme.dart';

class GroupManagementScreen extends ConsumerWidget {
  const GroupManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.watch(appDatabaseProvider);
    final storeId = ref.watch(activeStoreIdProvider).value ?? '';
    final groups = ref.watch(
      StreamProvider((ref) => db.storeGroupsDao.watchGroupsForStore(storeId)),
    );

    return Scaffold(
      appBar: AppBar(title: const Text('STORE GROUPS')),
      body: groups.when(
        data: (list) => list.isEmpty
            ? const Center(child: Text('No groups yet.'))
            : ListView(
                children: list
                    .map((g) => ListTile(
                          title: Text(g.name),
                          subtitle: g.description != null ? Text(g.description!) : null,
                        ))
                    .toList(),
              ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateDialog(context, ref, storeId),
        label: const Text('CREATE GROUP'),
        icon: const Icon(Icons.add),
        backgroundColor: AppTheme.accent,
      ),
    );
  }

  void _showCreateDialog(BuildContext context, WidgetRef ref, String storeId) {
    final nameCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Create Group'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Group name')),
            TextField(controller: descCtrl, decoration: const InputDecoration(labelText: 'Description (optional)')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('CANCEL')),
          ElevatedButton(
            onPressed: () async {
              final db = ref.read(appDatabaseProvider);
              final user = ref.read(authStateProvider).value;
              final now = DateTime.now().millisecondsSinceEpoch;
              final groupId = const Uuid().v4();
              await db.storeGroupsDao.upsertGroup(StoreGroupsTableCompanion.insert(
                id: groupId,
                name: nameCtrl.text.trim(),
                description: Value(descCtrl.text.trim().isEmpty ? null : descCtrl.text.trim()),
                createdByUid: user?.uid ?? '',
                createdAt: now,
              ));
              await db.storeGroupsDao.addMember(StoreGroupMembersTableCompanion.insert(
                id: const Uuid().v4(),
                groupId: groupId,
                storeId: storeId,
                addedAt: now,
                addedByUid: user?.uid ?? '',
              ));
              if (ctx.mounted) Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.accent),
            child: const Text('CREATE'),
          ),
        ],
      ),
    );
  }
}

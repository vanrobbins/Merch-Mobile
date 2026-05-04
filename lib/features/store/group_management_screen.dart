import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../core/models/store_group.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/providers/store_provider.dart';
import '../../core/services/firestore_refs.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/mm_button.dart';
import '../../core/widgets/mm_dialog.dart';
import '../../core/widgets/mm_text_field.dart';

class GroupManagementScreen extends ConsumerWidget {
  const GroupManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final storeId = ref.watch(activeStoreIdProvider).value ?? '';
    final groups = ref.watch(
      StreamProvider<List<StoreGroup>>((ref) {
        if (storeId.isEmpty) return Stream.value([]);
        return FirestoreRefs.groups(storeId)
            .snapshots()
            .map((s) => s.docs.map(StoreGroupFirestore.fromDoc).toList());
      }),
    );

    return Scaffold(
      appBar: AppBar(title: const Text('STORE GROUPS')),
      body: groups.when(
        data: (list) => list.isEmpty
            ? const Center(
                child: Text(
                  'No groups yet.',
                  style: TextStyle(color: AppTheme.textSecondary),
                ),
              )
            : ListView(
                children: list
                    .map((g) => ListTile(
                          title: Text(g.name),
                          subtitle: g.description != null
                              ? Text(g.description!)
                              : null,
                        ))
                    .toList(),
              ),
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppTheme.accent),
        ),
        error: (e, _) => Center(
          child: Text(
            'Error: $e',
            style: const TextStyle(color: AppTheme.textSecondary),
          ),
        ),
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
    MmDialog.show<void>(
      context,
      title: 'Create Group',
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          MmTextField(
            label: 'Group name',
            controller: nameCtrl,
          ),
          const SizedBox(height: 12),
          MmTextField(
            label: 'Description (optional)',
            controller: descCtrl,
          ),
        ],
      ),
      actions: [
        MmButton.text(
          label: 'CANCEL',
          onPressed: () => Navigator.pop(context),
        ),
        MmButton(
          label: 'CREATE',
          onPressed: () async {
            final user = ref.read(authStateProvider).value;
            final groupId = const Uuid().v4();
            final group = StoreGroup(
              id: groupId,
              name: nameCtrl.text.trim(),
              description: descCtrl.text.trim().isEmpty
                  ? null
                  : descCtrl.text.trim(),
              createdByUid: user?.uid ?? '',
              createdAt: DateTime.now().millisecondsSinceEpoch,
            );
            await FirestoreRefs.groups(storeId)
                .doc(groupId)
                .set(group.toFirestore());
            if (context.mounted) Navigator.pop(context);
          },
        ),
      ],
    );
  }
}

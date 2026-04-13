import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/database/app_database.dart';
import '../../core/providers/database_provider.dart';
import '../../core/providers/store_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/design_tokens.dart';

class MembersScreen extends ConsumerWidget {
  const MembersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final storeId = ref.watch(activeStoreIdProvider).value;
    if (storeId == null) return const SizedBox();
    final db = ref.watch(appDatabaseProvider);
    final pending = ref.watch(
      StreamProvider((ref) => db.storeMembershipsDao.watchPending(storeId)),
    );
    final members = ref.watch(
      StreamProvider((ref) => db.storeMembershipsDao.watchByStore(storeId)),
    );
    final myRole = ref.watch(currentMembershipProvider).value?.role ?? 'staff';

    return Scaffold(
      appBar: AppBar(title: const Text('MEMBERS')),
      body: ListView(
        children: [
          // Pending requests — visible to coordinator and manager
          if (myRole == 'coordinator' || myRole == 'manager') ...[
            pending.when(
              data: (list) {
                final pendingList = list;
                if (pendingList.isEmpty) return const SizedBox();
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                      child: Row(children: [
                        const Text('PENDING REQUESTS',
                            style: TextStyle(
                                fontSize: DesignTokens.typeXs,
                                fontWeight: DesignTokens.weightBold,
                                letterSpacing: DesignTokens.letterSpacingEyebrow,
                                color: AppTheme.textSecondary)),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppTheme.accent,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text('${pendingList.length}',
                              style: const TextStyle(color: Colors.white, fontSize: 11)),
                        ),
                      ]),
                    ),
                    ...pendingList.map((m) => _PendingMemberTile(
                          membership: m,
                          myRole: myRole,
                        )),
                  ],
                );
              },
              loading: () => const SizedBox(),
              error: (_, __) => const SizedBox(),
            ),
          ],
          // Active members
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text('ACTIVE MEMBERS',
                style: TextStyle(
                    fontSize: DesignTokens.typeXs,
                    fontWeight: DesignTokens.weightBold,
                    letterSpacing: DesignTokens.letterSpacingEyebrow,
                    color: AppTheme.textSecondary)),
          ),
          members.when(
            data: (list) {
              final active = list.where((m) => m.status == 'active').toList();
              return Column(
                children: active.map((m) => _ActiveMemberTile(
                      membership: m,
                      myRole: myRole,
                    )).toList(),
              );
            },
            loading: () => const CircularProgressIndicator(),
            error: (e, _) => Text('Error: $e'),
          ),
        ],
      ),
    );
  }
}

class _PendingMemberTile extends ConsumerWidget {
  const _PendingMemberTile({required this.membership, required this.myRole});
  final StoreMembershipsTableData membership;
  final String myRole;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      title: Text(membership.displayName),
      subtitle: Text('Requested ${_timeAgo(membership.joinedAt)}'),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ElevatedButton(
            onPressed: () => _showApproveDialog(context, ref),
            style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: Colors.white),
            child: const Text('APPROVE'),
          ),
          const SizedBox(width: 8),
          OutlinedButton(
            onPressed: () => _deny(ref),
            child: const Text('DENY'),
          ),
        ],
      ),
    );
  }

  void _deny(WidgetRef ref) {
    final db = ref.read(appDatabaseProvider);
    db.storeMembershipsDao.upsert(membership.toCompanion(true).copyWith(
          status: const Value('rejected'),
        ));
  }

  void _showApproveDialog(BuildContext context, WidgetRef ref) {
    // Manager can only assign 'staff'; coordinator can assign 'staff' or 'manager'
    final roles = myRole == 'coordinator' ? ['staff', 'manager'] : ['staff'];
    String selectedRole = 'staff';

    showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: Text('Approve ${membership.displayName}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: roles
                .map((r) => RadioListTile<String>(
                      title: Text(r.toUpperCase()),
                      value: r,
                      groupValue: selectedRole,
                      onChanged: (v) => setState(() => selectedRole = v!),
                    ))
                .toList(),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('CANCEL')),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                _approve(ref, selectedRole);
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.accent),
              child: const Text('CONFIRM'),
            ),
          ],
        ),
      ),
    );
  }

  void _approve(WidgetRef ref, String role) {
    final db = ref.read(appDatabaseProvider);
    db.storeMembershipsDao.upsert(membership.toCompanion(true).copyWith(
          status: const Value('active'),
          role: Value(role),
        ));
  }

  String _timeAgo(int ms) {
    final diff = DateTime.now()
        .difference(DateTime.fromMillisecondsSinceEpoch(ms));
    if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
    if (diff.inHours < 24) return '${diff.inHours} hr ago';
    return '${diff.inDays}d ago';
  }
}

class _ActiveMemberTile extends ConsumerWidget {
  const _ActiveMemberTile({required this.membership, required this.myRole});
  final StoreMembershipsTableData membership;
  final String myRole;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      title: Text(membership.displayName),
      subtitle: Text(membership.role.toUpperCase(),
          style: const TextStyle(fontSize: DesignTokens.typeXs)),
      trailing: myRole == 'coordinator'
          ? TextButton(
              onPressed: () => _showRoleDialog(context, ref),
              child: const Text('EDIT ROLE',
                  style: TextStyle(color: AppTheme.accent, fontSize: DesignTokens.typeXs)),
            )
          : null,
    );
  }

  void _showRoleDialog(BuildContext context, WidgetRef ref) {
    String selectedRole = membership.role;
    showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: Text('Edit role for ${membership.displayName}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: ['staff', 'manager', 'coordinator']
                .map((r) => RadioListTile<String>(
                      title: Text(r.toUpperCase()),
                      value: r,
                      groupValue: selectedRole,
                      onChanged: (v) => setState(() => selectedRole = v!),
                    ))
                .toList(),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('CANCEL')),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                final db = ref.read(appDatabaseProvider);
                db.storeMembershipsDao.upsert(
                    membership.toCompanion(true).copyWith(role: Value(selectedRole)));
              },
              child: const Text('SAVE'),
            ),
          ],
        ),
      ),
    );
  }
}

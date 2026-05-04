import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/models/store_membership.dart';
import '../../core/providers/store_provider.dart';
import '../../core/services/firestore_refs.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/design_tokens.dart';
import '../../core/widgets/mm_button.dart';
import '../../core/widgets/mm_dialog.dart';
import '../../core/widgets/mm_empty_state.dart';
import '../../core/widgets/mm_eyebrow.dart';

final _pendingMembersProvider =
    StreamProvider.autoDispose<List<StoreMembership>>((ref) {
  final storeId = ref.watch(activeStoreIdProvider).value;
  if (storeId == null) return Stream.value([]);
  return FirestoreRefs.memberships(storeId)
      .where('status', isEqualTo: 'pending')
      .snapshots()
      .map((s) => s.docs
          .map((d) => StoreMembershipFirestore.fromDoc(d, storeId))
          .toList());
});

final _activeMembersProvider =
    StreamProvider.autoDispose<List<StoreMembership>>((ref) {
  final storeId = ref.watch(activeStoreIdProvider).value;
  if (storeId == null) return Stream.value([]);
  return FirestoreRefs.memberships(storeId)
      .where('status', isEqualTo: 'active')
      .snapshots()
      .map((s) => s.docs
          .map((d) => StoreMembershipFirestore.fromDoc(d, storeId))
          .toList());
});

class MembersScreen extends ConsumerWidget {
  const MembersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pending = ref.watch(_pendingMembersProvider);
    final members = ref.watch(_activeMembersProvider);
    final myRole = ref.watch(currentMembershipProvider).value?.role ?? 'staff';
    final store = ref.watch(activeStoreProvider).value;

    return Scaffold(
      appBar: AppBar(title: const Text('MEMBERS')),
      body: ListView(
        children: [
          // Invite code card — visible to coordinator and manager
          if ((myRole == 'coordinator' || myRole == 'manager') &&
              store != null) ...[
            _InviteCodeCard(inviteCode: store.inviteCode),
          ],

          // Pending requests — visible to coordinator and manager
          if (myRole == 'coordinator' || myRole == 'manager') ...[
            pending.when(
              data: (pendingList) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(
                        DesignTokens.spaceMd,
                        DesignTokens.spaceMd,
                        DesignTokens.spaceMd,
                        DesignTokens.spaceSm,
                      ),
                      child: Row(
                        children: [
                          const MmEyebrow('PENDING REQUESTS'),
                          if (pendingList.isNotEmpty) ...[
                            const SizedBox(width: DesignTokens.spaceSm),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: DesignTokens.spaceSm,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppTheme.accent,
                                borderRadius: BorderRadius.circular(
                                    AppTheme.borderRadius),
                              ),
                              child: Text(
                                '${pendingList.length}',
                                style: const TextStyle(
                                  color: AppTheme.canvasBg,
                                  fontSize: 11,
                                  fontWeight: DesignTokens.weightBold,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    if (pendingList.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: DesignTokens.spaceMd,
                          vertical: DesignTokens.spaceSm,
                        ),
                        child: Text(
                          'No pending requests.',
                          style: TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: DesignTokens.typeSm,
                          ),
                        ),
                      )
                    else
                      for (var i = 0; i < pendingList.length; i++) ...[
                        _PendingMemberTile(
                          membership: pendingList[i],
                          myRole: myRole,
                        ),
                        if (i < pendingList.length - 1)
                          const Divider(
                              height: 1, indent: DesignTokens.spaceMd),
                      ],
                  ],
                );
              },
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(DesignTokens.spaceLg),
                  child: CircularProgressIndicator(color: AppTheme.accent),
                ),
              ),
              error: (_, __) => const MmEmptyState(
                icon: Icons.error_outline,
                headline: 'Something went wrong',
                body: 'Check your connection and try again.',
              ),
            ),
          ],
          // Active members
          const Padding(
            padding: EdgeInsets.fromLTRB(
              DesignTokens.spaceMd,
              DesignTokens.spaceMd,
              DesignTokens.spaceMd,
              DesignTokens.spaceSm,
            ),
            child: MmEyebrow('ACTIVE MEMBERS'),
          ),
          members.when(
            data: (list) {
              if (list.isEmpty) {
                return const MmEmptyState(
                  icon: Icons.people_outline,
                  headline: 'No Active Members',
                  body: 'Approved members will appear here.',
                );
              }
              return Column(
                children: [
                  for (var i = 0; i < list.length; i++) ...[
                    _ActiveMemberTile(
                      membership: list[i],
                      myRole: myRole,
                    ),
                    if (i < list.length - 1)
                      const Divider(
                          height: 1, indent: DesignTokens.spaceMd),
                  ],
                ],
              );
            },
            loading: () => const Padding(
              padding: EdgeInsets.all(DesignTokens.spaceLg),
              child: Center(
                child: CircularProgressIndicator(color: AppTheme.accent),
              ),
            ),
            error: (e, _) => const MmEmptyState(
              icon: Icons.error_outline,
              headline: 'Something went wrong',
              body: 'Check your connection and try again.',
            ),
          ),
        ],
      ),
    );
  }
}

class _InviteCodeCard extends StatelessWidget {
  const _InviteCodeCard({required this.inviteCode});
  final String inviteCode;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(
        DesignTokens.spaceMd,
        DesignTokens.spaceMd,
        DesignTokens.spaceMd,
        0,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: DesignTokens.spaceMd,
        vertical: DesignTokens.spaceMd,
      ),
      decoration: BoxDecoration(
        color: AppTheme.primary,
        borderRadius: BorderRadius.circular(AppTheme.borderRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'INVITE CODE',
            style: TextStyle(
              color: AppTheme.canvasBg.withValues(alpha: 0.70),
              fontSize: DesignTokens.typeXs,
              fontWeight: DesignTokens.weightBold,
              letterSpacing: DesignTokens.letterSpacingEyebrow,
            ),
          ),
          const SizedBox(height: DesignTokens.spaceXs),
          Row(
            children: [
              Text(
                inviteCode,
                style: const TextStyle(
                  color: AppTheme.canvasBg,
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 8,
                ),
              ),
              const Spacer(),
              IconButton(
                icon: Icon(Icons.copy,
                    color: AppTheme.canvasBg.withValues(alpha: 0.70)),
                tooltip: 'Copy code',
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: inviteCode));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Invite code copied'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
              ),
            ],
          ),
          Text(
            'Share this code with staff who want to join.',
            style: TextStyle(
              color: AppTheme.canvasBg.withValues(alpha: 0.60),
              fontSize: DesignTokens.typeSm,
            ),
          ),
        ],
      ),
    );
  }
}

class _PendingMemberTile extends ConsumerWidget {
  const _PendingMemberTile({required this.membership, required this.myRole});
  final StoreMembership membership;
  final String myRole;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      title: Text(
        membership.displayName,
        style: const TextStyle(fontWeight: DesignTokens.weightMedium),
      ),
      subtitle: Text('Requested ${_timeAgo(membership.joinedAt)}'),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 84,
            child: MmButton(
              label: 'APPROVE',
              onPressed: () => _showApproveDialog(context, ref),
            ),
          ),
          const SizedBox(width: DesignTokens.spaceSm),
          SizedBox(
            width: 72,
            child: MmButton.outlined(
              label: 'DENY',
              onPressed: () => _deny(ref),
            ),
          ),
        ],
      ),
    );
  }

  void _deny(WidgetRef ref) {
    FirestoreRefs.memberships(membership.storeId)
        .doc(membership.uid)
        .update({'status': 'rejected'});
  }

  void _showApproveDialog(BuildContext context, WidgetRef ref) {
    final roles = myRole == 'coordinator' ? ['staff', 'manager'] : ['staff'];
    String selectedRole = 'staff';

    MmDialog.show<void>(
      context,
      title: 'Approve ${membership.displayName}',
      content: StatefulBuilder(
        builder: (ctx, setState) => Column(
          mainAxisSize: MainAxisSize.min,
          children: roles
              .map((r) => RadioListTile<String>(
                    title: Text(r.toUpperCase()),
                    value: r,
                    // ignore: deprecated_member_use
                    groupValue: selectedRole,
                    activeColor: AppTheme.accent,
                    // ignore: deprecated_member_use
                    onChanged: (v) {
                      if (v != null) setState(() => selectedRole = v);
                    },
                  ))
              .toList(),
        ),
      ),
      actions: [
        MmButton.text(
          label: 'CANCEL',
          onPressed: () => Navigator.pop(context),
        ),
        MmButton(
          label: 'CONFIRM',
          onPressed: () {
            Navigator.pop(context);
            _approve(ref, selectedRole);
          },
        ),
      ],
    );
  }

  void _approve(WidgetRef ref, String role) {
    FirestoreRefs.memberships(membership.storeId)
        .doc(membership.uid)
        .update({'status': 'active', 'role': role});
    // Add store to the approved user's userStores so myStores picks it up.
    FirestoreRefs.userStores(membership.uid).set(
      {'activeStoreIds': FieldValue.arrayUnion([membership.storeId])},
      SetOptions(merge: true),
    );
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
    if (diff.inHours < 24) return '${diff.inHours} hr ago';
    return '${diff.inDays}d ago';
  }
}

class _ActiveMemberTile extends ConsumerWidget {
  const _ActiveMemberTile({required this.membership, required this.myRole});
  final StoreMembership membership;
  final String myRole;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      title: Text(membership.displayName),
      subtitle: Text(membership.role.toUpperCase(),
          style: const TextStyle(fontSize: DesignTokens.typeXs)),
      trailing: myRole == 'coordinator'
          ? MmButton.text(
              label: 'EDIT ROLE',
              onPressed: () => _showRoleDialog(context, ref),
            )
          : null,
    );
  }

  void _showRoleDialog(BuildContext context, WidgetRef ref) {
    String selectedRole = membership.role;

    MmDialog.show<void>(
      context,
      title: 'Edit role for ${membership.displayName}',
      content: StatefulBuilder(
        builder: (ctx, setState) => Column(
          mainAxisSize: MainAxisSize.min,
          children: ['staff', 'manager', 'coordinator']
              .map((r) => RadioListTile<String>(
                    title: Text(r.toUpperCase()),
                    value: r,
                    // ignore: deprecated_member_use
                    groupValue: selectedRole,
                    activeColor: AppTheme.accent,
                    // ignore: deprecated_member_use
                    onChanged: (v) {
                      if (v != null) setState(() => selectedRole = v);
                    },
                  ))
              .toList(),
        ),
      ),
      actions: [
        MmButton.text(
          label: 'CANCEL',
          onPressed: () => Navigator.pop(context),
        ),
        MmButton(
          label: 'SAVE',
          onPressed: () {
            Navigator.pop(context);
            FirestoreRefs.memberships(membership.storeId)
                .doc(membership.uid)
                .update({'role': selectedRole});
          },
        ),
      ],
    );
  }
}

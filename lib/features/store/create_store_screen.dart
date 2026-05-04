import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../core/models/store.dart';
import '../../core/models/store_membership.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/providers/store_provider.dart';
import '../../core/router/app_router.dart';
import '../../core/services/firestore_refs.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/design_tokens.dart';
import '../../core/services/seed_service.dart';
import '../../core/utils/invite_code_util.dart';
import '../../core/widgets/mm_button.dart';
import '../../core/widgets/mm_eyebrow.dart';
import '../../core/widgets/mm_text_field.dart';

class CreateStoreScreen extends ConsumerStatefulWidget {
  const CreateStoreScreen({super.key});

  @override
  ConsumerState<CreateStoreScreen> createState() => _CreateStoreScreenState();
}

class _CreateStoreScreenState extends ConsumerState<CreateStoreScreen> {
  final _nameCtrl = TextEditingController();
  bool _loading = false;
  String? _generatedCode;

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _create() async {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) return;
    setState(() => _loading = true);
    try {
      final user = ref.read(authStateProvider).value;
      if (user == null) return;
      final code = generateInviteCode();
      final storeId = const Uuid().v4();
      final now = DateTime.now();

      final store = Store(
        id: storeId,
        name: name,
        inviteCode: code,
        ownerUid: user.uid,
        createdAt: now,
      );
      await FirestoreRefs.store(storeId).set(store.toFirestore());

      final membership = StoreMembership(
        id: user.uid,
        storeId: storeId,
        uid: user.uid,
        role: 'coordinator',
        status: 'active',
        displayName: user.displayName ?? user.email ?? 'Coordinator',
        joinedAt: now,
      );
      await FirestoreRefs.memberships(storeId).doc(user.uid).set(membership.toFirestore());
      await FirestoreRefs.userStores(user.uid).set(
        {'activeStoreIds': FieldValue.arrayUnion([storeId])},
        SetOptions(merge: true),
      );

      await ref.read(activeStoreIdProvider.notifier).setStore(storeId);
      await seedDefaultStoreData(storeId);
      setState(() => _generatedCode = code);
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_generatedCode != null) {
      return _InviteCodeDisplay(code: _generatedCode!);
    }
    return Scaffold(
      appBar: AppBar(title: const Text('CREATE STORE')),
      body: Padding(
        padding: const EdgeInsets.all(DesignTokens.spaceLg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            MmTextField(
              label: 'Store name',
              controller: _nameCtrl,
              maxLength: 80,
            ),
            const SizedBox(height: DesignTokens.spaceLg),
            const Text(
              "You'll become the coordinator. An invite code is auto-generated.",
              style: TextStyle(color: AppTheme.textSecondary, fontSize: DesignTokens.typeSm),
            ),
            const SizedBox(height: DesignTokens.spaceLg),
            MmButton(
              label: 'CREATE STORE',
              isLoading: _loading,
              onPressed: _loading ? null : _create,
            ),
          ],
        ),
      ),
    );
  }
}

class _InviteCodeDisplay extends StatelessWidget {
  const _InviteCodeDisplay({required this.code});
  final String code;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('STORE CREATED')),
      body: Padding(
        padding: const EdgeInsets.all(DesignTokens.spaceLg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Success icon
            Container(
              width: 72,
              height: 72,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppTheme.accent.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle_outline,
                size: 40,
                color: AppTheme.accent,
              ),
            ),
            const SizedBox(height: DesignTokens.spaceLg),
            const Center(child: MmEyebrow('YOUR INVITE CODE')),
            const SizedBox(height: DesignTokens.spaceMd),
            // Warm-neutral code card
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: DesignTokens.spaceMd,
                vertical: DesignTokens.spaceLg,
              ),
              decoration: BoxDecoration(
                color: AppTheme.canvasBg,
                border: Border.all(
                  color: AppTheme.primary.withValues(alpha: 0.12),
                ),
                borderRadius:
                    BorderRadius.circular(AppTheme.borderRadius),
              ),
              child: Text(
                code,
                style: const TextStyle(
                  fontSize: 48,
                  fontWeight: DesignTokens.weightBold,
                  letterSpacing: 12,
                  color: AppTheme.primary,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: DesignTokens.spaceMd),
            const Text(
              'Share this with your team. They enter it on the join screen.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppTheme.textSecondary),
            ),
            const SizedBox(height: DesignTokens.spaceLg),
            MmButton.outlined(
              label: 'COPY CODE',
              icon: Icons.copy,
              onPressed: () => Clipboard.setData(ClipboardData(text: code)),
            ),
            const SizedBox(height: DesignTokens.spaceLg),
            MmButton(
              label: 'GO TO STORE',
              onPressed: () => context.goNamed(AppRoutes.zoneMap),
            ),
          ],
        ),
      ),
    );
  }
}

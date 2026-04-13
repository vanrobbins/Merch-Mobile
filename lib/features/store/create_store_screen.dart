import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../core/database/app_database.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/providers/database_provider.dart';
import '../../core/providers/store_provider.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/design_tokens.dart';
import '../../core/utils/invite_code_util.dart';

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
      final db = ref.read(appDatabaseProvider);
      final code = generateInviteCode();
      final storeId = const Uuid().v4();
      final now = DateTime.now().millisecondsSinceEpoch;

      await db.storesDao.upsert(StoresTableCompanion.insert(
        id: storeId,
        name: name,
        inviteCode: code,
        createdAt: now,
        ownerUid: user.uid,
      ));

      await db.storeMembershipsDao.upsert(StoreMembershipsTableCompanion.insert(
        id: const Uuid().v4(),
        storeId: storeId,
        userUid: user.uid,
        role: 'coordinator',
        displayName: user.displayName ?? user.email ?? 'Coordinator',
        status: 'active',
        joinedAt: now,
      ));

      await ref.read(activeStoreIdProvider.notifier).setStore(storeId);
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
            TextField(
              controller: _nameCtrl,
              decoration: const InputDecoration(labelText: 'Store name'),
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: DesignTokens.spaceLg),
            const Text(
              "You'll become the coordinator. An invite code is auto-generated.",
              style: TextStyle(color: AppTheme.textSecondary, fontSize: DesignTokens.typeSm),
            ),
            const SizedBox(height: DesignTokens.spaceLg),
            ElevatedButton(
              onPressed: _loading ? null : _create,
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.accent),
              child: _loading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('CREATE STORE'),
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
            const Text(
              'YOUR INVITE CODE',
              style: TextStyle(
                fontSize: DesignTokens.typeXs,
                fontWeight: DesignTokens.weightBold,
                letterSpacing: DesignTokens.letterSpacingEyebrow,
                color: AppTheme.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: DesignTokens.spaceMd),
            Text(
              code,
              style: const TextStyle(
                fontSize: 48,
                fontWeight: DesignTokens.weightBold,
                letterSpacing: 12,
                color: AppTheme.primary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: DesignTokens.spaceMd),
            const Text(
              'Share this with your team. They enter it on the join screen.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppTheme.textSecondary),
            ),
            const SizedBox(height: DesignTokens.spaceLg),
            OutlinedButton.icon(
              onPressed: () => Clipboard.setData(ClipboardData(text: code)),
              icon: const Icon(Icons.copy),
              label: const Text('COPY CODE'),
            ),
            const SizedBox(height: DesignTokens.spaceLg),
            ElevatedButton(
              onPressed: () => context.goNamed(AppRoutes.zoneMap),
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.accent),
              child: const Text('GO TO STORE'),
            ),
          ],
        ),
      ),
    );
  }
}

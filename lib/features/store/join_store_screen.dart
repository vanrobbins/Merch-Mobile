import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../core/database/app_database.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/providers/database_provider.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/design_tokens.dart';

class JoinStoreScreen extends ConsumerStatefulWidget {
  const JoinStoreScreen({super.key});

  @override
  ConsumerState<JoinStoreScreen> createState() => _JoinStoreScreenState();
}

class _JoinStoreScreenState extends ConsumerState<JoinStoreScreen> {
  final _codeCtrl = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _codeCtrl.dispose();
    super.dispose();
  }

  Future<void> _requestJoin() async {
    final code = _codeCtrl.text.trim().toUpperCase();
    if (code.length != 6) {
      setState(() => _error = 'Enter a 6-character code.');
      return;
    }
    setState(() { _loading = true; _error = null; });
    try {
      final db = ref.read(appDatabaseProvider);
      final store = await db.storesDao.findByInviteCode(code);
      if (store == null) {
        setState(() => _error = 'Invalid invite code.');
        return;
      }
      final user = ref.read(authStateProvider).value;
      if (user == null) return;

      // Check for existing membership
      final existing = await db.storeMembershipsDao.findActive(store.id, user.uid);
      if (existing != null) {
        // Already a member — just navigate
        if (mounted) context.goNamed(AppRoutes.zoneMap);
        return;
      }

      await db.storeMembershipsDao.upsert(StoreMembershipsTableCompanion.insert(
        id: const Uuid().v4(),
        storeId: store.id,
        userUid: user.uid,
        role: 'staff',
        displayName: user.displayName ?? user.email ?? 'Staff',
        status: 'pending',
        joinedAt: DateTime.now().millisecondsSinceEpoch,
      ));

      if (mounted) context.goNamed(AppRoutes.pendingApproval);
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('JOIN STORE')),
      body: Padding(
        padding: const EdgeInsets.all(DesignTokens.spaceLg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Enter the invite code from your coordinator.',
              style: TextStyle(color: AppTheme.textSecondary),
            ),
            const SizedBox(height: DesignTokens.spaceMd),
            TextField(
              controller: _codeCtrl,
              decoration: InputDecoration(
                labelText: 'Invite code',
                errorText: _error,
              ),
              textCapitalization: TextCapitalization.characters,
              maxLength: 6,
              style: const TextStyle(fontSize: 24, letterSpacing: 8),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: DesignTokens.spaceSm),
            const Text(
              "You'll join as staff. Your coordinator can change your role after approving.",
              style: TextStyle(color: AppTheme.textSecondary, fontSize: DesignTokens.typeSm),
            ),
            const SizedBox(height: DesignTokens.spaceLg),
            ElevatedButton(
              onPressed: _loading ? null : _requestJoin,
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.accent),
              child: _loading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('REQUEST TO JOIN'),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/router/app_router.dart';
import '../../core/services/firestore_refs.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/design_tokens.dart';

class JoinStoreScreen extends StatefulWidget {
  const JoinStoreScreen({super.key});

  @override
  State<JoinStoreScreen> createState() => _JoinStoreScreenState();
}

class _JoinStoreScreenState extends State<JoinStoreScreen> {
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
      final snap = await FirebaseFirestore.instance
          .collection('stores')
          .where('inviteCode', isEqualTo: code)
          .limit(1)
          .get();
      if (snap.docs.isEmpty) {
        setState(() => _error = 'Invalid invite code.');
        return;
      }
      final storeDoc = snap.docs.first;
      final storeId = storeDoc.id;
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      // Check for existing membership
      final existingSnap = await FirestoreRefs.memberships(storeId).doc(user.uid).get();
      if (existingSnap.exists) {
        final status = existingSnap.data()?['status'] as String?;
        if (status == 'active') {
          // Already a member — just navigate
          if (mounted) context.goNamed(AppRoutes.zoneMap);
          return;
        }
      }

      await FirestoreRefs.memberships(storeId).doc(user.uid).set({
        'role': 'staff',
        'status': 'pending',
        'displayName': user.displayName ?? user.email ?? 'Staff',
        'joinedAt': Timestamp.now(),
      });

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

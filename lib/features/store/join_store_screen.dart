import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/providers/store_provider.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/design_tokens.dart';
import '../../core/widgets/mm_button.dart';
import '../../core/widgets/mm_text_field.dart';

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
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final callable =
          FirebaseFunctions.instance.httpsCallable('joinByInviteCode');
      final result = await callable.call({'inviteCode': code});
      final data = result.data as Map<String, dynamic>;
      final storeId = data['storeId'] as String;
      final status = data['status'] as String;

      await ref.read(activeStoreIdProvider.notifier).setStore(storeId);
      if (!mounted) return;
      if (status == 'active') {
        context.goNamed(AppRoutes.zoneMap);
      } else {
        context.goNamed(AppRoutes.pendingApproval);
      }
    } on FirebaseFunctionsException catch (e) {
      setState(() => _error = e.message ?? 'Something went wrong.');
    } catch (_) {
      setState(() => _error = 'Something went wrong. Please try again.');
    } finally {
      if (mounted) setState(() => _loading = false);
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
            MmTextField(
              label: 'Invite code',
              controller: _codeCtrl,
            ),
            if (_error != null) ...[
              const SizedBox(height: DesignTokens.spaceXs),
              Text(
                _error!,
                style: const TextStyle(
                  color: AppTheme.errorColor,
                  fontSize: DesignTokens.typeSm,
                ),
              ),
            ],
            const SizedBox(height: DesignTokens.spaceSm),
            const Text(
              "You'll join as staff. Your coordinator can change your role after approving.",
              style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: DesignTokens.typeSm),
            ),
            const SizedBox(height: DesignTokens.spaceLg),
            MmButton(
              label: 'REQUEST TO JOIN',
              isLoading: _loading,
              onPressed: _loading ? null : _requestJoin,
            ),
          ],
        ),
      ),
    );
  }
}

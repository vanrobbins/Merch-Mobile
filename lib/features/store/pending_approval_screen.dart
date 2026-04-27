import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/providers/store_provider.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/design_tokens.dart';

class PendingApprovalScreen extends ConsumerWidget {
  const PendingApprovalScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider).value;

    if (user != null) {
      ref.listen(
        // Watch all user memberships for any that become active
        currentMembershipProvider,
        (_, next) {
          if (next.value != null && next.value!.status == 'active') {
            ref.read(activeStoreIdProvider.notifier).setStore(next.value!.storeId);
            context.goNamed(AppRoutes.zoneMap);
          }
        },
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('REQUEST SENT')),
      body: Padding(
        padding: const EdgeInsets.all(DesignTokens.spaceLg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(Icons.hourglass_top, size: 48, color: AppTheme.textSecondary),
            const SizedBox(height: DesignTokens.spaceMd),
            const Text(
              'Waiting for approval',
              style: TextStyle(
                fontSize: DesignTokens.typeLg,
                fontWeight: DesignTokens.weightBold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: DesignTokens.spaceSm),
            const Text(
              'A coordinator or manager will approve your request. This screen will update automatically.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppTheme.textSecondary),
            ),
            const SizedBox(height: DesignTokens.spaceLg),
            TextButton(
              onPressed: () => context.goNamed(AppRoutes.joinStore),
              child: const Text('Join a different store'),
            ),
          ],
        ),
      ),
    );
  }
}

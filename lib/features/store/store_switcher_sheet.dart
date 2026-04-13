import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/providers/store_provider.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/design_tokens.dart';

class StoreSwitcherSheet extends ConsumerWidget {
  const StoreSwitcherSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const StoreSwitcherSheet(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stores = ref.watch(myStoresProvider).value ?? [];
    final activeId = ref.watch(activeStoreIdProvider).value;
    final membership = ref.watch(currentMembershipProvider).value;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 8),
            width: 40, height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(DesignTokens.spaceMd),
            child: Text(
              'MY STORES',
              style: TextStyle(
                fontSize: DesignTokens.typeXs,
                fontWeight: DesignTokens.weightBold,
                letterSpacing: DesignTokens.letterSpacingEyebrow,
                color: AppTheme.textSecondary,
              ),
            ),
          ),
          ...stores.map((store) {
            final isActive = store.id == activeId;
            return ListTile(
              tileColor: isActive ? AppTheme.canvasBg : null,
              title: Text(store.name,
                  style: const TextStyle(fontWeight: FontWeight.w600)),
              subtitle: Text(
                isActive ? (membership?.role ?? '') : '',
                style: const TextStyle(fontSize: DesignTokens.typeXs),
              ),
              trailing: isActive
                  ? const Text('ACTIVE',
                      style: TextStyle(
                          color: AppTheme.accent,
                          fontSize: DesignTokens.typeXs,
                          fontWeight: FontWeight.w700))
                  : null,
              onTap: () async {
                await ref
                    .read(activeStoreIdProvider.notifier)
                    .setStore(store.id);
                if (context.mounted) Navigator.pop(context);
              },
            );
          }),
          ListTile(
            leading: const Icon(Icons.add, color: AppTheme.accent),
            title: const Text('JOIN ANOTHER STORE',
                style: TextStyle(
                    color: AppTheme.accent,
                    fontWeight: FontWeight.w700,
                    fontSize: DesignTokens.typeSm,
                    letterSpacing: 1)),
            onTap: () {
              Navigator.pop(context);
              context.goNamed(AppRoutes.joinStore);
            },
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

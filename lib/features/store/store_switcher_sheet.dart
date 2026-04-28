import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/models/store.dart';
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
    final stores = ref.watch(myStoresProvider).valueOrNull ?? [];
    final activeId = ref.watch(activeStoreIdProvider).value;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
            top: Radius.circular(DesignTokens.radiusLg)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle — matches mm_bottom_sheet.dart
          Container(
            margin: const EdgeInsets.only(top: DesignTokens.spaceSm),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius:
                  BorderRadius.circular(AppTheme.borderRadius),
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
          for (var i = 0; i < stores.length; i++) ...[
            _StoreTile(
              store: stores[i],
              isActive: stores[i].id == activeId,
            ),
            if (i < stores.length - 1)
              const Divider(height: 1, indent: DesignTokens.spaceMd),
          ],
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.add, color: AppTheme.accent),
            title: const Text(
              'JOIN ANOTHER STORE',
              style: TextStyle(
                color: AppTheme.accent,
                fontWeight: FontWeight.w700,
                fontSize: DesignTokens.typeSm,
                letterSpacing: DesignTokens.letterSpacingEyebrow,
              ),
            ),
            onTap: () {
              Navigator.pop(context);
              context.goNamed(AppRoutes.joinStore);
            },
          ),
          SizedBox(
            height: DesignTokens.spaceMd +
                MediaQuery.of(context).padding.bottom,
          ),
        ],
      ),
    );
  }
}

/// Single store row — role badge is derived from myStoresProvider membership data.
class _StoreTile extends ConsumerWidget {
  const _StoreTile({required this.store, required this.isActive});
  final Store store;
  final bool isActive;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // The active store's membership is available via currentMembershipProvider.
    // For non-active stores, we show no badge (role unknown without extra query).
    final role = isActive
        ? (ref.watch(currentMembershipProvider).value?.role ?? '')
        : '';

    return ListTile(
      tileColor: isActive ? AppTheme.canvasBg : null,
      title: Text(
        store.name,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: role.isEmpty
          ? null
          : Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: DesignTokens.spaceXs,
                      vertical: 1,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.roleColor(role),
                      borderRadius:
                          BorderRadius.circular(AppTheme.borderRadius),
                    ),
                    child: Text(
                      role.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: DesignTokens.typeXs,
                        fontWeight: DesignTokens.weightBold,
                        letterSpacing: DesignTokens.letterSpacingEyebrow,
                      ),
                    ),
                  ),
                ],
              ),
            ),
      trailing: isActive
          ? const Text(
              'ACTIVE',
              style: TextStyle(
                color: AppTheme.accent,
                fontSize: DesignTokens.typeXs,
                fontWeight: FontWeight.w700,
                letterSpacing: DesignTokens.letterSpacingEyebrow,
              ),
            )
          : null,
      onTap: () async {
        await ref
            .read(activeStoreIdProvider.notifier)
            .setStore(store.id);
        if (context.mounted) Navigator.pop(context);
      },
    );
  }
}

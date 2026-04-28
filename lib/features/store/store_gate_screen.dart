import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/providers/store_provider.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/design_tokens.dart';

class StoreGateScreen extends ConsumerWidget {
  const StoreGateScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final storesAsync = ref.watch(myStoresProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('MERCH MOBILE')),
      body: storesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => _body(context, ref, hasStores: false),
        data: (stores) {
          if (stores.isEmpty) return _body(context, ref, hasStores: false);

          // User has stores — let them pick one or add another.
          return ListView(
            padding: const EdgeInsets.all(DesignTokens.spaceMd),
            children: [
              const Padding(
                padding: EdgeInsets.only(bottom: DesignTokens.spaceMd),
                child: Text(
                  'YOUR STORES',
                  style: TextStyle(
                    fontSize: DesignTokens.typeXs,
                    fontWeight: DesignTokens.weightBold,
                    letterSpacing: DesignTokens.letterSpacingEyebrow,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ),
              for (final store in stores)
                Card(
                  margin: const EdgeInsets.only(bottom: DesignTokens.spaceSm),
                  child: ListTile(
                    title: Text(store.name,
                        style: const TextStyle(fontWeight: FontWeight.w600)),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () async {
                      await ref
                          .read(activeStoreIdProvider.notifier)
                          .setStore(store.id);
                      if (context.mounted) context.goNamed(AppRoutes.zoneMap);
                    },
                  ),
                ),
              const SizedBox(height: DesignTokens.spaceLg),
              const Divider(),
              const SizedBox(height: DesignTokens.spaceMd),
              OutlinedButton(
                onPressed: () => context.goNamed(AppRoutes.joinStore),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('JOIN ANOTHER STORE'),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _body(BuildContext context, WidgetRef ref, {required bool hasStores}) {
    return Padding(
      padding: const EdgeInsets.all(DesignTokens.spaceLg),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            "YOU'RE NOT A MEMBER OF ANY STORE YET.",
            style: TextStyle(
              fontSize: DesignTokens.typeMd,
              fontWeight: DesignTokens.weightBold,
              letterSpacing: DesignTokens.letterSpacingEyebrow,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: DesignTokens.spaceLg),
          ElevatedButton(
            onPressed: () => context.goNamed(AppRoutes.createStore),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text('CREATE A STORE'),
          ),
          const SizedBox(height: DesignTokens.spaceMd),
          OutlinedButton(
            onPressed: () => context.goNamed(AppRoutes.joinStore),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text('JOIN WITH INVITE CODE'),
          ),
        ],
      ),
    );
  }
}

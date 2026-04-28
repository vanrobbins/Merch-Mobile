import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/models/store.dart';
import '../../core/providers/store_provider.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/design_tokens.dart';
import '../store/store_switcher_sheet.dart';
import '../zone_manager/store_entrance.dart';
import '../zone_manager/zone_map_provider.dart';
import 'dashboard_provider.dart';

/// Role-aware home screen for the active store.
/// - Coordinator: zones, fixtures, products, join requests, proposals, store setup.
/// - Manager: products, join requests, proposals.
/// - Staff: my photos, my proposals.
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(dashboardStatsProvider);
    final membership = ref.watch(currentMembershipProvider).value;
    final role = membership?.role ?? 'staff';

    final activeStore = ref.watch(activeStoreProvider).value;

    return Scaffold(
      appBar: AppBar(
        title: GestureDetector(
          onTap: () => StoreSwitcherSheet.show(context),
          behavior: HitTestBehavior.opaque,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(
                  activeStore?.name.toUpperCase() ?? 'MERCH MOBILE',
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: DesignTokens.typeMd,
                    fontWeight: DesignTokens.weightBold,
                    letterSpacing: DesignTokens.letterSpacingAppBar,
                  ),
                ),
              ),
              const Icon(Icons.keyboard_arrow_down, size: 18),
            ],
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Log out',
            onPressed: () async {
              await ref.read(activeStoreIdProvider.notifier).clearStore();
              await FirebaseAuth.instance.signOut();
            },
          ),
        ],
      ),
      body: statsAsync.when(
        data: (stats) => ListView(
          padding: const EdgeInsets.all(DesignTokens.spaceMd),
          children: [
            // Role / welcome banner — subtle gradient for depth
            Container(
              padding: const EdgeInsets.all(DesignTokens.spaceMd),
              margin: const EdgeInsets.only(bottom: DesignTokens.spaceMd),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.primary,
                    AppTheme.primary.withValues(alpha: 0.85),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(AppTheme.borderRadius),
                boxShadow: const [AppTheme.cardShadow],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    membership?.displayName ?? 'Welcome',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: DesignTokens.typeLg,
                    ),
                  ),
                  const SizedBox(height: DesignTokens.spaceXs),
                  Text(
                    role.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: DesignTokens.typeXs,
                      fontWeight: DesignTokens.weightBold,
                      letterSpacing: DesignTokens.letterSpacingEyebrow,
                    ),
                  ),
                ],
              ),
            ),

            if (role == 'coordinator') ...[
              _StoreSetupCard(ref: ref),
              const SizedBox(height: DesignTokens.spaceMd),
              _StatsGrid(items: [
                _StatItem(
                  'Zones',
                  stats.zoneCount,
                  Icons.map_outlined,
                  () => context.goNamed(AppRoutes.zoneMap),
                ),
                _StatItem(
                  'Fixtures',
                  stats.fixtureCount,
                  Icons.chair_outlined,
                  null,
                ),
                _StatItem(
                  'Products',
                  stats.productCount,
                  Icons.inventory_2_outlined,
                  () => context.goNamed(AppRoutes.catalog),
                ),
                _StatItem(
                  'Join Requests',
                  stats.pendingJoinRequests,
                  Icons.person_add_outlined,
                  () => context.goNamed(AppRoutes.members),
                  badge: stats.pendingJoinRequests > 0,
                ),
                _StatItem(
                  'Proposals',
                  stats.pendingProposals,
                  Icons.edit_note,
                  null,
                  badge: stats.pendingProposals > 0,
                ),
              ]),
            ],

            if (role == 'manager') ...[
              _StatsGrid(items: [
                _StatItem(
                  'Products',
                  stats.productCount,
                  Icons.inventory_2_outlined,
                  () => context.goNamed(AppRoutes.catalog),
                ),
                _StatItem(
                  'Join Requests',
                  stats.pendingJoinRequests,
                  Icons.person_add_outlined,
                  () => context.goNamed(AppRoutes.members),
                  badge: stats.pendingJoinRequests > 0,
                ),
                _StatItem(
                  'Proposals',
                  stats.pendingProposals,
                  Icons.edit_note,
                  null,
                  badge: stats.pendingProposals > 0,
                ),
              ]),
            ],

            if (role == 'staff') ...[
              const Padding(
                padding: EdgeInsets.only(bottom: DesignTokens.spaceMd),
                child: Text(
                  'YOUR ACTIVITY',
                  style: TextStyle(
                    fontSize: DesignTokens.typeXs,
                    fontWeight: DesignTokens.weightBold,
                    letterSpacing: DesignTokens.letterSpacingEyebrow,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ),
              _StatsGrid(items: [
                _StatItem(
                  'My Photos',
                  stats.myPhotoCount,
                  Icons.photo_library_outlined,
                  () => context.goNamed(AppRoutes.photoList),
                ),
                _StatItem(
                  'My Proposals',
                  stats.myProposalCount,
                  Icons.edit_note,
                  null,
                ),
              ]),
            ],
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(DesignTokens.spaceLg),
            child: Text(
              'Error: $e',
              style: const TextStyle(color: AppTheme.textSecondary),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}

class _StoreSetupCard extends StatelessWidget {
  const _StoreSetupCard({required this.ref});
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    final zoneState = ref.watch(zoneMapNotifierProvider);
    final store = zoneState.storeData;
    final hasDims = store?.widthFt != null && store?.depthFt != null;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(AppTheme.borderRadius),
        boxShadow: const [AppTheme.cardShadow],
      ),
      padding: const EdgeInsets.all(DesignTokens.spaceMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'STORE SETUP',
            style: TextStyle(
              fontSize: DesignTokens.typeXs,
              fontWeight: DesignTokens.weightBold,
              letterSpacing: DesignTokens.letterSpacingEyebrow,
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: DesignTokens.spaceSm),
          Row(
            children: [
              const Icon(Icons.straighten,
                  size: DesignTokens.iconSm, color: AppTheme.textSecondary),
              const SizedBox(width: DesignTokens.spaceXs),
              Expanded(
                child: Text(
                  hasDims
                      ? '${store!.widthFt!.toStringAsFixed(0)} ft × ${store.depthFt!.toStringAsFixed(0)} ft'
                      : 'No dimensions set',
                  style: const TextStyle(fontSize: DesignTokens.typeSm),
                ),
              ),
              TextButton(
                onPressed: () => _showDimensionsDialog(context),
                child: Text(hasDims ? 'EDIT' : 'SET SIZE'),
              ),
            ],
          ),
          const SizedBox(height: DesignTokens.spaceXs),
          _EntranceRow(ref: ref, store: store),
        ],
      ),
    );
  }

  void _showDimensionsDialog(BuildContext context) {
    final widthCtrl = TextEditingController();
    final depthCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();
    showDialog<void>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('STORE DIMENSIONS'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: widthCtrl,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                    labelText: 'Width (ft)', border: OutlineInputBorder()),
                validator: (v) {
                  final n = double.tryParse(v ?? '');
                  return (n == null || n <= 0)
                      ? 'Enter a positive number'
                      : null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: depthCtrl,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                    labelText: 'Depth (ft)', border: OutlineInputBorder()),
                validator: (v) {
                  final n = double.tryParse(v ?? '');
                  return (n == null || n <= 0)
                      ? 'Enter a positive number'
                      : null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(dialogCtx),
              child: const Text('CANCEL')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accent,
                foregroundColor: Colors.white),
            onPressed: () {
              if (formKey.currentState!.validate()) {
                ref
                    .read(zoneMapNotifierProvider.notifier)
                    .updateStoreDimensions(
                      double.parse(widthCtrl.text),
                      double.parse(depthCtrl.text),
                    );
                Navigator.pop(dialogCtx);
              }
            },
            child: const Text('CONFIRM'),
          ),
        ],
      ),
    );
  }
}

class _EntranceRow extends StatelessWidget {
  const _EntranceRow({required this.ref, required this.store});
  final WidgetRef ref;
  final Store? store;

  @override
  Widget build(BuildContext context) {
    final entrance = StoreEntrance.fromJson(store?.entranceJson);

    if (entrance == null) {
      return SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          onPressed: () => context.goNamed(
            AppRoutes.zoneMap,
            queryParameters: {'entranceEdit': 'true'},
          ),
          icon: const Icon(Icons.door_front_door_outlined, size: 16),
          label: const Text('ADD ENTRANCE'),
        ),
      );
    }

    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => context.goNamed(
              AppRoutes.zoneMap,
              queryParameters: {'entranceEdit': 'true'},
            ),
            icon: const Icon(Icons.door_front_door_outlined, size: 16),
            label: Text('EDIT ENTRANCE (${entrance.wallName})'),
          ),
        ),
        const SizedBox(width: DesignTokens.spaceXs),
        OutlinedButton(
          onPressed: () =>
              ref.read(zoneMapNotifierProvider.notifier).removeEntrance(),
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.red.shade600,
            side: BorderSide(color: Colors.red.shade600),
          ),
          child: const Text('REMOVE'),
        ),
      ],
    );
  }
}

class _StatsGrid extends StatelessWidget {
  const _StatsGrid({required this.items});
  final List<_StatItem> items;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: DesignTokens.spaceSm,
      mainAxisSpacing: DesignTokens.spaceSm,
      childAspectRatio: 1.4,
      children: items.map((item) => _StatCard(item: item)).toList(),
    );
  }
}

class _StatItem {
  const _StatItem(
    this.label,
    this.value,
    this.icon,
    this.onTap, {
    this.badge = false,
  });
  final String label;
  final int value;
  final IconData icon;
  final VoidCallback? onTap;
  final bool badge;
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.item});
  final _StatItem item;

  @override
  Widget build(BuildContext context) {
    final highlighted = item.badge && item.value > 0;
    final borderRadius = BorderRadius.circular(AppTheme.borderRadius);

    return Material(
      color: Colors.white,
      borderRadius: borderRadius,
      elevation: 0,
      child: InkWell(
        onTap: item.onTap,
        borderRadius: borderRadius,
        child: Ink(
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(
              color: highlighted ? AppTheme.accent : Colors.grey.shade200,
              width: highlighted ? 1.5 : 1.0,
            ),
            borderRadius: borderRadius,
            boxShadow: const [AppTheme.cardShadow],
          ),
          padding: const EdgeInsets.all(DesignTokens.spaceMd),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    item.icon,
                    size: DesignTokens.iconMd,
                    color:
                        highlighted ? AppTheme.accent : AppTheme.textSecondary,
                  ),
                  const Spacer(),
                  if (highlighted)
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppTheme.accent,
                        shape: BoxShape.circle,
                      ),
                    ),
                ],
              ),
              const Spacer(),
              Text(
                '${item.value}',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                item.label,
                style: const TextStyle(
                  fontSize: DesignTokens.typeXs,
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

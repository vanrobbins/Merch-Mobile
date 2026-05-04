import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/models/store.dart';
import '../../core/providers/store_provider.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/design_tokens.dart';
import '../../core/widgets/mm_bottom_sheet.dart';
import '../../core/widgets/mm_button.dart';
import '../../core/widgets/mm_dialog.dart';
import '../../core/widgets/mm_eyebrow.dart';
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
            icon: const Icon(Icons.account_circle_outlined),
            tooltip: 'Profile',
            onPressed: () =>
                _showProfileSheet(context, ref, membership, role, activeStore),
          ),
        ],
      ),
      body: statsAsync.when(
        data: (stats) => ListView(
          padding: const EdgeInsets.all(DesignTokens.spaceMd),
          children: [
            if (role == 'coordinator') ...[
              Consumer(
                builder: (context, ref, _) {
                  final store =
                      ref.watch(zoneMapNotifierProvider).storeData;
                  final hasDims =
                      store?.widthFt != null && store?.depthFt != null;
                  final hasEntrance = store?.entranceJson != null &&
                      store!.entranceJson!.isNotEmpty;
                  if (!hasDims || !hasEntrance) {
                    return Column(
                      children: [
                        _StoreSetupCard(ref: ref),
                        const SizedBox(height: DesignTokens.spaceMd),
                      ],
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
              _StatsGrid(items: [
                _StatItem(
                  'Zones',
                  stats.zoneCount,
                  Icons.map_outlined,
                  () => context.goNamed(AppRoutes.zoneMap),
                  subtitle: '${stats.fixtureCount} fixtures',
                ),
                _StatItem(
                  'Products',
                  stats.productCount,
                  Icons.inventory_2_outlined,
                  () => context.goNamed(AppRoutes.catalog),
                ),
                _StatItem(
                  'Mannequins',
                  stats.mannequinCount,
                  Icons.accessibility_new_outlined,
                  () => context.goNamed(AppRoutes.zoneMap),
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
                  () => context.goNamed(AppRoutes.planogramList),
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
                  () => context.goNamed(AppRoutes.planogramList),
                  badge: stats.pendingProposals > 0,
                ),
              ]),
            ],

            if (role == 'staff') ...[
              const Padding(
                padding: EdgeInsets.only(bottom: DesignTokens.spaceMd),
                child: MmEyebrow('YOUR ACTIVITY'),
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
                  () => context.goNamed(AppRoutes.planogramList),
                ),
              ]),
            ],
          ],
        ),
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppTheme.accent),
        ),
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

void _showProfileSheet(
  BuildContext context,
  WidgetRef ref,
  dynamic membership,
  String role,
  dynamic activeStore,
) {
  showMmBottomSheet<void>(
    context: context,
    title: 'Profile',
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MmEyebrow(role.toUpperCase()),
        const SizedBox(height: DesignTokens.spaceXs),
        Text(
          membership?.displayName ?? 'User',
          style: const TextStyle(
            fontSize: DesignTokens.typeLg,
            fontWeight: DesignTokens.weightBold,
          ),
        ),
        if (activeStore != null) ...[
          const SizedBox(height: DesignTokens.spaceXs),
          Text(
            activeStore.name as String,
            style: const TextStyle(
              fontSize: DesignTokens.typeSm,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
        const SizedBox(height: DesignTokens.spaceLg),
        SizedBox(
          width: double.infinity,
          child: MmButton.destructive(
            label: 'LOG OUT',
            onPressed: () async {
              Navigator.pop(context);
              final confirmed = await MmDialog.show<bool>(
                context,
                title: 'LOG OUT',
                content: const Text('Are you sure you want to log out?'),
                actions: [
                  MmButton.text(
                    label: 'CANCEL',
                    onPressed: () => Navigator.pop(context, false),
                  ),
                  MmButton.destructive(
                    label: 'LOG OUT',
                    onPressed: () => Navigator.pop(context, true),
                  ),
                ],
              );
              if (confirmed == true) {
                await ref.read(activeStoreIdProvider.notifier).clearStore();
                await FirebaseAuth.instance.signOut();
              }
            },
          ),
        ),
      ],
    ),
  );
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
        color: AppTheme.cardSurface,
        border: Border.all(color: AppTheme.divider),
        borderRadius: BorderRadius.circular(AppTheme.borderRadius),
        boxShadow: const [AppTheme.cardShadow],
      ),
      padding: const EdgeInsets.all(DesignTokens.spaceMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const MmEyebrow('STORE SETUP'),
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
              MmButton.text(
                label: hasDims ? 'EDIT' : 'SET SIZE',
                onPressed: () => _showDimensionsDialog(context),
              ),
            ],
          ),
          const SizedBox(height: DesignTokens.spaceXs),
          _EntranceRow(ref: ref, store: store),
          const SizedBox(height: DesignTokens.spaceXs),
          _ShapeRow(ref: ref, store: store),
        ],
      ),
    );
  }

  void _showDimensionsDialog(BuildContext context) {
    final widthCtrl = TextEditingController();
    final depthCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();
    MmDialog.show<void>(
      context,
      title: 'STORE DIMENSIONS',
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
        MmButton.text(
          label: 'CANCEL',
          onPressed: () => Navigator.pop(context),
        ),
        MmButton(
          label: 'CONFIRM',
          onPressed: () {
            if (formKey.currentState!.validate()) {
              ref
                  .read(zoneMapNotifierProvider.notifier)
                  .updateStoreDimensions(
                    double.parse(widthCtrl.text),
                    double.parse(depthCtrl.text),
                  );
              Navigator.pop(context);
            }
          },
        ),
      ],
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
        child: MmButton.outlined(
          label: 'ADD ENTRANCE',
          icon: Icons.door_front_door_outlined,
          onPressed: () => context.goNamed(
            AppRoutes.zoneMap,
            queryParameters: {'entranceEdit': 'true'},
          ),
        ),
      );
    }

    return Row(
      children: [
        Expanded(
          child: MmButton.outlined(
            label: 'EDIT ENTRANCE (${entrance.wallName})',
            icon: Icons.door_front_door_outlined,
            onPressed: () => context.goNamed(
              AppRoutes.zoneMap,
              queryParameters: {'entranceEdit': 'true'},
            ),
          ),
        ),
        const SizedBox(width: DesignTokens.spaceXs),
        MmButton.destructive(
          label: 'REMOVE',
          onPressed: () =>
              ref.read(zoneMapNotifierProvider.notifier).removeEntrance(),
        ),
      ],
    );
  }
}

class _ShapeRow extends StatelessWidget {
  const _ShapeRow({required this.ref, required this.store});
  final WidgetRef ref;
  final Store? store;

  bool get _hasCustomShape {
    final raw = store?.shapePoints;
    if (raw == null || raw.isEmpty) return false;
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.crop_square_outlined,
            size: DesignTokens.iconSm, color: AppTheme.textSecondary),
        const SizedBox(width: DesignTokens.spaceXs),
        Expanded(
          child: Text(
            _hasCustomShape ? 'Custom store shape' : 'Default shape (rectangle)',
            style: const TextStyle(fontSize: DesignTokens.typeSm),
          ),
        ),
        MmButton.text(
          label: 'CHANGE',
          onPressed: () => context.goNamed(
            AppRoutes.zoneMap,
            queryParameters: {'storeShapeEdit': 'true'},
          ),
        ),
        if (_hasCustomShape)
          MmButton.destructive(
            label: 'RESET',
            onPressed: () =>
                ref.read(zoneMapNotifierProvider.notifier).updateStoreShape([]),
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
    this.subtitle,
  });
  final String label;
  final int value;
  final IconData icon;
  final VoidCallback? onTap;
  final bool badge;
  final String? subtitle;
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.item});
  final _StatItem item;

  @override
  Widget build(BuildContext context) {
    final highlighted = item.badge && item.value > 0;
    final borderRadius = BorderRadius.circular(AppTheme.borderRadius);

    return Material(
      color: AppTheme.cardSurface,
      borderRadius: borderRadius,
      elevation: 0,
      child: InkWell(
        onTap: item.onTap,
        borderRadius: borderRadius,
        child: Ink(
          decoration: BoxDecoration(
            color: AppTheme.cardSurface,
            border: Border.all(
              color: highlighted ? AppTheme.accent : AppTheme.divider,
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
                      padding: const EdgeInsets.symmetric(
                        horizontal: DesignTokens.spaceXs + 2,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.accent,
                        borderRadius:
                            BorderRadius.circular(DesignTokens.radiusPill),
                      ),
                      child: Text(
                        '${item.value}',
                        style: const TextStyle(
                          color: AppTheme.canvasBg,
                          fontSize: DesignTokens.typeXs,
                          fontWeight: DesignTokens.weightBold,
                        ),
                      ),
                    ),
                ],
              ),
              const Spacer(),
              Text(
                '${item.value}',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: DesignTokens.weightBold,
                ),
              ),
              Text(
                item.label,
                style: const TextStyle(
                  fontSize: DesignTokens.typeXs,
                  color: AppTheme.textSecondary,
                ),
              ),
              if (item.subtitle != null)
                Text(
                  item.subtitle!,
                  style: const TextStyle(
                    fontSize: DesignTokens.typeXs,
                    color: AppTheme.textHint,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

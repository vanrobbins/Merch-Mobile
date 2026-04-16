import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/providers/store_provider.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/design_tokens.dart';
import 'dashboard_provider.dart';

/// Role-aware home screen for the active store.
/// - Coordinator: zones, fixtures, products, join requests, proposals.
/// - Manager: products, join requests, proposals.
/// - Staff: my photos, my proposals.
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(dashboardStatsProvider);
    final membership = ref.watch(currentMembershipProvider).value;
    final role = membership?.role ?? 'staff';

    return Scaffold(
      appBar: AppBar(title: const Text('DASHBOARD')),
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
                  // ignore: deprecated_member_use
                  colors: [AppTheme.primary, AppTheme.primary.withOpacity(0.85)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius:
                    BorderRadius.circular(AppTheme.borderRadius),
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
                  stats.pendingJoinRequests > 0
                      ? () => context.goNamed(AppRoutes.members)
                      : null,
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
                  stats.pendingJoinRequests > 0
                      ? () => context.goNamed(AppRoutes.members)
                      : null,
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
              color: highlighted
                  ? AppTheme.accent
                  : Colors.grey.shade200,
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
                    color: highlighted
                        ? AppTheme.accent
                        : AppTheme.textSecondary,
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

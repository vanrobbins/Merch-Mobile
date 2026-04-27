import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/store_provider.dart';
import '../router/app_router.dart';
import '../theme/app_theme.dart';
import '../theme/design_tokens.dart';
import '../../features/store/store_switcher_sheet.dart';

class AppScaffold extends ConsumerWidget {
  const AppScaffold({super.key, required this.child});
  final Widget child;

  static const _tabs = <_Tab>[
    _Tab('Dashboard', Icons.dashboard_outlined, AppRoutes.dashboard, AppPaths.dashboard),
    _Tab('Zones', Icons.map_outlined, AppRoutes.zoneMap, AppPaths.zoneMap),
    _Tab('Planograms', Icons.grid_view_outlined, AppRoutes.planogramList, AppPaths.planogramList),
    _Tab('Catalog', Icons.inventory_2_outlined, AppRoutes.catalog, AppPaths.catalog),
    _Tab('Photos', Icons.photo_library_outlined, AppRoutes.photoList, AppPaths.photoList),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final location = GoRouterState.of(context).matchedLocation;
    final index = _tabs.indexWhere((t) => location.startsWith(t.path));
    final activeIndex = index < 0 ? 0 : index;

    final activeStore = ref.watch(activeStoreProvider).value;
    final membership = ref.watch(currentMembershipProvider).value;

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
          if (membership != null)
            Padding(
              padding: const EdgeInsets.only(right: DesignTokens.spaceMd),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: DesignTokens.spaceSm,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.roleColor(membership.role),
                    borderRadius:
                        BorderRadius.circular(AppTheme.borderRadius),
                  ),
                  child: Text(
                    membership.role.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: DesignTokens.typeXs,
                      fontWeight: DesignTokens.weightBold,
                      letterSpacing: DesignTokens.letterSpacingEyebrow,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: activeIndex,
        type: BottomNavigationBarType.fixed,
        onTap: (i) => context.goNamed(_tabs[i].routeName),
        items: [
          for (final t in _tabs)
            BottomNavigationBarItem(icon: Icon(t.icon), label: t.label),
        ],
      ),
    );
  }
}

class _Tab {
  const _Tab(this.label, this.icon, this.routeName, this.path);
  final String label;
  final IconData icon;
  final String routeName;
  final String path;
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/store_provider.dart';
import '../router/app_router.dart';
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
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(activeStore?.name ?? 'MERCH MOBILE'),
              const SizedBox(width: 4),
              const Icon(Icons.arrow_drop_down, size: 18),
            ],
          ),
        ),
        actions: [
          if (membership != null)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Chip(
                label: Text(
                  membership.role.toUpperCase(),
                  style: const TextStyle(fontSize: 10),
                ),
                backgroundColor: Colors.white24,
                labelStyle: const TextStyle(color: Colors.white),
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

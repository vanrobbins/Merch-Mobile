import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../router/app_router.dart';

class AppScaffold extends StatelessWidget {
  const AppScaffold({super.key, required this.child});

  final Widget child;

  static const _tabs = <_Tab>[
    _Tab('Zones', Icons.map_outlined, AppRoutes.zoneMap, AppPaths.zoneMap),
    _Tab('Planograms', Icons.grid_view_outlined, AppRoutes.planogramList, AppPaths.planogramList),
    _Tab('Catalog', Icons.inventory_2_outlined, AppRoutes.catalog, AppPaths.catalog),
    _Tab('Photos', Icons.photo_library_outlined, AppRoutes.photoList, AppPaths.photoList),
  ];

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    final index = _tabs.indexWhere((t) => location.startsWith(t.path));
    final activeIndex = index < 0 ? 0 : index;

    return Scaffold(
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

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../router/app_router.dart';
import '../theme/app_theme.dart';

class AppScaffold extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    final index = _tabs.indexWhere((t) => location.startsWith(t.path));
    final activeIndex = index < 0 ? 0 : index;

    return Scaffold(
      body: child,
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(color: AppTheme.divider, width: 0.5),
          ),
        ),
        child: Theme(
          data: Theme.of(context).copyWith(
            navigationBarTheme: NavigationBarThemeData(
              backgroundColor: AppTheme.primary,
              indicatorColor: Colors.transparent,
              elevation: 0,
              labelTextStyle: WidgetStateProperty.resolveWith(
                (states) => TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: states.contains(WidgetState.selected)
                      ? AppTheme.accent
                      : AppTheme.textHint,
                ),
              ),
            ),
          ),
          child: NavigationBar(
            selectedIndex: activeIndex,
            onDestinationSelected: (i) => context.goNamed(_tabs[i].routeName),
            backgroundColor: AppTheme.primary,
            indicatorColor: Colors.transparent,
            elevation: 0,
            labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
            destinations: [
              for (final t in _tabs)
                NavigationDestination(
                  icon: Icon(t.icon, color: AppTheme.textHint),
                  selectedIcon: Icon(t.icon, color: AppTheme.accent),
                  label: t.label,
                ),
            ],
          ),
        ),
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

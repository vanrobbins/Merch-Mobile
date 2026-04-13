import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../router/app_router.dart';

class AppScaffold extends ConsumerStatefulWidget {
  const AppScaffold({super.key});

  @override
  ConsumerState<AppScaffold> createState() => _AppScaffoldState();
}

class _AppScaffoldState extends ConsumerState<AppScaffold> {
  int _index = 0;

  static const _tabs = <_Tab>[
    _Tab('Zones', Icons.map_outlined, AppRoutes.zoneMap),
    _Tab('Planograms', Icons.grid_view_outlined, AppRoutes.planogramList),
    _Tab('Catalog', Icons.inventory_2_outlined, AppRoutes.catalog),
    _Tab('Photos', Icons.photo_library_outlined, AppRoutes.photoList),
  ];

  @override
  Widget build(BuildContext context) {
    final tab = _tabs[_index];
    return Scaffold(
      appBar: AppBar(title: Text(tab.label.toUpperCase())),
      body: Center(child: Text(tab.label)),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        type: BottomNavigationBarType.fixed,
        onTap: (i) {
          setState(() => _index = i);
          context.goNamed(_tabs[i].routeName);
        },
        items: [
          for (final t in _tabs)
            BottomNavigationBarItem(icon: Icon(t.icon), label: t.label),
        ],
      ),
    );
  }
}

class _Tab {
  const _Tab(this.label, this.icon, this.routeName);
  final String label;
  final IconData icon;
  final String routeName;
}

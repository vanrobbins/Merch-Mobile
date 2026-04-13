import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../widgets/app_scaffold.dart';
import '../../features/auth/splash_screen.dart';
import '../../features/auth/login_screen.dart';
import '../../features/zone_manager/zone_map_screen.dart';
import '../../features/floor_builder/floor_builder_screen.dart';
import '../../features/auto_build/auto_build_screen.dart';
import '../../features/planogram/planogram_list_screen.dart';
import '../../features/planogram/planogram_detail_screen.dart';
import '../../features/product_catalog/catalog_screen.dart';
import '../../features/photo_docs/photo_list_screen.dart';
import '../../features/photo_docs/photo_detail_screen.dart';

part 'app_router.g.dart';

/// Bridges Firebase Auth's stream to GoRouter's refreshListenable so the
/// router re-evaluates its redirect whenever auth state changes.
class _AuthChangeNotifier extends ChangeNotifier {
  _AuthChangeNotifier() {
    _subscription =
        FirebaseAuth.instance.authStateChanges().listen((_) => notifyListeners());
  }

  late final StreamSubscription<User?> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

class AppRoutes {
  static const splash = 'splash';
  static const login = 'login';
  static const home = 'home';
  static const zoneMap = 'zoneMap';
  static const floorBuilder = 'floorBuilder';
  static const autoBuild = 'autoBuild';
  static const planogramList = 'planogramList';
  static const planogramDetail = 'planogramDetail';
  static const catalog = 'catalog';
  static const photoList = 'photoList';
  static const photoDetail = 'photoDetail';
}

class AppPaths {
  static const splash = '/';
  static const login = '/login';
  static const home = '/home';
  static const zoneMap = '/home/zones';
  static const floorBuilder = '/home/zones/:zoneId/builder';
  static const autoBuild = '/home/zones/:zoneId/auto';
  static const planogramList = '/home/planograms';
  static const planogramDetail = '/home/planograms/:planogramId';
  static const catalog = '/home/catalog';
  static const photoList = '/home/photos';
  static const photoDetail = '/home/photos/:photoId';
}


@Riverpod(keepAlive: true)
GoRouter appRouter(AppRouterRef ref) {
  return GoRouter(
    initialLocation: AppPaths.splash,
    refreshListenable: _AuthChangeNotifier(),
    redirect: (context, state) {
      final isLoggedIn = FirebaseAuth.instance.currentUser != null;
      final loc = state.matchedLocation;
      final isPublic = loc == AppPaths.splash || loc == AppPaths.login;

      if (!isLoggedIn && !isPublic) return AppPaths.login;
      if (isLoggedIn && loc == AppPaths.login) return AppPaths.zoneMap;
      return null;
    },
    routes: [
      GoRoute(
        name: AppRoutes.splash,
        path: AppPaths.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        name: AppRoutes.login,
        path: AppPaths.login,
        builder: (context, state) => const LoginScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) => AppScaffold(child: child),
        routes: [
          GoRoute(
            name: AppRoutes.zoneMap,
            path: AppPaths.zoneMap,
            builder: (context, state) => const ZoneMapScreen(),
            routes: [
              GoRoute(
                name: AppRoutes.floorBuilder,
                path: ':zoneId/builder',
                builder: (context, state) => FloorBuilderScreen(
                  zoneId: state.pathParameters['zoneId']!,
                ),
              ),
              GoRoute(
                name: AppRoutes.autoBuild,
                path: ':zoneId/auto',
                builder: (context, state) => AutoBuildScreen(
                  zoneId: state.pathParameters['zoneId']!,
                ),
              ),
            ],
          ),
          GoRoute(
            name: AppRoutes.planogramList,
            path: AppPaths.planogramList,
            builder: (context, state) => const PlanogramListScreen(),
            routes: [
              GoRoute(
                name: AppRoutes.planogramDetail,
                path: ':planogramId',
                builder: (context, state) => PlanogramDetailScreen(
                  planogramId: state.pathParameters['planogramId']!,
                ),
              ),
            ],
          ),
          GoRoute(
            name: AppRoutes.catalog,
            path: AppPaths.catalog,
            builder: (context, state) => const CatalogScreen(),
          ),
          GoRoute(
            name: AppRoutes.photoList,
            path: AppPaths.photoList,
            builder: (context, state) => const PhotoListScreen(),
            routes: [
              GoRoute(
                name: AppRoutes.photoDetail,
                path: ':photoId',
                builder: (context, state) => PhotoDetailScreen(
                  photoId: state.pathParameters['photoId']!,
                ),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}

// TODO(Agent5): add connectivity listener here

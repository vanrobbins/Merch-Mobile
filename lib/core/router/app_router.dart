import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../widgets/app_scaffold.dart';
import '../../features/auth/splash_screen.dart';
import '../../features/auth/login_screen.dart';
import 'route_guards.dart';

part 'app_router.g.dart';

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

class _PlaceholderScreen extends StatelessWidget {
  const _PlaceholderScreen(this.title);
  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title.toUpperCase())),
      body: Center(child: Text(title)),
    );
  }
}

@Riverpod(keepAlive: true)
GoRouter appRouter(AppRouterRef ref) {
  return GoRouter(
    initialLocation: AppPaths.splash,
    routes: [
      GoRoute(
        name: AppRoutes.splash,
        path: AppPaths.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        name: AppRoutes.login,
        path: AppPaths.login,
        redirect: (context, state) => redirectIfAuthed(ref),
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        name: AppRoutes.home,
        path: AppPaths.home,
        redirect: (context, state) => requireAuth(ref),
        builder: (context, state) => const AppScaffold(),
      ),
      GoRoute(
        name: AppRoutes.zoneMap,
        path: AppPaths.zoneMap,
        redirect: (context, state) => requireAuth(ref),
        builder: (context, state) => const _PlaceholderScreen('Zones'),
        routes: [
          GoRoute(
            name: AppRoutes.floorBuilder,
            path: ':zoneId/builder',
            redirect: (context, state) => requireAuth(ref),
            builder: (context, state) =>
                const _PlaceholderScreen('Floor Builder'),
          ),
          GoRoute(
            name: AppRoutes.autoBuild,
            path: ':zoneId/auto',
            redirect: (context, state) => requireAuth(ref),
            builder: (context, state) =>
                const _PlaceholderScreen('Auto Build'),
          ),
        ],
      ),
      GoRoute(
        name: AppRoutes.planogramList,
        path: AppPaths.planogramList,
        redirect: (context, state) => requireAuth(ref),
        builder: (context, state) => const _PlaceholderScreen('Planograms'),
        routes: [
          GoRoute(
            name: AppRoutes.planogramDetail,
            path: ':planogramId',
            redirect: (context, state) => requireAuth(ref),
            builder: (context, state) =>
                const _PlaceholderScreen('Planogram Detail'),
          ),
        ],
      ),
      GoRoute(
        name: AppRoutes.catalog,
        path: AppPaths.catalog,
        redirect: (context, state) => requireAuth(ref),
        builder: (context, state) => const _PlaceholderScreen('Catalog'),
      ),
      GoRoute(
        name: AppRoutes.photoList,
        path: AppPaths.photoList,
        redirect: (context, state) => requireAuth(ref),
        builder: (context, state) => const _PlaceholderScreen('Photos'),
        routes: [
          GoRoute(
            name: AppRoutes.photoDetail,
            path: ':photoId',
            redirect: (context, state) => requireAuth(ref),
            builder: (context, state) =>
                const _PlaceholderScreen('Photo Detail'),
          ),
        ],
      ),
    ],
  );
}

// TODO(Agent5): add connectivity listener here

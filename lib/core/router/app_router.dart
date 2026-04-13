import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
import '../../features/store/store_gate_screen.dart';
import '../../features/store/create_store_screen.dart';
import '../../features/store/join_store_screen.dart';
import '../../features/store/pending_approval_screen.dart';
import '../../features/store/members_screen.dart';
import '../../features/store/group_management_screen.dart';

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
  static const dashboard = 'dashboard';
  static const zoneMap = 'zoneMap';
  static const floorBuilder = 'floorBuilder';
  static const autoBuild = 'autoBuild';
  static const planogramList = 'planogramList';
  static const planogramDetail = 'planogramDetail';
  static const catalog = 'catalog';
  static const photoList = 'photoList';
  static const photoDetail = 'photoDetail';
  static const storeGate = 'storeGate';
  static const createStore = 'createStore';
  static const joinStore = 'joinStore';
  static const pendingApproval = 'pendingApproval';
  static const members = 'members';
  static const groupManagement = 'groupManagement';
  static const zoneDetail = 'zoneDetail';
  static const proposalReview = 'proposalReview';
}

class AppPaths {
  static const splash = '/';
  static const login = '/login';
  static const home = '/home';
  static const dashboard = '/home/dashboard';
  static const zoneMap = '/home/zones';
  static const floorBuilder = '/home/zones/:zoneId/builder';
  static const autoBuild = '/home/zones/:zoneId/auto';
  static const planogramList = '/home/planograms';
  static const planogramDetail = '/home/planograms/:planogramId';
  static const catalog = '/home/catalog';
  static const photoList = '/home/photos';
  static const photoDetail = '/home/photos/:photoId';
  static const storeGate = '/store-gate';
  static const createStore = '/store-gate/create';
  static const joinStore = '/store-gate/join';
  static const pendingApproval = '/store-gate/pending';
  static const members = '/home/members';
  static const groupManagement = '/home/groups';
  static const zoneDetail = '/home/zones/:zoneId/detail';
  static const proposalReview = '/home/planograms/:planogramId/proposals';
}


@Riverpod(keepAlive: true)
GoRouter appRouter(AppRouterRef ref) {
  return GoRouter(
    initialLocation: AppPaths.splash,
    refreshListenable: _AuthChangeNotifier(),
    redirect: (context, state) async {
      final isLoggedIn = FirebaseAuth.instance.currentUser != null;
      final loc = state.matchedLocation;
      final isPublic = loc == AppPaths.splash || loc == AppPaths.login;
      final isStoreGate = loc.startsWith('/store-gate');

      if (!isLoggedIn && !isPublic) return AppPaths.login;
      if (isLoggedIn && loc == AppPaths.login) {
        // Will be redirected to storeGate or home by store gate check below
        return AppPaths.zoneMap;
      }

      // Store gate: if logged in but no active store, send to gate
      // (Skip this check for store gate routes themselves)
      if (isLoggedIn && !isPublic && !isStoreGate) {
        final prefs = await SharedPreferences.getInstance();
        final storeId = prefs.getString('active_store_id');
        if (storeId == null || storeId.isEmpty) return AppPaths.storeGate;
      }
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
      // Store gate routes (outside ShellRoute — no bottom nav)
      GoRoute(
        name: AppRoutes.storeGate,
        path: AppPaths.storeGate,
        builder: (_, __) => const StoreGateScreen(),
        routes: [
          GoRoute(
            name: AppRoutes.createStore,
            path: 'create',
            builder: (_, __) => const CreateStoreScreen(),
          ),
          GoRoute(
            name: AppRoutes.joinStore,
            path: 'join',
            builder: (_, __) => const JoinStoreScreen(),
          ),
          GoRoute(
            name: AppRoutes.pendingApproval,
            path: 'pending',
            builder: (_, __) => const PendingApprovalScreen(),
          ),
        ],
      ),
      ShellRoute(
        builder: (context, state, child) => AppScaffold(child: child),
        routes: [
          GoRoute(
            name: AppRoutes.dashboard,
            path: AppPaths.dashboard,
            builder: (_, __) => const Scaffold(
              body: Center(child: Text('Dashboard — Agent 4')),
            ),
          ),
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
          GoRoute(
            name: AppRoutes.members,
            path: AppPaths.members,
            builder: (_, __) => const MembersScreen(),
          ),
          GoRoute(
            name: AppRoutes.groupManagement,
            path: AppPaths.groupManagement,
            builder: (_, __) => const GroupManagementScreen(),
          ),
        ],
      ),
    ],
  );
}

// TODO(Agent5): add connectivity listener here

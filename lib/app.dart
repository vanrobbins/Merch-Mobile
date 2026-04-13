import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';

// TODO(Agent5): add connectivity listener here

class MerchMobileApp extends ConsumerWidget {
  const MerchMobileApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    return MaterialApp.router(
      title: 'Merch Mobile',
      theme: AppTheme.light,
      routerConfig: router,
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/providers/connectivity_provider.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';

class MerchMobileApp extends ConsumerWidget {
  const MerchMobileApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final isOnline = ref.watch(connectivityProvider).valueOrNull ?? true;
    return MaterialApp.router(
      title: 'Merch Mobile',
      theme: AppTheme.light,
      routerConfig: router,
      builder: (context, child) => Column(
        children: [
          if (!isOnline)
            const Material(
              color: AppTheme.errorColor,
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  child: Row(
                    children: [
                      Icon(Icons.wifi_off, color: Colors.white, size: 16),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Offline — changes will sync when reconnected',
                          style: TextStyle(color: Colors.white, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          Expanded(child: child ?? const SizedBox()),
        ],
      ),
    );
  }
}

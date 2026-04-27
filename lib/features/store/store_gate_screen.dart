import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/design_tokens.dart';

class StoreGateScreen extends StatelessWidget {
  const StoreGateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('MERCH MOBILE')),
      body: Padding(
        padding: const EdgeInsets.all(DesignTokens.spaceLg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              "YOU'RE NOT A MEMBER OF ANY STORE YET.",
              style: TextStyle(
                fontSize: DesignTokens.typeMd,
                fontWeight: DesignTokens.weightBold,
                letterSpacing: DesignTokens.letterSpacingEyebrow,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: DesignTokens.spaceLg),
            ElevatedButton(
              onPressed: () => context.goNamed(AppRoutes.createStore),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('CREATE A STORE'),
            ),
            const SizedBox(height: DesignTokens.spaceMd),
            OutlinedButton(
              onPressed: () => context.goNamed(AppRoutes.joinStore),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('JOIN WITH INVITE CODE'),
            ),
          ],
        ),
      ),
    );
  }
}

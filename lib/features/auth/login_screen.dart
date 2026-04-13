import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import 'login_notifier.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(loginNotifierProvider);
    final error = state.hasError ? state.error.toString() : null;
    final isLoading = state.isLoading;

    const underline = InputDecoration(
      enabledBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: AppTheme.textSecondary),
      ),
      focusedBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: AppTheme.primary),
      ),
      border: InputBorder.none,
    );

    return Scaffold(
      backgroundColor: AppTheme.canvasBg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 48),
              const Text(
                'MERCH MOBILE',
                style: TextStyle(
                  color: AppTheme.primary,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 2.0,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              if (error != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 16),
                  color: AppTheme.accent.withValues(alpha: 0.12),
                  child: Text(
                    error,
                    style: const TextStyle(color: AppTheme.accent),
                  ),
                ),
              TextField(
                controller: _emailCtrl,
                decoration: underline.copyWith(labelText: 'EMAIL'),
                keyboardType: TextInputType.emailAddress,
                autocorrect: false,
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _passwordCtrl,
                decoration: underline.copyWith(labelText: 'PASSWORD'),
                obscureText: true,
              ),
              const SizedBox(height: 48),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  foregroundColor: AppTheme.canvasBg,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(
                        Radius.circular(AppTheme.borderRadius)),
                  ),
                ),
                onPressed: isLoading
                    ? null
                    : () => ref.read(loginNotifierProvider.notifier).signIn(
                          _emailCtrl.text,
                          _passwordCtrl.text,
                        ),
                child: isLoading
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppTheme.canvasBg,
                        ),
                      )
                    : const Text(
                        'SIGN IN',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.5,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

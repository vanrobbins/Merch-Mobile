import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import 'login_notifier.dart';
import 'signup_notifier.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  bool _isSignUp = false;
  String? _confirmError;

  void _toggleMode() {
    setState(() {
      _isSignUp = !_isSignUp;
      _confirmError = null;
    });
    _nameCtrl.clear();
    _emailCtrl.clear();
    _passwordCtrl.clear();
    _confirmCtrl.clear();
    if (_isSignUp) {
      ref.invalidate(loginNotifierProvider);
    } else {
      ref.invalidate(signUpNotifierProvider);
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loginState = ref.watch(loginNotifierProvider);
    final signUpState = ref.watch(signUpNotifierProvider);
    final activeState = _isSignUp ? signUpState : loginState;

    final error = activeState.hasError
        ? activeState.error.toString()
        : _confirmError;
    final isLoading = activeState.isLoading;

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
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 24),
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
              const SizedBox(height: 24),
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
              if (_isSignUp) ...[
                TextField(
                  controller: _nameCtrl,
                  decoration: underline.copyWith(labelText: 'NAME'),
                  textCapitalization: TextCapitalization.words,
                  autocorrect: false,
                ),
                const SizedBox(height: 24),
              ],
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
              if (_isSignUp) ...[
                const SizedBox(height: 24),
                TextField(
                  controller: _confirmCtrl,
                  decoration:
                      underline.copyWith(labelText: 'CONFIRM PASSWORD'),
                  obscureText: true,
                ),
              ],
              const SizedBox(height: 24),
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
                onPressed: isLoading ? null : _submit,
                child: isLoading
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppTheme.canvasBg,
                        ),
                      )
                    : Text(
                        _isSignUp ? 'SIGN UP' : 'SIGN IN',
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.5,
                        ),
                      ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _isSignUp
                        ? 'Already have an account? '
                        : "Don't have an account? ",
                    style: const TextStyle(color: AppTheme.textSecondary),
                  ),
                  TextButton(
                    onPressed: _toggleMode,
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      _isSignUp ? 'Sign in' : 'Sign up',
                      style: const TextStyle(color: AppTheme.textSecondary),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _submit() {
    if (_isSignUp) {
      if (_passwordCtrl.text != _confirmCtrl.text) {
        setState(() => _confirmError = 'Passwords do not match');
        return;
      }
      setState(() => _confirmError = null);
      ref.read(signUpNotifierProvider.notifier).signUp(
            _nameCtrl.text,
            _emailCtrl.text,
            _passwordCtrl.text,
          );
    } else {
      ref.read(loginNotifierProvider.notifier).signIn(
            _emailCtrl.text,
            _passwordCtrl.text,
          );
    }
  }
}

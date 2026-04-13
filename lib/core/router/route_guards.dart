import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';

/// Returns redirect path `/login` if user is not authenticated.
/// Returns null to allow the navigation.
String? requireAuth(Ref ref) {
  final auth = ref.read(authStateProvider);
  final user = auth.value;
  if (user == null) return '/login';
  return null;
}

/// Returns redirect path `/home` if user is already authenticated.
/// Used on the login screen to skip it when already signed in.
String? redirectIfAuthed(Ref ref) {
  final auth = ref.read(authStateProvider);
  final user = auth.value;
  if (user != null) return '/home';
  return null;
}

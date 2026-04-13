import 'package:firebase_auth/firebase_auth.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/app_user.dart';

part 'auth_provider.g.dart';

@Riverpod(keepAlive: true)
Stream<User?> authState(AuthStateRef ref) =>
    FirebaseAuth.instance.authStateChanges();

@riverpod
Future<AppUser?> currentUser(CurrentUserRef ref) async {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return null;
  final token = await user.getIdTokenResult();
  final role = token.claims?['role'] as String? ?? 'staff';
  return AppUser(
    uid: user.uid,
    email: user.email ?? '',
    role: role,
    displayName: user.displayName,
  );
}

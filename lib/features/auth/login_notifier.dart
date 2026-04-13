import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../core/services/auth_service.dart';

part 'login_notifier.g.dart';

@riverpod
class LoginNotifier extends _$LoginNotifier {
  @override
  FutureOr<void> build() {}

  Future<void> signIn(String email, String password) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => AuthService().signInWithEmail(email.trim(), password),
    );
  }
}

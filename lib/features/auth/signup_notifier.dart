import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../core/services/auth_service.dart';

part 'signup_notifier.g.dart';

@riverpod
class SignUpNotifier extends _$SignUpNotifier {
  @override
  FutureOr<void> build() {}

  Future<void> signUp(String name, String email, String password) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => AuthService().signUpWithEmail(name, email.trim(), password),
    );
  }
}

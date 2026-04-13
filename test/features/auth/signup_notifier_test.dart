import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:merch_mobile/features/auth/signup_notifier.dart';

void main() {
  test('SignUpNotifier initial state is AsyncData(null)', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final state = container.read(signUpNotifierProvider);
    expect(state, const AsyncData<void>(null));
  });
}

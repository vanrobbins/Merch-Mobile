import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:merch_mobile/core/services/auth_service.dart';

class _FakeFirebaseAuth implements FirebaseAuth {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  test('AuthService exposes signUpWithEmail', () {
    // Verify the method exists on the class (compile-time check).
    // ignore: unnecessary_type_check
    expect(AuthService(_FakeFirebaseAuth()).signUpWithEmail is Function, isTrue);
  });
}

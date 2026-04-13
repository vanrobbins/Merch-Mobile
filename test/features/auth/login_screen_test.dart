import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:merch_mobile/core/providers/auth_provider.dart';
import 'package:merch_mobile/features/auth/login_screen.dart';

// Wrap LoginScreen with ProviderScope overrides and a plain MaterialApp.
// authStateProvider is overridden to stream null (not authed) so the
// ref.listen navigation callback never fires during tests.
Widget _buildSubject() {
  return ProviderScope(
    overrides: [
      authStateProvider.overrideWith((ref) => Stream.value(null)),
    ],
    child: const MaterialApp(home: LoginScreen()),
  );
}

void main() {
  testWidgets('shows SIGN IN button by default', (tester) async {
    await tester.pumpWidget(_buildSubject());
    expect(find.text('SIGN IN'), findsOneWidget);
    expect(find.text('SIGN UP'), findsNothing);
  });

  testWidgets('does not show Name or Confirm Password fields in sign-in mode',
      (tester) async {
    await tester.pumpWidget(_buildSubject());
    expect(find.widgetWithText(TextField, 'NAME'), findsNothing);
    expect(find.widgetWithText(TextField, 'CONFIRM PASSWORD'), findsNothing);
  });

  testWidgets('toggling to sign-up mode shows SIGN UP button and extra fields',
      (tester) async {
    await tester.pumpWidget(_buildSubject());
    await tester.tap(find.text('Sign up'));
    await tester.pumpAndSettle();

    expect(find.text('SIGN UP'), findsOneWidget);
    expect(find.text('SIGN IN'), findsNothing);
    expect(find.widgetWithText(TextField, 'NAME'), findsOneWidget);
    expect(find.widgetWithText(TextField, 'CONFIRM PASSWORD'), findsOneWidget);
  });

  testWidgets('shows error when passwords do not match', (tester) async {
    await tester.pumpWidget(_buildSubject());

    // Switch to sign-up mode
    await tester.tap(find.text('Sign up'));
    await tester.pumpAndSettle();

    // Fill name and email
    await tester.enterText(
        find.widgetWithText(TextField, 'NAME'), 'Test User');
    await tester.enterText(
        find.widgetWithText(TextField, 'EMAIL'), 'test@example.com');
    await tester.enterText(
        find.widgetWithText(TextField, 'PASSWORD'), 'password1');
    await tester.enterText(
        find.widgetWithText(TextField, 'CONFIRM PASSWORD'), 'password2');

    await tester.tap(find.text('SIGN UP'));
    await tester.pump();

    expect(find.text('Passwords do not match'), findsOneWidget);
  });

  testWidgets('toggling back to sign-in mode hides extra fields', (tester) async {
    await tester.pumpWidget(_buildSubject());

    await tester.tap(find.text('Sign up'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Sign in'));
    await tester.pumpAndSettle();

    expect(find.text('SIGN IN'), findsOneWidget);
    expect(find.widgetWithText(TextField, 'NAME'), findsNothing);
    expect(find.widgetWithText(TextField, 'CONFIRM PASSWORD'), findsNothing);
  });
}

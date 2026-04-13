# Signup Feature Design

**Date:** 2026-04-13
**Branch:** feature/build-flutter-app
**Status:** Approved

## Summary

Add self-serve account creation to the existing login screen. New accounts are always `staff` role. No new routes or screens — the login screen toggles between sign-in and sign-up mode in-place.

## Scope

- `lib/core/services/auth_service.dart` — add `signUpWithEmail`
- `lib/features/auth/signup_notifier.dart` — new file
- `lib/features/auth/signup_notifier.g.dart` — generated
- `lib/features/auth/login_screen.dart` — toggle UI

## Service Layer

### `AuthService.signUpWithEmail`

```dart
Future<UserCredential> signUpWithEmail(String name, String email, String password) async {
  final cred = await _auth.createUserWithEmailAndPassword(email: email, password: password);
  await cred.user?.updateDisplayName(name);
  return cred;
}
```

New users receive the `staff` role automatically via the `currentUser` provider fallback (`token.claims?['role'] ?? 'staff'`). No Firebase Admin SDK or custom claims work is required.

### `SignUpNotifier`

New file at `lib/features/auth/signup_notifier.dart`. Mirrors the existing `LoginNotifier` pattern.

```dart
@riverpod
class SignUpNotifier extends _$SignUpNotifier {
  @override
  FutureOr<void> build() {}

  Future<void> signUp(String name, String email, String password) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => AuthService().signUpWithEmail(name.trim(), email.trim(), password),
    );
  }
}
```

## UI Layer

### Toggle mechanism

`LoginScreen` adds a `_isSignUp` bool in local `ConsumerStatefulWidget` state. Toggling:

- Switches visible fields via `AnimatedCrossFade`
- Invalidates the inactive notifier (clears stale errors)
- Clears all `TextEditingController`s

### Field order (signup mode)

1. Name
2. Email
3. Password
4. Confirm Password

Sign-in mode keeps the existing Email + Password fields unchanged.

### Password confirmation validation

Checked in the UI before calling `SignUpNotifier.signUp`. If the two password fields don't match, a local `_confirmError` string displays inline beneath the Confirm Password field. The notifier is not called.

### Navigation

The existing `ref.listen(authStateProvider, ...)` added to `LoginScreen.build` already navigates to home when a user is present. Signup navigation is covered with no additional code.

### Toggle link

A `TextButton` at the bottom of the form:

- Sign-in mode: "Don't have an account? **Sign up**"
- Sign-up mode: "Already have an account? **Sign in**"

The primary button label (`SIGN IN` / `SIGN UP`) and the `onPressed` handler swap with the mode.

## Error Handling

Both notifiers expose `AsyncValue` state. `LoginScreen` reads the active notifier's error and displays it in the existing error banner. Switching modes clears the banner by invalidating the inactive notifier.

## What Is Not Included

- Role selection during signup (roles above `staff` require Firebase Admin SDK)
- Email verification flow
- Password strength requirements beyond Firebase's defaults (minimum 6 characters)
- Separate `/signup` route

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:merch_mobile/core/database/app_database.dart';
import 'package:merch_mobile/core/providers/store_provider.dart';
import 'package:merch_mobile/core/widgets/role_guard.dart';

/// Builds a [StoreMembershipsTableData] with the given role/status.
StoreMembershipsTableData _membership({
  String role = 'staff',
  String status = 'active',
}) =>
    StoreMembershipsTableData(
      id: 'test',
      storeId: 'store',
      userUid: 'user',
      role: role,
      displayName: 'Test',
      status: status,
      joinedAt: 0,
    );

/// Creates a [currentMembershipProvider] override that streams the given
/// membership (or null for the "no membership" state).
Override _membershipOverride(StoreMembershipsTableData? m) =>
    currentMembershipProvider.overrideWith((ref) => Stream.value(m));

/// Wraps [child] in a [ProviderScope] with the membership override applied.
Widget _buildApp({
  StoreMembershipsTableData? membership,
  required Widget child,
}) =>
    ProviderScope(
      overrides: [_membershipOverride(membership)],
      child: MaterialApp(home: Scaffold(body: child)),
    );

void main() {
  group('RoleGuard', () {
    testWidgets('shows child when role is allowed', (tester) async {
      await tester.pumpWidget(_buildApp(
        membership: _membership(role: 'coordinator'),
        child: const RoleGuard(
          allowedRoles: ['coordinator', 'manager'],
          child: Text('ALLOWED'),
        ),
      ));
      await tester.pump();
      expect(find.text('ALLOWED'), findsOneWidget);
    });

    testWidgets('hides child when role is not allowed (default fallback)',
        (tester) async {
      await tester.pumpWidget(_buildApp(
        membership: _membership(role: 'staff'),
        child: const RoleGuard(
          allowedRoles: ['coordinator', 'manager'],
          child: Text('RESTRICTED'),
        ),
      ));
      await tester.pump();
      expect(find.text('RESTRICTED'), findsNothing);
    });

    testWidgets('shows fallback when role is not allowed', (tester) async {
      await tester.pumpWidget(_buildApp(
        membership: _membership(role: 'staff'),
        child: const RoleGuard(
          allowedRoles: ['coordinator'],
          fallback: Text('NO ACCESS'),
          child: Text('RESTRICTED'),
        ),
      ));
      await tester.pump();
      expect(find.text('NO ACCESS'), findsOneWidget);
      expect(find.text('RESTRICTED'), findsNothing);
    });

    testWidgets('shows child for staff when staff is in allowedRoles',
        (tester) async {
      await tester.pumpWidget(_buildApp(
        membership: _membership(role: 'staff'),
        child: const RoleGuard(
          allowedRoles: ['coordinator', 'manager', 'staff'],
          child: Text('STAFF OK'),
        ),
      ));
      await tester.pump();
      expect(find.text('STAFF OK'), findsOneWidget);
    });

    testWidgets('shows fallback when membership is null', (tester) async {
      await tester.pumpWidget(_buildApp(
        membership: null,
        child: const RoleGuard(
          allowedRoles: ['coordinator', 'manager', 'staff'],
          fallback: Text('NO MEMBER'),
          child: Text('HAS ACCESS'),
        ),
      ));
      await tester.pump();
      expect(find.text('NO MEMBER'), findsOneWidget);
      expect(find.text('HAS ACCESS'), findsNothing);
    });

    testWidgets('manager sees manager-only UI', (tester) async {
      await tester.pumpWidget(_buildApp(
        membership: _membership(role: 'manager'),
        child: const RoleGuard(
          allowedRoles: ['manager'],
          child: Text('MANAGER'),
        ),
      ));
      await tester.pump();
      expect(find.text('MANAGER'), findsOneWidget);
    });
  });
}

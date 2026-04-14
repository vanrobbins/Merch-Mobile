import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/store_provider.dart';

/// Shows a snackbar and returns false if the user's role is not in [allowedRoles].
/// Use this in onPressed handlers for additional protection beyond RoleGuard.
bool checkRole(
    BuildContext context, WidgetRef ref, List<String> allowedRoles) {
  final role =
      ref.read(currentMembershipProvider).value?.role ?? 'staff';
  if (allowedRoles.contains(role)) return true;
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text('Access restricted. Insufficient role.'),
      duration: Duration(seconds: 2),
    ),
  );
  return false;
}

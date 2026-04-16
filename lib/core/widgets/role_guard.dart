import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/store_provider.dart';

/// Hides [child] if the current user's role is not in [allowedRoles].
/// Shows [fallback] instead (default: SizedBox.shrink()).
///
/// Usage:
///   RoleGuard(
///     allowedRoles: ['coordinator', 'manager'],
///     child: FloatingActionButton(...),
///   )
class RoleGuard extends ConsumerWidget {
  const RoleGuard({
    super.key,
    required this.allowedRoles,
    required this.child,
    this.fallback = const SizedBox.shrink(),
  });

  final List<String> allowedRoles;
  final Widget child;
  final Widget fallback;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final membership = ref.watch(currentMembershipProvider).value;
    if (membership == null) return fallback;
    if (allowedRoles.contains(membership.role)) return child;
    return fallback;
  }
}

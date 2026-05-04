import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/mm_chip.dart';

class ApprovalStatusChip extends StatelessWidget {
  const ApprovalStatusChip({super.key, required this.status});

  final String status;

  Color _color() {
    return switch (status.toLowerCase()) {
      'approved' => AppTheme.successColor,
      'rejected' => AppTheme.errorColor,
      _ => AppTheme.textHint, // pending / unknown
    };
  }

  @override
  Widget build(BuildContext context) {
    return MmChip(
      label: status.toUpperCase(),
      color: _color(),
    );
  }
}

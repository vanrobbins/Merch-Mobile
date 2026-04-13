import 'package:flutter/material.dart';
import '../../core/widgets/mm_chip.dart';

class ApprovalStatusChip extends StatelessWidget {
  const ApprovalStatusChip({super.key, required this.status});

  final String status;

  Color _color() {
    return switch (status.toLowerCase()) {
      'approved' => Colors.green.shade600,
      'rejected' => Colors.red.shade600,
      _ => Colors.grey.shade400, // pending / unknown
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

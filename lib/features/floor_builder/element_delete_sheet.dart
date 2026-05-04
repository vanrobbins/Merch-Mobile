import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/design_tokens.dart';
import '../../core/widgets/mm_bottom_sheet.dart';
import '../../core/widgets/mm_button.dart';

class ElementDeleteSheet extends StatelessWidget {
  const ElementDeleteSheet({
    super.key,
    required this.title,
    required this.subtitle,
    required this.onDelete,
  });
  final String title;
  final String subtitle;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return MmBottomSheet(
      title: title,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: DesignTokens.typeXs,
              color: AppTheme.textSecondary,
              letterSpacing: DesignTokens.letterSpacingEyebrow,
            ),
          ),
          const SizedBox(height: DesignTokens.spaceMd),
          MmButton.destructive(
            label: 'Delete',
            icon: Icons.delete_outline,
            onPressed: () {
              Navigator.pop(context);
              onDelete();
            },
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/design_tokens.dart';

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
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).padding.bottom + 16,
        left: 16, right: 16, top: 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: DesignTokens.weightBold,
              fontSize: DesignTokens.typeMd,
              letterSpacing: DesignTokens.letterSpacingEyebrow,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: DesignTokens.typeXs,
              color: AppTheme.textSecondary,
              letterSpacing: DesignTokens.letterSpacingEyebrow,
            ),
          ),
          const SizedBox(height: DesignTokens.spaceMd),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
              foregroundColor: Colors.white,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(AppTheme.borderRadius)),
              ),
            ),
            onPressed: () {
              Navigator.pop(context);
              onDelete();
            },
            child: const Text('DELETE'),
          ),
        ],
      ),
    );
  }
}

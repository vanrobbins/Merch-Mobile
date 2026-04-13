import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../theme/design_tokens.dart';

class MmBottomSheet extends StatelessWidget {
  const MmBottomSheet({
    super.key,
    required this.title,
    required this.child,
    this.actions,
  });

  final String title;
  final Widget child;
  final List<Widget>? actions;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(DesignTokens.radiusLg),
          topRight: Radius.circular(DesignTokens.radiusLg),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Drag handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: DesignTokens.spaceSm),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          // Title
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: DesignTokens.spaceMd,
              vertical: DesignTokens.spaceSm,
            ),
            child: Text(
              title.toUpperCase(),
              style: const TextStyle(
                fontSize: DesignTokens.typeLg,
                fontWeight: DesignTokens.weightBold,
                letterSpacing: DesignTokens.letterSpacingEyebrow,
                color: AppTheme.textPrimary,
              ),
            ),
          ),
          const Divider(height: 1),
          // Scrollable body
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(DesignTokens.spaceMd),
              child: child,
            ),
          ),
          // Actions
          if (actions != null && actions!.isNotEmpty) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(DesignTokens.spaceMd),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: actions!
                    .map((a) => Padding(
                          padding: const EdgeInsets.only(left: DesignTokens.spaceSm),
                          child: a,
                        ))
                    .toList(),
              ),
            ),
          ],
          // Safe area padding
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }
}

/// Convenience function to show an [MmBottomSheet].
Future<T?> showMmBottomSheet<T>({
  required BuildContext context,
  required String title,
  required Widget child,
  List<Widget>? actions,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => MmBottomSheet(
      title: title,
      actions: actions,
      child: child,
    ),
  );
}

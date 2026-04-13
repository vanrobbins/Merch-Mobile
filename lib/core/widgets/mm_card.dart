import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../theme/design_tokens.dart';

class MmCard extends StatelessWidget {
  const MmCard({
    super.key,
    this.header,
    required this.child,
    this.footer,
    this.padding,
    this.onTap,
  });

  final Widget? header;
  final Widget child;
  final Widget? footer;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (header != null) ...[
          header!,
          const Divider(height: 1),
        ],
        Padding(
          padding: padding ?? const EdgeInsets.all(DesignTokens.spaceMd),
          child: child,
        ),
        if (footer != null) ...[
          const Divider(height: 1),
          footer!,
        ],
      ],
    );

    final card = Container(
      decoration: BoxDecoration(
        color: AppTheme.cardSurface,
        borderRadius: BorderRadius.circular(DesignTokens.radiusSm),
        boxShadow: const [AppTheme.cardShadow],
      ),
      child: content,
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(DesignTokens.radiusSm),
        child: card,
      );
    }
    return card;
  }
}

import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../theme/design_tokens.dart';
import 'mm_eyebrow.dart';

class MmListTile extends StatelessWidget {
  const MmListTile({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.onTap,
    this.isDestructive = false,
  });

  final String title;
  final String? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool isDestructive;

  @override
  Widget build(BuildContext context) {
    final effectiveTrailing = trailing ??
        (onTap != null
            ? const Icon(Icons.chevron_right,
                color: AppTheme.textHint, size: 16)
            : null);

    return Material(
      color: AppTheme.cardSurface,
      child: InkWell(
        onTap: onTap,
        child: ListTile(
          leading: leading,
          trailing: effectiveTrailing,
          title: Text(
            title,
            style: TextStyle(
              color:
                  isDestructive ? AppTheme.errorColor : AppTheme.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          subtitle: subtitle != null
              ? Text(
                  subtitle!,
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 11,
                  ),
                )
              : null,
        ),
      ),
    );
  }
}

class MmListSection extends StatelessWidget {
  const MmListSection({
    super.key,
    required this.children,
    this.header,
  });

  final List<Widget> children;
  final String? header;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (header != null) MmEyebrow(header!),
        Container(
          decoration: BoxDecoration(
            color: AppTheme.cardSurface,
            borderRadius: BorderRadius.circular(DesignTokens.radiusCard),
            border: Border.all(color: AppTheme.divider),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (int i = 0; i < children.length; i++) ...[
                children[i],
                if (i < children.length - 1)
                  const Divider(height: 1, indent: 16, endIndent: 0),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

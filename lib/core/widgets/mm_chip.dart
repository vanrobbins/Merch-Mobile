import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../theme/design_tokens.dart';

class MmChip extends StatelessWidget {
  const MmChip({
    super.key,
    required this.label,
    this.color,
    this.textColor,
    this.selected = false,
    this.onTap,
  });

  final String label;
  /// Explicit background color. When null, [selected] drives the color:
  /// accent fill when true, surfaceVariant when false.
  final Color? color;
  final Color? textColor;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final bgColor = color ?? (selected ? AppTheme.accent : AppTheme.surfaceVariant);
    final fgColor = textColor ?? (selected ? AppTheme.canvasBg : AppTheme.textSecondary);

    final chip = AnimatedContainer(
      duration: DesignTokens.durationFast,
      padding: const EdgeInsets.symmetric(
        horizontal: DesignTokens.spaceSm,
        vertical: DesignTokens.spaceXs,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(DesignTokens.radiusSm),
      ),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          fontSize: DesignTokens.typeXs,
          fontWeight: DesignTokens.weightBold,
          letterSpacing: DesignTokens.letterSpacingEyebrow,
          color: fgColor,
        ),
      ),
    );

    if (onTap != null) {
      return GestureDetector(onTap: onTap, child: chip);
    }
    return chip;
  }
}

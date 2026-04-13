import 'package:flutter/material.dart';
import '../theme/design_tokens.dart';

class MmChip extends StatelessWidget {
  const MmChip({
    super.key,
    required this.label,
    required this.color,
    this.textColor,
    this.onTap,
  });

  final String label;
  final Color color;
  final Color? textColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final chip = Container(
      padding: const EdgeInsets.symmetric(
        horizontal: DesignTokens.spaceSm,
        vertical: DesignTokens.spaceXs,
      ),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(DesignTokens.radiusSm),
      ),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          fontSize: DesignTokens.typeXs,
          fontWeight: DesignTokens.weightBold,
          letterSpacing: DesignTokens.letterSpacingEyebrow,
          color: textColor ?? Colors.white,
        ),
      ),
    );

    if (onTap != null) {
      return GestureDetector(onTap: onTap, child: chip);
    }
    return chip;
  }
}

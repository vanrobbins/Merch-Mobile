import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../theme/design_tokens.dart';

class MmColorSwatch extends StatelessWidget {
  const MmColorSwatch({
    super.key,
    required this.hexValue,
    this.size = 24.0,
    this.isSelected = false,
    this.onTap,
    this.label,
  });

  final String hexValue;
  final double size;
  final bool isSelected;
  final VoidCallback? onTap;
  final String? label;

  Color get _color {
    try {
      return Color(int.parse(hexValue.replaceFirst('#', 'FF'), radix: 16));
    } catch (_) {
      return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final swatch = GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: DesignTokens.durationFast,
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: _color,
          borderRadius: BorderRadius.circular(AppTheme.borderRadius),
          border: Border.all(
            color: isSelected ? AppTheme.accent : AppTheme.divider,
            width: isSelected ? 2.0 : 1.0,
          ),
          boxShadow: const [AppTheme.cardShadow],
        ),
        child: isSelected
            ? Icon(
                Icons.check,
                size: size * 0.5,
                color: _color.computeLuminance() > 0.5
                    ? AppTheme.primary
                    : Colors.white,
              )
            : null,
      ),
    );
    if (label == null) return swatch;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        swatch,
        const SizedBox(height: DesignTokens.spaceXs),
        Text(
          label!,
          style: const TextStyle(
            fontSize: DesignTokens.typeXs,
            color: AppTheme.textSecondary,
          ),
        ),
      ],
    );
  }
}

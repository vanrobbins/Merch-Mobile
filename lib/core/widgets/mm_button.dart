import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../theme/design_tokens.dart';

enum _MmButtonVariant { filled, outlined, destructive, text }

class MmButton extends StatelessWidget {
  const MmButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
    _MmButtonVariant variant = _MmButtonVariant.filled,
  }) : _variant = variant;

  const MmButton.outlined({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
  }) : _variant = _MmButtonVariant.outlined;

  const MmButton.destructive({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
  }) : _variant = _MmButtonVariant.destructive;

  const MmButton.text({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
  }) : _variant = _MmButtonVariant.text;

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final _MmButtonVariant _variant;

  static const _shape = RoundedRectangleBorder(
    borderRadius: BorderRadius.all(Radius.circular(DesignTokens.radiusCta)),
  );

  static const _labelStyle = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w700,
    letterSpacing: 1.2,
  );

  Widget _buildChild(Color indicatorColor) {
    if (isLoading) {
      return SizedBox(
        width: 16,
        height: 16,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: indicatorColor,
        ),
      );
    }
    if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16),
          const SizedBox(width: 8),
          Text(label.toUpperCase(), style: _labelStyle),
        ],
      );
    }
    return Text(label.toUpperCase(), style: _labelStyle);
  }

  @override
  Widget build(BuildContext context) {
    const minSize = Size(double.infinity, 44);

    switch (_variant) {
      case _MmButtonVariant.filled:
        return ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primary,
            foregroundColor: Colors.white,
            minimumSize: minSize,
            shape: _shape,
            elevation: 0,
          ),
          child: _buildChild(Colors.white),
        );

      case _MmButtonVariant.outlined:
        return OutlinedButton(
          onPressed: isLoading ? null : onPressed,
          style: OutlinedButton.styleFrom(
            foregroundColor: AppTheme.accent,
            minimumSize: minSize,
            shape: _shape,
            side: const BorderSide(color: AppTheme.accent),
          ),
          child: _buildChild(AppTheme.accent),
        );

      case _MmButtonVariant.destructive:
        return ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.errorColor,
            foregroundColor: Colors.white,
            minimumSize: minSize,
            shape: _shape,
            elevation: 0,
          ),
          child: _buildChild(Colors.white),
        );

      case _MmButtonVariant.text:
        return TextButton(
          onPressed: isLoading ? null : onPressed,
          style: TextButton.styleFrom(
            foregroundColor: AppTheme.accent,
            minimumSize: minSize,
            shape: _shape,
          ),
          child: _buildChild(AppTheme.accent),
        );
    }
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';
import '../theme/design_tokens.dart';

class MmTextField extends StatelessWidget {
  const MmTextField({
    super.key,
    this.label,
    this.hint,
    this.controller,
    this.onChanged,
    this.onSubmitted,
    this.autofocus = false,
    this.readOnly = false,
    this.maxLines = 1,
    this.keyboardType,
    this.inputFormatters,
    this.prefix,
    this.suffix,
    this.validator,
  });

  final String? label;
  final String? hint;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final bool autofocus;
  final bool readOnly;
  final int maxLines;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final Widget? prefix;
  final Widget? suffix;
  final FormFieldValidator<String>? validator;

  static OutlineInputBorder _border(Color color, {double width = 1.0}) =>
      OutlineInputBorder(
        borderRadius: BorderRadius.circular(DesignTokens.radiusCta),
        borderSide: BorderSide(color: color, width: width),
      );

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      onChanged: onChanged,
      onFieldSubmitted: onSubmitted,
      autofocus: autofocus,
      readOnly: readOnly,
      maxLines: maxLines,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      validator: validator,
      style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: prefix,
        suffixIcon: suffix,
        filled: true,
        fillColor: AppTheme.surfaceVariant,
        labelStyle: const TextStyle(color: AppTheme.textSecondary, fontSize: 14),
        hintStyle: const TextStyle(color: AppTheme.textHint, fontSize: 14),
        border: _border(AppTheme.divider),
        enabledBorder: _border(AppTheme.divider),
        focusedBorder: _border(AppTheme.accent, width: 1.5),
        errorBorder: _border(AppTheme.errorColor),
        focusedErrorBorder: _border(AppTheme.errorColor, width: 1.5),
      ),
    );
  }
}

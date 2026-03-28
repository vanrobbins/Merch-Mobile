import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import '../../models/color_variant.dart';
import '../../theme/app_theme.dart';

/// Dialog to create or edit a named ColorVariant.
/// Returns the created/edited [ColorVariant] or null if cancelled.
class ColorPickerDialog extends StatefulWidget {
  final ColorVariant? initial;

  const ColorPickerDialog({super.key, this.initial});

  @override
  State<ColorPickerDialog> createState() => _ColorPickerDialogState();
}

class _ColorPickerDialogState extends State<ColorPickerDialog> {
  late Color _selectedColor;
  late final TextEditingController _nameCtrl;
  late final TextEditingController _hexCtrl;

  @override
  void initState() {
    super.initState();
    _selectedColor = widget.initial?.color ?? const Color(0xFF1C1C1C);
    _nameCtrl = TextEditingController(text: widget.initial?.name ?? '');
    _hexCtrl = TextEditingController(
        text: _colorToHex(_selectedColor));
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _hexCtrl.dispose();
    super.dispose();
  }

  String _colorToHex(Color c) =>
      '#${c.value.toRadixString(16).substring(2).toUpperCase()}';

  void _onColorChanged(Color c) {
    setState(() {
      _selectedColor = c;
      _hexCtrl.text = _colorToHex(c);
    });
  }

  void _onHexChanged(String hex) {
    final cleaned = hex.replaceAll('#', '');
    if (cleaned.length == 6) {
      try {
        final c = Color(int.parse('FF$cleaned', radix: 16));
        setState(() => _selectedColor = c);
      } catch (_) {}
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Set Color'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Color name input
            TextField(
              controller: _nameCtrl,
              decoration: const InputDecoration(
                labelText: 'Color Name / Code',
                hintText: 'e.g. Foam Blue, BLK, NVY-24',
              ),
              textCapitalization: TextCapitalization.characters,
            ),
            const SizedBox(height: 16),

            // Quick defaults
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: ColorVariant.defaults.map((cv) {
                final isSelected = cv.color.value == _selectedColor.value;
                return GestureDetector(
                  onTap: () {
                    _onColorChanged(cv.color);
                    if (_nameCtrl.text.isEmpty) _nameCtrl.text = cv.name;
                  },
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: cv.color,
                      border: Border.all(
                        color: isSelected
                            ? AppTheme.accent
                            : AppTheme.outline,
                        width: isSelected ? 2.5 : 1,
                      ),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: isSelected
                        ? Icon(
                            Icons.check,
                            size: 16,
                            color: cv.color.computeLuminance() > 0.5
                                ? Colors.black
                                : Colors.white,
                          )
                        : null,
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 16),

            // Full color wheel
            ColorPicker(
              pickerColor: _selectedColor,
              onColorChanged: _onColorChanged,
              pickerAreaHeightPercent: 0.5,
              enableAlpha: false,
              hexInputBar: false,
              labelTypes: const [],
            ),

            // Hex input
            TextField(
              controller: _hexCtrl,
              decoration: const InputDecoration(
                labelText: 'Hex Code',
                hintText: '#1C1C1C',
                prefixText: '#',
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9A-Fa-f#]')),
                LengthLimitingTextInputFormatter(7),
              ],
              onChanged: _onHexChanged,
            ),

            const SizedBox(height: 12),

            // Preview
            Container(
              height: 40,
              decoration: BoxDecoration(
                color: _selectedColor,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: AppTheme.outline),
              ),
              alignment: Alignment.center,
              child: Text(
                _nameCtrl.text.isEmpty ? 'Preview' : _nameCtrl.text,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: _selectedColor.computeLuminance() > 0.5
                      ? Colors.black87
                      : Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            final name = _nameCtrl.text.trim();
            if (name.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Enter a color name')),
              );
              return;
            }
            Navigator.pop(
              context,
              ColorVariant(
                name: name,
                colorValue: _selectedColor.value,
              ),
            );
          },
          child: const Text('Apply'),
        ),
      ],
    );
  }
}

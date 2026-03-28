import 'package:flutter/material.dart';
import '../../models/garment_item.dart';
import '../../models/garment_type.dart';
import '../../models/color_variant.dart';
import '../../theme/app_theme.dart';
import '../painters/garment_painter.dart';
import 'color_picker_dialog.dart';

/// Dialog to add or edit a GarmentItem.
class AddGarmentDialog extends StatefulWidget {
  final GarmentItem? initial;

  const AddGarmentDialog({super.key, this.initial});

  @override
  State<AddGarmentDialog> createState() => _AddGarmentDialogState();
}

class _AddGarmentDialogState extends State<AddGarmentDialog> {
  final _nameCtrl = TextEditingController();
  GarmentType _type = GarmentType.hoodie;
  List<ColorVariant> _colorways = [];
  bool _isFeatured = false;

  @override
  void initState() {
    super.initState();
    if (widget.initial != null) {
      _nameCtrl.text = widget.initial!.name;
      _type = widget.initial!.type;
      _colorways = [...widget.initial!.colorways];
      _isFeatured = widget.initial!.isFeatured;
    } else {
      // Default: black
      _colorways = [ColorVariant.black];
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _addColor() async {
    final cv = await showDialog<ColorVariant>(
      context: context,
      builder: (_) => const ColorPickerDialog(),
    );
    if (cv != null) setState(() => _colorways.add(cv));
  }

  Future<void> _editColor(int index) async {
    final cv = await showDialog<ColorVariant>(
      context: context,
      builder: (_) => ColorPickerDialog(initial: _colorways[index]),
    );
    if (cv != null) {
      setState(() => _colorways[index] = cv);
    }
  }

  void _removeColor(int index) {
    setState(() => _colorways.removeAt(index));
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(maxWidth: 480, maxHeight: 680),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.fromLTRB(20, 16, 12, 16),
              decoration: const BoxDecoration(
                border: Border(
                    bottom: BorderSide(color: AppTheme.outline)),
              ),
              child: Row(
                children: [
                  Text(
                    widget.initial == null ? 'Add Product' : 'Edit Product',
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            // Body
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Preview
                    Center(
                      child: GarmentIllustration(
                        type: _type,
                        color: _colorways.isNotEmpty
                            ? _colorways.first.color
                            : Colors.grey,
                        width: 100,
                        height: 100,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Product name
                    TextField(
                      controller: _nameCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Product Name',
                        hintText: 'e.g. Smooth Spacer Hoodie',
                      ),
                      textCapitalization: TextCapitalization.words,
                    ),
                    const SizedBox(height: 16),

                    // Garment type
                    const Text(
                      'GARMENT TYPE',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: GarmentType.values.map((t) {
                        final selected = t == _type;
                        return GestureDetector(
                          onTap: () => setState(() => _type = t),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: selected
                                  ? AppTheme.primary
                                  : AppTheme.surface,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: selected
                                    ? AppTheme.primary
                                    : AppTheme.outline,
                              ),
                            ),
                            child: Text(
                              t.displayName,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: selected
                                    ? Colors.white
                                    : AppTheme.textPrimary,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 20),

                    // Colorways
                    Row(
                      children: [
                        const Text(
                          'COLORWAYS',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.8,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                        const Spacer(),
                        TextButton.icon(
                          onPressed: _addColor,
                          icon: const Icon(Icons.add, size: 16),
                          label: const Text('Add Color'),
                          style: TextButton.styleFrom(
                            foregroundColor: AppTheme.primary,
                            textStyle: const TextStyle(fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    if (_colorways.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(12),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          border: Border.all(
                              color: AppTheme.outline,
                              style: BorderStyle.solid),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'No colors added yet',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppTheme.textTertiary,
                          ),
                        ),
                      )
                    else
                      ReorderableListView(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        onReorder: (o, n) {
                          setState(() {
                            final item = _colorways.removeAt(o);
                            _colorways.insert(n > o ? n - 1 : n, item);
                          });
                        },
                        children: [
                          for (int i = 0; i < _colorways.length; i++)
                            ListTile(
                              key: ValueKey(_colorways[i].name + i.toString()),
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 4),
                              leading: GestureDetector(
                                onTap: () => _editColor(i),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 28,
                                      height: 28,
                                      decoration: BoxDecoration(
                                        color: _colorways[i].color,
                                        borderRadius:
                                            BorderRadius.circular(4),
                                        border: Border.all(
                                            color: AppTheme.outline),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    GarmentIllustration(
                                      type: _type,
                                      color: _colorways[i].color,
                                      width: 32,
                                      height: 32,
                                    ),
                                  ],
                                ),
                              ),
                              title: Text(
                                _colorways[i].name,
                                style: const TextStyle(fontSize: 13),
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit_outlined,
                                        size: 18),
                                    onPressed: () => _editColor(i),
                                    tooltip: 'Edit color',
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline,
                                        size: 18,
                                        color: Colors.red),
                                    onPressed: () => _removeColor(i),
                                    tooltip: 'Remove',
                                  ),
                                  const Icon(Icons.drag_handle,
                                      size: 18,
                                      color: AppTheme.textTertiary),
                                ],
                              ),
                            ),
                        ],
                      ),

                    const SizedBox(height: 16),

                    // Featured toggle
                    SwitchListTile(
                      value: _isFeatured,
                      onChanged: (v) => setState(() => _isFeatured = v),
                      title: const Text('Featured / Callout'),
                      subtitle: const Text(
                        'Highlight with a callout box in the schematic',
                        style: TextStyle(fontSize: 12),
                      ),
                      contentPadding: EdgeInsets.zero,
                      activeColor: AppTheme.accent,
                    ),
                  ],
                ),
              ),
            ),

            // Footer buttons
            Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: AppTheme.outline)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: _submit,
                      child: Text(widget.initial == null ? 'Add' : 'Save'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _submit() {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a product name')),
      );
      return;
    }
    if (_colorways.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add at least one colorway')),
      );
      return;
    }
    Navigator.pop(
      context,
      GarmentItem(
        id: widget.initial?.id,
        name: name,
        type: _type,
        colorways: _colorways,
        isFeatured: _isFeatured,
      ),
    );
  }
}

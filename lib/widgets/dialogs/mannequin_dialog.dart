import 'package:flutter/material.dart';
import '../../models/garment_item.dart';
import '../../models/mannequin_look.dart';
import '../../models/color_variant.dart';
import '../../theme/app_theme.dart';
import '../painters/mannequin_painter.dart';
import 'color_picker_dialog.dart';

/// Dialog to configure the Mannequin Look for a section.
class MannequinDialog extends StatefulWidget {
  final MannequinLook? initial;
  final List<GarmentItem> availableGarments;

  const MannequinDialog({
    super.key,
    this.initial,
    required this.availableGarments,
  });

  @override
  State<MannequinDialog> createState() => _MannequinDialogState();
}

class _MannequinDialogState extends State<MannequinDialog> {
  late List<MannequinItem> _items;

  @override
  void initState() {
    super.initState();
    _items = widget.initial?.items.toList() ?? [];
  }

  Future<void> _addItem() async {
    final result = await showDialog<MannequinItem>(
      context: context,
      builder: (_) => _AddMannequinItemDialog(
        availableGarments: widget.availableGarments,
      ),
    );
    if (result != null) setState(() => _items.add(result));
  }

  Future<void> _editItem(int index) async {
    final result = await showDialog<MannequinItem>(
      context: context,
      builder: (_) => _AddMannequinItemDialog(
        availableGarments: widget.availableGarments,
        initial: _items[index],
      ),
    );
    if (result != null) setState(() => _items[index] = result);
  }

  void _removeItem(int index) {
    setState(() => _items.removeAt(index));
  }

  @override
  Widget build(BuildContext context) {
    final topColor = _items.isNotEmpty
        ? _items.first.colorVariant.color
        : const Color(0xFF90B8CC);
    final bottomColor =
        _items.length > 1 ? _items[1].colorVariant.color : const Color(0xFF1C1C1C);

    return AlertDialog(
      title: const Text('Mannequin Look'),
      content: SizedBox(
        width: 360,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Preview
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MannequinFigure(
                    topColor: topColor,
                    bottomColor: bottomColor,
                    width: 80,
                    height: 160,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'MANNEQUIN LOOK',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.accent,
                            letterSpacing: 0.6,
                          ),
                        ),
                        const SizedBox(height: 6),
                        ..._items.map((item) => Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: RichText(
                                text: TextSpan(
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: AppTheme.textPrimary,
                                  ),
                                  children: [
                                    TextSpan(
                                        text: '• ${item.productName} – '),
                                    TextSpan(
                                      text: item.colorVariant.name,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w800,
                                        color: AppTheme.accent,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )),
                      ],
                    ),
                  ),
                ],
              ),

              const Divider(height: 24),

              // Items list
              ReorderableListView(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                onReorder: (o, n) {
                  setState(() {
                    final item = _items.removeAt(o);
                    _items.insert(n > o ? n - 1 : n, item);
                  });
                },
                children: [
                  for (int i = 0; i < _items.length; i++)
                    ListTile(
                      key: ValueKey(i),
                      contentPadding: EdgeInsets.zero,
                      leading: Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: _items[i].colorVariant.color,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: AppTheme.outline),
                        ),
                      ),
                      title: Text(_items[i].productName,
                          style: const TextStyle(fontSize: 13)),
                      subtitle: Text(_items[i].colorVariant.name,
                          style: const TextStyle(
                              fontSize: 11, color: AppTheme.accent)),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit_outlined, size: 18),
                            onPressed: () => _editItem(i),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline,
                                size: 18, color: Colors.red),
                            onPressed: () => _removeItem(i),
                          ),
                          const Icon(Icons.drag_handle,
                              size: 18, color: AppTheme.textTertiary),
                        ],
                      ),
                    ),
                ],
              ),

              const SizedBox(height: 8),
              TextButton.icon(
                onPressed: _addItem,
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Add Item to Look'),
                style: TextButton.styleFrom(
                  foregroundColor: AppTheme.primary,
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, null),
          style: TextButton.styleFrom(foregroundColor: Colors.red),
          child: const Text('Remove Look'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, MannequinLook(items: _items)),
          child: const Text('Save'),
        ),
      ],
    );
  }
}

class _AddMannequinItemDialog extends StatefulWidget {
  final List<GarmentItem> availableGarments;
  final MannequinItem? initial;

  const _AddMannequinItemDialog({
    required this.availableGarments,
    this.initial,
  });

  @override
  State<_AddMannequinItemDialog> createState() =>
      _AddMannequinItemDialogState();
}

class _AddMannequinItemDialogState extends State<_AddMannequinItemDialog> {
  final _nameCtrl = TextEditingController();
  ColorVariant _color = ColorVariant.black;

  @override
  void initState() {
    super.initState();
    if (widget.initial != null) {
      _nameCtrl.text = widget.initial!.productName;
      _color = widget.initial!.colorVariant;
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Item to Look'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Quick-pick from section garments
          if (widget.availableGarments.isNotEmpty) ...[
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'QUICK PICK FROM SECTION',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.7,
                  color: AppTheme.textSecondary,
                ),
              ),
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: widget.availableGarments.map((g) {
                return ActionChip(
                  label: Text(g.name, style: const TextStyle(fontSize: 11)),
                  onPressed: () {
                    setState(() {
                      _nameCtrl.text = g.name;
                      if (g.colorways.isNotEmpty) _color = g.colorways.first;
                    });
                  },
                );
              }).toList(),
            ),
            const Divider(height: 20),
          ],

          // Custom name
          TextField(
            controller: _nameCtrl,
            decoration: const InputDecoration(
              labelText: 'Product Name',
              hintText: 'e.g. Smooth Spacer Hoodie',
            ),
            textCapitalization: TextCapitalization.words,
          ),
          const SizedBox(height: 12),

          // Color
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: _color.color,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: AppTheme.outline),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  _color.name,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              TextButton(
                onPressed: () async {
                  final cv = await showDialog<ColorVariant>(
                    context: context,
                    builder: (_) => ColorPickerDialog(initial: _color),
                  );
                  if (cv != null) setState(() => _color = cv);
                },
                child: const Text('Change'),
              ),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            final name = _nameCtrl.text.trim();
            if (name.isEmpty) return;
            Navigator.pop(
              context,
              MannequinItem(productName: name, colorVariant: _color),
            );
          },
          child: const Text('Add'),
        ),
      ],
    );
  }
}

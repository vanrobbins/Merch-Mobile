import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/wall_arm_template.dart';
import '../../models/display_section.dart';
import '../../models/garment_item.dart';
import '../../providers/projects_provider.dart';
import '../../theme/app_theme.dart';
import '../painters/garment_painter.dart';

// ── Manage arm templates ───────────────────────────────────────────────────────

/// Shows the list of wall arm templates and allows create/edit/delete.
class WallArmTemplatesScreen extends StatelessWidget {
  const WallArmTemplatesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.canvasBg,
      appBar: AppBar(title: const Text('Wall Arm Templates')),
      body: Consumer<ProjectsProvider>(
        builder: (context, provider, _) {
          final templates = provider.armTemplates;
          if (templates.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.space_bar_outlined,
                      size: 56, color: AppTheme.textTertiary),
                  const SizedBox(height: 16),
                  const Text('No arm templates yet',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary)),
                  const SizedBox(height: 8),
                  const Text('Templates define face-out, U-bar, and shelf arm\narrangements for quick wall setup.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 12, color: AppTheme.textSecondary)),
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    onPressed: () => _createTemplate(context),
                    icon: const Icon(Icons.add),
                    label: const Text('Create Template'),
                  ),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: templates.length,
            itemBuilder: (ctx, i) {
              final t = templates[i];
              return _TemplateCard(
                template: t,
                onEdit: () => _editTemplate(context, t),
                onDelete: () => provider.deleteArmTemplate(t.id),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _createTemplate(context),
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('New Template'),
      ),
    );
  }

  Future<void> _createTemplate(BuildContext context) async {
    final template = await showDialog<WallArmTemplate>(
      context: context,
      builder: (_) => const _EditArmTemplateDialog(),
    );
    if (template != null && context.mounted) {
      await context.read<ProjectsProvider>().saveArmTemplate(template);
    }
  }

  Future<void> _editTemplate(
      BuildContext context, WallArmTemplate template) async {
    final updated = await showDialog<WallArmTemplate>(
      context: context,
      builder: (_) => _EditArmTemplateDialog(initial: template),
    );
    if (updated != null && context.mounted) {
      await context.read<ProjectsProvider>().saveArmTemplate(updated);
    }
  }
}

class _TemplateCard extends StatelessWidget {
  final WallArmTemplate template;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _TemplateCard({
    required this.template,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppTheme.cardBg,
        border: Border.all(color: AppTheme.outline),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        title: Text(template.name,
            style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(
          '${template.arms.length} arms · ${template.faceOutArmCount} FO · '
          '${template.uBarArmCount} UB · ${template.shelfArmCount} shelves · '
          '${template.totalCapacity} total capacity',
          style:
              const TextStyle(fontSize: 11, color: AppTheme.textSecondary),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
                icon: const Icon(Icons.edit_outlined, size: 18),
                onPressed: onEdit),
            IconButton(
              icon: const Icon(Icons.delete_outline,
                  size: 18, color: Colors.red),
              onPressed: onDelete,
            ),
          ],
        ),
        leading: _ArmStrip(arms: template.arms),
      ),
    );
  }
}

/// Mini visual strip showing arm type color codes.
class _ArmStrip extends StatelessWidget {
  final List<WallArm> arms;
  const _ArmStrip({required this.arms});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 56,
      height: 56,
      child: Center(
        child: Wrap(
          spacing: 2,
          runSpacing: 2,
          children: arms.map((a) {
            Color c;
            switch (a.type) {
              case ArmType.faceOut:
                c = AppTheme.accent;
                break;
              case ArmType.uBar:
                c = AppTheme.primary;
                break;
              case ArmType.shelf2ft:
              case ArmType.shelf4ft:
                c = const Color(0xFFC8A870);
                break;
            }
            return Container(
              width: 10,
              height: 16,
              decoration: BoxDecoration(
                color: c,
                borderRadius: BorderRadius.circular(2),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

// ── Edit arm template dialog ───────────────────────────────────────────────────

class _EditArmTemplateDialog extends StatefulWidget {
  final WallArmTemplate? initial;
  const _EditArmTemplateDialog({this.initial});

  @override
  State<_EditArmTemplateDialog> createState() =>
      _EditArmTemplateDialogState();
}

class _EditArmTemplateDialogState extends State<_EditArmTemplateDialog> {
  final _nameCtrl = TextEditingController();
  List<WallArm> _arms = [];

  @override
  void initState() {
    super.initState();
    if (widget.initial != null) {
      _nameCtrl.text = widget.initial!.name;
      _arms = List.from(widget.initial!.arms);
    } else {
      // Default template: 4 face-out arms
      _arms = [
        const WallArm(type: ArmType.faceOut, capacity: 2),
        const WallArm(type: ArmType.faceOut, capacity: 2),
        const WallArm(type: ArmType.faceOut, capacity: 2),
        const WallArm(type: ArmType.faceOut, capacity: 2),
      ];
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  void _addArm(ArmType type) {
    setState(() {
      _arms.add(WallArm(type: type, capacity: type.defaultCapacity));
    });
  }

  void _removeArm(int index) {
    setState(() => _arms.removeAt(index));
  }

  void _changeCapacity(int index, int delta) {
    final arm = _arms[index];
    final newCap = (arm.capacity + delta).clamp(1, 20);
    setState(() => _arms[index] = arm.copyWith(capacity: newCap));
  }

  void _changeType(int index, ArmType type) {
    final arm = _arms[index];
    setState(() => _arms[index] =
        arm.copyWith(type: type, capacity: type.defaultCapacity));
  }

  @override
  Widget build(BuildContext context) {
    final totalCap = _arms.fold(0, (s, a) => s + a.capacity);

    return AlertDialog(
      title:
          Text(widget.initial == null ? 'New Arm Template' : 'Edit Template'),
      contentPadding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      content: SizedBox(
        width: 360,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameCtrl,
              decoration:
                  const InputDecoration(labelText: 'Template Name'),
            ),
            const SizedBox(height: 16),

            // Arm list
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 320),
              child: _arms.isEmpty
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Text('No arms yet. Add arms below.',
                            style: TextStyle(color: AppTheme.textSecondary)),
                      ),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      itemCount: _arms.length,
                      itemBuilder: (ctx, i) => _ArmRow(
                        index: i,
                        arm: _arms[i],
                        onRemove: () => _removeArm(i),
                        onCapacityChange: (d) => _changeCapacity(i, d),
                        onTypeChange: (t) => _changeType(i, t),
                      ),
                    ),
            ),

            const Divider(),

            // Add arm buttons
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 4),
              child: Text('ADD ARM',
                  style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.7,
                      color: AppTheme.textSecondary)),
            ),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              alignment: WrapAlignment.center,
              children: ArmType.values.map((t) {
                return ActionChip(
                  label: Text(t.displayName,
                      style: const TextStyle(fontSize: 12)),
                  avatar: const Icon(Icons.add, size: 14),
                  onPressed: () => _addArm(t),
                );
              }).toList(),
            ),
            const SizedBox(height: 8),

            // Summary
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                '${_arms.length} arms · ${_arms.where((a) => a.type == ArmType.faceOut).length} FO · '
                '${_arms.where((a) => a.type == ArmType.uBar).length} UB · '
                '${_arms.where((a) => a.type.isShelf).length} shelves · '
                '$totalCap total items',
                style: const TextStyle(
                    fontSize: 11, color: AppTheme.textSecondary),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _arms.isEmpty || _nameCtrl.text.trim().isEmpty
              ? null
              : () {
                  Navigator.pop(
                    context,
                    WallArmTemplate(
                      id: widget.initial?.id,
                      name: _nameCtrl.text.trim(),
                      arms: _arms,
                    ),
                  );
                },
          child: const Text('Save'),
        ),
      ],
    );
  }
}

class _ArmRow extends StatelessWidget {
  final int index;
  final WallArm arm;
  final VoidCallback onRemove;
  final void Function(int) onCapacityChange;
  final void Function(ArmType) onTypeChange;

  const _ArmRow({
    required this.index,
    required this.arm,
    required this.onRemove,
    required this.onCapacityChange,
    required this.onTypeChange,
  });

  @override
  Widget build(BuildContext context) {
    Color chipColor;
    switch (arm.type) {
      case ArmType.faceOut:
        chipColor = AppTheme.accent;
        break;
      case ArmType.uBar:
        chipColor = AppTheme.primary;
        break;
      case ArmType.shelf2ft:
      case ArmType.shelf4ft:
        chipColor = const Color(0xFFC8A870);
        break;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Text('${index + 1}.',
              style: const TextStyle(
                  fontSize: 12,
                  color: AppTheme.textSecondary,
                  fontWeight: FontWeight.w600)),
          const SizedBox(width: 8),

          // Type picker
          PopupMenuButton<ArmType>(
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: chipColor.withAlpha(30),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: chipColor),
              ),
              child: Text(arm.type.displayName,
                  style:
                      TextStyle(fontSize: 11, color: chipColor)),
            ),
            itemBuilder: (_) => ArmType.values
                .map((t) => PopupMenuItem(
                    value: t,
                    child: Text(t.displayName,
                        style: const TextStyle(fontSize: 13))))
                .toList(),
            onSelected: onTypeChange,
          ),

          const Spacer(),

          // Capacity stepper
          if (arm.type.isHanging) ...[
            const Text('×',
                style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
            const SizedBox(width: 4),
            _SmallBtn(icon: Icons.remove, onTap: () => onCapacityChange(-1)),
            Container(
              width: 28,
              alignment: Alignment.center,
              child: Text('${arm.capacity}',
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w700)),
            ),
            _SmallBtn(icon: Icons.add, onTap: () => onCapacityChange(1)),
            const SizedBox(width: 4),
          ] else ...[
            Text('${arm.type.widthFt}ft wide',
                style: const TextStyle(
                    fontSize: 11, color: AppTheme.textSecondary)),
            const SizedBox(width: 8),
          ],

          IconButton(
            icon: const Icon(Icons.close, size: 16, color: Colors.red),
            visualDensity: VisualDensity.compact,
            onPressed: onRemove,
          ),
        ],
      ),
    );
  }
}

class _SmallBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _SmallBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 22,
        height: 22,
        decoration: BoxDecoration(
          border: Border.all(color: AppTheme.outline),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Icon(icon, size: 14),
      ),
    );
  }
}

// ── Auto-fill dialog ───────────────────────────────────────────────────────────

/// Shown from within a wall section to pick template + garment and auto-fill.
class WallAutoFillDialog extends StatefulWidget {
  final DisplaySection section;
  final String projectId;

  const WallAutoFillDialog({
    super.key,
    required this.section,
    required this.projectId,
  });

  @override
  State<WallAutoFillDialog> createState() => _WallAutoFillDialogState();
}

class _WallAutoFillDialogState extends State<WallAutoFillDialog> {
  WallArmTemplate? _selectedTemplate;
  GarmentItem? _selectedGarment;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProjectsProvider>();
    final templates = provider.armTemplates;
    final garments = widget.section.garments;

    return AlertDialog(
      title: const Text('Auto-Fill Wall Arms'),
      contentPadding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      content: SizedBox(
        width: 340,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Color triangle note
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppTheme.accent.withAlpha(15),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: AppTheme.accent.withAlpha(60)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline,
                      size: 14, color: AppTheme.accent),
                  SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Colors are distributed in a triangle pattern: '
                      'same colorway repeats at both ends and midpoints for visual balance.',
                      style: TextStyle(
                          fontSize: 10.5, color: AppTheme.textPrimary),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Template picker
            const Text('ARM TEMPLATE',
                style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.7,
                    color: AppTheme.textSecondary)),
            const SizedBox(height: 8),

            if (templates.isEmpty)
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Text(
                  'No templates yet. Create one first.',
                  style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.accent,
                      decoration: TextDecoration.underline),
                ),
              )
            else
              ...templates.map((t) => RadioListTile<WallArmTemplate>(
                    value: t,
                    groupValue: _selectedTemplate,
                    onChanged: (v) =>
                        setState(() => _selectedTemplate = v),
                    title: Text(t.name,
                        style: const TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w600)),
                    subtitle: Text(
                      '${t.arms.length} arms · ${t.faceOutArmCount} FO · '
                      '${t.uBarArmCount} UB · ${t.shelfArmCount} shelves',
                      style: const TextStyle(
                          fontSize: 11, color: AppTheme.textSecondary),
                    ),
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    activeColor: AppTheme.accent,
                  )),

            const SizedBox(height: 16),

            // Garment picker
            const Text('PRODUCT TO FILL',
                style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.7,
                    color: AppTheme.textSecondary)),
            const SizedBox(height: 8),

            if (garments.isEmpty)
              const Text(
                'No products in this section. Add products first.',
                style:
                    TextStyle(fontSize: 12, color: AppTheme.textSecondary),
              )
            else
              ...garments.map((g) => RadioListTile<GarmentItem>(
                    value: g,
                    groupValue: _selectedGarment,
                    onChanged: (v) =>
                        setState(() => _selectedGarment = v),
                    title: Text(g.name,
                        style: const TextStyle(fontSize: 13)),
                    subtitle: _selectedGarment?.id == g.id
                        ? _ColorTrianglePreview(garment: g)
                        : Text(
                            '${g.colorways.length} colorway${g.colorways.length == 1 ? '' : 's'}',
                            style: const TextStyle(
                                fontSize: 11,
                                color: AppTheme.textSecondary),
                          ),
                    secondary: GarmentIllustration(
                      type: g.type,
                      color: g.colorways.isNotEmpty
                          ? g.colorways.first.color
                          : Colors.grey,
                      width: 32,
                      height: 32,
                    ),
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    activeColor: AppTheme.accent,
                  )),

            if (_selectedTemplate != null && _selectedGarment != null) ...[
              const SizedBox(height: 16),
              _FillPreview(
                  template: _selectedTemplate!,
                  garment: _selectedGarment!),
            ],

            const SizedBox(height: 12),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _selectedTemplate == null || _selectedGarment == null
              ? null
              : () async {
                  await context.read<ProjectsProvider>().applyArmTemplate(
                        widget.projectId,
                        widget.section.id,
                        _selectedTemplate!,
                        _selectedGarment!,
                      );
                  if (context.mounted) Navigator.pop(context);
                },
          child: const Text('Fill Arms'),
        ),
      ],
    );
  }
}

/// Preview of how colorways will be distributed across arms.
class _FillPreview extends StatelessWidget {
  final WallArmTemplate template;
  final GarmentItem garment;

  const _FillPreview({required this.template, required this.garment});

  @override
  Widget build(BuildContext context) {
    final cwIndices = List<int>.generate(garment.colorways.length, (i) => i);
    final assignments = template.autoFill(garment.id, cwIndices);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('PREVIEW',
            style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.7,
                color: AppTheme.textSecondary)),
        const SizedBox(height: 6),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: assignments.map((a) {
              final hasColor = garment.colorways.isNotEmpty;
              final cw = hasColor && a.colorwayIndex < garment.colorways.length
                  ? garment.colorways[a.colorwayIndex]
                  : null;
              return Padding(
                padding: const EdgeInsets.only(right: 6),
                child: Column(
                  children: [
                    Container(
                      width: 32,
                      height: 40,
                      decoration: BoxDecoration(
                        color: a.armType.isShelf
                            ? const Color(0xFFF0E8D0)
                            : (cw?.color ?? Colors.grey).withAlpha(30),
                        border: Border.all(
                          color: a.armType == ArmType.faceOut
                              ? AppTheme.accent
                              : a.armType == ArmType.uBar
                                  ? AppTheme.primary
                                  : const Color(0xFFC8A870),
                          width: 1.5,
                        ),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: a.armType.isShelf
                          ? const Icon(Icons.table_bar,
                              size: 16, color: Color(0xFFC8A870))
                          : cw != null
                              ? GarmentIllustration(
                                  type: garment.type,
                                  color: cw.color,
                                  width: 28,
                                  height: 36,
                                )
                              : const SizedBox.shrink(),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      cw?.name ?? a.armType.shortName,
                      style: const TextStyle(
                          fontSize: 7,
                          color: AppTheme.textSecondary,
                          fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Total: ${assignments.fold(0, (s, a) => s + a.capacity)} units',
          style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppTheme.textSecondary),
        ),
      ],
    );
  }
}

/// Shows the triangle color distribution as a small swatch strip.
class _ColorTrianglePreview extends StatelessWidget {
  final GarmentItem garment;
  const _ColorTrianglePreview({required this.garment});

  @override
  Widget build(BuildContext context) {
    if (garment.colorways.isEmpty) return const SizedBox.shrink();
    // Show mirror pattern for 4 sample arms
    const sampleArms = 6;
    final cwCount = garment.colorways.length;
    final indices = <int>[];
    for (int i = 0; i < sampleArms; i++) {
      final cwIdx = WallArmTemplate.triangleColorwayIndex(
          i, sampleArms, cwCount, List.generate(cwCount, (j) => j));
      indices.add(cwIdx);
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: indices.map((idx) {
        final cw = garment.colorways[idx];
        return Padding(
          padding: const EdgeInsets.only(right: 3),
          child: Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: cw.color,
              borderRadius: BorderRadius.circular(2),
              border: Border.all(color: AppTheme.outline),
            ),
          ),
        );
      }).toList(),
    );
  }
}

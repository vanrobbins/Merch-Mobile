import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/schematic_project.dart';
import '../models/display_section.dart';
import '../models/garment_item.dart';
import '../models/mannequin_look.dart';
import '../models/decorative_element.dart';
import '../models/color_variant.dart';
import '../providers/projects_provider.dart';
import '../providers/editor_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/sections/table_section_widget.dart';
import '../widgets/sections/wall_section_widget.dart';
import '../widgets/sections/rack_section_widget.dart';
import '../widgets/painters/plant_painter.dart';
import '../widgets/painters/mannequin_painter.dart';
import '../widgets/dialogs/add_section_dialog.dart';
import '../widgets/dialogs/add_garment_dialog.dart';
import '../widgets/dialogs/mannequin_dialog.dart';
import '../widgets/dialogs/auto_layout_dialog.dart';
import '../widgets/dialogs/color_picker_dialog.dart';
import '../widgets/dialogs/wall_arm_template_dialog.dart';
import 'export_screen.dart';
import 'store_layout_screen.dart';

class EditorScreen extends StatelessWidget {
  final String projectId;

  const EditorScreen({super.key, required this.projectId});

  @override
  Widget build(BuildContext context) {
    return Consumer<ProjectsProvider>(
      builder: (context, provider, _) {
        final project = provider.getProject(projectId);
        if (project == null) {
          return Scaffold(
            appBar: AppBar(),
            body: const Center(child: Text('Project not found')),
          );
        }
        return _EditorView(project: project);
      },
    );
  }
}

class _EditorView extends StatefulWidget {
  final SchematicProject project;

  const _EditorView({required this.project});

  @override
  State<_EditorView> createState() => _EditorViewState();
}

class _EditorViewState extends State<_EditorView> {
  bool _isEditing = true;

  SchematicProject get _project => widget.project;

  ProjectsProvider get _provider =>
      context.read<ProjectsProvider>();

  // ── Sections ──────────────────────────────────────────────────────────────

  Future<void> _addSection() async {
    final section = await showDialog<DisplaySection>(
      context: context,
      builder: (_) => const AddSectionDialog(),
    );
    if (section != null) await _provider.addSection(_project.id, section);
  }

  Future<void> _editSection(DisplaySection section) async {
    final updated = await showDialog<DisplaySection>(
      context: context,
      builder: (_) => AddSectionDialog(initial: section),
    );
    if (updated != null) {
      await _provider.updateSection(_project.id, updated);
    }
  }

  Future<void> _deleteSection(DisplaySection section) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Section'),
        content: Text('Delete "${section.title}"?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await _provider.deleteSection(_project.id, section.id);
    }
  }

  // ── Garments ──────────────────────────────────────────────────────────────

  Future<void> _addGarment(DisplaySection section) async {
    final garment = await showDialog<GarmentItem>(
      context: context,
      builder: (_) => const AddGarmentDialog(),
    );
    if (garment != null) {
      await _provider.addGarment(_project.id, section.id, garment);
    }
  }

  Future<void> _editGarment(DisplaySection section, GarmentItem garment) async {
    final result = await showDialog<GarmentItem>(
      context: context,
      builder: (_) => AddGarmentDialog(initial: garment),
    );
    if (result != null) {
      await _provider.updateGarment(_project.id, section.id, result);
    }
  }

  // ── Mannequin ─────────────────────────────────────────────────────────────

  Future<void> _editMannequin(DisplaySection section) async {
    final look = await showDialog<MannequinLook?>(
      context: context,
      builder: (_) => MannequinDialog(
        initial: section.mannequinLook,
        availableGarments: section.garments,
      ),
    );
    // null means remove, undefined means cancelled
    if (look != null || (look == null && section.mannequinLook != null)) {
      await _provider.setMannequinLook(_project.id, section.id, look);
    }
  }

  // ── Decorative elements ───────────────────────────────────────────────────

  Future<void> _addDecorativeElement(DisplaySection section) async {
    final element = await showDialog<DecorativeElement>(
      context: context,
      builder: (_) => const _DecorativeElementDialog(),
    );
    if (element != null) {
      final updated = section.copyWith(
        decorativeElements: [...section.decorativeElements, element],
      );
      await _provider.updateSection(_project.id, updated);
    }
  }

  Future<void> _removeDecorativeElement(
      DisplaySection section, String elementId) async {
    final updated = section.copyWith(
      decorativeElements: section.decorativeElements
          .where((e) => e.id != elementId)
          .toList(),
    );
    await _provider.updateSection(_project.id, updated);
  }

  // ── Auto-layout ───────────────────────────────────────────────────────────

  Future<void> _autoLayout() async {
    final products = await showDialog<List<GarmentItem>>(
      context: context,
      builder: (_) => const AutoLayoutDialog(),
    );
    if (products == null || products.isEmpty) return;

    final editor = context.read<EditorProvider>();
    final sections = editor.generateAutoLayout(products);
    for (final s in sections) {
      await _provider.addSection(_project.id, s);
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              '${sections.length} section${sections.length == 1 ? '' : 's'} generated'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  // ── Wall arm fill ─────────────────────────────────────────────────────────

  Future<void> _fillWallArms(DisplaySection section) async {
    await showDialog(
      context: context,
      builder: (_) => WallAutoFillDialog(
        section: section,
        projectId: _project.id,
      ),
    );
  }

  // ── Store layout nav ──────────────────────────────────────────────────────

  void _openStoreLayout() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => StoreLayoutScreen(projectId: _project.id),
      ),
    );
  }

  void _openArmTemplates() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const WallArmTemplatesScreen(),
      ),
    );
  }

  // ── Export ────────────────────────────────────────────────────────────────

  void _exportPdf() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ExportScreen(project: _project),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final sections = _project.sections;

    return Scaffold(
      backgroundColor: AppTheme.canvasBg,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_project.name),
            if (_project.storeName != null)
              Text(
                _project.storeName!,
                style: const TextStyle(
                    fontSize: 12, color: AppTheme.textSecondary),
              ),
          ],
        ),
        actions: [
          // Toggle edit mode
          IconButton(
            icon: Icon(_isEditing ? Icons.visibility : Icons.edit_outlined),
            tooltip: _isEditing ? 'Preview' : 'Edit',
            onPressed: () => setState(() => _isEditing = !_isEditing),
          ),
          // Store layout floor plan
          IconButton(
            icon: const Icon(Icons.map_outlined),
            tooltip: 'Store Layout',
            onPressed: _openStoreLayout,
          ),
          // More menu
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (v) {
              if (v == 'auto') _autoLayout();
              if (v == 'arms') _openArmTemplates();
              if (v == 'pdf') _exportPdf();
            },
            itemBuilder: (_) => const [
              PopupMenuItem(
                value: 'auto',
                child: ListTile(
                  leading: Icon(Icons.auto_awesome, size: 18),
                  title: Text('Auto-Layout'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              PopupMenuItem(
                value: 'arms',
                child: ListTile(
                  leading: Icon(Icons.space_bar_outlined, size: 18),
                  title: Text('Arm Templates'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              PopupMenuItem(
                value: 'pdf',
                child: ListTile(
                  leading: Icon(Icons.picture_as_pdf_outlined, size: 18),
                  title: Text('Export PDF'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ],
      ),
      body: sections.isEmpty
          ? _EmptyProjectState(
              onAddSection: _addSection,
              onAutoLayout: _autoLayout,
            )
          : ReorderableListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: sections.length,
              onReorder: (o, n) =>
                  _provider.reorderSections(_project.id, o, n),
              itemBuilder: (ctx, i) {
                final section = sections[i];
                return _SectionCard(
                  key: ValueKey(section.id),
                  section: section,
                  isEditing: _isEditing,
                  onEdit: () => _editSection(section),
                  onDelete: () => _deleteSection(section),
                  onAddGarment: () => _addGarment(section),
                  onGarmentTap: (g) => _editGarment(section, g),
                  onEditMannequin: () => _editMannequin(section),
                  onAddDecor: () => _addDecorativeElement(section),
                  onRemoveDecor: (id) =>
                      _removeDecorativeElement(section, id),
                  onFillArms: section.type == SectionType.perimeter
                      ? () => _fillWallArms(section)
                      : null,
                );
              },
            ),
      floatingActionButton: _isEditing
          ? FloatingActionButton.extended(
              onPressed: _addSection,
              backgroundColor: AppTheme.primary,
              foregroundColor: Colors.white,
              icon: const Icon(Icons.add),
              label: const Text('Add Section'),
            )
          : null,
    );
  }
}

// ── Section card wrapper ──────────────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  final DisplaySection section;
  final bool isEditing;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onAddGarment;
  final void Function(GarmentItem) onGarmentTap;
  final VoidCallback onEditMannequin;
  final VoidCallback onAddDecor;
  final void Function(String) onRemoveDecor;
  final VoidCallback? onFillArms;

  const _SectionCard({
    super.key,
    required this.section,
    required this.isEditing,
    required this.onEdit,
    required this.onDelete,
    required this.onAddGarment,
    required this.onGarmentTap,
    required this.onEditMannequin,
    required this.onAddDecor,
    required this.onRemoveDecor,
    this.onFillArms,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header
          _SectionHeader(
            section: section,
            isEditing: isEditing,
            onEdit: onEdit,
            onDelete: onDelete,
            onAddGarment: onAddGarment,
            onEditMannequin: onEditMannequin,
            onAddDecor: onAddDecor,
          ),

          // Section body
          _buildBody(),

          // Decorative elements row
          if (section.decorativeElements.isNotEmpty)
            _DecorRow(
              elements: section.decorativeElements,
              isEditing: isEditing,
              onRemove: onRemoveDecor,
            ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    return switch (section.type) {
      SectionType.table => TableSectionWidget(
          section: section,
          onGarmentTap: onGarmentTap,
          onAddGarment: onAddGarment,
          isEditing: isEditing,
        ),
      SectionType.perimeter => WallSectionWidget(
          section: section,
          onGarmentTap: onGarmentTap,
          onAddGarment: onAddGarment,
          onFillArms: onFillArms,
          isEditing: isEditing,
        ),
      SectionType.floorRack => RackSectionWidget(
          section: section,
          onGarmentTap: onGarmentTap,
          onAddGarment: onAddGarment,
          isEditing: isEditing,
        ),
    };
  }
}

// ── Section header ────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final DisplaySection section;
  final bool isEditing;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onAddGarment;
  final VoidCallback onEditMannequin;
  final VoidCallback onAddDecor;

  const _SectionHeader({
    required this.section,
    required this.isEditing,
    required this.onEdit,
    required this.onDelete,
    required this.onAddGarment,
    required this.onEditMannequin,
    required this.onAddDecor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          // Drag handle (only in edit mode)
          if (isEditing)
            const Icon(Icons.drag_indicator,
                size: 18, color: AppTheme.textTertiary),
          if (isEditing) const SizedBox(width: 4),

          Text(section.type.icon, style: const TextStyle(fontSize: 14)),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              section.title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.2,
                color: AppTheme.textPrimary,
              ),
            ),
          ),

          if (isEditing) ...[
            // Mannequin look
            IconButton(
              icon: Icon(
                section.mannequinLook != null
                    ? Icons.person
                    : Icons.person_outline,
                size: 18,
                color: section.mannequinLook != null
                    ? AppTheme.accent
                    : AppTheme.textTertiary,
              ),
              tooltip: 'Mannequin Look',
              onPressed: onEditMannequin,
              visualDensity: VisualDensity.compact,
            ),

            // Decorative elements
            IconButton(
              icon: const Icon(Icons.nature, size: 18,
                  color: AppTheme.textTertiary),
              tooltip: 'Add Plant / Mannequin',
              onPressed: onAddDecor,
              visualDensity: VisualDensity.compact,
            ),

            // More menu
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, size: 18,
                  color: AppTheme.textTertiary),
              visualDensity: VisualDensity.compact,
              onSelected: (v) {
                if (v == 'edit') onEdit();
                if (v == 'add') onAddGarment();
                if (v == 'delete') onDelete();
              },
              itemBuilder: (_) => [
                const PopupMenuItem(
                    value: 'edit',
                    child: ListTile(
                      leading: Icon(Icons.edit_outlined, size: 18),
                      title: Text('Edit Section'),
                      contentPadding: EdgeInsets.zero,
                    )),
                const PopupMenuItem(
                    value: 'add',
                    child: ListTile(
                      leading: Icon(Icons.add, size: 18),
                      title: Text('Add Product'),
                      contentPadding: EdgeInsets.zero,
                    )),
                const PopupMenuItem(
                    value: 'delete',
                    child: ListTile(
                      leading:
                          Icon(Icons.delete_outline, size: 18, color: Colors.red),
                      title: Text('Delete Section',
                          style: TextStyle(color: Colors.red)),
                      contentPadding: EdgeInsets.zero,
                    )),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

// ── Decorative elements row ───────────────────────────────────────────────────

class _DecorRow extends StatelessWidget {
  final List<DecorativeElement> elements;
  final bool isEditing;
  final void Function(String) onRemove;

  const _DecorRow({
    required this.elements,
    required this.isEditing,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.surface,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: elements.map((e) {
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Column(
                  children: [
                    if (e.type == DecorElementType.plant)
                      PlantWidget(
                        style: PlantStyle.leafy,
                        width: 48,
                        height: 64,
                      )
                    else if (e.type == DecorElementType.halfMannequin)
                      HalfMannequinFigure(
                        topColor: e.outfitTopColor?.color ??
                            const Color(0xFF90B8CC),
                        width: 40,
                        height: 72,
                      )
                    else if (e.type == DecorElementType.braMannequin)
                      BraMannequinFigure(
                        braColor: e.outfitTopColor?.color ??
                            const Color(0xFF90B8CC),
                        width: 38,
                        height: 62,
                      )
                    else
                      MannequinFigure(
                        topColor: e.outfitTopColor?.color ??
                            const Color(0xFF90B8CC),
                        bottomColor: e.outfitBottomColor?.color ??
                            const Color(0xFF1C1C1C),
                        width: 40,
                        height: 80,
                      ),
                    if (e.label != null)
                      Text(
                        e.label!,
                        style: const TextStyle(
                            fontSize: 7, color: AppTheme.textSecondary),
                      ),
                  ],
                ),
                if (isEditing)
                  Positioned(
                    top: -6,
                    right: -6,
                    child: GestureDetector(
                      onTap: () => onRemove(e.id),
                      child: Container(
                        width: 18,
                        height: 18,
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.close,
                            size: 12, color: Colors.white),
                      ),
                    ),
                  ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ── Decorative element picker dialog ─────────────────────────────────────────

class _DecorativeElementDialog extends StatefulWidget {
  const _DecorativeElementDialog();

  @override
  State<_DecorativeElementDialog> createState() =>
      _DecorativeElementDialogState();
}

class _DecorativeElementDialogState extends State<_DecorativeElementDialog> {
  DecorElementType _type = DecorElementType.plant;
  PlantStyle _plantStyle = PlantStyle.leafy;
  ColorVariant _topColor = ColorVariant.foam;
  ColorVariant _bottomColor = ColorVariant.black;
  bool _onShelf = false;
  final _labelCtrl = TextEditingController();

  @override
  void dispose() {
    _labelCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Decorative Element'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Type selector — shown as a scrollable chip row
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: DecorElementType.values.map((t) {
                  final selected = _type == t;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text('${t.icon} ${t.displayName}',
                          style: const TextStyle(fontSize: 11)),
                      selected: selected,
                      onSelected: (_) => setState(() {
                        _type = t;
                        _onShelf = t.isShelfForm;
                      }),
                      selectedColor: AppTheme.primary,
                      labelStyle:
                          TextStyle(color: selected ? Colors.white : null),
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 16),

            // Preview
            Center(
              child: _type == DecorElementType.plant
                  ? PlantWidget(style: _plantStyle, width: 70, height: 90)
                  : _type == DecorElementType.halfMannequin
                      ? HalfMannequinFigure(
                          topColor: _topColor.color, width: 56, height: 88)
                      : _type == DecorElementType.braMannequin
                          ? BraMannequinFigure(
                              braColor: _topColor.color,
                              width: 56,
                              height: 80)
                          : MannequinFigure(
                              topColor: _topColor.color,
                              bottomColor: _bottomColor.color,
                              width: 60,
                              height: 120,
                            ),
            ),

            const SizedBox(height: 12),

            // Plant options
            if (_type == DecorElementType.plant) ...[
              const Text('PLANT STYLE',
                  style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.7,
                      color: AppTheme.textSecondary)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: PlantStyle.values.map((s) {
                  return ChoiceChip(
                    label: Text(s.displayName,
                        style: const TextStyle(fontSize: 11)),
                    selected: _plantStyle == s,
                    onSelected: (_) => setState(() => _plantStyle = s),
                    selectedColor: AppTheme.primary,
                    labelStyle: TextStyle(
                      color: _plantStyle == s ? Colors.white : null,
                    ),
                  );
                }).toList(),
              ),
            ],

            // Color pickers
            if (_type != DecorElementType.plant) ...[
              const Text('OUTFIT COLOR',
                  style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.7,
                      color: AppTheme.textSecondary)),
              const SizedBox(height: 8),
              _ColorRow(
                label: _type == DecorElementType.braMannequin
                    ? 'Bra'
                    : 'Top',
                color: _topColor,
                onPick: () async {
                  final cv = await showDialog<ColorVariant>(
                    context: context,
                    builder: (_) =>
                        ColorPickerDialog(initial: _topColor),
                  );
                  if (cv != null) setState(() => _topColor = cv);
                },
              ),
              if (_type == DecorElementType.mannequin) ...[
                const SizedBox(height: 8),
                _ColorRow(
                  label: 'Bottom',
                  color: _bottomColor,
                  onPick: () async {
                    final cv = await showDialog<ColorVariant>(
                      context: context,
                      builder: (_) =>
                          ColorPickerDialog(initial: _bottomColor),
                    );
                    if (cv != null) setState(() => _bottomColor = cv);
                  },
                ),
              ],
            ],

            // Shelf placement toggle for half/bra forms
            if (_type.isShelfForm) ...[
              const SizedBox(height: 10),
              SwitchListTile(
                value: _onShelf,
                onChanged: (v) => setState(() => _onShelf = v),
                title: const Text('Place on shelf',
                    style: TextStyle(fontSize: 13)),
                subtitle: const Text(
                  'Renders the form on the wall top shelf',
                  style: TextStyle(fontSize: 11, color: AppTheme.textSecondary),
                ),
                contentPadding: EdgeInsets.zero,
                activeColor: AppTheme.accent,
              ),
            ],

            const SizedBox(height: 12),
            TextField(
              controller: _labelCtrl,
              decoration: const InputDecoration(
                labelText: 'Label (optional)',
                hintText: 'e.g. Prop 1',
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
            final label = _labelCtrl.text.trim().isEmpty
                ? null
                : _labelCtrl.text.trim();
            late final DecorativeElement result;
            if (_type == DecorElementType.plant) {
              result = DecorativeElement.plant(label: label);
            } else if (_type == DecorElementType.halfMannequin) {
              result = DecorativeElement.halfMannequin(
                topColor: _topColor,
                label: label,
                onShelf: _onShelf,
              );
            } else if (_type == DecorElementType.braMannequin) {
              result = DecorativeElement.braMannequin(
                topColor: _topColor,
                label: label,
                onShelf: _onShelf,
              );
            } else {
              result = DecorativeElement.mannequin(
                topColor: _topColor,
                bottomColor: _bottomColor,
                label: label,
              );
            }
            Navigator.pop(context, result);
          },
          child: const Text('Add'),
        ),
      ],
    );
  }
}

class _ColorRow extends StatelessWidget {
  final String label;
  final ColorVariant color;
  final VoidCallback onPick;

  const _ColorRow({
    required this.label,
    required this.color,
    required this.onPick,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 48,
          child: Text(label,
              style: const TextStyle(
                  fontSize: 12, color: AppTheme.textSecondary)),
        ),
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: color.color,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: AppTheme.outline),
          ),
        ),
        const SizedBox(width: 8),
        Text(color.name,
            style: const TextStyle(
                fontSize: 12, fontWeight: FontWeight.w500)),
        const Spacer(),
        TextButton(
          onPressed: onPick,
          child: const Text('Change'),
        ),
      ],
    );
  }
}

// ── Empty state ───────────────────────────────────────────────────────────────

class _EmptyProjectState extends StatelessWidget {
  final VoidCallback onAddSection;
  final VoidCallback onAutoLayout;

  const _EmptyProjectState({
    required this.onAddSection,
    required this.onAutoLayout,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.view_quilt_outlined,
              size: 56, color: AppTheme.textTertiary),
          const SizedBox(height: 16),
          const Text(
            'Empty schematic',
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary),
          ),
          const SizedBox(height: 8),
          const Text(
            'Add sections manually or use Auto-Layout',
            style: TextStyle(fontSize: 13, color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              OutlinedButton.icon(
                onPressed: onAddSection,
                icon: const Icon(Icons.add),
                label: const Text('Add Section'),
              ),
              const SizedBox(width: 12),
              FilledButton.icon(
                onPressed: onAutoLayout,
                icon: const Icon(Icons.auto_awesome, size: 16),
                label: const Text('Auto-Layout'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

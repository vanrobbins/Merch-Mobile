import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/schematic_project.dart';
import '../models/display_section.dart';
import '../models/store_zone.dart';
import '../models/store_template.dart';
import '../providers/projects_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/layout/floor_plan_painter.dart';
import '../widgets/dialogs/add_section_dialog.dart';
import 'editor_screen.dart';

class StoreLayoutScreen extends StatefulWidget {
  final String projectId;

  const StoreLayoutScreen({super.key, required this.projectId});

  @override
  State<StoreLayoutScreen> createState() => _StoreLayoutScreenState();
}

class _StoreLayoutScreenState extends State<StoreLayoutScreen> {
  String? _selectedSectionId;
  String? _selectedZoneId;
  bool _editingPolygon = false;
  bool _placingSection = false; // drag-to-place mode for floor sections
  DisplaySection? _pendingSection; // section waiting to be placed

  // ── Helpers ───────────────────────────────────────────────────────────────

  ProjectsProvider get _provider => context.read<ProjectsProvider>();

  SchematicProject? get _project =>
      context.read<ProjectsProvider>().getProject(widget.projectId);

  Size get _canvasSize => const Size(800, 600);

  Rect get _floorRect => FloorPlanPainter.floorRect(_canvasSize);

  // ── Section selection and editing ─────────────────────────────────────────

  void _onCanvasTap(Offset localPos, SchematicProject project) {
    if (_placingSection && _pendingSection != null) {
      _placeFloorSection(localPos, project);
      return;
    }

    final painter = FloorPlanPainter(project: project);
    final hit = painter.hitTest(localPos, _canvasSize);
    setState(() {
      _selectedSectionId = hit;
      _selectedZoneId = null;
    });
    if (hit != null) {
      _showSectionActions(
          project.sections.firstWhere((s) => s.id == hit), project);
    }
  }

  void _placeFloorSection(Offset pos, SchematicProject project) {
    final norm = FloorPlanPainter.canvasToNorm(pos, _floorRect);
    final placed = _pendingSection!.copyWith(
      layoutX: norm.x,
      layoutY: norm.y,
    );
    _provider.addSection(project.id, placed);
    setState(() {
      _placingSection = false;
      _pendingSection = null;
    });
  }

  void _onCanvasPanUpdate(DragUpdateDetails d, SchematicProject project) {
    if (_selectedSectionId == null) return;
    final section =
        project.sections.firstWhere((s) => s.id == _selectedSectionId);
    if (section.type == SectionType.perimeter) {
      // Drag along the assigned wall
      _dragWallSection(section, d.delta, project);
    } else {
      // Drag freely on floor
      final fr = _floorRect;
      final painter = FloorPlanPainter(project: project);
      final currentRect = painter.hitTest(
          Offset(_floorRect.left + section.layoutX * _floorRect.width,
              _floorRect.top + section.layoutY * _floorRect.height),
          _canvasSize);

      final newX = (section.layoutX + d.delta.dx / fr.width).clamp(0.0, 1.0);
      final newY = (section.layoutY + d.delta.dy / fr.height).clamp(0.0, 1.0);
      _provider.setSectionLayout(
        project.id,
        section.id,
        layoutX: newX,
        layoutY: newY,
      );
    }
  }

  void _dragWallSection(
      DisplaySection section, Offset delta, SchematicProject project) {
    final fr = _floorRect;
    double dp = 0;
    switch (section.wallSide) {
      case WallSide.north:
      case WallSide.south:
        dp = delta.dx / fr.width;
      case WallSide.east:
      case WallSide.west:
        dp = delta.dy / fr.height;
      case WallSide.none:
        return;
    }
    final newPos = (section.layoutPosition + dp).clamp(0.0, 0.9);
    _provider.setSectionLayout(project.id, section.id,
        layoutPosition: newPos);
  }

  // ── Section action sheet ──────────────────────────────────────────────────

  void _showSectionActions(DisplaySection section, SchematicProject project) {
    showModalBottomSheet(
      context: context,
      builder: (_) => _SectionActionSheet(
        section: section,
        project: project,
        onOpenDesign: () {
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => EditorScreen(projectId: project.id),
            ),
          );
        },
        onEditSection: () async {
          Navigator.pop(context);
          final updated = await showDialog<DisplaySection>(
            context: context,
            builder: (_) => AddSectionDialog(initial: section),
          );
          if (updated != null) {
            await _provider.updateSection(project.id, updated);
          }
        },
        onAssignWall: (side) async {
          Navigator.pop(context);
          await _provider.setSectionLayout(project.id, section.id,
              wallSide: side);
        },
        onAssignZone: (zoneId) async {
          Navigator.pop(context);
          await _provider.setSectionLayout(project.id, section.id,
              zoneId: zoneId,
              clearZone: zoneId == null);
        },
        onDelete: () async {
          Navigator.pop(context);
          await _provider.deleteSection(project.id, section.id);
          setState(() => _selectedSectionId = null);
        },
      ),
    );
  }

  // ── Zone management ───────────────────────────────────────────────────────

  Future<void> _addZone(SchematicProject project) async {
    final result = await showDialog<StoreZone>(
      context: context,
      builder: (_) => _ZoneDialog(existingZones: project.zones),
    );
    if (result != null) await _provider.addZone(project.id, result);
  }

  Future<void> _editZone(SchematicProject project, StoreZone zone) async {
    final result = await showDialog<StoreZone>(
      context: context,
      builder: (_) =>
          _ZoneDialog(initial: zone, existingZones: project.zones),
    );
    if (result != null) await _provider.updateZone(project.id, result);
  }

  Future<void> _deleteZone(SchematicProject project, String zoneId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Zone'),
        content:
            const Text('All sections in this zone will become unassigned.'),
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
    if (confirmed == true) await _provider.deleteZone(project.id, zoneId);
  }

  // ── Store dimensions ──────────────────────────────────────────────────────

  Future<void> _editStoreDimensions(SchematicProject project) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (_) => _StoreDimensionsDialog(project: project),
    );
    if (result != null) {
      await _provider.updateStoreDimensions(
        project.id,
        widthFt: result['width'] as double,
        depthFt: result['depth'] as double,
        polygon: result['polygon'] as List<StorePoint>?,
      );
    }
  }

  // ── Template management ───────────────────────────────────────────────────

  Future<void> _saveAsTemplate(SchematicProject project) async {
    final nameCtrl = TextEditingController(
        text: '${project.name} Template');
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Save as Template'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Saves the store shape, zones, and section layout (without garments) as a reusable template.',
              style: TextStyle(fontSize: 13, color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(labelText: 'Template Name'),
              autofocus: true,
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
          FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Save')),
        ],
      ),
    );
    if (confirmed == true) {
      final template = StoreTemplate.fromProject(
        nameCtrl.text.trim(),
        projectId: project.id,
        widthFt: project.storeWidthFt,
        depthFt: project.storeDepthFt,
        zones: project.zones,
        sections: project.sections,
      );
      await _provider.saveTemplate(template);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Template saved'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _loadTemplate(SchematicProject project) async {
    final templates = _provider.templates;
    if (templates.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No templates saved yet'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final chosen = await showDialog<StoreTemplate>(
      context: context,
      builder: (_) => _TemplatePickerDialog(templates: templates),
    );
    if (chosen != null) {
      await _provider.applyTemplate(project.id, chosen);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Applied template "${chosen.name}"'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  // ── Add section from layout screen ───────────────────────────────────────

  Future<void> _addSection(SchematicProject project) async {
    final section = await showDialog<DisplaySection>(
      context: context,
      builder: (_) => const AddSectionDialog(),
    );
    if (section == null) return;

    if (section.type == SectionType.perimeter) {
      // Ask which wall
      final side = await showDialog<WallSide>(
        context: context,
        builder: (_) => const _WallSideDialog(),
      );
      if (side != null) {
        await _provider.addSection(
          project.id,
          section.copyWith(wallSide: side),
        );
      }
    } else {
      // Place on floor by tapping
      setState(() {
        _placingSection = true;
        _pendingSection = section;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tap on the floor to place this section'),
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 4),
        ),
      );
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Consumer<ProjectsProvider>(
      builder: (context, provider, _) {
        final project = provider.getProject(widget.projectId);
        if (project == null) {
          return Scaffold(appBar: AppBar(), body: const Center(child: Text('Not found')));
        }

        return Scaffold(
          backgroundColor: AppTheme.canvasBg,
          appBar: AppBar(
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('STORE LAYOUT'),
                Text(
                  '${project.storeWidthFt.toStringAsFixed(0)}FT × ${project.storeDepthFt.toStringAsFixed(0)}FT',
                  style: const TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                    color: AppTheme.textTertiary,
                  ),
                ),
              ],
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.straighten_outlined),
                tooltip: 'Store Dimensions',
                onPressed: () => _editStoreDimensions(project),
              ),
              IconButton(
                icon: const Icon(Icons.bookmark_add_outlined),
                tooltip: 'Save as Template',
                onPressed: () => _saveAsTemplate(project),
              ),
              PopupMenuButton<String>(
                onSelected: (v) {
                  if (v == 'load_template') _loadTemplate(project);
                },
                itemBuilder: (_) => [
                  const PopupMenuItem(
                    value: 'load_template',
                    child: ListTile(
                      leading: Icon(Icons.bookmark_outlined),
                      title: Text('Load Template'),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ],
              ),
            ],
          ),
          body: Column(
            children: [
              // ── Zone strip ────────────────────────────────────────────────
              _ZoneStrip(
                project: project,
                selectedZoneId: _selectedZoneId,
                onAdd: () => _addZone(project),
                onTap: (z) =>
                    setState(() => _selectedZoneId =
                        _selectedZoneId == z.id ? null : z.id),
                onEdit: (z) => _editZone(project, z),
                onDelete: (z) => _deleteZone(project, z.id),
              ),

              // ── Canvas ────────────────────────────────────────────────────
              Expanded(
                child: InteractiveViewer(
                  minScale: 0.4,
                  maxScale: 4.0,
                  child: Center(
                    child: GestureDetector(
                      onTapDown: (d) =>
                          _onCanvasTap(d.localPosition, project),
                      onPanUpdate: (d) =>
                          _onCanvasPanUpdate(d, project),
                      child: CustomPaint(
                        size: _canvasSize,
                        painter: FloorPlanPainter(
                          project: project,
                          selectedSectionId: _selectedSectionId,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // ── Bottom section list for selected zone ─────────────────────
              if (_selectedZoneId != null)
                _ZoneSectionList(
                  project: project,
                  zoneId: _selectedZoneId!,
                  onSectionTap: (s) {
                    setState(() => _selectedSectionId = s.id);
                    _showSectionActions(s, project);
                  },
                ),

              // ── Place hint banner ─────────────────────────────────────────
              if (_placingSection)
                Container(
                  color: AppTheme.accent,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 10),
                  child: Row(
                    children: [
                      const Icon(Icons.touch_app,
                          color: Colors.white, size: 18),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          'Tap the floor plan to place this section',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                      TextButton(
                        onPressed: () => setState(() {
                          _placingSection = false;
                          _pendingSection = null;
                        }),
                        child: const Text('Cancel',
                            style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _addSection(project),
            backgroundColor: AppTheme.primary,
            foregroundColor: Colors.white,
            icon: const Icon(Icons.add),
            label: const Text('Add Section'),
          ),
        );
      },
    );
  }
}

// ── Zone strip ────────────────────────────────────────────────────────────────

class _ZoneStrip extends StatelessWidget {
  final SchematicProject project;
  final String? selectedZoneId;
  final VoidCallback onAdd;
  final void Function(StoreZone) onTap;
  final void Function(StoreZone) onEdit;
  final void Function(StoreZone) onDelete;

  const _ZoneStrip({
    required this.project,
    required this.selectedZoneId,
    required this.onAdd,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      color: AppTheme.cardBg,
      child: Row(
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              'ZONES',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: AppTheme.textTertiary,
                letterSpacing: 0.8,
              ),
            ),
          ),
          Expanded(
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                ...project.zones.map((z) {
                  final selected = z.id == selectedZoneId;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () => onTap(z),
                      onLongPress: () => onEdit(z),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: selected
                              ? Color(z.colorValue)
                              : Color(z.colorValue).withAlpha(30),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Color(z.colorValue),
                            width: selected ? 2 : 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: selected
                                    ? Colors.white
                                    : Color(z.colorValue),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              z.name,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: selected
                                    ? Colors.white
                                    : Color(z.colorValue),
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '(${project.sectionsInZone(z.id).length})',
                              style: TextStyle(
                                fontSize: 10,
                                color: selected
                                    ? Colors.white.withAlpha(180)
                                    : Color(z.colorValue).withAlpha(180),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
                // Add zone button
                GestureDetector(
                  onTap: onAdd,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: AppTheme.outline,
                          style: BorderStyle.solid),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.add, size: 14,
                            color: AppTheme.textTertiary),
                        SizedBox(width: 4),
                        Text('Add Zone',
                            style: TextStyle(
                                fontSize: 12,
                                color: AppTheme.textSecondary)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Zone section list ─────────────────────────────────────────────────────────

class _ZoneSectionList extends StatelessWidget {
  final SchematicProject project;
  final String zoneId;
  final void Function(DisplaySection) onSectionTap;

  const _ZoneSectionList({
    required this.project,
    required this.zoneId,
    required this.onSectionTap,
  });

  @override
  Widget build(BuildContext context) {
    final zone = project.getZone(zoneId);
    if (zone == null) return const SizedBox.shrink();
    final sections = project.sectionsInZone(zoneId);

    return Container(
      constraints: const BoxConstraints(maxHeight: 160),
      color: AppTheme.cardBg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
            child: Row(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: Color(zone.colorValue),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  zone.name.toUpperCase(),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Color(zone.colorValue),
                    letterSpacing: 0.7,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${sections.length} section${sections.length == 1 ? '' : 's'}',
                  style: const TextStyle(
                      fontSize: 11, color: AppTheme.textTertiary),
                ),
              ],
            ),
          ),
          if (sections.isEmpty)
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Text(
                'No sections assigned to this zone yet.\nTap a section on the plan and assign it here.',
                style:
                    TextStyle(fontSize: 12, color: AppTheme.textTertiary),
              ),
            )
          else
            SizedBox(
              height: 100,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                itemCount: sections.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (_, i) {
                  final s = sections[i];
                  return GestureDetector(
                    onTap: () => onSectionTap(s),
                    child: Container(
                      width: 120,
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Color(zone.colorValue).withAlpha(20),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                            color: Color(zone.colorValue).withAlpha(80)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(s.type.icon,
                              style: const TextStyle(fontSize: 18)),
                          const SizedBox(height: 4),
                          Text(
                            s.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            '${s.garments.length} products',
                            style: const TextStyle(
                              fontSize: 10,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

// ── Section action sheet ──────────────────────────────────────────────────────

class _SectionActionSheet extends StatelessWidget {
  final DisplaySection section;
  final SchematicProject project;
  final VoidCallback onOpenDesign;
  final VoidCallback onEditSection;
  final void Function(WallSide) onAssignWall;
  final void Function(String?) onAssignZone;
  final VoidCallback onDelete;

  const _SectionActionSheet({
    required this.section,
    required this.project,
    required this.onOpenDesign,
    required this.onEditSection,
    required this.onAssignWall,
    required this.onAssignZone,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: Row(
                children: [
                  Text(section.type.icon,
                      style: const TextStyle(fontSize: 20)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(section.title,
                            style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600)),
                        Text(
                          section.type.displayName +
                              (section.wallSide != WallSide.none
                                  ? ' · ${section.wallSide.displayName}'
                                  : ''),
                          style: const TextStyle(
                              fontSize: 12,
                              color: AppTheme.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),

            // Open design
            ListTile(
              leading: const Icon(Icons.view_quilt_outlined),
              title: const Text('Open Design'),
              subtitle: const Text('View / edit garments & details'),
              onTap: onOpenDesign,
            ),

            // Edit section settings
            ListTile(
              leading: const Icon(Icons.settings_outlined),
              title: const Text('Edit Section Settings'),
              subtitle: const Text('Title, LF, face-out, U-bar…'),
              onTap: onEditSection,
            ),

            // Assign to wall (perimeter only)
            if (section.type == SectionType.perimeter)
              ListTile(
                leading: const Icon(Icons.vertical_align_center_outlined),
                title: const Text('Assign to Wall'),
                subtitle: Text(section.wallSide.displayName),
                trailing: const Icon(Icons.chevron_right, size: 18),
                onTap: () {
                  Navigator.pop(context);
                  showDialog<WallSide>(
                    context: context,
                    builder: (_) => const _WallSideDialog(),
                  ).then((side) {
                    if (side != null) onAssignWall(side);
                  });
                },
              ),

            // Assign to zone
            ListTile(
              leading: const Icon(Icons.label_outline),
              title: const Text('Assign Zone'),
              subtitle: Text(
                section.zoneId != null
                    ? (project.getZone(section.zoneId!)?.name ?? 'Unknown')
                    : 'Unassigned',
              ),
              trailing: const Icon(Icons.chevron_right, size: 18),
              onTap: () {
                Navigator.pop(context);
                _showZonePicker(context);
              },
            ),

            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: Colors.red),
              title: const Text('Delete Section',
                  style: TextStyle(color: Colors.red)),
              onTap: onDelete,
            ),
          ],
        ),
      ),
    );
  }

  void _showZonePicker(BuildContext context) {
    showDialog<String?>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Assign Zone'),
        content: SizedBox(
          width: 280,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.label_off_outlined),
                title: const Text('Unassigned'),
                selected: section.zoneId == null,
                onTap: () => Navigator.pop(context, null),
              ),
              ...project.zones.map((z) => ListTile(
                    leading: Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: Color(z.colorValue),
                        shape: BoxShape.circle,
                      ),
                    ),
                    title: Text(z.name),
                    selected: section.zoneId == z.id,
                    onTap: () => Navigator.pop(context, z.id),
                  )),
            ],
          ),
        ),
      ),
    ).then((zoneId) {
      if (zoneId == null && section.zoneId == null) return;
      onAssignZone(zoneId);
    });
  }
}

// ── Wall side picker ──────────────────────────────────────────────────────────

class _WallSideDialog extends StatelessWidget {
  const _WallSideDialog();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Assign to Wall'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: WallSide.values.map((s) {
          return ListTile(
            title: Text(s.displayName),
            trailing: s == WallSide.none
                ? null
                : Text(s.shortName,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w700)),
            onTap: () => Navigator.pop(context, s),
          );
        }).toList(),
      ),
    );
  }
}

// ── Zone creation/edit dialog ─────────────────────────────────────────────────

class _ZoneDialog extends StatefulWidget {
  final StoreZone? initial;
  final List<StoreZone> existingZones;

  const _ZoneDialog({this.initial, required this.existingZones});

  @override
  State<_ZoneDialog> createState() => _ZoneDialogState();
}

class _ZoneDialogState extends State<_ZoneDialog> {
  final _nameCtrl = TextEditingController();
  late int _colorValue;

  @override
  void initState() {
    super.initState();
    _nameCtrl.text = widget.initial?.name ?? '';
    _colorValue = widget.initial?.colorValue ??
        StoreZone.presetColors[
            widget.existingZones.length % StoreZone.presetColors.length];
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.initial == null ? 'Add Zone' : 'Edit Zone'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _nameCtrl,
            autofocus: true,
            decoration: const InputDecoration(
              labelText: 'Zone Name',
              hintText: "e.g. Women's, Entrance, Back Wall",
            ),
            textCapitalization: TextCapitalization.words,
          ),
          const SizedBox(height: 16),
          const Text(
            'ZONE COLOR',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.7,
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: StoreZone.presetColors.map((c) {
              final selected = c == _colorValue;
              return GestureDetector(
                onTap: () => setState(() => _colorValue = c),
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Color(c),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: selected
                          ? AppTheme.primary
                          : Colors.transparent,
                      width: 3,
                    ),
                    boxShadow: selected
                        ? [
                            const BoxShadow(
                              color: Colors.black26,
                              blurRadius: 4,
                            )
                          ]
                        : [],
                  ),
                  child: selected
                      ? const Icon(Icons.check,
                          color: Colors.white, size: 16)
                      : null,
                ),
              );
            }).toList(),
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
              StoreZone(
                id: widget.initial?.id,
                name: name,
                colorValue: _colorValue,
                sectionIds: widget.initial?.sectionIds ?? [],
              ),
            );
          },
          child: Text(widget.initial == null ? 'Add' : 'Save'),
        ),
      ],
    );
  }
}

// ── Store dimensions dialog ───────────────────────────────────────────────────

class _StoreDimensionsDialog extends StatefulWidget {
  final SchematicProject project;

  const _StoreDimensionsDialog({required this.project});

  @override
  State<_StoreDimensionsDialog> createState() =>
      _StoreDimensionsDialogState();
}

class _StoreDimensionsDialogState extends State<_StoreDimensionsDialog> {
  final _wCtrl = TextEditingController();
  final _dCtrl = TextEditingController();
  String _selectedShape = 'rectangle';

  // Predefined polygon shapes (normalised)
  static const _shapes = <String, List<StorePoint>>{
    'rectangle': [
      StorePoint(0, 0), StorePoint(1, 0),
      StorePoint(1, 1), StorePoint(0, 1),
    ],
    'l_shape': [
      StorePoint(0, 0), StorePoint(1, 0),
      StorePoint(1, 0.5), StorePoint(0.5, 0.5),
      StorePoint(0.5, 1), StorePoint(0, 1),
    ],
    'u_shape': [
      StorePoint(0, 0), StorePoint(0.35, 0),
      StorePoint(0.35, 0.6), StorePoint(0.65, 0.6),
      StorePoint(0.65, 0), StorePoint(1, 0),
      StorePoint(1, 1), StorePoint(0, 1),
    ],
    't_shape': [
      StorePoint(0.25, 0), StorePoint(0.75, 0),
      StorePoint(0.75, 0.4), StorePoint(1, 0.4),
      StorePoint(1, 1), StorePoint(0, 1),
      StorePoint(0, 0.4), StorePoint(0.25, 0.4),
    ],
  };

  static const _shapeLabels = {
    'rectangle': 'Rectangle',
    'l_shape': 'L-Shape',
    'u_shape': 'U-Shape',
    't_shape': 'T-Shape',
  };

  @override
  void initState() {
    super.initState();
    _wCtrl.text = widget.project.storeWidthFt.toStringAsFixed(0);
    _dCtrl.text = widget.project.storeDepthFt.toStringAsFixed(0);
    // Detect current shape from polygon
    final current = widget.project.storePolygon;
    for (final entry in _shapes.entries) {
      if (_polygonMatches(current, entry.value)) {
        _selectedShape = entry.key;
        break;
      }
    }
  }

  bool _polygonMatches(List<StorePoint> a, List<StorePoint> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if ((a[i].x - b[i].x).abs() > 0.01 ||
          (a[i].y - b[i].y).abs() > 0.01) return false;
    }
    return true;
  }

  @override
  void dispose() {
    _wCtrl.dispose();
    _dCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Store Dimensions'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Width / Depth inputs
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _wCtrl,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: const InputDecoration(
                      labelText: 'Width',
                      suffixText: 'ft',
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _dCtrl,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: const InputDecoration(
                      labelText: 'Depth',
                      suffixText: 'ft',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Text(
              'STORE SHAPE',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.7,
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: _shapes.keys.map((key) {
                final isSelected = _selectedShape == key;
                return GestureDetector(
                  onTap: () => setState(() => _selectedShape = key),
                  child: Column(
                    children: [
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppTheme.primary.withAlpha(12)
                              : AppTheme.surface,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: isSelected
                                ? AppTheme.primary
                                : AppTheme.outline,
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        padding: const EdgeInsets.all(8),
                        child: CustomPaint(
                          painter: _ShapePreviewPainter(
                            points: _shapes[key]!,
                            color: isSelected
                                ? AppTheme.primary
                                : AppTheme.textTertiary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _shapeLabels[key]!,
                        style: TextStyle(
                          fontSize: 10,
                          color: isSelected
                              ? AppTheme.primary
                              : AppTheme.textSecondary,
                          fontWeight: isSelected
                              ? FontWeight.w700
                              : FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
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
            final w = double.tryParse(_wCtrl.text) ?? 60;
            final d = double.tryParse(_dCtrl.text) ?? 80;
            Navigator.pop(context, {
              'width': w,
              'depth': d,
              'polygon': _shapes[_selectedShape],
            });
          },
          child: const Text('Apply'),
        ),
      ],
    );
  }
}

class _ShapePreviewPainter extends CustomPainter {
  final List<StorePoint> points;
  final Color color;

  const _ShapePreviewPainter({required this.points, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) return;
    final path = Path();
    path.moveTo(points.first.x * size.width, points.first.y * size.height);
    for (final p in points.skip(1)) {
      path.lineTo(p.x * size.width, p.y * size.height);
    }
    path.close();
    canvas.drawPath(path,
        Paint()..color = color.withAlpha(30)..style = PaintingStyle.fill);
    canvas.drawPath(
        path,
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5);
  }

  @override
  bool shouldRepaint(_ShapePreviewPainter old) =>
      old.color != color || old.points != points;
}

// ── Template picker dialog ────────────────────────────────────────────────────

class _TemplatePickerDialog extends StatelessWidget {
  final List<StoreTemplate> templates;

  const _TemplatePickerDialog({required this.templates});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Load Template'),
      content: SizedBox(
        width: 300,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Applying a template adds its zones and empty sections to the current project.',
              style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 12),
            ...templates.map((t) => ListTile(
                  title: Text(t.name),
                  subtitle: Text(
                    '${t.storeWidthFt.toStringAsFixed(0)}ft × ${t.storeDepthFt.toStringAsFixed(0)}ft · '
                    '${t.zones.length} zones · ${t.sectionStubs.length} sections',
                    style: const TextStyle(fontSize: 11),
                  ),
                  onTap: () => Navigator.pop(context, t),
                )),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}

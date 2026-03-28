import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/projects_provider.dart';
import '../models/schematic_project.dart';
import '../theme/app_theme.dart';
import 'editor_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surface,
      appBar: AppBar(
        title: const Text('MERCH MOBILE'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline, size: 20),
            color: AppTheme.textTertiary,
            onPressed: () => _showAbout(context),
          ),
        ],
      ),
      body: Consumer<ProjectsProvider>(
        builder: (context, provider, _) {
          final projects = provider.projects;
          if (projects.isEmpty) {
            return _EmptyState(onCreate: () => _createProject(context));
          }
          return CustomScrollView(
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 28, 20, 8),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${projects.length} Schematic${projects.length == 1 ? '' : 's'}',
                        style: context.headlineLarge,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Your store display plans',
                        style: context.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
                sliver: SliverList.separated(
                  itemCount: projects.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, i) => _ProjectCard(
                    project: projects[i],
                    onTap: () => _openProject(context, projects[i]),
                    onDelete: () =>
                        _deleteProject(context, provider, projects[i]),
                  ),
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _createProject(context),
        icon: const Icon(Icons.add, size: 18),
        label: const Text('NEW SCHEMATIC'),
      ),
    );
  }

  Future<void> _createProject(BuildContext context) async {
    final result = await showDialog<Map<String, String?>>(
      context: context,
      builder: (_) => const _NewProjectDialog(),
    );
    if (result == null || !context.mounted) return;
    final provider = context.read<ProjectsProvider>();
    final project = await provider.createProject(
      name: result['name']!,
      storeName: result['storeName'],
    );
    if (context.mounted) _openProject(context, project);
  }

  void _openProject(BuildContext context, SchematicProject project) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => EditorScreen(projectId: project.id)),
    );
  }

  Future<void> _deleteProject(
    BuildContext context,
    ProjectsProvider provider,
    SchematicProject project,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('DELETE SCHEMATIC'),
        content: Text('Delete "${project.name}"? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red.shade900),
            child: const Text('DELETE'),
          ),
        ],
      ),
    );
    if (confirmed == true) await provider.deleteProject(project.id);
  }

  void _showAbout(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('MERCH MOBILE'),
        content: const Text(
          'Visual merchandising schematic tool.\n\n'
          'Plan store display layouts — perimeter walls, tables, floor racks, '
          'zones, and color stories. Export to PDF.',
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CLOSE'),
          ),
        ],
      ),
    );
  }
}

// ── Project card ──────────────────────────────────────────────────────────────

class _ProjectCard extends StatelessWidget {
  final SchematicProject project;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _ProjectCard({
    required this.project,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('MMM d, yyyy');
    final sectionCount = project.sections.length;

    return Material(
      color: AppTheme.cardBg,
      borderRadius: BorderRadius.circular(2),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(2),
        child: Container(
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(2)),
            boxShadow: AppTheme.cardShadow,
            color: AppTheme.cardBg,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Accent stripe
              Container(
                width: 3,
                decoration: const BoxDecoration(
                  color: AppTheme.primary,
                  borderRadius:
                      BorderRadius.horizontal(left: Radius.circular(2)),
                ),
              ),

              // Content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 8, 14),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Store name eyebrow
                            if (project.storeName != null) ...[
                              Text(
                                project.storeName!.toUpperCase(),
                                style: context.labelSmall,
                              ),
                              const SizedBox(height: 3),
                            ],
                            // Project name
                            Text(project.name, style: context.titleMedium),
                            const SizedBox(height: 6),
                            // Meta
                            Row(
                              children: [
                                _MetaBadge(
                                  label: '$sectionCount SECTION${sectionCount == 1 ? '' : 'S'}',
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  fmt.format(project.updatedAt),
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: AppTheme.textTertiary,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // Menu
                      PopupMenuButton<String>(
                        icon: const Icon(Icons.more_vert,
                            size: 18, color: AppTheme.textTertiary),
                        onSelected: (v) {
                          if (v == 'delete') onDelete();
                        },
                        itemBuilder: (_) => const [
                          PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(Icons.delete_outline,
                                    size: 16, color: Colors.red),
                                SizedBox(width: 10),
                                Text('Delete',
                                    style: TextStyle(color: Colors.red)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MetaBadge extends StatelessWidget {
  final String label;
  const _MetaBadge({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        border: Border.all(color: AppTheme.outline),
        borderRadius: BorderRadius.circular(2),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.8,
          color: AppTheme.textSecondary,
        ),
      ),
    );
  }
}

// ── Empty state ───────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final VoidCallback onCreate;
  const _EmptyState({required this.onCreate});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 2,
            color: AppTheme.accent,
          ),
          const SizedBox(height: 24),
          Text(
            'No schematics\nyet.',
            style: context.headlineLarge.copyWith(
              fontSize: 32,
              height: 1.05,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Build your first store display plan —\nwalls, tables, floor racks, and zones.',
            style: context.bodyMedium.copyWith(height: 1.6),
          ),
          const SizedBox(height: 36),
          FilledButton.icon(
            onPressed: onCreate,
            icon: const Icon(Icons.add, size: 16),
            label: const Text('NEW SCHEMATIC'),
          ),
        ],
      ),
    );
  }
}

// ── New project dialog ────────────────────────────────────────────────────────

class _NewProjectDialog extends StatefulWidget {
  const _NewProjectDialog();

  @override
  State<_NewProjectDialog> createState() => _NewProjectDialogState();
}

class _NewProjectDialogState extends State<_NewProjectDialog> {
  final _nameCtrl = TextEditingController();
  final _storeCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _nameCtrl.dispose();
    _storeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('NEW SCHEMATIC'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _nameCtrl,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'SCHEMATIC NAME',
                hintText: 'e.g. Fall Collection Floor Set',
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Required' : null,
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _storeCtrl,
              decoration: const InputDecoration(
                labelText: 'STORE / LOCATION',
                hintText: 'e.g. NYC Flagship',
              ),
              textCapitalization: TextCapitalization.words,
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
            if (_formKey.currentState!.validate()) {
              Navigator.pop(context, {
                'name': _nameCtrl.text.trim(),
                'storeName': _storeCtrl.text.trim().isEmpty
                    ? null
                    : _storeCtrl.text.trim(),
              });
            }
          },
          child: const Text('CREATE'),
        ),
      ],
    );
  }
}
